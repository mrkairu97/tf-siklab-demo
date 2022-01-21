pipeline {
    agent any
    
    parameters {
        string(name: 'varsFile', defaultValue: './dev.tfvars', description: 'tfvars file to use')
        booleanParam(name: 'destroy', defaultValue: false, description: 'Destroy Terraform build?')
    }
    tools {
        terraform 'terraform' 
    }
    stages {
        stage('checkout') {
            steps {
                 script{
                        dir("terraform")
                        {
                            checkout([$class: 'GitSCM', branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[credentialsId: 'GitHub_Jenkins_Token', url: 'https://github.com/kairu97/tf-siklab-demo-private.git']]])
                        }
                    }
                }
            }

        stage('Plan') {
            when {
                not {
                    equals expected: true, actual: params.destroy
                }
            }
            
            steps {
                sh 'terraform init -input=false'
                sh "terraform plan -input=false -out tfplan -var-file=${varsFile}"
                sh 'terraform show -no-color tfplan > tfplan.txt'
            }
        }

        stage('Approval') {
           when {
               not {
                    equals expected: true, actual: params.destroy
                }
           }
           
           steps {
               script {
                    def plan = readFile 'tfplan.txt'
                    input message: "Do you want to apply the plan?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
               }
           }
       }

        stage('Apply') {
            when {
                not {
                    equals expected: true, actual: params.destroy
                }
            }
            
            steps {
                sh "terraform apply -input=false tfplan"
            }
        }
        stage('Destroy') {
            when {
                equals expected: true, actual: params.destroy
            }
        
        steps {
           sh "terraform destroy --auto-approve -var-file=${varsFile}"
            }
        }
    }
}