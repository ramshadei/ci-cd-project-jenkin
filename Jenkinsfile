cat <<EOL > Jenkinsfile
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    echo 'Building the application...'
                    sh 'docker build -t ci-cd-project-jenkin:latest .'
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    echo 'Running tests...'
                    // Add test commands here
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    echo 'Deploying the application...'
                    // Add deployment commands here
                }
            }
        }
    }
}
EOL
