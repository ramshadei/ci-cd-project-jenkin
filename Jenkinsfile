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
                echo "Starting SonarQube analysis..."
                withSonarQubeEnv('SonarQube') {  // Ensure this name matches your SonarQube configuration in Jenkins
                    sh '''
                    sonar-scanner \
                      -Dsonar.projectKey=ramshadei_ci-cd-project-jenkin_208bbfa5-a864-4ed8-8d43-23d9b95c36a9 \  // Replace with your actual Project Key
                      -Dsonar.sources=./src \
                      -Dsonar.host.url=http://<SonarQube-IP>:9000 \
                      -Dsonar.login=sqp_354adbdc46287c3accb8d91c5b2453bcfd651fb5
                    '''
                }
            }
        }

        stage('Container Security Scan - Trivy') {
            steps {
                script {
                    // Run Trivy scan and capture output
                    def trivyOutput = sh(script: "trivy image ${ECR_REPO}:${TAG}", returnStdout: true).trim()
                    
                    // Store the Trivy output in a file to be sent by email
                    writeFile(file: 'trivy_report.txt', text: trivyOutput)
                    
                    // Send the Trivy output via email
                    emailext(
                        subject: "Jenkins Job - Trivy Security Scan Report",
                        body: """Hello,

The security scan report from Trivy is as follows:

${trivyOutput}

Best regards,
Jenkins""",
                        recipientProviders: [[$class: 'DevelopersRecipientProvider']],
                        to: "m.ehtasham.azhar@gmail.com",
                        attachmentsPattern: 'trivy_report.txt'  // Attach the Trivy output file
                    )
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
                        sshagent([SSH_KEY_CRED_ID]) {  // Ensure that the correct SSH key credentials ID is provided
                            sh """
                            ssh -tt -o StrictHostKeyChecking=no ubuntu@${targetHost} << EOF
                            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${env.ECR_REPO}
                            docker pull ${ECR_REPO}:${TAG}
                            docker stop ${IMAGE_NAME} || true
                            docker rm ${IMAGE_NAME} || true
                            docker run -d --name ${IMAGE_NAME} -p 80:80 ${ECR_REPO}:${TAG}
                            exit 0
                            EOF
                            """
                        }
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
