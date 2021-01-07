# hello_gcp

if you see below message, you retry command *terraform apply*
```
Error loading zone 'us-central1-a': googleapi: Error 403: Compute Engine API has not been used in project project_id before or it is disabled. Enable it by visiting https://console.developers.google.com/apis/api/compute.googleapis.com/overview?project=project_id then retry. If you enabled this API recently, wait a few minutes for the action to propagate to our systems and retry., accessNotConfigured
```


## terraform




## gcloud

how to use
```shell
# create service account.
gcloud iam service-accounts create *service_account_name*

# 
gcloud auth application-default login

# enable gcp service compute in your project.
gcloud services enable compute.googleapis.com

# enable gcp service cloudbilling in your project.
gcloud services enable cloudbilling.googleapis.com

# show service account scope list
gcloud compute instances create --scope --help

# show services api-keys list. this function is alpha.
gcloud alpha services api-keys list

# shoe your config
gcloud config list

# create gcp project
gcloud projects create *project_name*

# show gcp access token
gcloud auth print-access-token

# shoe your projects in gcp
gcloud projects list

# show billing account list. this function is beta.
gcloud beta billing accounts list

# change gcp project 
gcloud config set project PROJECT_ID

# show your project having networks and vpc list in gcp
gcloud compute networks list

# show your internet-gateway list in aws
aws ec2 describe-internet-gateways

# show route table list in aws
gcloud compute routes list

# show subnets list in aws
gcloud compute networks subnets list

# show your security-group list in aws
gcloud app firewall-rules list
gcloud compute firewall-rules list

# show your external static ip address list in aws
gcloud compute addresses list

# show ec2 assigned nic list in aws
aws ec2 describe-network-interfaces

# aws route53 list-resource-record-sets help
# aws route53 list-health-checks

# list policies
gcloud projects get-iam-policy PROJECT_ID_OR_NUMBER

gcloud iam service-accounts list

gcloud iam service-accounts keys list --iam-account my-iam-account@somedomain.com

gcloud iam roles list

aws iam list-groups

# show droplet image list
gcloud compute images list

aws ec2 describe-images --owners aws-marketplace

# show avairable instance-type
gcloud compute machine-types list

# show region list
## use lightsail command
gcloud app regions list
gcloud compute regions list

# shoe availability zone
## use ec2 command
gcloud compute zones list

# shoe project list

# show exists your ssh-key in digital-ocean
gcloud compute os-login ssh-keys list

# show your project having existing your compute instance.
gcloud compute instances list

# connect
# if you have not yet install EC2 Instance Connect CLI, you execute below command
# pip3 install ec2instanceconnectcli
# instance ID

# oslogin
gcloud compute ssh *VM_NAME*
```