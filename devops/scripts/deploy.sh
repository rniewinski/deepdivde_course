#!/usr/bin/env bash
# Usage: ./devops/scripts/deploy.sh [image-tag]
# Builds the Docker image, pushes it to ECR, and forces an ECS rolling deploy.
# Requires: aws cli, docker, jq, and terraform outputs in devops/terraform/.
set -euo pipefail

IMAGE_TAG="${1:-latest}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$SCRIPT_DIR/../terraform"

echo "==> Reading Terraform outputs..."
ECR_URL=$(terraform -chdir="$TF_DIR" output -raw ecr_repository_url)
CLUSTER=$(terraform -chdir="$TF_DIR" output -raw ecs_cluster_name)
SERVICE=$(terraform -chdir="$TF_DIR" output -raw ecs_service_name)
REGION=$(terraform -chdir="$TF_DIR" output -json | jq -r '.aws_region.value // "us-east-1"')

echo "==> ECR: $ECR_URL"
echo "==> Cluster: $CLUSTER / Service: $SERVICE"

echo "==> Authenticating Docker with ECR..."
aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin "$ECR_URL"

echo "==> Building image $ECR_URL:$IMAGE_TAG ..."
docker build -t "$ECR_URL:$IMAGE_TAG" "$(git rev-parse --show-toplevel)"

echo "==> Pushing image..."
docker push "$ECR_URL:$IMAGE_TAG"

echo "==> Forcing ECS rolling deployment..."
aws ecs update-service \
  --cluster "$CLUSTER" \
  --service "$SERVICE" \
  --force-new-deployment \
  --region "$REGION" \
  --query "service.{status:status,running:runningCount,desired:desiredCount}" \
  --output table

echo "==> Done. Monitor progress:"
echo "    aws ecs describe-services --cluster $CLUSTER --services $SERVICE --region $REGION"
