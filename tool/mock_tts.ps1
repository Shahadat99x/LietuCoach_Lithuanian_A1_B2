
# Mock TTS Generator for Development
# Copies an existing OGG to all new audioId paths to satisfy validation

$sourceFile = "content/a1/unit_01/audio/a1_u01_iki_normal.ogg"
$targetUnits = 3..10

if (-not (Test-Path $sourceFile)) {
    Write-Error "Source file not found: $sourceFile"
    exit 1
}

foreach ($i in $targetUnits) {
    $unitNum = "{0:D2}" -f $i
    $unitPath = "content/a1/unit_$unitNum"
    $jsonPath = "$unitPath/unit.json"
    $audioDir = "$unitPath/audio"

    if (Test-Path $jsonPath) {
        Write-Host "Processing Unit $unitNum..."
        if (-not (Test-Path $audioDir)) {
            New-Item -ItemType Directory -Force -Path $audioDir | Out-Null
        }

        $jsonContent = Get-Content $jsonPath -Raw | ConvertFrom-Json
        $items = $jsonContent.items

        foreach ($key in $items.PSObject.Properties.Name) {
            $item = $items.$key
            if ($item.audioId) {
                $targetFile = "$audioDir/$($item.audioId)_normal.ogg"
                if (-not (Test-Path $targetFile)) {
                    Copy-Item $sourceFile $targetFile
                    Write-Host "  -> Created $targetFile"
                }
            }
        }
    } else {
        Write-Warning "Unit $unitNum not found at $jsonPath"
    }
}

Write-Host "Mock TTS generation complete."
