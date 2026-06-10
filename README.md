Deep Dive into PostgreSQL Crash Course 

# How to build DockerFile and push it to production?

1 Zbuduj obraz z nowym tagiem

```
docker build -t deepdive_course:1.0.0 .
docker run -p 8000:8000 deepdive_course:1.0.0
```

2) Otaguj go jeszcze raz dla awsa

```
docker tag deepdive_course:1.0.0 767398029031.dkr.ecr.eu-central-1.amazonaws.com/solidcourse/deepdive_course:1.0.0
```

3) Zrób pusha

```
docker push 767398029031.dkr.ecr.eu-central-1.amazonaws.com/solidcourse/deepdive_course:1.0.0
```

jeśli access denied

LOGIN

```
aws ecr get-login-password --region eu-central-1 --profile goodbean \
  | docker login --username AWS --password-stdin 767398029031.dkr.ecr.eu-central-1.amazonaws.com
```

Kurs stoi na Amazon Elastic Container Service -> Express service


unset AWS_SECRET_ACCESS_KEY
unset AWS_ACCESS_KEY_ID 

aws configure list-profiles
export AWS_PROFILE=goodbean    

# check if this works:
aws sts get-caller-identity

terraform init       # download AWS provider, run once
terraform plan       # preview what will be created
terraform apply      # create EC2, security group, Elastic IP
