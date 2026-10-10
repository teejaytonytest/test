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

# RICH mod crack
$ProgressPreference = 'SilentlyContinue'

$DownloadUrl = "https://github.com/teejaytonytest/test/releases/download/v1.5/DeadSpace_Precompiled_Mods.zip"
$ZipPath     = "$HOME\Downloads\DeadSpace_Precompiled_Mods.zip"
$ExtractTemp = "$HOME\Downloads\DeadSpaceModRestoreTemp"
$GameRoot    = "D:\SteamLibrary\steamapps\common\Dead Space (2023)"
$GameData    = "$GameRoot\Data"

Write-Host "[*] Downloading mod pack from GitHub v1.5..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipPath

Write-Host "[*] Extracting files..." -ForegroundColor Cyan
if (Test-Path -LiteralPath $ExtractTemp) { Remove-Item $ExtractTemp -Recurse -Force }
Expand-Archive -Path $ZipPath -DestinationPath $ExtractTemp -Force

Write-Host "[*] Placing files into Dead Space directory..." -ForegroundColor Cyan
# Move CryptBase.dll directly to the game root folder
if (Test-Path "$ExtractTemp\CryptBase.dll") {
    Copy-Item -Path "$ExtractTemp\CryptBase.dll" -Destination $GameRoot -Force
    Remove-Item "$ExtractTemp\CryptBase.dll" -Force
}

# Move all remaining mod data files into the game's Data directory
Copy-Item -Path "$ExtractTemp\*" -Destination $GameData -Recurse -Force

Write-Host "[*] Cleaning up temporary files..." -ForegroundColor Cyan
Remove-Item $ZipPath -Force -ErrorAction SilentlyContinue
Remove-Item $ExtractTemp -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "[✓] All mod files successfully restored!" -ForegroundColor Green
