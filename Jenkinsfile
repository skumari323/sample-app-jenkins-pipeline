@Library('jenkins-shared-library') _


pipeline {


    agent {
        label 'build-agent-02'
    }


    options {

        skipDefaultCheckout(true)

        disableConcurrentBuilds()

    }



    environment {


        // Application

        APP_NAME = "sample-app-jenkins-pipeline"



        // Docker Hub

        DOCKER_REPO = "snehaldesai241/sample-app-jenkins-pipeline"

        IMAGE_TAG = "${BUILD_NUMBER}"

        IMAGE_NAME = "${DOCKER_REPO}:${IMAGE_TAG}"



        // Kubernetes

        DEV_NAMESPACE = "dev"

        PROD_NAMESPACE = "prod"

        HELM_RELEASE = "sample-app"


    }



    stages {



        stage('Generate Image Tag') {


            steps {


                echo """

=========================================

Application : ${APP_NAME}

Docker Repo : ${DOCKER_REPO}

Image Tag   : ${IMAGE_TAG}

Image Name  : ${IMAGE_NAME}

=========================================

"""


            }

        }





        stage('Checkout SCM') {


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





        stage('SonarQube Analysis') {


            steps {


                echo "Running SonarQube Analysis"



                withSonarQubeEnv('sonarqube') {


                    sh '''

                    sonar-scanner

                    '''


                }


            }

        }





        stage('Quality Gate') {


            steps {


                echo "Checking SonarQube Quality Gate"



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





        stage('Trivy Image Scan') {


            steps {


                echo "Running Trivy Security Scan"



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


                echo "Pushing Image To Docker Hub"



                withCredentials([


                    usernamePassword(

                        credentialsId: 'dockerhub-credentials',

                        usernameVariable: 'DOCKER_USER',

                        passwordVariable: 'DOCKER_PASS'


                    )


                ]) {



                    sh """


                    echo \$DOCKER_PASS | docker login \
                    -u \$DOCKER_USER \
                    --password-stdin



                    docker push ${IMAGE_NAME}



                    docker logout


                    """


                }


            }

        }





        stage('Deploy DEV') {


            steps {


                echo "Deploying Application To DEV"



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

                    message: 'Deploy application to PROD?',

                    ok: 'Approve Deployment'


                )


            }

        }





        stage('Deploy PROD') {


            steps {


                echo "Deploying Application To PROD"



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


        success {


            echo """

=========================================

PIPELINE SUCCESSFUL


Application:
${APP_NAME}


Docker Image:
${IMAGE_NAME}


Deployment:
DEV + PROD


=========================================

"""


        }




        failure {


            echo """

=========================================

PIPELINE FAILED

Check Jenkins Console Logs


=========================================

"""


        }



    }



}