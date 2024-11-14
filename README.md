# ci-cd-project-jenkin
Assignment10
Project Outline
1.	Jenkins Setup: Jenkins master instance in Docker on an EC2 instance; Jenkins agent (slave) on another EC2 instance.
2.	Production , Staging and Development server in Other EC2
3.	Pipeline Structure: Code checkout, Docker image build, security scanning, testing, and multi-environment deployment.
4.	AWS Services Integration: ECR for Docker image storage, IAM roles for secure permissions, and Secrets Manager for secret management.
5.	Notifications: Email notification upon a successful image push to ECR.
6.	SonarQube for Code Quality Analysis
•  Master EC2 Instance:
•	Launch an EC2 instance (preferably Ubuntu or Amazon Linux).
•	Install Docker and Jenkins.
•	Run Jenkins in a Docker container.
•	Expose Jenkins on port 8080 and set up the security group rules to allow traffic on this port.
•  Agent EC2 Instance:
•	Launch a separate EC2 instance and install Java (for Jenkins agent).
•	Install Docker on the agent instance if Docker-based tasks will run here.



Set Up SonarQube for Code Quality Analysis
1. Install and Configure SonarQube
•	SonarQube Server:
o	Set up a SonarQube server. This can be done on a separate EC2 instance or using a Docker container on the Jenkins master.
o	To run SonarQube in Docker, execute:
docker run -d --name sonarqube -p 9000:9000 sonarqube:latest
Access SonarQube at  http://3.10.142.101/9000 and complete the setup process.

Set Up Email Notifications in Jenkins
1. Install and Configure Email Extension Plugin
•	Go to Manage Jenkins > Manage Plugins > Available and install the Email Extension Plugin.
•	In Manage Jenkins > Configure System, scroll to Extended E-mail Notification to set up your SMTP server details (e.g., for Gmail, AWS SES, or another SMTP service).
2. Configure Email Notifications in the Jenkins Pipeline
	Add Email steps in Jenkinsfile
•  Trivy Output Capture:
•	The output of the trivy scan is captured using sh(script: "trivy image ${ECR_REPO}:${TAG}", returnStdout: true).trim(). The result is stored in the trivyOutput variable.
•  Write Trivy Output to File:
•	We write the captured Trivy output to a file (trivy_report.txt) using writeFile(file: 'trivy_report.txt', text: trivyOutput). This ensures that the output can also be sent as an attachment.
•  Send Trivy Output via Email:
•	The emailext step sends the Trivy report as the body of the email, with the contents of trivyOutput included.
•	Additionally, the trivy_report.txt file is attached to the email using the attachmentsPattern parameter.

