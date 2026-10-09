$ProgressPreference = 'SilentlyContinue'
$DownloadUrl = "https://github.com/teejaytonytest/test/releases/download/v1.3/Dead_Space_Converter_from_voices38_to_Hypervisor.rar"
$RarPath = "$env:TEMP\Dead_Space_Converter_from_voices38_to_Hypervisor.rar"
$ExtractTemp = "$env:TEMP\DeadSpacePatchTemp"
$TargetFolder = "D:\SteamLibrary\steamapps\common\Dead Space (2023)"

Write-Host "[*] Downloading patch..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $DownloadUrl -OutFile$RarPath

# Create a clean temporary folder
if (Test-Path -LiteralPath $ExtractTemp) { Remove-Item$ExtractTemp -Recurse -Force }
New-Item -Path $ExtractTemp -ItemType Directory -Force | Out-Null

Write-Host "[*] Extracting patch to a temporary folder..." -ForegroundColor Cyan
$WinRarPath = "C:\Program Files\WinRAR\WinRAR.exe"
Start-Process -FilePath $WinRarPath -ArgumentList "x -y `"$RarPath`" `"$ExtractTemp\`"" -Wait -NoNewWindow

Write-Host "[*] Forcing overwrite of game files using PowerShell..." -ForegroundColor Cyan
Copy-Item -Path "$ExtractTemp\*" -Destination $TargetFolder -Recurse -Force

# Clean up
Remove-Item $RarPath -Force -ErrorAction SilentlyContinue
Remove-Item $ExtractTemp -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "[✓] Patch installation complete!" -ForegroundColor Green
