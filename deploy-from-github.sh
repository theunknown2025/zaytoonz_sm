#!/bin/bash

# Zaytoonz Website - Deploy from GitHub
# Run this script on your VPS to deploy the website

set -e  # Exit on any error

REPO_URL="https://github.com/YOUR_USERNAME/zaytoonz-website.git"
WEB_DIR="/var/www/zaytoonz"
REPO_DIR="/opt/zaytoonz-repo"

echo "================================================"
echo "Zaytoonz Website - GitHub Deployment"
echo "================================================"
echo ""

# Update system packages
echo "📦 Updating system packages..."
sudo apt update

# Install required packages
echo "📥 Installing required packages..."
sudo apt install -y nginx git

# Clone or pull repository
if [ -d "$REPO_DIR" ]; then
    echo "📂 Repository exists, pulling latest changes..."
    cd "$REPO_DIR"
    git pull origin main
else
    echo "📥 Cloning repository..."
    sudo git clone "$REPO_URL" "$REPO_DIR"
fi

# Create web directory if it doesn't exist
echo "📁 Setting up web directory..."
sudo mkdir -p "$WEB_DIR"

# Copy files from repo to web directory
echo "📋 Copying files to web directory..."
sudo rsync -av --delete \
    --exclude='.git' \
    --exclude='.gitignore' \
    --exclude='README.md' \
    --exclude='*.sh' \
    "$REPO_DIR/" "$WEB_DIR/"

# Set correct permissions
echo "🔐 Setting permissions..."
sudo chown -R www-data:www-data "$WEB_DIR"
sudo chmod -R 755 "$WEB_DIR"
sudo find "$WEB_DIR" -type f -exec chmod 644 {} \;
sudo find "$WEB_DIR" -type d -exec chmod 755 {} \;

# Configure Nginx if not already configured
if [ ! -f /etc/nginx/sites-available/zaytoonz ]; then
    echo "⚙️  Configuring Nginx..."
    sudo tee /etc/nginx/sites-available/zaytoonz > /dev/null <<'EOF'
server {
    listen 80;
    listen [::]:80;
    
    server_name srv1182909.hstgr.cloud 168.231.87.171;
    
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
EOF

    # Enable the site
    sudo ln -sf /etc/nginx/sites-available/zaytoonz /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default
fi

# Test Nginx configuration
echo "🧪 Testing Nginx configuration..."
sudo nginx -t

# Restart Nginx
echo "🔄 Restarting Nginx..."
sudo systemctl restart nginx
sudo systemctl enable nginx

# Configure firewall
if command -v ufw &> /dev/null; then
    echo "🔥 Configuring firewall..."
    sudo ufw allow 'Nginx Full'
    sudo ufw --force enable
fi

echo ""
echo "================================================"
echo "✅ Deployment Complete!"
echo "================================================"
echo ""
echo "Your website is now live at:"
echo "  🌐 http://168.231.87.171"
echo "  🌐 http://srv1182909.hstgr.cloud"
echo ""
echo "To update your website in the future, just run:"
echo "  sudo bash $0"
echo ""

