$DownloadUrl = "https://github.com/teejaytonytest/test/releases/download/v1.0/1693980.zip"
$ZipPath = "$env:TEMP\1693980.zip"
$TargetFolder = "D:\SteamLibrary\steamapps\common\Dead Space (2023)"

Write-Host "[*] Downloading 264MB Dead Space patch..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipPath

# Ensure the Steam library path exists before extracting
if (-not (Test-Path -LiteralPath $TargetFolder)) {
    New-Item -Path $TargetFolder -ItemType Directory -Force | Out-Null
}

Write-Host "[*] Extracting patch files to D: drive game folder..." -ForegroundColor Cyan
Expand-Archive -Path $ZipPath -DestinationPath $TargetFolder -Force

# Clean up the downloaded zip to free up space
Remove-Item $ZipPath -Force

Write-Host "[✓] Patch installation complete!" -ForegroundColor Green
