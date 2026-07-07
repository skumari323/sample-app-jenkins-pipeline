@Library('jenkins-shared-library') _

pipeline {

    agent {
        label 'build-agent-02'
    }

    stages {

        stage('Shared Library Test') {

            steps {

                helloWorld()

            }
        }
    }
}
