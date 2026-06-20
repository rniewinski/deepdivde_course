Deep Dive into PostgreSQL Crash Course 

# How to run application locally 

poetry shell
poetry install
python manage.py migrate
python manage.py runserver

# How to build locally

docker stop $(docker ps -a -q)
docker build -f compose/prod/Dockerfile -t deepdive-course:latest .
docker run -p 8000:8000 deepdive-course:latest
docker ps 
docker stop <container-id>

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

git push origin master   # triggers GitHub Actions to build and push new image

unset AWS_SECRET_ACCESS_KEY
unset AWS_ACCESS_KEY_ID 

aws configure list-profiles
export AWS_PROFILE=goodbean    

cd devops
./redeploy.sh            # reboots EC2; on boot it pulls the latest image automatically

# Register SSL 

sudo certbot --nginx -d pgdeepdive.pl -d www.pgdeepdive.pl

