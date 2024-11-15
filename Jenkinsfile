pipeline {
    agent { label 'connect-agent-node' }

    environment {
        ECR_REPO = '866934333672.dkr.ecr.eu-west-2.amazonaws.com/ramshadimgs'  // Replace with actual ECR URL
        IMAGE_NAME = 'app-image'
        TAG = "${env.BRANCH_NAME}-${env.BUILD_ID}"
        AWS_REGION = "eu-west-2"
        SSH_KEY_CRED_ID = '279f3b55-bab9-4f40-be07-05b91e729588'  // Credential ID for SSH key to access EC2
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: "${env.BRANCH_NAME}", url: 'https://github.com/ramshadei/ci-cd-project-jenkin.git', credentialsId: 'github-token'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${env.ECR_REPO}:${env.TAG}")
                }
            }
        }

        stage('Push to ECR') {
            steps {
                withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${env.ECR_REPO}"
                    sh "docker push ${env.ECR_REPO}:${env.TAG}"
                }
            }
            post {
                success {
                    emailext(
                        subject: "Jenkins Job - Docker Image Pushed to ECR Successfully",
                        body: "Hello,\n\nThe Docker image '${env.IMAGE_NAME}:${env.TAG}' has been successfully pushed to ECR.\n\nBest regards,\nJenkins",
                        recipientProviders: [[$class: 'DevelopersRecipientProvider']],
                        to: "m.ehtasham.azhar@gmail.com"
                    )
                }
            }
        }

        stage('Static Code Analysis - SonarQube') {
            steps {
                echo "Success: The operation completed successfully."
                // Uncomment and configure the following lines to use SonarQube
                // script {
                //     withSonarQubeEnv('SonarQubeServer') {
                //         sh 'mvn sonar:sonar'
                //     }
                // }
            }
        }

        stage('Container Security Scan - Trivy') {
            steps {
                script {
                    sh "trivy image ${ECR_REPO}:${TAG}"
                }
            }
        }

        stage('Deploy to Environment') {
            steps {
                script {
                    def targetHost = ''
                    if (env.BRANCH_NAME == 'dev') {
                        targetHost = '13.40.123.29'  // Development EC2 instance IP
                    } else if (env.BRANCH_NAME == 'staging') {
                        targetHost = '18.169.167.222'  // Staging EC2 instance IP
                    } else if (env.BRANCH_NAME == 'main') {
                        targetHost = '18.130.136.114'  // Production EC2 instance IP
                    }

                    // Use withCredentials to inject the SSH key securely
                    withCredentials([usernamePassword(credentialsId: 'aws-ecr', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sshagent(['MY_SSH_KEY']){
                    sh """
                    ssh -tt -o StrictHostKeyChecking=no ubuntu@${targetHost} << EOF
                    aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin ${env.ECR_REPO}
                    docker pull ${ECR_REPO}:${TAG}
                    docker stop ${IMAGE_NAME} || true
                    docker rm ${IMAGE_NAME} || true
                    docker run -d --name ${IMAGE_NAME} -p 80:80 ${ECR_REPO}:${TAG}
                    exit 0
EOF
"""
                    }//with credential
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()  // Clean up workspace after the build
        }
    }
}
