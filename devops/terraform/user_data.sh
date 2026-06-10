#!/bin/bash
set -e

# Install Docker
yum update -y
yum install -y docker
systemctl enable docker
systemctl start docker

# Install Docker Compose plugin
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL "https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-linux-x86_64" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

mkdir -p /app
cd /app

# Write the docker-compose file directly — no need to clone the repository
# since we pull a pre-built image from GHCR
cat > /app/docker-compose.yml << 'EOF'
services:
  web:
    image: ${django_image}
    ports:
      - "80:8000"
    env_file: .env
    restart: unless-stopped
EOF

# Write .env — single-quoted heredoc so bash doesn't re-interpret the values
cat > /app/.env << 'EOF'
DEBUG=False
SECRET_KEY=${django_secret_key}
ALLOWED_HOSTS=${public_ip}
DJANGO_IMAGE=${django_image}
EOF

# Log in to GitHub Container Registry so Docker can pull the private image
echo "${ghcr_token}" | docker login ghcr.io -u "${ghcr_username}" --password-stdin

# Pull the pre-built image and start all services
docker compose pull
docker compose up -d
