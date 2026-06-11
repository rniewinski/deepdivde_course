Deep Dive into PostgreSQL Crash Course 

# How to run application locally 

poetry shell
poetry install
python manage.py migrate
python manage.py runserver

# How to deploy application on prod first time

unset AWS_SECRET_ACCESS_KEY
unset AWS_ACCESS_KEY_ID 

aws configure list-profiles
export AWS_PROFILE=goodbean    

### check if this works:
aws sts get-caller-identity

terraform init       # download AWS provider, run once
terraform plan       # preview what will be created
terraform apply      # create EC2, security group, Elastic IP
terraform destroy    # delete all resources

# How to redeploy application