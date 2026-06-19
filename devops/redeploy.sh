#!/bin/bash
set -euo pipefail

PROJECT_NAME="deepdive-course"
AWS_REGION="${AWS_DEFAULT_REGION:-eu-central-1}"

echo "Looking up instance..."
INSTANCE_ID=$(aws ec2 describe-instances \
  --region "$AWS_REGION" \
  --filters \
    "Name=tag:Name,Values=${PROJECT_NAME}" \
    "Name=instance-state-name,Values=running" \
  --query "Reservations[0].Instances[0].InstanceId" \
  --output text)

if [[ "$INSTANCE_ID" == "None" || -z "$INSTANCE_ID" ]]; then
  echo "No running instance found with tag Name=${PROJECT_NAME}"
  exit 1
fi

PUBLIC_IP=$(aws ec2 describe-instances \
  --region "$AWS_REGION" \
  --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

echo "Rebooting ${INSTANCE_ID} (${PUBLIC_IP})..."
aws ec2 reboot-instances --region "$AWS_REGION" --instance-ids "$INSTANCE_ID"

echo "Waiting for application to come back up at http://${PUBLIC_IP} ..."
for i in $(seq 1 30); do
  sleep 10
  if curl -sf --max-time 5 "http://${PUBLIC_IP}" > /dev/null 2>&1; then
    echo "Application is up: http://${PUBLIC_IP}"
    exit 0
  fi
  echo "  attempt ${i}/30..."
done

echo "Application did not respond after 5 minutes"
exit 1
