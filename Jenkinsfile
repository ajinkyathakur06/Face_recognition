pipeline {
    agent any

    environment {
        IMAGE_NAME = "ajinkya06/face-recognition"
        CONTAINER_NAME = "face-rec-container"
        PORT = "8000"
    }

    stages {
        stage('Checkout') {
            steps {
                // Pull latest code from GitHub
                git branch: 'main', url: 'https://github.com/ajinkyathakur06/Face_recognition.git'
            }
        }

        stage('Pull Docker Image') {
            steps {
                script {
                    sh "docker pull ${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Stop & Remove Existing Container') {
            steps {
                script {
                    sh """
                    if [ \$(docker ps -a -q -f name=${CONTAINER_NAME}) ]; then
                        docker stop ${CONTAINER_NAME} || true
                        docker rm ${CONTAINER_NAME} || true
                    fi
                    """
                }
            }
        }

        stage('Run Container') {
            steps {
                script {
                    sh "docker run -d -p ${PORT}:8000 --name ${CONTAINER_NAME} ${IMAGE_NAME}:latest python manage.py runserver 0.0.0.0:8000"
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished."
        }
    }
}
