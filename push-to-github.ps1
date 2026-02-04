# Push Zaytoonz Website to GitHub
$PROJECT_DIR = "c:\Users\Dell\Desktop\Sora_digital\projects\Zaytoonz SM"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Push Zaytoonz Website to GitHub" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

Set-Location $PROJECT_DIR

Write-Host "✅ Git repository is ready to push" -ForegroundColor Green
Write-Host ""
Write-Host "Please create a GitHub repository first:" -ForegroundColor Yellow
Write-Host "  1. Go to: https://github.com/new" -ForegroundColor White
Write-Host "  2. Repository name: zaytoonz-website" -ForegroundColor White
Write-Host "  3. Description: Zaytoonz Social Impact Community Website" -ForegroundColor White
Write-Host "  4. Public or Private (your choice)" -ForegroundColor White
Write-Host "  5. Do NOT initialize with README, .gitignore, or license" -ForegroundColor White
Write-Host "  6. Click 'Create repository'" -ForegroundColor White
Write-Host ""

$repoUrl = Read-Host "Enter your GitHub repository URL (e.g., https://github.com/username/zaytoonz-website.git)"

if ([string]::IsNullOrWhiteSpace($repoUrl)) {
    Write-Host "❌ No repository URL provided!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "🔗 Adding remote repository..." -ForegroundColor Cyan
git remote add origin $repoUrl

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Remote already exists, updating..." -ForegroundColor Yellow
    git remote set-url origin $repoUrl
}

Write-Host "✅ Remote added" -ForegroundColor Green
Write-Host ""

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
    
    # Update deployment script with repo URL
    Write-Host "🔧 Updating deployment script..." -ForegroundColor Cyan
    $deployScript = Get-Content "deploy-from-github.sh" -Raw
    $deployScript = $deployScript -replace 'REPO_URL="https://github.com/YOUR_USERNAME/zaytoonz-website.git"', "REPO_URL=`"$repoUrl`""
    $deployScript | Set-Content "deploy-from-github.sh" -NoNewline
    
    # Commit and push the updated deployment script
    git add deploy-from-github.sh
    git commit -m "Update deployment script with repository URL"
    git push origin main
    
    Write-Host "✅ Deployment script updated" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "Next: Deploy to VPS" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "SSH into your VPS and run:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "ssh root@168.231.87.171" -ForegroundColor White
    Write-Host ""
    Write-Host "Then run these commands:" -ForegroundColor Yellow
    Write-Host ""
    
    $rawUrl = $repoUrl -replace '\.git$', '' -replace 'github.com', 'raw.githubusercontent.com'
    Write-Host "curl -o /tmp/deploy.sh $rawUrl/main/deploy-from-github.sh" -ForegroundColor White
    Write-Host "chmod +x /tmp/deploy.sh" -ForegroundColor White
    Write-Host "bash /tmp/deploy.sh" -ForegroundColor White
    Write-Host ""
    
    # Copy commands to clipboard
    $vpsCommands = @"
curl -o /tmp/deploy.sh $rawUrl/main/deploy-from-github.sh
chmod +x /tmp/deploy.sh
bash /tmp/deploy.sh
"@
    
    Set-Clipboard $vpsCommands
    Write-Host "✅ VPS commands copied to clipboard!" -ForegroundColor Green
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
    Write-Host "  1. Authentication failed - You may need to set up a Personal Access Token" -ForegroundColor White
    Write-Host "  2. Repository doesn't exist - Create it on GitHub first" -ForegroundColor White
    Write-Host "  3. Repository URL is incorrect" -ForegroundColor White
    Write-Host ""
    Write-Host "For authentication help:" -ForegroundColor Yellow
    Write-Host "  https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens" -ForegroundColor White
}

Write-Host ""
Read-Host "Press Enter to exit"

