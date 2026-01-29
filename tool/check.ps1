# LietuCoach check script (PowerShell)
# Runs flutter analyze + flutter test + content validation + optional TTS generation

param(
    [switch]$WithTts  # Run TTS generation if credentials are set
)

$ErrorActionPreference = "Stop"

# Find flutter
$flutterPath = "flutter"
if (-not (Get-Command $flutterPath -ErrorAction SilentlyContinue)) {
    $flutterPath = "W:\Flutter\flutter\bin\flutter.bat"
    if (-not (Test-Path $flutterPath)) {
        Write-Host "ERROR: Flutter not found. Please add Flutter to PATH." -ForegroundColor Red
        exit 1
    }
}

$dartPath = "dart"
if (-not (Get-Command $dartPath -ErrorAction SilentlyContinue)) {
    $dartPath = "W:\Flutter\flutter\bin\dart.bat"
}

Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           LietuCoach Check                 ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Optional: TTS generation
$credsSet = $env:GOOGLE_APPLICATION_CREDENTIALS -and (Test-Path $env:GOOGLE_APPLICATION_CREDENTIALS -ErrorAction SilentlyContinue)
if ($WithTts -or $credsSet) {
    if ($credsSet) {
        Write-Host "Running TTS audio generation..." -ForegroundColor Yellow
        python tool/generate_tts_audio.py --unit unit_01
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        Write-Host ""
        
        Write-Host "Syncing audio to assets..." -ForegroundColor Yellow
        & "$PSScriptRoot\sync_audio_to_assets.ps1"
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        Write-Host ""
    } else {
        Write-Host "Skipping TTS generation (GOOGLE_APPLICATION_CREDENTIALS not set)" -ForegroundColor DarkGray
        Write-Host ""
    }
}

Write-Host "Running flutter analyze..." -ForegroundColor Yellow
& $flutterPath analyze
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host ""

Write-Host "Running flutter test..." -ForegroundColor Yellow
& $flutterPath test
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host ""

Write-Host "Running content validator..." -ForegroundColor Yellow
& $dartPath run tool/validate_content.dart
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host ""

Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║           All checks passed!               ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Green
