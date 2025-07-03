provider aws {
  region = var.aws_region
}

resource "aws_instance" "ec2_instance" {
  count             = var.instances_count
  ami               = var.ami_id
  instance_type    = var.instance_type
  subnet_id        = var.subnets_ids[count.index]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name         = var.key_name1
  associate_public_ip_address = var.assign_public_ip  
  
  tags =   merge(
    {
      Name = "${var.ec2_name}-${count.index + 1}"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = var.sg_name
  description = "Security group for ${var.ec2_name} instances"
  vpc_id      = var.vpc_id

  # Basic SSH rule for all types
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.adress_to_open]
  }

  # Basic egress for all types
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Conditional rules based on sg_type
  dynamic "ingress" {
    for_each = var.sg_type == "basic" ? [1] : []
    content {
      from_port   = var.port_to_open
      to_port     = var.port_to_open
      protocol    = "tcp"
      cidr_blocks = [var.adress_to_open]
    }
  }

  # K8s Master specific rules
  dynamic "ingress" {
    for_each = var.sg_type == "k8s-master" ? [
      { port = 6443, desc = "API Server" },
      { port = 2379, desc = "etcd" },
      { port = 2380, desc = "etcd" },
      { port = 10250, desc = "kubelet" },
      { port = 10251, desc = "kube-scheduler" },
      { port = 10252, desc = "kube-controller" }
    ] : []

    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = [var.adress_to_open]
    }
  }

  # K8s Worker specific rules
  dynamic "ingress" {
    for_each = var.sg_type == "k8s-worker" ? [
      { from_port = 10250, to_port = 10250, desc = "kubelet" },
      { from_port = 30000, to_port = 32767, desc = "NodePort" }
    ] : []

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = "tcp"
      cidr_blocks = [var.adress_to_open]
    }
  }

  # ICMP for all K8s nodes
  dynamic "ingress" {
    for_each = contains(["k8s-master", "k8s-worker"], var.sg_type) ? [1] : []
    content {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = [var.adress_to_open]
    }
  }
}