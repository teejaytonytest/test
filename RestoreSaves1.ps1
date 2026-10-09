$ProgressPreference = 'SilentlyContinue'
$DownloadUrl = "https://github.com/teejaytonytest/test/releases/download/v1.3/Dead_Space_Converter_from_voices38_to_Hypervisor.rar"
$RarPath = "$env:TEMP\Dead_Space_Converter_from_voices38_to_Hypervisor.rar"
$TargetFolder = "D:\SteamLibrary\steamapps\common\Dead Space (2023)"

Write-Host "[*] Re-downloading patch..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $DownloadUrl -OutFile $RarPath

Write-Host "[*] Extracting and overwriting patch files..." -ForegroundColor Cyan
$UnrarPath = "C:\Program Files\WinRAR\UnRAR.exe"

# -o+ forces UnRAR to overwrite existing files instead of skipping them
$UnrarArgs = @("x", "-y", "-o+", $RarPath, "$TargetFolder\")
Start-Process -FilePath $UnrarPath -ArgumentList $UnrarArgs -Wait -NoNewWindow

Remove-Item $RarPath -Force
Write-Host "[✓] Patch installation complete!" -ForegroundColor Green
