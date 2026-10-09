$ProgressPreference = 'SilentlyContinue'
$DownloadUrl = "https://github.com/teejaytonytest/test/releases/download/v1.3/Dead_Space_Converter_from_voices38_to_Hypervisor.rar"
$RarPath = "$env:TEMP\Dead_Space_Converter_from_voices38_to_Hypervisor.rar"
$TargetFolder = "D:\SteamLibrary\steamapps\common\Dead Space (2023)"

Write-Host "[*] Downloading Dead Space patch..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $DownloadUrl -OutFile$RarPath

# Ensure the Steam library path exists before extracting
if (-not (Test-Path -LiteralPath $TargetFolder)) {
    New-Item -Path $TargetFolder -ItemType Directory -Force | Out-Null
}

Write-Host "[*] Extracting patch files to D: drive game folder using WinRAR..." -ForegroundColor Cyan
# Call WinRAR silently to extract the archive and overwrite existing files automatically (-y)
$WinRarPath = "C:\Program Files\WinRAR\WinRAR.exe"
Start-Process -FilePath $WinRarPath -ArgumentList "x -y `"$RarPath`" `"$TargetFolder\`"" -Wait -NoNewWindow

# Clean up the downloaded rar to free up space
Remove-Item $RarPath -Force

Write-Host "[✓] Patch installation complete!" -ForegroundColor Green
