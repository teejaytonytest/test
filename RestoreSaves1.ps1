$ProgressPreference = 'SilentlyContinue'
$DownloadUrl = "https://github.com/teejaytonytest/test/releases/download/v1.3/Dead_Space_Converter_from_voices38_to_Hypervisor.rar"
$RarPath = "$env:TEMP\Dead_Space_Converter_from_voices38_to_Hypervisor.rar"
$TargetFolder = "D:\SteamLibrary\steamapps\common\Dead Space (2023)"

Write-Host "[*] Re-downloading patch..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $DownloadUrl -OutFile $RarPath

Write-Host "[*] Extracting patch files..." -ForegroundColor Cyan
$UnrarPath = "C:\Program Files\WinRAR\UnRAR.exe"

# Passing arguments as an array prevents PowerShell from breaking the quotes
$UnrarArgs = @("x", "-y", $RarPath, "$TargetFolder\")
Start-Process -FilePath $UnrarPath -ArgumentList $UnrarArgs -Wait -NoNewWindow

Remove-Item $RarPath -Force
Write-Host "[✓] Patch installation complete!" -ForegroundColor Green
