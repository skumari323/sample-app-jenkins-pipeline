@Library('jenkins-shared-library') _

pipeline {

    agent {
        label 'build-agent-02'
    }

    options {
        skipDefaultCheckout(true)
        timestamps()
        disableConcurrentBuilds()
    }

    tools {
        sonarQubeScanner 'sonar-scanner'
    }

    environment {

        // ==========================
        // Application
        // ==========================

        APP_NAME = "sample-app-jenkins-pipeline"

        // ==========================
        // Docker
        // ==========================

        DOCKER_REPO = "snehaldesai241/sample-app-jenkins-pipeline"

        IMAGE_TAG = "${BUILD_NUMBER}"

        IMAGE_NAME = "${DOCKER_REPO}:${IMAGE_TAG}"

        // ==========================
        // Kubernetes
        // ==========================

        DEV_NAMESPACE = "dev"

        PROD_NAMESPACE = "prod"

        HELM_RELEASE = "sample-app"

    }

    stages {

        stage('Generate Image Tag') {

            steps {

                echo "========================================="
                echo "Application : ${APP_NAME}"
                echo "Docker Repo : ${DOCKER_REPO}"
                echo "Image Tag   : ${IMAGE_TAG}"
                echo "Image Name  : ${IMAGE_NAME}"
                echo "========================================="

            }

        }

        stage('Checkout SCM') {

            steps {

                echo "Checking out source code..."

                checkout scm

            }

        }

        stage('Shared Library') {

            steps {

                echo "Executing Shared Library..."

                helloWorld()

            }

        }

        stage('SonarQube Analysis') {

            steps {

                withSonarQubeEnv('sonarqube') {

                    sh '''
                        sonar-scanner
                    '''

                }

            }

        }

        stage('Quality Gate') {

            steps {

                timeout(time: 5, unit: 'MINUTES') {

                    waitForQualityGate abortPipeline: true

                }

            }

        }

        stage('Docker Build') {

            steps {

                echo "Building Docker Image..."

                sh """

                docker build \
                -t ${IMAGE_NAME} .

                """

            }

        }

        stage('Trivy Image Scan') {

            steps {

                echo "Scanning Docker Image..."

                sh """

                trivy image \
                    --scanners vuln \
                    --timeout 15m \
                    --severity HIGH,CRITICAL \
                    --exit-code 1 \
                    ${IMAGE_NAME}

                """

            }

        }

        stage('Docker Push') {

            steps {

                echo "Pushing Docker Image..."

                withCredentials([

                    usernamePassword(

                        credentialsId: 'dockerhub-credentials',

                        usernameVariable: 'DOCKER_USER',

                        passwordVariable: 'DOCKER_PASS'

                    )

                ]) {

                    sh '''

                        echo "$DOCKER_PASS" | docker login \
                        -u "$DOCKER_USER" \
                        --password-stdin

                        docker push '"${IMAGE_NAME}"'

                        docker logout

                    '''

                }

            }

        }

        stage('Deploy to DEV') {

            steps {

                echo "Deploying to DEV Namespace..."

                sh """

                kubectl create namespace ${DEV_NAMESPACE} \
                --dry-run=client -o yaml | kubectl apply -f -

                helm upgrade --install ${HELM_RELEASE} ./helm \
                    --namespace ${DEV_NAMESPACE} \
                    --create-namespace \
                    --set image.repository=${DOCKER_REPO} \
                    --set image.tag=${IMAGE_TAG}

                """

            }

        }

        stage('Manual Approval') {

            steps {

                input(

                    message: 'Deploy to Production?',

                    ok: 'Deploy'

                )

            }

        }

        stage('Deploy to PROD') {

            steps {

                echo "Deploying to Production..."

                sh """

                kubectl create namespace ${PROD_NAMESPACE} \
                --dry-run=client -o yaml | kubectl apply -f -

                helm upgrade --install ${HELM_RELEASE} ./helm \
                    --namespace ${PROD_NAMESPACE} \
                    --create-namespace \
                    --set image.repository=${DOCKER_REPO} \
                    --set image.tag=${IMAGE_TAG}

                """

            }

        }

    }

    post {

        always {

            cleanWs()

        }

        success {

            echo """

==================================================

PIPELINE SUCCESSFUL

Application :
${APP_NAME}

Docker Image :
${IMAGE_NAME}

DEV Namespace :
${DEV_NAMESPACE}

PROD Namespace :
${PROD_NAMESPACE}

==================================================

"""

        }

        failure {

            echo """

==================================================

PIPELINE FAILED

Please check Jenkins Console Output.

==================================================

"""

        }

    }

}