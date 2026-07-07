@Library('jenkins-shared-library') _


pipeline {

    agent {
        label 'build-agent-02'
    }


    environment {

        APP_NAME = "sample-app-jenkins-pipeline"

        DOCKER_REPO = "snehaldesai241/sample-app-jenkins-pipeline"

        IMAGE_TAG = "${BUILD_NUMBER}"

        IMAGE_NAME = "${DOCKER_REPO}:${IMAGE_TAG}"

        DEV_NAMESPACE = "dev"

        PROD_NAMESPACE = "prod"

        ENVIRONMENT = "DEV"

    }


    stages {


        stage('Generate Image Tag') {

            steps {

                echo "===================================="
                echo "Application : ${APP_NAME}"
                echo "Image       : ${IMAGE_NAME}"
                echo "Environment : ${ENVIRONMENT}"
                echo "===================================="

            }

        }



        stage('Checkout SCM') {

            steps {

                echo "Checking out source code"

                checkout scm

            }

        }



        stage('Shared Library Test') {

            steps {

                echo "Calling Shared Library"

                helloWorld()

            }

        }



        stage('SonarQube Analysis') {

            steps {

                echo "Starting SonarQube Analysis"


                withSonarQubeEnv('sonarqube') {


                    script {


                        def scannerHome = tool 'sonar-scanner'


                        sh """

                        ${scannerHome}/bin/sonar-scanner

                        """


                    }


                }


            }

        }




        stage('Quality Gate') {

            steps {


                echo "Waiting for SonarQube Quality Gate"


                timeout(time: 5, unit: 'MINUTES') {


                    waitForQualityGate abortPipeline: true


                }


            }


        }





        stage('Docker Build') {

            steps {


                echo "Building Docker Image"


                sh """

                docker build \
                -t ${IMAGE_NAME} .

                """


            }

        }





        stage('Trivy Scan') {

            steps {


                echo "Scanning Docker Image"


                sh """

                trivy image \
                --severity HIGH,CRITICAL \
                --exit-code 0 \
                ${IMAGE_NAME}

                """


            }

        }





        stage('Docker Push') {

            steps {


                echo "Pushing Image to Docker Hub"


                withCredentials([

                    usernamePassword(

                        credentialsId: 'dockerhub-credentials',

                        usernameVariable: 'DOCKER_USER',

                        passwordVariable: 'DOCKER_PASS'

                    )

                ]) {


                    sh '''

                    echo $DOCKER_PASS | docker login \
                    -u $DOCKER_USER \
                    --password-stdin


                    docker push ${IMAGE_NAME}


                    '''


                }


            }

        }





        stage('Deploy DEV') {

            steps {


                echo "Deploying Application to DEV"


                sh """

                kubectl apply -f kubernetes/dev/

                """


            }

        }




        stage('Manual Approval') {

            steps {


                input message: 'Deploy to Production?', 
                ok: 'Approve'


            }

        }




        stage('Deploy PROD') {

            steps {


                echo "Deploying Application to PROD"


                sh """

                kubectl apply -f kubernetes/prod/

                """


            }

        }



    }




    post {


        success {

            echo """

            ====================================
            PIPELINE SUCCESSFUL

            Application:
            ${APP_NAME}

            Image:
            ${IMAGE_NAME}

            ====================================

            """

        }



        failure {

            echo """

            ====================================
            PIPELINE FAILED

            Check Jenkins logs

            ====================================

            """

        }


    }


}