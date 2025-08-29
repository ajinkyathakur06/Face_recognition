pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: python
    image: python:3.8-slim-bullseye
    command:
    - cat
    tty: true
  - name: sonar-scanner
    image: sonarsource/sonar-scanner-cli
    command:
    - cat
    tty: true
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - cat
    tty: true
    securityContext:
      runAsUser: 0
      readOnlyRootFilesystem: false
    env:
    - name: KUBECONFIG
      value: /kube/config        
    volumeMounts:
    - name: kubeconfig-secret
      mountPath: /kube/config
      subPath: kubeconfig
  - name: dind
    image: docker:dind
    args: ["--registry-mirror=https://mirror.gcr.io", "--storage-driver=overlay2"]
    securityContext:
      privileged: true  # Needed to run Docker daemon
    env:
    - name: DOCKER_TLS_CERTDIR
      value: ""  # Disable TLS for simplicity
    volumeMounts:
    - name: docker-config
      mountPath: /etc/docker/daemon.json
      subPath: daemon.json  # Mount the file directly here
  volumes:
  - name: docker-config
    configMap:
      name: docker-daemon-config
  - name: kubeconfig-secret
    secret:
      secretName: kubeconfig-secret
'''
        }
    }
    
    
    stages {
        stage('Build Docker Image') {
            steps {
                container('dind') {
                    sh '''
                        docker build -t face-detection:latest .
                        docker image ls
                    '''
                }
            }
        }

        stage('Run Tests in Docker') {
            steps {
                container('dind') {
                    sh '''
                        docker run --rm face-detection:latest sh -c "
                            python -m venv venv && \
                            . venv/bin/activate && \
                            pip install --upgrade pip && \
                            pip install pytest pytest-cov && \
                            pytest --maxfail=1 --disable-warnings --cov=. --cov-report=xml
                        "
                    '''
                }
            }
        }
        stage('SonarQube Analysis') {
            steps {
                container('sonar-scanner') {
                     withCredentials([string(credentialsId: 'sonar-token-2401199', variable: 'SONAR_TOKEN')]) {
                        sh '''
                            sonar-scanner \
                                -Dsonar.projectKey=2401199_attendance-system \
                                -Dsonar.host.url=http://my-sonarqube-sonarqube.sonarqube.svc.cluster.local:9000 \
                                -Dsonar.login=$SONAR_TOKEN \
                                -Dsonar.python.coverage.reportPaths=coverage.xml
                        '''
                    }
                }
            }
        }
        stage('Login to Docker Registry') {
            steps {
                container('dind') {
                    sh 'docker --version'
                    sh 'sleep 10'
                    sh 'docker login nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085 -u admin -p Changeme@2025'
                }
            }
        }
        stage('Build - Tag - Push') {
            steps {
                container('dind') {
                    sh 'docker tag face-detection:latest nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085/ajinkya-project/face-detection:v1'
                    sh 'docker push nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085/ajinkya-project/face-detection:v1'
                    sh 'docker pull nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085/ajinkya-project/face-detection:v1'
                    sh 'docker image ls'
                }
            }
        }
        stage('Deploy AI Application') {
            steps {
                container('kubectl') {
                    script {
                        dir('ai-app-deployment') {
                            sh '''
                                # Apply all resources in deployment YAML
                                kubectl apply -f face-detection-deployment.yaml

                                # Wait for rollout
                                kubectl rollout status deployment/face-detection-deployment -n 2401199
                            '''
                        }
                    }
                }
            }
        }
    }
}
