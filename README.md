# AWS Siklab Terraform Demo using Jenkins
## Set-up / Architecture
![AWS-Demo-Skilab-Diagram drawio](https://user-images.githubusercontent.com/63029919/150540755-16f5c10e-bc55-4fcd-ab73-0367ac174dcc.png)

## GitOps Process
![Jenkins AWS CICD Setup drawio](https://user-images.githubusercontent.com/63029919/150540981-c6f529fc-2368-45df-a0e2-cbdabd1509ba.png)

The setup will use Jenkins to build the Terraform code and deploy it to AWS. We are using a Git repository to store the code instead of building it locally from our machine. This is called GitOps. GitOps is a process where our code can be built in an automation tool using a Git repository.

## Plugins needed to install in Jenkins
- AnsiColor
- Terraform
- Dark Theme

## Setting up Jenkins in EC2 Manually
```
#!/bin/bash
sudo apt update
sudo apt install -y default-jre
sudo apt install -y default-jdk
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install -y jenkins
sudo systemctl start jenkins
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install -y terraform
```
The above code can be put in EC2 User-Data when setting up your EC2. Just make sure to open up ports **80, 22, 443, and 8080** in your security group. 

## Running Jenkins for the First Time
1. Get the public IP address of the Jenkins instance appending port 8080 to the link (e.g. **http://<Jenkins_IP_Address>:8080**). 
2. Once able to access, you can see that you are being asked for an intiial administrator password. To get the initial administrator password, open your terminal and sign in into your Jenkins EC2 instance using your key pair (e.g. **ssh -i <Key_Pair>.pem ubuntu@<Jenkins_IP_Address>** ).
3. Once logged in, type: ```sudo cat /var/lib/jenkins/secrets/initialAdminPassword```
4. Get the output of the command and paste it into the password field and click Continue.
5. Then click **Install suggested plugins**.
6. Once plugins have been installed, you will be prompted to create your administrator account.

## Installing the Terraform Plugin
1. In your Jenkins dashboard, click on **Manage Jenkins**
2. Then click on **Manage Plugins**
3. Click on **Available** and search for **Terraform Plugin**
4. Tick the **Terraform Plugin** and click on **Install without restart**.
5. Wait for the plugin to finish installing by making sure that all are ticked or marked as **Success**.
6. Click on **Go back to the top page**
7. Then, go to **Manage Jenkins** > **Global Tool Configuration**
8. Search for **Terraform**, then click on **Terraform installations...**
9. Type terraform in the **Name** field and untick **Install Automatically**. In the **Install directory**, indicate the file location of the Terraform binary. To search for this, open your terminal and sign in to your Jenkins EC2 instance (e.g. **ssh -i <Key_Pair>.pem ubuntu@<Jenkins_IP_Address>** ). Then type ```which terraform```. Get the output of the command and paste it in the **Install directory field**.
10. Then click on **Save**
11. Do the same steps for **AnsiColor** and **Dark Theme** from steps 1 to 6. After installing, go to **Manage Jenkins** > **Configure System**. For AnsiColor, search for **ANSI Color**, then type **xterm** in **Global color map for all builds** field. For **Dark Theme**, search for **Built-in Themes**, then tick **Dark** radio button. Finally, click on **Save**

## Creation of S3 Backend and DynamoDB for Terraform tfstate file
1. Clone **https://github.com/kairu97/tf-s3-backend**
2. In the **backend.tf** file, type a globally unique S3 Bucket Name in bucket under 
```
resource "aws_s3_bucket" "terraform_tfstate" {
  bucket = "<Globally Unique Name of S3 Bucket>"
}
```
3. Also do the same for the DynamoDB. Type a globally unique DynamoDB name under 
```
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "<Globally Unique Name of DynamoDB>"
}
```
4. Then run the following Terraform commands locally
```
terraform init
terraform plan
terraform apply --auto-approve
```
5. Once the backend has been built, go back to your **backend.tf** file in **tf-siklab-demo** repository. Input the name you entered for the S3 Bucket and DynamoDB. 
6. After that, you can push the changes. If you haven't created your repository, please create in GitHub. To push the changes, do the following commands:
```
git add .
git commit -m "Your Message/Changes"
git push
```

## Creating a Job for the First Time
1. Click on **New Item**.
2. Enter your desired name of the job in the field and choose **Pipeline**
3. Click on **Advanced Project Options**, then on definition **Pipeline** section, choose **Pipeline script from SCM**. For SCM, choose **Git**. Then input the URL of the repository (e.g. **https://www.github.com/Username/Repository_Name.git**)
4. If you are using a public repository, you can ignore adding credentials. But it is best practice to always use a private repository. For those using a private repository, click on **Add** beside Credentials, then Jenkins. Since we are going to use a personal access token (PAT) from GitHub, choose **Username with password**. Enter your email address used in GitHub in **Username**. Enter the GitHub Personal Access Token in **Password**. For **ID** and **Description**, you may enter your desired inputs. Finally, click on Add.
5. If you are going to use a different branch aside from main/master, change the branch in the **Branch Specifier**
6. Finally, click on **Save**

## Running a Pipeline Job for the First Time
1. In your job section, click on **Build Now**. After that, go to the first build that comes out in **Build History**. Click on it and go to **Console Output**.
2. Your first build will fail because it is getting the parameters needed from the Jenkinsfile. Exit from the console output and go back to project dashboard.
3. Right now, you can notice that the **Build Now** became **Build with Parameter**. Click on **Build with Parameters**
4. You can notice now that you are being asked for the location of the dev.tfvars file and there is a radio button for destroy. Indicate the location in the field and, if you are building, do not tick **Destroy**. Then click on **Build**
5. Go to the build that will show up in **Build History** and go to **Console Output**. 
6. Click on **Input Requested** when it shows up. Review the Terraform plan by scrolling it down. Then click on **Apply**
7. To determine that your build was successful, it should display the link of the load balancer, instance IDs of the EC2 instances, and the VPC ID. Otherwise, it is failed.

## Destroying your Infrastructure
1. Go to your job dashboard, then click on **Build with Parameter**
2. Enter the file location of the dev.tfvars and tick **Destroy**. After that, click on **Build**
3. To determine that your destroy was successful, there should be an output of a number of resources destroyed. Otherwise, it is a failed destroy.
