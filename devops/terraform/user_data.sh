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

# Install Nginx and Certbot
yum install -y nginx
yum install -y python3-certbot-nginx || pip3 install certbot certbot-nginx --break-system-packages

# Static files directory — bind-mounted into the container, served directly by Nginx
mkdir -p /srv/deepdive/static

mkdir -p /app

# Write docker-compose — web binds only to 127.0.0.1; Nginx is the public entry point
cat > /app/docker-compose.yml << 'EOF'
services:
  web:
    image: ${django_image}
    ports:
      - "127.0.0.1:8000:8000"
    env_file: .env
    restart: unless-stopped
    volumes:
      - /srv/deepdive/static:/app/static
EOF

cat > /app/docker-entrypoint.sh << 'EOF'
#!/bin/sh
set -e
python manage.py migrate --noinput
python manage.py collectstatic --noinput
exec uwsgi --ini uwsgi.ini
EOF
chmod +x /app/docker-entrypoint.sh

# Write .env — single-quoted heredoc so bash doesn't re-interpret the values
cat > /app/.env << 'EOF'
DEBUG=False
SECRET_KEY=${django_secret_key}
ALLOWED_HOSTS=${public_ip},${join(",", allowed_hosts)}
DJANGO_IMAGE=${django_image}
EOF

# Write Nginx config — HTTP only for now
# Run /app/setup-ssl.sh after DNS is pointed at this server to enable HTTPS
rm -f /etc/nginx/conf.d/default.conf
cat > /etc/nginx/conf.d/deepdive.conf << 'EOF'
server {
    listen 80;
    server_name ${join(" ", allowed_hosts)};

    location /static/ {
        alias /srv/deepdive/static/;
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }

    location / {
        include uwsgi_params;
        uwsgi_pass 127.0.0.1:8000;
    }
}
EOF

systemctl enable nginx
nginx -t
systemctl start nginx

# Helper script to obtain the SSL cert once DNS resolves to this server.
# Usage: sudo /app/setup-ssl.sh
#cat > /app/setup-ssl.sh << 'EOF'
##!/bin/bash
#set -e
#certbot --nginx \
#  -d ${join(" -d ", allowed_hosts)} \
#  --non-interactive --agree-tos \
#  -m admin@${allowed_hosts[0]}
#systemctl reload nginx
#EOF
#chmod +x /app/setup-ssl.sh

# Log in to GHCR and start the app
echo "${ghcr_token}" | docker login ghcr.io -u "${ghcr_username}" --password-stdin
docker compose -f /app/docker-compose.yml pull
docker compose -f /app/docker-compose.yml up -d
