# Audio Sync Script (PowerShell)
# Mirrors audio files from content/ to assets/ for Flutter dev playback
#
# Usage:
#   .\tool\sync_audio_to_assets.ps1

$ErrorActionPreference = "Stop"

Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Audio Sync: content/ -> assets/        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$contentRoot = "content"
$assetsRoot = "assets/audio"
$copied = 0
$skipped = 0

# Find all unit audio directories
$unitDirs = Get-ChildItem -Path "$contentRoot/a1" -Directory -Filter "unit_*" -ErrorAction SilentlyContinue

if (-not $unitDirs) {
    Write-Host "No unit directories found in $contentRoot/a1" -ForegroundColor Yellow
    exit 0
}

foreach ($unitDir in $unitDirs) {
    $unitId = $unitDir.Name
    $sourceDir = "$contentRoot/a1/$unitId/audio"
    $destDir = "$assetsRoot/a1/$unitId"
    
    if (-not (Test-Path $sourceDir)) {
        Write-Host "  Skipping $unitId (no audio folder)"
        continue
    }
    
    # Create destination directory
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        Write-Host "  Created: $destDir" -ForegroundColor Green
    }
    
    # Copy audio files
    $audioFiles = Get-ChildItem -Path $sourceDir -Filter "*.ogg" -ErrorAction SilentlyContinue
    
    foreach ($file in $audioFiles) {
        $destPath = Join-Path $destDir $file.Name
        
        # Check if file needs updating (newer or different size)
        $needsCopy = $true
        if (Test-Path $destPath) {
            $sourceFile = Get-Item $file.FullName
            $destFile = Get-Item $destPath
            if ($sourceFile.Length -eq $destFile.Length -and 
                $sourceFile.LastWriteTime -le $destFile.LastWriteTime) {
                $needsCopy = $false
                $skipped++
            }
        }
        
        if ($needsCopy) {
            Copy-Item $file.FullName -Destination $destPath -Force
            Write-Host "  ✓ Copied: $($file.Name)" -ForegroundColor Green
            $copied++
        }
    }
}

Write-Host ""
Write-Host "────────────────────────────────────────────" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Files copied:  $copied"
Write-Host "  Files skipped: $skipped (already up to date)"
Write-Host "────────────────────────────────────────────" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Audio sync complete!" -ForegroundColor Green
