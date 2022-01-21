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
                            checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/kairu97/tf-siklab-demo.git']]])
                            // Use Pipeline Syntax in Jenkins to create command above. To do this, go to your created job/pipeline, then click Pipeline Syntax. In sample step, choose checkout: Check out from version control, then choose Git, then copy the link of the repository. If you are using a private repository, you must provide your personal access token from your GitHub account  
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