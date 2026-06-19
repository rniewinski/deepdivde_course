# Free SSL Certificate with Let's Encrypt

Let's Encrypt provides free, automated, and open TLS/SSL certificates via the ACME protocol. The recommended client is **Certbot**.

---

## Prerequisites

- A domain name pointing to your server's IP address (A record configured)
- Root or sudo access on the server
- Port 80 open (for HTTP challenge) or port 443 open (for TLS-ALPN challenge)

---

## Installation

### Debian / Ubuntu

```bash
sudo apt update
sudo apt install certbot python3-certbot-nginx   # for Nginx
# or
sudo apt install certbot python3-certbot-apache  # for Apache
```

### RHEL / CentOS / AlmaLinux

```bash
sudo dnf install epel-release
sudo dnf install certbot python3-certbot-nginx
```

### Snap (universal, any Linux)

```bash
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

---

## Obtaining a Certificate

### Nginx (automatic config update)

```bash
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

### Apache (automatic config update)

```bash
sudo certbot --apache -d yourdomain.com -d www.yourdomain.com
```

### Standalone (no web server running)

Certbot spins up its own temporary HTTP server on port 80:

```bash
sudo certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com
```

### Webroot (web server keeps running)

Point Certbot at a directory your web server already serves:

```bash
sudo certbot certonly --webroot -w /var/www/html -d yourdomain.com
```

### Wildcard certificate (DNS challenge)

Wildcard certs (`*.yourdomain.com`) require a DNS TXT record challenge:

```bash
sudo certbot certonly --manual --preferred-challenges dns \
  -d yourdomain.com -d "*.yourdomain.com"
```

Certbot will print a TXT record value — add it to your DNS provider as `_acme-challenge.yourdomain.com`, wait for propagation, then press Enter.

---

## Certificate Files

After a successful run, certificates are stored in `/etc/letsencrypt/live/yourdomain.com/`:

| File | Purpose |
|------|---------|
| `fullchain.pem` | Certificate + intermediate chain (use this in web server config) |
| `privkey.pem` | Private key |
| `cert.pem` | Your certificate only |
| `chain.pem` | Intermediate chain only |

---

## Nginx Configuration Example

```nginx
server {
    listen 443 ssl;
    server_name yourdomain.com www.yourdomain.com;

    ssl_certificate     /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    return 301 https://$host$request_uri;
}
```

---

## Auto-Renewal

Let's Encrypt certificates expire after **90 days**. Certbot installs a systemd timer or cron job automatically.

### Check renewal timer

```bash
sudo systemctl status certbot.timer
```

### Test renewal (dry run)

```bash
sudo certbot renew --dry-run
```

### Manual renewal

```bash
sudo certbot renew
```

After renewal, reload your web server:

```bash
sudo systemctl reload nginx
# or
sudo systemctl reload apache2
```

### Renewal hook (auto-reload on renew)

Create `/etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh`:

```bash
#!/bin/bash
systemctl reload nginx
```

```bash
sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh
```

---

## Revoke a Certificate

```bash
sudo certbot revoke --cert-path /etc/letsencrypt/live/yourdomain.com/cert.pem
```

---

## Useful Commands

```bash
# List all certificates managed by Certbot
sudo certbot certificates

# Delete a certificate
sudo certbot delete --cert-name yourdomain.com

# Check expiry date manually
openssl x509 -noout -dates -in /etc/letsencrypt/live/yourdomain.com/cert.pem
```

---

## Rate Limits

Let's Encrypt enforces rate limits on its production environment:

- **50 certificates per registered domain per week**
- **5 duplicate certificates per week**

Use the **staging environment** while testing to avoid hitting limits:

```bash
sudo certbot --nginx --staging -d yourdomain.com
```

Remove `--staging` once you confirm everything works, then re-run for a real certificate.
