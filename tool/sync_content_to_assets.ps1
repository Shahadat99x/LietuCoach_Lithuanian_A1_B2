# Content Sync Script (PowerShell)
# Mirrors unit.json files from content/ to assets/ for Flutter dev loading
#
# Usage:
#   .\tool\sync_content_to_assets.ps1

$ErrorActionPreference = "Stop"

Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Content Sync: content/ -> assets/       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$contentRoot = "content"
$assetsRoot = "assets/content"
$copied = 0
$skipped = 0

# Find all unit directories
$unitDirs = Get-ChildItem -Path "$contentRoot/a1" -Directory -Filter "unit_*" -ErrorAction SilentlyContinue

if (-not $unitDirs) {
    Write-Host "No unit directories found in $contentRoot/a1" -ForegroundColor Yellow
    exit 0
}

foreach ($unitDir in $unitDirs) {
    $unitId = $unitDir.Name
    $sourceFile = "$contentRoot/a1/$unitId/unit.json"
    $destDir = "$assetsRoot/a1/$unitId"
    $destFile = "$destDir/unit.json"
    
    if (-not (Test-Path $sourceFile)) {
        Write-Host "  Skipping $unitId (no unit.json)"
        continue
    }
    
    # Create destination directory
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        Write-Host "  Created: $destDir" -ForegroundColor Green
    }
    
    # Check if file needs updating
    $needsCopy = $true
    if (Test-Path $destFile) {
        $src = Get-Item $sourceFile
        $dst = Get-Item $destFile
        if ($src.Length -eq $dst.Length -and 
            $src.LastWriteTime -le $dst.LastWriteTime) {
            $needsCopy = $false
            $skipped++
        }
    }
    
    if ($needsCopy) {
        Copy-Item $sourceFile -Destination $destFile -Force
        Write-Host "  ✓ Copied: $unitId/unit.json" -ForegroundColor Green
        $copied++
    }
}

Write-Host ""
Write-Host "────────────────────────────────────────────" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Files copied:  $copied"
Write-Host "  Files skipped: $skipped (already up to date)"
Write-Host "────────────────────────────────────────────" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Content sync complete!" -ForegroundColor Green
