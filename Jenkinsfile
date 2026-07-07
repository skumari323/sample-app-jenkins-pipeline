@Library('jenkins-shared-library') _


pipeline {


    agent {
        label 'build-agent-02'
    }


    environment {


        // Application Name
        APP_NAME = "sample-app-jenkins-pipeline"


        // Docker Hub Repository
        DOCKER_REPO = "snehaldesai241/sample-app-jenkins-pipeline"


        // Jenkins automatically generates this
        IMAGE_TAG = "${BUILD_NUMBER}"


        // Complete Docker Image Name
        IMAGE_NAME = "${DOCKER_REPO}:${IMAGE_TAG}"


        // Kubernetes namespaces (used later)
        DEV_NAMESPACE = "dev"

        PROD_NAMESPACE = "prod"


        // Current environment
        ENVIRONMENT = "DEV"

    }



    stages {



        stage('Generate Image Tag') {


            steps {


                echo "===================================="

                echo "Application Name : ${APP_NAME}"

                echo "Docker Repository: ${DOCKER_REPO}"

                echo "Image Tag        : ${IMAGE_TAG}"

                echo "Docker Image     : ${IMAGE_NAME}"

                echo "Environment      : ${ENVIRONMENT}"

                echo "===================================="


            }

        }





        stage('Checkout Code') {


            steps {


                echo "Checking out source code from GitHub"


                checkout scm


            }


        }






        stage('Shared Library Test') {


            steps {


                echo "Calling Jenkins Shared Library"


                helloWorld()


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







        stage('Docker Push') {


            steps {


                echo "Pushing Docker Image to Docker Hub"



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
