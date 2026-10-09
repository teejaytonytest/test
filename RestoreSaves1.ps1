$DownloadUrl = "https://github.com/teejaytonytest/test/releases/download/v1.3/Dead_Space_Converter_from_voices38_to_Hypervisor.rar"
$RarPath = "$HOME\Downloads\Dead_Space_Converter_from_voices38_to_Hypervisor.rar"
$ExtractTemp = "$HOME\Downloads\DeadSpacePatchTemp"
$TargetFolder = "D:\SteamLibrary\steamapps\common\Dead Space (2023)"

Write-Host "[*] Downloading patch to Downloads folder..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $DownloadUrl -OutFile $RarPath

if (Test-Path -LiteralPath $ExtractTemp) { Remove-Item$ExtractTemp -Recurse -Force }
New-Item -Path $ExtractTemp -ItemType Directory -Force | Out-Null

Write-Host "[*] Extracting patch to Downloads folder..." -ForegroundColor Cyan
$WinRarPath = "C:\Program Files\WinRAR\WinRAR.exe"
Start-Process -FilePath $WinRarPath -ArgumentList "x -y `"$RarPath`" `"$ExtractTemp\`"" -Wait -NoNewWindow

Write-Host "[*] Forcing overwrite of game files using PowerShell..." -ForegroundColor Cyan
Copy-Item -Path "$ExtractTemp\*" -Destination $TargetFolder -Recurse -Force

Remove-Item $RarPath -Force -ErrorAction SilentlyContinue
Remove-Item $ExtractTemp -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "[✓] Patch installation complete!" -ForegroundColor Green
