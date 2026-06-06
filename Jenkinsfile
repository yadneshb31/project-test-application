pipeline {
    agent any

    tools {
        maven 'Maven3'
        jdk 'JDK17'
    }

    environment {
        EC2_HOST    = 'ubuntu@98.92.149.96'
        PEM_FILE    = '/var/lib/jenkins/.ssh/Ubuntu.pem'
        REMOTE_DIR  = '/opt/demo'
        JAR_NAME    = 'demo.jar'
        SERVICE_NAME = 'demo'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit allowEmptyResults: true,
                          testResults: 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sh '''
                set -e

                ssh -i $PEM_FILE \
                    -o StrictHostKeyChecking=no \
                    $EC2_HOST \
                    "sudo mkdir -p $REMOTE_DIR && sudo chown ubuntu:ubuntu $REMOTE_DIR"

                scp -i $PEM_FILE \
                    -o StrictHostKeyChecking=no \
                    target/demo.jar \
                    $EC2_HOST:$REMOTE_DIR/$JAR_NAME

                scp -i $PEM_FILE \
                    -o StrictHostKeyChecking=no \
                    demo.service \
                    $EC2_HOST:/tmp/demo.service

                ssh -i $PEM_FILE \
                    -o StrictHostKeyChecking=no \
                    $EC2_HOST "
                        sudo mv /tmp/demo.service /etc/systemd/system/${SERVICE_NAME}.service &&
                        sudo systemctl daemon-reload &&
                        sudo systemctl enable ${SERVICE_NAME} &&
                        sudo systemctl restart ${SERVICE_NAME} &&
                        sleep 5 &&
                        sudo systemctl status ${SERVICE_NAME} --no-pager
                    "
                '''
            }
        }
    }

    post {
        success {
            echo "Deployment successful"
        }

        failure {
            echo "Deployment failed"
        }
    }
}