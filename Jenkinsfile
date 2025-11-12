pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials()
        AWS_SECRET_ACCESS_KEY = credentials()
        AWS_DEFAULT_REGION = 'eu-north-1'  // change region if needed
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/ramsrikanthpabbineedi/resource.git'
            }
        }

        stage('Initialize Terraform') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Validate Terraform') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Plan Terraform') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Apply Terraform') {
            steps {
                input message: 'Do you want to apply the Terraform plan?', ok: 'Apply'
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished!'
        }
    }
}
