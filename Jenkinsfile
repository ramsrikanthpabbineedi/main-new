pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-north-1'
    }
    withCredentials([file(credentialsId: 'aws-key', variable: 'AWS_KEY_FILE')]) {
    sh '''
      cp "$AWS_KEY_FILE" ./aws-key.pem
      terraform validate
    '''
}

    

    stages {
        stage('Checkout') {
            steps {
                echo "Checking out Terraform code..."
                git branch: 'main', url: 'https://github.com/ramsrikanthpabbineedi/main-new.git'
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
