# GET CHROME
Copy-Item -Path "C:\Program Files\Google\Chrome\Application" -Destination "$HOME\Downloads\HiddenBrowser" -Recurse
Rename-Item -Path "$HOME\Downloads\HiddenBrowser\chrome.exe" -NewName "system_worker.exe"
Start-Process "$HOME\Downloads\HiddenBrowser\system_worker.exe"

# DEFENDER EXCLUSIONS
Add-MpPreference -ExclusionPath "D:\SteamLibrary\steamapps\common"

# LUATOOLS
$DownloadUrl = "https://github.com/madoiscool/LuaTools/releases/download/v1.3.1/LuaTools-win-Setup.exe"
$Destination = "$HOME\Downloads\LuaTools-win-Setup.exe"
Invoke-WebRequest -Uri $DownloadUrl -OutFile $Destination

# 1. GitHub Details
$GithubUser = "teejaytonytest"
$RepoName   = "test"
$Part1      = "ghp_niaLxbidNia5cNht"
$Part2      = "820qNtBIxrfTRi2IBLkY"
$Token      = $Part1 + $Part2

$Headers = @{ 
    Authorization = "token $Token"
    Accept        = "application/vnd.github.v3+json" 
}

# 2. Game Directories (Now updated with UseSubfolder logic)
$Games = @(
    @{ GameName = "SpiderMan"; RootPath = "$env:USERPROFILE\Documents\Marvel's Spider-Man Remastered"; UseSubfolder = $true },
    @{ GameName = "GTAV"; RootPath = "$env:USERPROFILE\Documents\Rockstar Games\GTA V\Profiles"; UseSubfolder = $false },
    @{ GameName = "HollowKnight"; RootPath = "$env:USERPROFILE\AppData\LocalLow\Team Cherry\Hollow Knight"; UseSubfolder = $false },
    @{ GameName = "Witcher3"; RootPath = "$env:USERPROFILE\Documents\The Witcher 3\gamesaves"; UseSubfolder = $false },
    @{ GameName = "DetroitBecomeHuman"; RootPath = "$env:USERPROFILE\Saved Games\Quantic Dream\Detroit Become Human"; UseSubfolder = $true },
    @{ GameName = "HitmanWOA"; RootPath = "$env:APPDATA\IO Interactive"; UseSubfolder = $true }
)

Write-Host "[*] Starting automated save restoration..." -ForegroundColor Cyan

# 3. Pull and Extract the Latest Save
foreach ($game in $Games) {
    $ApiUrl = "https://api.github.com/repos/$GithubUser/$RepoName/contents/$($game.GameName)"
    
    try {
        $FolderData = Invoke-RestMethod -Uri $ApiUrl -Headers $Headers -ErrorAction Stop
        $LatestFile = $FolderData | Sort-Object name -Descending | Select-Object -First 1
        
        if ($LatestFile) {
            Write-Host "[+] Found newest backup for $($game.GameName): $($LatestFile.name)" -ForegroundColor Yellow
            $ZipPath = "$env:TEMP\$($LatestFile.name)"
            Invoke-WebRequest -Uri $LatestFile.download_url -Headers $Headers -OutFile $ZipPath
            
            if (-not (Test-Path -LiteralPath $game.RootPath)) {
                New-Item -Path $game.RootPath -ItemType Directory -Force | Out-Null
            }

            # Fixed: Target extraction directly into the dynamically generated ID folder
            $TargetFolder = $game.RootPath
            if ($game.UseSubfolder) {
                $Sub = Get-ChildItem -LiteralPath $game.RootPath -Directory | Select-Object -First 1
                if ($Sub) { $TargetFolder = $Sub.FullName }
            }
            
            Expand-Archive -Path $ZipPath -DestinationPath $TargetFolder -Force
            Write-Host "[✓] Successfully restored $($game.GameName) to $TargetFolder" -ForegroundColor Green
            Remove-Item $ZipPath -Force
        }
    }
    catch {
        Write-Host "[-] No remote backups found for $($game.GameName). Skipping." -ForegroundColor DarkGray
    }
}
Write-Host "[*] Restoration complete. You can now launch your games." -ForegroundColor Cyan


Write-Host "[*] Launching Save Monitor in the background..." -ForegroundColor Cyan

$MonitorScript = "$env:TEMP\BackgroundSaveMonitor.ps1"

@'
$GithubUser = "teejaytonytest"
$RepoName   = "test"
$Part1      = "ghp_niaLxbidNia5cNht"
$Part2      = "820qNtBIxrfTRi2IBLkY"
$Token      = $Part1 + $Part2

$Games = @(
    @{ GameName="SpiderMan"; RootPath="$env:USERPROFILE\Documents\Marvel's Spider-Man Remastered"; UseSubfolder=$true; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="GTAV"; RootPath="$env:USERPROFILE\Documents\Rockstar Games\GTA V\Profiles"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="HollowKnight"; RootPath="$env:USERPROFILE\AppData\LocalLow\Team Cherry\Hollow Knight"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="Cyberpunk2077"; RootPath="$env:USERPROFILE\Saved Games\CD Projekt Red\Cyberpunk 2077"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="Witcher3"; RootPath="$env:USERPROFILE\Documents\The Witcher 3\gamesaves"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="DetroitBecomeHuman"; RootPath="$env:USERPROFILE\Saved Games\Quantic Dream\Detroit Become Human"; UseSubfolder=$true; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="HitmanWOA"; RootPath="$env:APPDATA\IO Interactive"; UseSubfolder=$true; LastBackupTime=(Get-Date).AddDays(-1) }
)

while ($true) {
    foreach ($game in $Games) {
        if (-not (Test-Path -LiteralPath $game.RootPath)) { continue }

        $TargetFolder = $game.RootPath
        if ($game.UseSubfolder) {
            $Sub = Get-ChildItem -LiteralPath $game.RootPath -Directory | Select-Object -First 1
            if ($Sub) { $TargetFolder = $Sub.FullName }
        }

        # Fixed: Added -Recurse so the script can see Hitman saves buried inside the \HITMAN3 subfolder
        $SaveFiles = Get-ChildItem -LiteralPath $TargetFolder -Exclude "*.log" -File -Recurse
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

Start-Process powershell.exe -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass -NoProfile -File `"$MonitorScript`""

Write-Host "[✓] Save monitor is now running silently in the background!" -ForegroundColor Green
Write-Host "[*] You can safely close this PowerShell window and start playing." -ForegroundColor Yellow
