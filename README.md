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