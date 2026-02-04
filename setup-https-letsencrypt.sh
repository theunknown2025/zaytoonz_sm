#!/bin/bash

# Let's Encrypt SSL Certificate Setup (PRODUCTION)
# This requires a domain name pointing to your VPS

set -e

echo "================================================"
echo "Let's Encrypt SSL Certificate Setup"
echo "================================================"
echo ""
echo "⚠️  REQUIREMENTS:"
echo "   1. A domain name (e.g., zaytoonz.com)"
echo "   2. DNS A record pointing to: 168.231.87.171"
echo "   3. Port 80 and 443 open in firewall"
echo ""

# Check if domain is provided
if [ -z "$1" ]; then
    echo "❌ Error: Domain name required!"
    echo ""
    echo "Usage: bash $0 yourdomain.com"
    echo "Example: bash $0 zaytoonz.com"
    echo ""
    exit 1
fi

DOMAIN=$1
WWW_DOMAIN="www.$DOMAIN"

echo "📋 Domain: $DOMAIN"
echo "📋 WWW Domain: $WWW_DOMAIN"
echo ""

# Update system
echo "📦 Updating system packages..."
sudo apt update

# Install Certbot
echo "📥 Installing Certbot..."
sudo apt install -y certbot python3-certbot-nginx

# Update Nginx config with domain name
echo "⚙️  Updating Nginx configuration..."
sudo tee /etc/nginx/sites-available/zaytoonz > /dev/null <<EOF
server {
    listen 80;
    listen [::]:80;
    
    server_name $DOMAIN $WWW_DOMAIN srv1182909.hstgr.cloud 168.231.87.171;
    
    root /var/www/zaytoonz;
    index index.html;
    
    # Enable gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/javascript application/json image/svg+xml;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
    
    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|webp)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Security headers
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Disable access to hidden files
    location ~ /\. {
        deny all;
    }
    
    # Let's Encrypt verification
    location ~ /.well-known/acme-challenge {
        allow all;
    }
}
EOF

# Test Nginx configuration
echo "🧪 Testing Nginx configuration..."
sudo nginx -t

# Reload Nginx
echo "🔄 Reloading Nginx..."
sudo systemctl reload nginx

# Configure firewall
if command -v ufw &> /dev/null; then
    echo "🔥 Configuring firewall..."
    sudo ufw allow 'Nginx Full'
    sudo ufw --force enable
fi

# Get SSL certificate
echo ""
echo "🔐 Obtaining SSL certificate from Let's Encrypt..."
echo "   This will ask for your email address"
echo ""

sudo certbot --nginx -d $DOMAIN -d $WWW_DOMAIN \
    --non-interactive \
    --agree-tos \
    --email admin@$DOMAIN \
    --redirect

# Test certificate renewal
echo ""
echo "🧪 Testing certificate auto-renewal..."
sudo certbot renew --dry-run

echo ""
echo "================================================"
echo "✅ HTTPS Setup Complete!"
echo "================================================"
echo ""
echo "🌐 Your website is now available at:"
echo "   https://$DOMAIN"
echo "   https://$WWW_DOMAIN"
echo ""
echo "🔒 SSL certificate will auto-renew every 90 days"
echo ""
echo "📋 Certificate location:"
echo "   /etc/letsencrypt/live/$DOMAIN/"
echo ""


