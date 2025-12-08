# Zaytoonz Website - GitHub Deployment Guide

## 🚀 Quick Start

### Step 1: Push to GitHub

```bash
# Initialize git (if not already done)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - Zaytoonz website"

# Add your GitHub repository
git remote add origin https://github.com/YOUR_USERNAME/zaytoonz-website.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### Step 2: Deploy to VPS

SSH into your VPS:

```bash
ssh root@168.231.87.171
```

Download and run the deployment script:

```bash
# Download the deployment script
curl -o /tmp/deploy.sh https://raw.githubusercontent.com/YOUR_USERNAME/zaytoonz-website/main/deploy-from-github.sh

# Make it executable
chmod +x /tmp/deploy.sh

# Edit the script to add your GitHub repo URL
nano /tmp/deploy.sh
# Change: REPO_URL="https://github.com/YOUR_USERNAME/zaytoonz-website.git"

# Run the deployment
bash /tmp/deploy.sh
```

## 🔄 Future Updates

Whenever you make changes to your website:

### On Your Local Machine:

```bash
# Make your changes to the website files
# Then commit and push

git add .
git commit -m "Update website"
git push origin main
```

### On Your VPS:

```bash
ssh root@168.231.87.171

# Run the deployment script again
bash /tmp/deploy.sh
```

Or create an alias for easy updates:

```bash
# On VPS, add this to ~/.bashrc
echo 'alias deploy-zaytoonz="bash /tmp/deploy.sh"' >> ~/.bashrc
source ~/.bashrc

# Now you can just run:
deploy-zaytoonz
```

## 📁 Project Structure

```
zaytoonz-website/
├── index.html              # Main website file
├── public/                 # Static assets
│   ├── image.png          # Logo
│   ├── Health.png         # Background images
│   ├── Water.png
│   ├── Green.png
│   ├── Education.png
│   └── sm/                # QR codes
│       ├── whatsapp-qr.png
│       ├── telegram-qr.png
│       ├── facebook-qr.png
│       ├── linkedin-qr.png
│       ├── facebook-group-qr.png
│       └── linkedin-group-qr.png
├── README.md              # Project documentation
├── .gitignore            # Git ignore rules
└── deploy-from-github.sh # VPS deployment script
```

## 🔐 Setting Up SSL (HTTPS)

After your site is working, secure it with SSL:

```bash
# On VPS
sudo apt install -y certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal is configured automatically
```

## 🌐 Custom Domain Setup

1. **Update DNS Records** (in your domain registrar):
   ```
   Type    Name    Value               TTL
   A       @       168.231.87.171      3600
   A       www     168.231.87.171      3600
   ```

2. **Update Nginx Config** on VPS:
   ```bash
   sudo nano /etc/nginx/sites-available/zaytoonz
   ```
   
   Change `server_name` to:
   ```nginx
   server_name yourdomain.com www.yourdomain.com;
   ```

3. **Reload Nginx**:
   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   ```

4. **Install SSL**:
   ```bash
   sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
   ```

## 🛠️ Useful Commands

### On VPS:

```bash
# Check Nginx status
sudo systemctl status nginx

# View logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Restart Nginx
sudo systemctl restart nginx

# Update website from GitHub
cd /opt/zaytoonz-repo
git pull origin main
sudo rsync -av --delete --exclude='.git' /opt/zaytoonz-repo/ /var/www/zaytoonz/
sudo systemctl reload nginx
```

### On Local Machine:

```bash
# Check git status
git status

# View commit history
git log --oneline

# Create a new branch for testing
git checkout -b feature/new-design

# Merge changes back to main
git checkout main
git merge feature/new-design
```

## 🔧 Troubleshooting

### Website not updating?

```bash
# On VPS, force pull and clear cache
cd /opt/zaytoonz-repo
git fetch --all
git reset --hard origin/main
bash /tmp/deploy.sh
```

### Permission errors?

```bash
sudo chown -R www-data:www-data /var/www/zaytoonz
sudo chmod -R 755 /var/www/zaytoonz
```

### Nginx errors?

```bash
# Check configuration
sudo nginx -t

# View error logs
sudo tail -50 /var/log/nginx/error.log
```

## 📊 Benefits of GitHub Deployment

✅ **Version Control** - Track all changes to your website
✅ **Easy Updates** - Just push to GitHub and pull on VPS
✅ **Backup** - Your code is safely stored on GitHub
✅ **Collaboration** - Easy to work with team members
✅ **Rollback** - Can revert to previous versions easily
✅ **Professional** - Industry-standard deployment method

## 🎯 Next Steps

1. ✅ Create GitHub repository
2. ✅ Push your code
3. ✅ Deploy to VPS
4. 🔲 Set up custom domain
5. 🔲 Install SSL certificate
6. 🔲 Set up automatic deployments (optional)

---

**Your VPS Details:**
- IP: 168.231.87.171
- Hostname: srv1182909.hstgr.cloud
- OS: Ubuntu 24.04 LTS

**Live URLs:**
- http://168.231.87.171
- http://srv1182909.hstgr.cloud

