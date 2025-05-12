pipeline {
    agent any
    environment {
        IMAGE_NAME = 'omerbenda98/ui_topia'
        email = 'omerbenda98@gmail.com'
        SLACK_CHANNEL = '#devops'
        REMOTE_USER = 'ubuntu'
        REMOTE_HOST_STAGE = '172.31.83.109'  // Your staging server IP
        REMOTE_HOST_PRODUCTION = '172.31.86.183'  // Your production server IP
    }
    stages {
        stage('Deploy to staging') {
            when { changeset "stage_version.txt" }
            steps {
                script {
                    env.ENVIRONMENT = 'staging'
                    env.VERSION = readFile('stage_version.txt').trim()
                    echo "📦 Extracted staging version from file: ${env.VERSION}"
                    
                    withCredentials([
                        string(credentialsId: 'mongodb-uri', variable: 'MONGODB_URI'),
                        string(credentialsId: 'nextauth-secret', variable: 'NEXTAUTH_SECRET'),
                        string(credentialsId: 'google-id', variable: 'GOOGLE_ID'),
                        string(credentialsId: 'google-client-secret', variable: 'GOOGLE_CLIENT_SECRET')
                    ]) {
                        sshagent (credentials: ['ssh']) {
                            sh """
                                ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST_STAGE} "\
                                docker system prune -af && \
                                docker pull ${IMAGE_NAME}:${env.VERSION} && \
                                docker rm -f ui_topia || true && \
                                docker run -d --name ui_topia --restart unless-stopped \
                                -e MONGODB_URI='${MONGODB_URI}' \
                                -e NEXTAUTH_URL='http://localhost:3000' \
                                -e NEXTAUTH_URL_INTERNAL='http://localhost:3000' \
                                -e NEXTAUTH_SECRET='${NEXTAUTH_SECRET}' \
                                -e GOOGLE_ID='${GOOGLE_ID}' \
                                -e GOOGLE_CLIENT_SECRET='${GOOGLE_CLIENT_SECRET}' \
                                -p 3000:3000 \
                                ${IMAGE_NAME}:${env.VERSION}"
                            """
                        }
                    }
                }    
            }
        }
        
        stage('Deploy to production') {
            when { changeset "production_version.txt" }
            steps {
                script {
                    env.ENVIRONMENT = 'production'
                    env.VERSION = readFile('production_version.txt').trim()
                    echo "📦 Extracted Production version from file: ${env.VERSION}"
                    
                    withCredentials([
                        string(credentialsId: 'mongodb-uri', variable: 'MONGODB_URI'),
                        string(credentialsId: 'nextauth-secret', variable: 'NEXTAUTH_SECRET'),
                        string(credentialsId: 'google-id', variable: 'GOOGLE_ID'),
                        string(credentialsId: 'google-client-secret', variable: 'GOOGLE_CLIENT_SECRET')
                    ]) {
                        sshagent (credentials: ['ssh']) {
                            sh """
                                ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST_PRODUCTION} "\
                                docker system prune -af && \
                                docker pull ${IMAGE_NAME}:${env.VERSION} && \
                                docker rm -f ui_topia || true && \
                                docker run -d --name ui_topia --restart unless-stopped \
                                -e MONGODB_URI='${MONGODB_URI}' \
                                -e NEXTAUTH_URL='http://localhost:3000' \
                                -e NEXTAUTH_URL_INTERNAL='http://localhost:3000' \
                                -e NEXTAUTH_SECRET='${NEXTAUTH_SECRET}' \
                                -e GOOGLE_ID='${GOOGLE_ID}' \
                                -e GOOGLE_CLIENT_SECRET='${GOOGLE_CLIENT_SECRET}' \
                                -p 3000:3000 \
                                ${IMAGE_NAME}:${env.VERSION}"
                            """
                        }
                    }
                }    
            }
        }
    }
    
    post {
        failure {
            script {
                def msg = ''
                if (env.VERSION && env.ENVIRONMENT) {
                    msg = "❌ FAILED to deploy ${env.ENVIRONMENT} version ${env.VERSION}"
                } else {
                    msg = "❌ FAILED to deploy"
                }
                
                slackSend(
                    channel: "${SLACK_CHANNEL}",
                    color: 'danger',
                    message: msg
                )
                
                emailext(
                    subject: "${JOB_NAME}.${BUILD_NUMBER} FAILED",
                    mimeType: 'text/html',
                    to: "$email",
                    body: msg
                )
            }
        }
        success {
            script {
                def msg = ''
                if (env.VERSION && env.ENVIRONMENT) {
                    def url = env.ENVIRONMENT == 'staging' ? 'http://staging.yourdomain.com' : 'http://yourdomain.com'
                    msg = "✅ Successfully deployed ${env.ENVIRONMENT} version ${env.VERSION} to ${url}"
                } else {
                    msg = "✅ Deployment successful"
                }
                
                slackSend(
                    channel: "${SLACK_CHANNEL}",
                    color: 'good',
                    message: msg
                )
                
                emailext(
                    subject: "${JOB_NAME}.${BUILD_NUMBER} PASSED",
                    mimeType: 'text/html',
                    to: "$email",
                    body: msg
                )
            }
        }
    }
}