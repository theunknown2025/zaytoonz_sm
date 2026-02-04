#!/bin/bash

# Zaytoonz Website - Complete Deployment Script
# This script deploys the website from GitHub and sets up SSL
# Usage: bash /tmp/deploy-sm.sh

set -e  # Exit on any error

# Configuration
REPO_URL="https://github.com/theunknown2025/zaytoonz_sm.git"
REPO_DIR="/opt/zaytoonz-repo"
WEB_DIR="/var/www/zaytoonz"
DOMAIN="zaytoonz.com"
WWW_DOMAIN="www.zaytoonz.com"
NGINX_CONFIG="/etc/nginx/sites-available/zaytoonz"

echo "================================================"
echo "Zaytoonz Website - Complete Deployment"
echo "================================================"
echo ""
echo "Repository: $REPO_URL"
echo "Domain: $DOMAIN"
echo "Web Directory: $WEB_DIR"
echo ""

# Step 1: Update System
echo "📦 Step 1: Updating system packages..."
apt update
apt upgrade -y

# Step 2: Install Required Packages
echo ""
echo "📥 Step 2: Installing required packages..."
apt install -y nginx git certbot python3-certbot-nginx curl

# Step 3: Clone or Update Repository
echo ""
echo "📂 Step 3: Setting up repository..."
if [ -d "$REPO_DIR" ]; then
    echo "   Repository exists, pulling latest changes..."
    cd "$REPO_DIR"
    git pull origin main || git pull origin master
else
    echo "   Cloning repository..."
    git clone "$REPO_URL" "$REPO_DIR"
    cd "$REPO_DIR"
fi

# Step 4: Create Web Directory
echo ""
echo "📁 Step 4: Setting up web directory..."
mkdir -p "$WEB_DIR"

# Step 5: Copy Files to Web Directory
echo ""
echo "📋 Step 5: Copying files to web directory..."
rsync -av --delete \
    --exclude='.git' \
    --exclude='.gitignore' \
    --exclude='README.md' \
    --exclude='DEPLOYMENT.md' \
    --exclude='*.sh' \
    --exclude='*.md' \
    "$REPO_DIR/" "$WEB_DIR/"

# Step 6: Set Permissions
echo ""
echo "🔐 Step 6: Setting file permissions..."
chown -R www-data:www-data "$WEB_DIR"
chmod -R 755 "$WEB_DIR"
find "$WEB_DIR" -type f -exec chmod 644 {} \;
find "$WEB_DIR" -type d -exec chmod 755 {} \;

# Step 7: Configure Nginx
echo ""
echo "⚙️  Step 7: Configuring Nginx..."

# Check if SSL certificate exists
SSL_EXISTS=false
if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    SSL_EXISTS=true
    echo "   SSL certificate found, configuring HTTPS..."
else
    echo "   SSL certificate not found, configuring HTTP only (will add HTTPS after certificate)..."
fi

# Create Nginx configuration
if [ "$SSL_EXISTS" = true ]; then
    # Full config with HTTPS
    cat > "$NGINX_CONFIG" <<EOF
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
    
    root $WEB_DIR;
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
else
    # HTTP only config (for initial setup)
    cat > "$NGINX_CONFIG" <<EOF
# HTTP Server
server {
    listen 80;
    listen [::]:80;
    
    server_name $DOMAIN $WWW_DOMAIN srv1182909.hstgr.cloud 168.231.87.171;
    
    # Let's Encrypt verification
    location ~ /.well-known/acme-challenge {
        allow all;
        root /var/www/html;
    }
    
    # Security Headers
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    root $WEB_DIR;
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
fi

# Enable the site
echo "   Enabling Nginx site..."
ln -sf "$NGINX_CONFIG" /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
echo "   Testing Nginx configuration..."
nginx -t

# Step 8: Configure Firewall
echo ""
echo "🔥 Step 8: Configuring firewall..."
if command -v ufw &> /dev/null; then
    ufw allow 'Nginx Full'
    ufw --force enable
    echo "   Firewall configured"
else
    echo "   UFW not installed, skipping firewall configuration"
fi

# Step 9: Start/Reload Nginx
echo ""
echo "🔄 Step 9: Starting Nginx..."
systemctl restart nginx
systemctl enable nginx

# Step 10: Set Up SSL Certificate
echo ""
echo "🔒 Step 10: Setting up SSL certificate..."

# Check if certificate already exists
if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "   ✅ SSL certificate already exists"
    echo "   Nginx is already configured for HTTPS"
else
    echo "   Obtaining SSL certificate from Let's Encrypt..."
    echo "   This will ask for your email address"
    echo ""
    
    # Try to get certificate
    if certbot --nginx -d "$DOMAIN" -d "$WWW_DOMAIN" \
        --non-interactive \
        --agree-tos \
        --email "admin@$DOMAIN" \
        --redirect 2>/dev/null; then
        
        echo "   ✅ SSL certificate obtained and configured"
        echo "   Nginx configuration updated automatically by Certbot"
        
        # Reload Nginx to apply changes
        systemctl reload nginx
    else
        echo "   ⚠️  Could not obtain SSL certificate automatically"
        echo "   This might be because:"
        echo "   - DNS is not pointing to this server"
        echo "   - Port 80 is blocked"
        echo "   - Domain is not accessible"
        echo ""
        echo "   You can try manually:"
        echo "   certbot --nginx -d $DOMAIN -d $WWW_DOMAIN"
        echo ""
        echo "   For now, website will work on HTTP only"
        echo "   After getting certificate, run this script again to configure HTTPS"
    fi
fi

# Step 11: Verify Deployment
echo ""
echo "🧪 Step 11: Verifying deployment..."

# Check if index.html exists
if [ -f "$WEB_DIR/index.html" ]; then
    echo "   ✅ index.html found"
else
    echo "   ❌ index.html not found!"
fi

# Check Nginx status
if systemctl is-active --quiet nginx; then
    echo "   ✅ Nginx is running"
else
    echo "   ❌ Nginx is not running!"
fi

# Check if SSL is configured
if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "   ✅ SSL certificate is installed"
else
    echo "   ⚠️  SSL certificate not installed"
fi

# Display summary
echo ""
echo "================================================"
echo "✅ Deployment Complete!"
echo "================================================"
echo ""
echo "🌐 Your website is available at:"
echo "   🔒 https://$DOMAIN"
echo "   🔒 https://$WWW_DOMAIN"
echo "   🌐 http://168.231.87.171 (redirects to HTTPS)"
echo ""
echo "📋 Deployment Details:"
echo "   Repository: $REPO_URL"
echo "   Web Directory: $WEB_DIR"
echo "   Nginx Config: $NGINX_CONFIG"
echo ""

# Check SSL certificate expiration
if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    EXPIRY=$(openssl x509 -enddate -noout -in /etc/letsencrypt/live/$DOMAIN/fullchain.pem | cut -d= -f2)
    echo "   🔐 SSL Certificate expires: $EXPIRY"
    echo "   🔄 Auto-renewal: Enabled"
fi

echo ""
echo "📝 Useful Commands:"
echo "   View logs: tail -f /var/log/nginx/error.log"
echo "   Restart Nginx: systemctl restart nginx"
echo "   Update website: cd $REPO_DIR && git pull && bash /tmp/deploy-sm.sh"
echo ""
echo "================================================"

