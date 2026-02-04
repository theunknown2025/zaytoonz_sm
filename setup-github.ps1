# Setup GitHub Repository for Zaytoonz Website
$PROJECT_DIR = "c:\Users\Dell\Desktop\Sora_digital\projects\Zaytoonz SM"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Zaytoonz Website - GitHub Setup" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if git is installed
$gitInstalled = Get-Command git -ErrorAction SilentlyContinue

if (-not $gitInstalled) {
    Write-Host "❌ Git is not installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Git from: https://git-scm.com/download/win" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✅ Git is installed" -ForegroundColor Green
Write-Host ""

# Navigate to project directory
Set-Location $PROJECT_DIR

# Check if already a git repository
if (Test-Path ".git") {
    Write-Host "📂 Git repository already initialized" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host "🎯 Initializing Git repository..." -ForegroundColor Cyan
    git init
    Write-Host "✅ Git repository initialized" -ForegroundColor Green
    Write-Host ""
}

# Show current status
Write-Host "📊 Current Git Status:" -ForegroundColor Cyan
git status
Write-Host ""

# Ask for GitHub repository URL
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "GitHub Repository Setup" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Please create a new repository on GitHub:" -ForegroundColor Yellow
Write-Host "  1. Go to https://github.com/new" -ForegroundColor White
Write-Host "  2. Repository name: zaytoonz-website" -ForegroundColor White
Write-Host "  3. Description: Zaytoonz Social Impact Community Website" -ForegroundColor White
Write-Host "  4. Choose: Public or Private" -ForegroundColor White
Write-Host "  5. Do NOT initialize with README, .gitignore, or license" -ForegroundColor White
Write-Host "  6. Click 'Create repository'" -ForegroundColor White
Write-Host ""

$repoUrl = Read-Host "Enter your GitHub repository URL (e.g., https://github.com/username/zaytoonz-website.git)"

if ([string]::IsNullOrWhiteSpace($repoUrl)) {
    Write-Host "❌ No repository URL provided!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Add remote origin
Write-Host ""
Write-Host "🔗 Adding remote repository..." -ForegroundColor Cyan

$remoteExists = git remote | Select-String "origin"
if ($remoteExists) {
    Write-Host "📝 Updating remote origin..." -ForegroundColor Yellow
    git remote set-url origin $repoUrl
} else {
    git remote add origin $repoUrl
}

Write-Host "✅ Remote repository added" -ForegroundColor Green
Write-Host ""

# Stage all files
Write-Host "📦 Staging files..." -ForegroundColor Cyan
git add .

# Show what will be committed
Write-Host ""
Write-Host "📋 Files to be committed:" -ForegroundColor Cyan
git status --short
Write-Host ""

# Commit
$commitMessage = Read-Host "Enter commit message (press Enter for 'Initial commit - Zaytoonz website')"
if ([string]::IsNullOrWhiteSpace($commitMessage)) {
    $commitMessage = "Initial commit - Zaytoonz website"
}

Write-Host ""
Write-Host "💾 Creating commit..." -ForegroundColor Cyan
git commit -m "$commitMessage"
Write-Host "✅ Commit created" -ForegroundColor Green
Write-Host ""

# Set main branch
Write-Host "🌿 Setting main branch..." -ForegroundColor Cyan
git branch -M main
Write-Host ""

# Push to GitHub
Write-Host "🚀 Pushing to GitHub..." -ForegroundColor Cyan
Write-Host "You may be asked to authenticate..." -ForegroundColor Yellow
Write-Host ""

git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "✅ Successfully Pushed to GitHub!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your repository: $repoUrl" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "  1. ✅ Code is now on GitHub" -ForegroundColor White
    Write-Host "  2. 📝 Update deploy-from-github.sh with your repo URL" -ForegroundColor White
    Write-Host "  3. 🚀 Deploy to VPS (see DEPLOYMENT.md)" -ForegroundColor White
    Write-Host ""
    
    # Update deployment script with repo URL
    Write-Host "🔧 Updating deployment script..." -ForegroundColor Cyan
    $deployScript = Get-Content "deploy-from-github.sh" -Raw
    $deployScript = $deployScript -replace 'REPO_URL="https://github.com/YOUR_USERNAME/zaytoonz-website.git"', "REPO_URL=`"$repoUrl`""
    $deployScript | Set-Content "deploy-from-github.sh" -NoNewline
    Write-Host "✅ Deployment script updated with your repo URL" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "📋 VPS Deployment Commands:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "ssh root@168.231.87.171" -ForegroundColor White
    Write-Host "curl -o /tmp/deploy.sh $repoUrl/raw/main/deploy-from-github.sh" -ForegroundColor White
    Write-Host "chmod +x /tmp/deploy.sh" -ForegroundColor White
    Write-Host "bash /tmp/deploy.sh" -ForegroundColor White
    Write-Host ""
    
    $openBrowser = Read-Host "Open GitHub repository in browser? (Y/N)"
    if ($openBrowser -eq "Y" -or $openBrowser -eq "y") {
        $webUrl = $repoUrl -replace '\.git$', ''
        Start-Process $webUrl
    }
} else {
    Write-Host ""
    Write-Host "❌ Failed to push to GitHub!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "  1. Authentication failed - Set up Git credentials" -ForegroundColor White
    Write-Host "  2. Repository doesn't exist - Create it on GitHub first" -ForegroundColor White
    Write-Host "  3. No internet connection" -ForegroundColor White
    Write-Host ""
    Write-Host "For authentication help:" -ForegroundColor Yellow
    Write-Host "  https://docs.github.com/en/authentication" -ForegroundColor White
}

Write-Host ""
Read-Host "Press Enter to exit"

