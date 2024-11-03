pipeline {
    agent any
    environment {
        DOCKER_REGISTRY = "localhost:5000/repository/docker-local"
        KUBECONFIG = "/etc/rancher/k3s/k3s.yaml"
        SONARQUBE_SERVER = 'SonarQube'
        SONARQUBE_TOKEN = credentials('sonarqube-token')
        NEXUS_CREDENTIALS = credentials('nexus-credentials')
    }
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/wolfofbabylon/springboot_app.git', branch: 'main'
            }
        }
        stage('Unit Tests') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv(SONARQUBE_SERVER) {
                    sh 'mvn sonar:sonar -Dsonar.projectKey=myapp -Dsonar.login=$SONARQUBE_TOKEN'
                }
            }
        }
        stage('Build JAR and Push to Nexus') {
            steps {
                sh 'mvn clean package -DskipTests'
                nexusArtifactUploader artifacts: [
                    [artifactId: 'myapp', classifier: '', file: 'target/myapp-0.0.1.jar', type: 'jar'] // Ensure the version is correct here
                ],
                credentialsId: 'nexus-credentials', 
                groupId: 'com.example', 
                nexusUrl: 'localhost:8081', 
                nexusVersion: 'nexus3', 
                protocol: 'http', 
                repository: 'maven-releases', 
                version: '0.0.1' // Changed to fixed release version
            }
        }
        stage('Docker Build & Push') {
            steps {
                sh """
                docker build -t ${DOCKER_REGISTRY}/myapp:latest .
                docker push ${DOCKER_REGISTRY}/myapp:latest
                """
            }
        }
        stage('Helm Deploy') {
            steps {
                sh "helm upgrade --install myapp ./charts/myapp-chart --set image.repository=${DOCKER_REGISTRY}/myapp --kubeconfig ${KUBECONFIG}"
            }
        }
    }
    post {
        always {
            mail to: 'tanaythulkar3@example.com', subject: "Jenkins Pipeline", body: "Pipeline completed."
        }
    }
}
