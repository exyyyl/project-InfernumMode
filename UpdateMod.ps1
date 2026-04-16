# UpdateMod.ps1 - Automated Infernum Mode Fix Update Script
# Usage: Run this script in PowerShell to download and install the latest mod version from GitHub.

$Owner = "exyyyl"
$Repo = "project-InfernumMode"
$ModsFolder = Join-Path $HOME "Documents\My Games\Terraria\tModLoader\Mods"

Write-Host "------------------------------------------------" -ForegroundColor Cyan
Write-Host "  Infernum Mode Fix - Auto Updater" -ForegroundColor Cyan
Write-Host "------------------------------------------------" -ForegroundColor Cyan

# 1. Fetch latest release info from GitHub
Write-Host "Checking GitHub for the latest version..." -ForegroundColor Gray
try {
    $ReleaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/$Owner/$Repo/releases/latest" -ErrorAction Stop
} catch {
    Write-Host "Error: Could not reach GitHub API. Check your internet connection." -ForegroundColor Red
    Pause
    exit
}

$LatestVersion = $ReleaseInfo.tag_name
Write-Host "Found version: $LatestVersion" -ForegroundColor Green

# 2. Locate the .tmod asset
$Asset = $ReleaseInfo.assets | Where-Object { $_.name -like "*.tmod" } | Select-Object -First 1

if ($null -eq $Asset) {
    Write-Host "Error: No .tmod file found in the latest release assets." -ForegroundColor Red
    Pause
    exit
}

$DownloadUrl = $Asset.browser_download_url
$FileName = $Asset.name
$DestPath = Join-Path $ModsFolder $FileName

# 3. Check and Create Mods Folder
if (-not (Test-Path $ModsFolder)) {
    Write-Host "Creating Mods directory at $ModsFolder..." -ForegroundColor Gray
    New-Item -ItemType Directory -Path $ModsFolder -Force | Out-Null
}

# 4. Download and Install
Write-Host "Downloading $FileName..." -ForegroundColor Yellow
try {
    # Check if file is in use (Terraria running)
    if (Test-Path $DestPath) {
        try {
            $fileStream = [System.IO.File]::Open($DestPath, 'Open', 'Write', 'None')
            $fileStream.Close()
            $fileStream.Dispose()
        } catch {
            Write-Host "Error: Cannot overwrite the mod file. Is Terraria running? Close it and try again." -ForegroundColor Red
            Pause
            exit
        }
    }

    Invoke-WebRequest -Uri $DownloadUrl -OutFile $DestPath -ErrorAction Stop
    Write-Host "------------------------------------------------" -ForegroundColor Green
    Write-Host "Successfully installed $FileName!" -ForegroundColor Green
    Write-Host "Location: $ModsFolder" -ForegroundColor Gray
    Write-Host "------------------------------------------------" -ForegroundColor Green
} catch {
    Write-Host "Error: Failed to download the mod. $_" -ForegroundColor Red
}

Write-Host "Done! Press any key to exit..."
Pause
