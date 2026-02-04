#!/bin/bash

# Self-Signed SSL Certificate Setup (FOR TESTING ONLY)
# This will show browser warnings but enables HTTPS

echo "================================================"
echo "Setting up Self-Signed SSL Certificate"
echo "================================================"
echo ""
echo "⚠️  WARNING: This creates a self-signed certificate"
echo "   Browsers will show security warnings!"
echo "   Use only for testing!"
echo ""

# Create SSL directory
sudo mkdir -p /etc/nginx/ssl

# Generate self-signed certificate
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/zaytoonz.key \
    -out /etc/nginx/ssl/zaytoonz.crt \
    -subj "/C=US/ST=State/L=City/O=Zaytoonz/CN=168.231.87.171"

# Set permissions
sudo chmod 600 /etc/nginx/ssl/zaytoonz.key
sudo chmod 644 /etc/nginx/ssl/zaytoonz.crt

echo "✅ Self-signed certificate created"
echo ""

# Update Nginx configuration
sudo tee -a /etc/nginx/sites-available/zaytoonz > /dev/null <<'EOF'

# HTTPS Server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    
    server_name srv1182909.hstgr.cloud 168.231.87.171;
    
    ssl_certificate /etc/nginx/ssl/zaytoonz.crt;
    ssl_certificate_key /etc/nginx/ssl/zaytoonz.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    root /var/www/zaytoonz;
    index index.html;
    
    # Enable gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/javascript application/json image/svg+xml;
    
    location / {
        try_files $uri $uri/ =404;
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
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name srv1182909.hstgr.cloud 168.231.87.171;
    return 301 https://$host$request_uri;
}
EOF

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

echo ""
echo "================================================"
echo "✅ Self-Signed SSL Configured"
echo "================================================"
echo ""
echo "⚠️  Your website is now available at:"
echo "   https://168.231.87.171"
echo ""
echo "⚠️  Browsers will show a security warning!"
echo "   Click 'Advanced' → 'Proceed to site'"
echo ""
echo "💡 For production, use a real domain with Let's Encrypt!"
echo ""


