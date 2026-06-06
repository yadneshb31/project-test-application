pipeline {
    agent {
        label 'app-server'
    }

    tools {
        maven 'Maven3'   // Configure in Jenkins: Manage Jenkins > Tools
        jdk   'JDK17'
    }

    environment {
        EC2_HOST     = 'ubuntu@98.92.149.96'  // e.g. ec2-user@ec2-1-2-3-4.compute-1.amazonaws.com
        SSH_CRED_ID  = 'ec2-ssh-key'                   // Jenkins SSH Username+Private Key credential ID
        REMOTE_DIR   = '/opt/demo'
        JAR_NAME     = 'demo.jar'
        SERVICE_NAME = 'demo'
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Build') {
            steps {
                sh 'mvn -B clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn -B test'
            }
            post {
                always { junit allowEmptyResults: true, testResults: 'target/surefire-reports/*.xml' }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(credentials: [env.SSH_CRED_ID]) {
                    sh '''
                        set -e
                        ssh -o StrictHostKeyChecking=no $EC2_HOST "sudo mkdir -p $REMOTE_DIR && sudo chown ubuntu:ubuntu $REMOTE_DIR"
                        scp -o StrictHostKeyChecking=no target/demo.jar $EC2_HOST:$REMOTE_DIR/$JAR_NAME
                        scp -o StrictHostKeyChecking=no demo.service     $EC2_HOST:/tmp/demo.service
                        ssh -o StrictHostKeyChecking=no $EC2_HOST "
                            sudo mv /tmp/demo.service /etc/systemd/system/${SERVICE_NAME}.service &&
                            sudo systemctl daemon-reload &&
                            sudo systemctl enable ${SERVICE_NAME} &&
                            sudo systemctl restart ${SERVICE_NAME} &&
                            sleep 3 &&
                            sudo systemctl status ${SERVICE_NAME} --no-pager
                        "
                    '''
                }
            }
        }
    }

    post {
        success { echo "Deployed successfully to ${env.EC2_HOST}" }
        failure { echo "Deployment failed" }
    }
}
