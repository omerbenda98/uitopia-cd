#!/bin/bash
# deploy.sh

# Choose environment to deploy
SSH_USER="ubuntu"
SSH_KEY_PATH="~/mykey.pem"
read -p "Which environment do you want to deploy to? (prod/dev): " ENV
# Validate environment
if [[ "$ENV" != "dev" && "$ENV" != "prod" ]]; then
  echo "Error: Environment must be either 'dev' or 'prod'"
  echo "Usage: ./deploy.sh [environment]"
  exit 1
fi

echo "Deploying to $ENV environment..."

# Run Terraform
cd terraform/environments/$ENV
terraform apply -auto-approve

# Get the IP address
IP=$(terraform output -raw instance_public_ip)

echo "Deployed $ENV instance at IP: $IP"
# Create a temporary inventory file
cd ../../../ansible
echo "[$ENV]" > terraform_inventory.ini
echo "$ENV-server ansible_host=$IP ansible_user=$SSH_USER ansible_python_interpreter=/usr/bin/python3 ansible_ssh_private_key_file=$SSH_KEY_PATH" >> terraform_inventory.ini

# Copy SSH key to home directory with proper permissions
if [[ ! -f ~/mykey.pem ]]; then
  cp /mnt/c/Users/omerb/projects/uitopia-cd/mykey.pem ~/mykey.pem
  chmod 600 ~/mykey.pem
fi

# Wait for SSH to be available
echo "Waiting for SSH to become available..."
until ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -i "$SSH_KEY_PATH" $SSH_USER@$IP 'exit' 2>/dev/null
do
  echo "Retrying SSH connection..."
  sleep 10
done

# Fetch parameters from AWS SSM Parameter Store
echo "Retrieving parameters from AWS SSM Parameter Store..."
MONGODB_URI=$(aws ssm get-parameter --name "MONGODB_URI" --with-decryption --query "Parameter.Value" --output text)
NEXTAUTH_SECRET=$(aws ssm get-parameter --name "NEXTAUTH_SECRET" --with-decryption --query "Parameter.Value" --output text)
GOOGLE_ID=$(aws ssm get-parameter --name "GOOGLE_ID" --with-decryption --query "Parameter.Value" --output text)
GOOGLE_CLIENT_SECRET=$(aws ssm get-parameter --name "GOOGLE_CLIENT_SECRET" --with-decryption --query "Parameter.Value" --output text)

# Check if parameters were successfully retrieved
if [[ -z "$MONGODB_URI" || -z "$NEXTAUTH_SECRET" || -z "$GOOGLE_ID" || -z "$GOOGLE_CLIENT_SECRET" ]]; then
  echo "Error: Failed to retrieve all required parameters from AWS SSM Parameter Store"
  echo "Please check your AWS credentials and parameter names"
  exit 1
fi

# Export parameters as environment variables for Ansible to use
export MONGODB_URI
export NEXTAUTH_SECRET
export GOOGLE_ID
export GOOGLE_CLIENT_SECRET


# Run the appropriate Ansible playbook
if [[ "$ENV" == "dev" ]]; then
  echo "Running development playbook..."
  ansible-playbook -i terraform_inventory.ini playbooks/staging.yml
else
  echo "Running production playbook..."
  ansible-playbook -i terraform_inventory.ini playbooks/production.yml
fi

echo "Deployment to $ENV environment completed successfully!"
echo "Application is available at: ? http://$IP:3000"