#!/bin/bash

# Fix Nginx SSL Configuration for zaytoonz.com
# This script configures Nginx to use the Let's Encrypt certificate

set -e

DOMAIN="zaytoonz.com"
WWW_DOMAIN="www.zaytoonz.com"

echo "================================================"
echo "Configuring Nginx for HTTPS"
echo "================================================"
echo ""

# Backup current configuration
echo "💾 Backing up current Nginx configuration..."
sudo cp /etc/nginx/sites-available/zaytoonz /etc/nginx/sites-available/zaytoonz.backup

# Create new Nginx configuration with SSL
echo "⚙️  Creating new Nginx configuration with SSL..."
sudo tee /etc/nginx/sites-available/zaytoonz > /dev/null <<EOF
# HTTP Server - Redirect to HTTPS
server {
    listen 80;
    listen [::]:80;
    
    server_name $DOMAIN $WWW_DOMAIN srv1182909.hstgr.cloud 168.231.87.171;
    
    # Let's Encrypt verification
    location ~ /.well-known/acme-challenge {
        allow all;
        root /var/www/html;
    }
    
    # Redirect all other traffic to HTTPS
    location / {
        return 301 https://\$host\$request_uri;
    }
}

# HTTPS Server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    
    server_name $DOMAIN $WWW_DOMAIN srv1182909.hstgr.cloud 168.231.87.171;
    
    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    
    # SSL Security Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
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
    
    # Disable access to hidden files
    location ~ /\. {
        deny all;
    }
}
EOF

# Test Nginx configuration
echo "🧪 Testing Nginx configuration..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Nginx configuration is valid"
    
    # Reload Nginx
    echo "🔄 Reloading Nginx..."
    sudo systemctl reload nginx
    
    echo ""
    echo "================================================"
    echo "✅ HTTPS Configuration Complete!"
    echo "================================================"
    echo ""
    echo "🌐 Your website is now available at:"
    echo "   🔒 https://$DOMAIN"
    echo "   🔒 https://$WWW_DOMAIN"
    echo ""
    echo "📋 HTTP will automatically redirect to HTTPS"
    echo ""
    echo "🔐 SSL Certificate Details:"
    echo "   Expires: 2026-03-12"
    echo "   Auto-renewal: Enabled"
    echo ""
else
    echo "❌ Nginx configuration test failed!"
    echo "Restoring backup..."
    sudo cp /etc/nginx/sites-available/zaytoonz.backup /etc/nginx/sites-available/zaytoonz
    exit 1
fi


