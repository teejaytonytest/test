$ProgressPreference = 'SilentlyContinue'
# DEAD SPACE CRACKFIX (voices38)
$CrackUrl = "https://github.com/teejaytonytest/test/releases/download/v1.4/Dead.Space.Remake.REAL.CRACKFIX-voices38.rar"
$CrackRar = "$env:TEMP\DeadSpace_Crack.rar"
$CrackTemp = "$env:TEMP\DeadSpace_CrackTemp"
$GameDir = "D:\SteamLibrary\steamapps\common\Dead Space (2023)"

Write-Host "[*] Downloading Dead Space CrackFix..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $CrackUrl -OutFile $CrackRar

if (-not (Test-Path -LiteralPath $CrackTemp)) { 
    New-Item -Path $CrackTemp -ItemType Directory -Force | Out-Null 
}

Write-Host "[*] Extracting CrackFix using WinRAR..." -ForegroundColor Cyan
# Uses the newly installed WinRAR to extract the contents to a temporary folder
$WinRarPath = "C:\Program Files\WinRAR\WinRAR.exe"
Start-Process -FilePath $WinRarPath -ArgumentList "x -y `"$CrackRar`" `"$CrackTemp\`"" -Wait -NoNewWindow

Write-Host "[*] Moving CrackFix files to game directory..." -ForegroundColor Cyan
# Copies the contents inside the voices38 folder directly to the root of the Dead Space game folder
if (Test-Path "$CrackTemp\voices38") {
    Copy-Item -Path "$CrackTemp\voices38\*" -Destination $GameDir -Recurse -Force
    Write-Host "[✓] CrackFix applied successfully!" -ForegroundColor Green
} else {
    Write-Host "[-] Could not locate voices38 folder inside the extracted RAR." -ForegroundColor Red
}

# Cleanup CrackFix temp files
Remove-Item $CrackRar -Force
Remove-Item $CrackTemp -Recurse -Force
