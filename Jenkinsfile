pipeline {
    agent any

    tools {
        jdk 'java-21'
    }

    stages {
        stage('Detect Changed Services') {
            steps {
                script {
                    def changedFiles = sh(
                        script: "git diff --name-only HEAD~1 HEAD || true",
                        returnStdout: true
                    ).trim()

                    echo "Changed files:"
                    echo changedFiles

                    env.BUILD_CUSTOMERS = changedFiles.contains("spring-petclinic-customers-service") ? "true" : "false"
                    env.BUILD_VETS = changedFiles.contains("spring-petclinic-vets-service") ? "true" : "false"
                    env.BUILD_VISITS = changedFiles.contains("spring-petclinic-visits-service") ? "true" : "false"
                    env.BUILD_API_GATEWAY = changedFiles.contains("spring-petclinic-api-gateway") ? "true" : "false"
                    env.BUILD_DISCOVERY = changedFiles.contains("spring-petclinic-discovery-server") ? "true" : "false"
                    env.BUILD_ADMIN = changedFiles.contains("spring-petclinic-admin-server") ? "true" : "false"
                }
            }
        }

        stage('Test Customers Service') {
            when {
                expression { env.BUILD_CUSTOMERS == "true" }
            }
            steps {
                dir('spring-petclinic-customers-service') {
                    sh './mvnw test'
                }
            }
            post {
                always {
                    junit 'spring-petclinic-customers-service/target/surefire-reports/*.xml'
                    jacoco execPattern: 'spring-petclinic-customers-service/target/jacoco.exec'
                }
            }
        }

        stage('Build Customers Service') {
            when {
                expression { env.BUILD_CUSTOMERS == "true" }
            }
            steps {
                dir('spring-petclinic-customers-service') {
                    sh './mvnw clean package -DskipTests'
                }
            }
        }

        stage('Test Vets Service') {
            when {
                expression { env.BUILD_VETS == "true" }
            }
            steps {
                dir('spring-petclinic-vets-service') {
                    sh './mvnw test'
                }
            }
            post {
                always {
                    junit 'spring-petclinic-vets-service/target/surefire-reports/*.xml'
                    jacoco execPattern: 'spring-petclinic-vets-service/target/jacoco.exec'
                }
            }
        }

        stage('Build Vets Service') {
            when {
                expression { env.BUILD_VETS == "true" }
            }
            steps {
                dir('spring-petclinic-vets-service') {
                    sh './mvnw clean package -DskipTests'
                }
            }
        }

        stage('Test Visits Service') {
            when {
                expression { env.BUILD_VISITS == "true" }
            }
            steps {
                dir('spring-petclinic-visits-service') {
                    sh './mvnw test'
                }
            }
            post {
                always {
                    junit 'spring-petclinic-visits-service/target/surefire-reports/*.xml'
                    jacoco execPattern: 'spring-petclinic-visits-service/target/jacoco.exec'
                }
            }
        }

        stage('Build Visits Service') {
            when {
                expression { env.BUILD_VISITS == "true" }
            }
            steps {
                dir('spring-petclinic-visits-service') {
                    sh './mvnw clean package -DskipTests'
                }
            }
        }
    }
}