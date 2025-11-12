pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-north-1'
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Checking out Terraform code..."
                git branch: 'main', url: 'https://github.com/your-username/your-terraform-repo.git'
            }
        }

        stage('Terraform Format Check') {
            steps {
                echo "Checking Terraform formatting..."
                sh 'terraform fmt -check -recursive'
            }
        }

        stage('Terraform Init') {
            steps {
                withAWS(credentials: 'aws-credentials-id', region: "${AWS_REGION}") {
                    sh 'terraform init -input=false'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                withAWS(credentials: 'aws-credentials-id', region: "${AWS_REGION}") {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withAWS(credentials: 'aws-credentials-id', region: "${AWS_REGION}") {
                    sh 'terraform plan -out=tfplan -input=false'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    def userInput = input message: 'Do you want to apply the Terraform plan?', ok: 'Apply'
                    if (userInput) {
                        withAWS(credentials: 'aws-credentials-id', region: "${AWS_REGION}") {
                            sh 'terraform apply -input=false tfplan'
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Terraform resources deployed successfully!"
        }
        failure {
            echo "❌ Terraform pipeline failed!"
        }
        always {
            cleanWs()
        }
    }
}
