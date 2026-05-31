pipeline {

    agent any

    environment {
        git_credentials = credentials('github-cred')
    }

    stages {
        stage('checkout') {
            steps {
                git branch: 'main', credentialsId: 'github-cred', url: 'https://github.com/mangeshchauhan/Test-application.git'
            }
        }
        stage('build') {
            steps {
                echo 'Building the application...'
            }
        }
        stage('deploy') {
            steps {
                sh 'sudo chmod +x hello.sh'
                sh 'sudo ./hello.sh'
            }
        }
    }
}