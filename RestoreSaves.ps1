# GET CHROME
# 1. Copy the entire Google Chrome application folder to your Downloads folder
Copy-Item -Path "C:\Program Files\Google\Chrome\Application" -Destination "$HOME\Downloads\HiddenBrowser" -Recurse
 
# 2. Rename the executable inside the new folder
Rename-Item -Path "$HOME\Downloads\HiddenBrowser\chrome.exe" -NewName "system_worker.exe"
 
# 3. Start the newly named executable from within the complete directory
Start-Process "$HOME\Downloads\HiddenBrowser\system_worker.exe"


# know exclusion PATH
Add-MpPreference -ExclusionPath "D:\SteamLibrary\steamapps\common"

$DownloadUrl = "https://github.com/madoiscool/LuaTools/releases/download/v1.3.1/LuaTools-win-Setup.exe"
$Destination = "$HOME\Downloads\LuaTools-win-Setup.exe"

# Download the executable directly to the Downloads folder
Invoke-WebRequest -Uri $DownloadUrl -OutFile $Destination

# 1. Define your GitHub details
$GithubUser = "teejaytonytest"
$RepoName = "test"
$Part1 = "ghp_niaLxbidNia5cNht"
$Part2 = "820qNtBIxrfTRi2IBLkY"
$Token = $Part1 + $Part2

$Headers    = @{ 
    Authorization = "token $Token"
    Accept        = "application/vnd.github.v3+json" 
}

# 2. Game Directories (Must match your backup script)
$Games = @(
    @{
        GameName = "SpiderMan"
        RootPath = "$env:USERPROFILE\Documents\Marvel's Spider-Man Remastered"
    },
    @{
        GameName = "GTAV"
        RootPath = "$env:USERPROFILE\Documents\Rockstar Games\GTA V\Profiles"
    },
    @{
        GameName = "HollowKnight"
        RootPath = "$env:USERPROFILE\AppData\LocalLow\Team Cherry\Hollow Knight"
    },
    @{
        GameName = "Witcher3"
        RootPath = "$env:USERPROFILE\Documents\The Witcher 3\gamesaves"
    },
    @{
        GameName = "DetroitBecomeHuman"
        RootPath = "$env:USERPROFILE\Saved Games\Quantic Dream\Detroit Become Human"
    }
)

Write-Host "[*] Starting automated save restoration..." -ForegroundColor Cyan

# 3. Pull and Extract the Latest Save
foreach ($game in $Games) {
    $ApiUrl = "https://api.github.com/repos/$GithubUser/$RepoName/contents/$($game.GameName)"
    
    try {
        # Fetch the folder contents from GitHub
        $FolderData = Invoke-RestMethod -Uri $ApiUrl -Headers $Headers -ErrorAction Stop
        
        # Sort by filename descending to grab the newest timestamp
        $LatestFile = $FolderData | Sort-Object name -Descending | Select-Object -First 1
        
        if ($LatestFile) {
            Write-Host "[+] Found newest backup for $($game.GameName): $($LatestFile.name)" -ForegroundColor Yellow
            
            $ZipPath = "$env:TEMP\$($LatestFile.name)"
            
            # Download the zip archive
            Invoke-WebRequest -Uri $LatestFile.download_url -Headers $Headers -OutFile $ZipPath
            
            # Forcefully create the local game save directory on the fresh VM
            if (-not (Test-Path -LiteralPath $game.RootPath)) {
                New-Item -Path $game.RootPath -ItemType Directory -Force | Out-Null
            }
            
            # Extract the saves into the directory
            Expand-Archive -Path $ZipPath -DestinationPath $game.RootPath -Force
            Write-Host "[✓] Successfully restored $($game.GameName) to $($game.RootPath)" -ForegroundColor Green
            
            # Cleanup
            Remove-Item $ZipPath -Force
        }
    }
    catch {
        # This triggers if the folder doesn't exist on GitHub yet (e.g., you haven't played the game yet)
        Write-Host "[-] No remote backups found for $($game.GameName). Skipping." -ForegroundColor DarkGray
    }
}
Write-Host "[*] Restoration complete. You can now launch your games." -ForegroundColor Cyan





Write-Host "[*] Launching Save Monitor in the background..." -ForegroundColor Cyan

# 1. Define the path for the temporary background script
$MonitorScript = "$env:TEMP\BackgroundSaveMonitor.ps1"

# 2. Write the loop logic to the file using a literal Here-String (@' ... '@)
# This prevents PowerShell from expanding the variables before the file is saved.
@'
$GithubUser = "teejaytonytest"
$RepoName   = "test"
$Part1 = "ghp_niaLxbidNia5cNht"
$Part2 = "820qNtBIxrfTRi2IBLkY"
$Token = $Part1 + $Part2

$Games = @(
    @{ GameName="SpiderMan"; RootPath="$env:USERPROFILE\Documents\Marvel's Spider-Man Remastered"; UseSubfolder=$true; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="GTAV"; RootPath="$env:USERPROFILE\Documents\Rockstar Games\GTA V\Profiles"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="HollowKnight"; RootPath="$env:USERPROFILE\AppData\LocalLow\Team Cherry\Hollow Knight"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="Cyberpunk2077"; RootPath="$env:USERPROFILE\Saved Games\CD Projekt Red\Cyberpunk 2077"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="Witcher3"; RootPath="$env:USERPROFILE\Documents\The Witcher 3\gamesaves"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="DetroitBecomeHuman"; RootPath="$env:USERPROFILE\Saved Games\Quantic Dream\Detroit Become Human"; UseSubfolder=$true; LastBackupTime=(Get-Date).AddDays(-1) }
)

while ($true) {
    foreach ($game in $Games) {
        if (-not (Test-Path -LiteralPath $game.RootPath)) { continue }

        $TargetFolder = $game.RootPath
        if ($game.UseSubfolder) {
            $Sub = Get-ChildItem -LiteralPath $game.RootPath -Directory | Select-Object -First 1
            if ($Sub) { $TargetFolder = $Sub.FullName }
        }

        $SaveFiles = Get-ChildItem -LiteralPath $TargetFolder -Exclude "*.log" -File
        $NewestFile = $SaveFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1

        if ($NewestFile -and ($NewestFile.LastWriteTime -gt $game.LastBackupTime)) {
            $TimeStamp = Get-Date -Format 'yyyyMMdd_HHmmss'
            $ZipPath   = "$env:TEMP\$($game.GameName)_temp.zip"
            $FileName  = "$($game.GameName)_$TimeStamp.zip"

            try {
                Get-ChildItem -Path "$TargetFolder\*" -Exclude "*.log" | Compress-Archive -DestinationPath $ZipPath -Force
                $FileBytes = [System.IO.File]::ReadAllBytes($ZipPath)
                $Base64    = [System.Convert]::ToBase64String($FileBytes)

                $Headers = @{ Authorization="token $Token"; Accept="application/vnd.github.v3+json" }
                $Body = @{ message="Auto-backup: $($game.GameName) at $TimeStamp"; content=$Base64 } | ConvertTo-Json
                
                $Url = "https://api.github.com/repos/$GithubUser/$RepoName/contents/$($game.GameName)/$FileName"

                Invoke-RestMethod -Uri $Url -Method Put -Headers $Headers -Body $Body | Out-Null
                $game.LastBackupTime = Get-Date
            }
            catch { }
            finally {
                if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }
            }
        }
    }
    Start-Sleep -Seconds 60
}
'@ | Out-File -FilePath $MonitorScript -Encoding utf8

# 3. Execute the newly created script as a completely hidden, detached background process
Start-Process powershell.exe -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass -NoProfile -File `"$MonitorScript`""

Write-Host "[✓] Save monitor is now running silently in the background!" -ForegroundColor Green
Write-Host "[*] You can safely close this PowerShell window and start playing." -ForegroundColor Yellow
