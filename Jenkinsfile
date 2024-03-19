pipeline {
    agent any
    stages {
        stage('clone tf files') {
            steps {
                deleteDir()
                sh 'echo cloning project...'
                sh 'git clone https://github.com/chaimco579/terrex.git'
            }
        }

        stage('terraform init') {
            steps {
                dir('terrex') {
                        sh 'terraform init'
                }
            }
        }
       stage('terraform plan and apply') {
            steps {
                dir('terrex') {
                        sh 'terraform plan'
                        sh 'terraform apply -auto-approve'
                }
            }
        }

    }
}
