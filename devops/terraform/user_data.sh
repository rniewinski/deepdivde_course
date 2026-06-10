#!/bin/bash
set -e

# Install Docker and git
yum update -y
yum install -y docker git
systemctl enable docker
systemctl start docker

# Install Docker Compose plugin
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL "https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-linux-x86_64" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Clone the private repository
git clone "${clone_url}" /app
cd /app

# Write .env — single-quoted heredoc so bash doesn't re-interpret the values
cat > /app/.env << 'EOF'
DEBUG=False
SECRET_KEY=${django_secret_key}
ALLOWED_HOSTS=${public_ip}
DB_ENGINE=django.db.backends.postgresql
DB_NAME=deepdive
DB_USER=deepdive_user
DB_PASSWORD=${db_password}
DB_HOST=db
DB_PORT=5432
EOF

# Build images and start all services in the background
docker compose up -d --build
