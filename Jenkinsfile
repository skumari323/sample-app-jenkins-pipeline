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


        // Dynamic image tag from Jenkins build number
        IMAGE_TAG = "${BUILD_NUMBER}"


        // Complete Docker image name
        IMAGE_NAME = "${DOCKER_REPO}:${IMAGE_TAG}"


        // Kubernetes namespaces
        DEV_NAMESPACE = "dev"

        PROD_NAMESPACE = "prod"


        // Environment name
        ENVIRONMENT = "DEV"

    }


    stages {


        stage('Generate Image Tag') {

            steps {

                echo "================================="
                echo "Application Name : ${APP_NAME}"
                echo "Docker Repository: ${DOCKER_REPO}"
                echo "Image Tag        : ${IMAGE_TAG}"
                echo "Full Image Name  : ${IMAGE_NAME}"
                echo "Environment      : ${ENVIRONMENT}"
                echo "================================="

            }

        }


        stage('Checkout Code') {

            steps {

                echo "Checking out source code..."

                checkout scm

            }

        }


        stage('Shared Library Test') {

            steps {

                echo "Calling Shared Library Function..."

                helloWorld()

            }

        }


    }


    post {


        success {

            echo "================================="
            echo "Pipeline completed successfully"
            echo "================================="

        }


        failure {

            echo "================================="
            echo "Pipeline failed"
            echo "================================="

        }


    }


}
