# 🔒 HTTPS Setup Guide for Zaytoonz Website

## 📋 Overview

To enable HTTPS (secure connection), you need an SSL certificate. There are two main options:

1. **Let's Encrypt (Recommended)** - Free, trusted by browsers, requires a domain name
2. **Self-Signed Certificate** - Works but shows browser warnings, good for testing

---

## ✅ Option 1: Let's Encrypt SSL (Production - Recommended)

### Requirements:
- ✅ A domain name (e.g., zaytoonz.com)
- ✅ DNS A record pointing to: `168.231.87.171`
- ✅ Ports 80 and 443 open

### Step 1: Set Up DNS

In your domain registrar (GoDaddy, Namecheap, etc.), add these DNS records:

```
Type    Name    Value               TTL
A       @       168.231.87.171      3600
A       www     168.231.87.171      3600
```

**Wait 5-10 minutes** for DNS to propagate. Verify with:
```bash
nslookup yourdomain.com
```

### Step 2: Deploy SSL Setup Script

Upload the script to your VPS:

```bash
# On your local machine
scp setup-https-letsencrypt.sh root@168.231.87.171:/tmp/

# SSH into VPS
ssh root@168.231.87.171

# Make executable and run
chmod +x /tmp/setup-https-letsencrypt.sh
bash /tmp/setup-https-letsencrypt.sh yourdomain.com
```

**Replace `yourdomain.com` with your actual domain!**

### Step 3: Verify HTTPS

Visit: **https://yourdomain.com**

You should see a secure padlock 🔒 in your browser!

---

## ⚠️ Option 2: Self-Signed Certificate (Testing Only)

**Warning:** Browsers will show security warnings. Use only for testing!

### Quick Setup:

```bash
# SSH into VPS
ssh root@168.231.87.171

# Upload script
# (From your local machine)
scp setup-ssl-self-signed.sh root@168.231.87.171:/tmp/

# Run script
chmod +x /tmp/setup-ssl-self-signed.sh
bash /tmp/setup-ssl-self-signed.sh
```

### Access Your Site:

Visit: **https://168.231.87.171**

**You'll see a warning** - Click "Advanced" → "Proceed to site"

---

## 🆓 Free Domain Options

If you don't have a domain yet, here are free options:

### 1. Freenom (Free Domains)
- **URL:** https://www.freenom.com
- **TLDs:** .tk, .ml, .ga, .cf, .gq
- **Steps:**
  1. Create account
  2. Search for domain
  3. Add to cart (select "Free" period)
  4. Complete registration
  5. Configure DNS (point to 168.231.87.171)

### 2. Cloudflare (Free DNS + SSL)
- **URL:** https://www.cloudflare.com
- Use Cloudflare's free DNS and SSL
- Works with any domain

### 3. Buy a Domain (Recommended)
- **Namecheap:** ~$10/year for .com
- **GoDaddy:** ~$12/year for .com
- **Google Domains:** ~$12/year for .com

---

## 🔧 Manual Let's Encrypt Setup

If you prefer manual setup:

```bash
# SSH into VPS
ssh root@168.231.87.171

# Install Certbot
sudo apt update
sudo apt install -y certbot python3-certbot-nginx

# Get certificate (replace with your domain)
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Follow prompts:
# - Enter email address
# - Agree to terms
# - Choose redirect HTTP to HTTPS (option 2)

# Test auto-renewal
sudo certbot renew --dry-run
```

---

## 🔄 Certificate Auto-Renewal

Let's Encrypt certificates expire every 90 days. Certbot sets up auto-renewal automatically.

**Verify auto-renewal is set up:**
```bash
sudo systemctl status certbot.timer
```

**Test renewal manually:**
```bash
sudo certbot renew --dry-run
```

---

## 🌐 Update Nginx for Custom Domain

If you're using a custom domain, update Nginx config:

```bash
sudo nano /etc/nginx/sites-available/zaytoonz
```

Change `server_name` to:
```nginx
server_name yourdomain.com www.yourdomain.com;
```

Then:
```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

## 🔍 Troubleshooting

### Certificate Not Issued?

1. **Check DNS:**
   ```bash
   nslookup yourdomain.com
   ```
   Should return: `168.231.87.171`

2. **Check Port 80:**
   ```bash
   sudo ufw status
   sudo ufw allow 'Nginx Full'
   ```

3. **Check Nginx:**
   ```bash
   sudo systemctl status nginx
   ```

### Browser Shows "Not Secure"?

- Make sure you're using `https://` not `http://`
- Clear browser cache
- Check certificate: Click padlock → Certificate

### Certificate Expired?

```bash
sudo certbot renew
sudo systemctl reload nginx
```

---

## 📊 SSL Certificate Status

Check certificate details:
```bash
sudo certbot certificates
```

---

## 🎯 Recommended Setup

**For Production:**
1. ✅ Get a domain name (even free one from Freenom)
2. ✅ Point DNS to your VPS
3. ✅ Use Let's Encrypt SSL
4. ✅ Enable auto-renewal

**For Testing:**
1. ⚠️ Use self-signed certificate
2. ⚠️ Accept browser warnings

---

## 📝 Quick Reference

### Your VPS Details:
- **IP:** 168.231.87.171
- **Hostname:** srv1182909.hstgr.cloud
- **OS:** Ubuntu 24.04 LTS

### Current URLs:
- **HTTP:** http://168.231.87.171
- **HTTPS (after setup):** https://yourdomain.com

---

## 🚀 Next Steps After HTTPS Setup

1. ✅ Test website on HTTPS
2. ✅ Update all links to use HTTPS
3. ✅ Set up HSTS (HTTP Strict Transport Security)
4. ✅ Monitor certificate expiration
5. ✅ Configure backup SSL renewal

---

**Need Help?** Check Certbot documentation: https://certbot.eff.org/


