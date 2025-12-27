pipeline {
     agent any
    
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION = 'eu-north-1'
    }
    
    stages {
        stage('Git Checkout'){
            steps {
                git branch: 'main', url:'https://github.com/E335-comma/aws-jenkins-pipeline'
            }
        }

        stage ('Create S3 Bucket') {
            environment {
                AWS_DEFAULT_REGION = 'eu-north-1'
                BUCKET_NAME = "adeife-terraform-state-bucket"
            }
                
             steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-creds'
                ]]) {
        
                    sh '''
                        aws s3api create-bucket --bucket "$BUCKET_NAME" --region eu-north-1 --create-bucket-configuration LocationConstraint=eu-north-1
                    '''
                }
            }
        }

        stage('Terraform Init'){
            steps {
                dir('terraform-config') {
                     sh 'terraform init -input=false'
                }
            }
        }
        
        stage('Terraform Plan'){
            steps {
                dir('terraform-config') {
                    sh 'terraform plan -out=tfplan -input=false'
                }
            }
        }
    
        stage('Terraform Apply') {
            steps {
                dir('terraform-config') {
                    sh 'terraform apply -input=false -auto-approve tfplan'
                }       
            }
        }

        stage('Output EC2 IP and Key') {
            steps {
                script {
                    env.EC2_PUBLIC_IP = sh(
                        script: "cd terraform-config && terraform output -raw ec2_public_ip",
                        returnStdout: true
                    ).trim()
        
                    sh '''
                    KEY_FILE=$(mktemp)
                    echo "Using key file $KEY_FILE"

                    cd terraform-config
                    terraform output -raw private_key > "$KEY_FILE"
                    chmod 400 "$KEY_FILE"

                    echo "Using EC2 IP: $EC2_PUBLIC_IP"
<<<<<<< HEAD
                    scp -o StrictHostKeyChecking=no -i "$KEY_FILE" docker.sh ec2-user@$EC2_PUBLIC_IP:~/
=======
                    scp -o StrictHostKeyChecking=no -i "$KEY_FILE" ../docker.sh ec2-user@$EC2_PUBLIC_IP:~/
>>>>>>> 6554ff0 (fix)

                    ssh -o StrictHostKeyChecking=no -i "$KEY_FILE" ec2-user@$EC2_PUBLIC_IP \
                      'chmod +x docker.sh && ./docker.sh'

                    rm -f "$KEY_FILE"
                   '''

                }
            }
        }
    }
}