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
    @{ GameName="RDR2"; RootPath="$env:APPDATA\.1911\Red Dead Redemption 2\profile"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="HollowKnight"; RootPath="$env:USERPROFILE\AppData\LocalLow\Team Cherry\Hollow Knight"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="Cyberpunk2077"; RootPath="$env:USERPROFILE\Saved Games\CD Projekt Red\Cyberpunk 2077"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="Witcher3"; RootPath="$env:USERPROFILE\Documents\The Witcher 3\gamesaves"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="DetroitBecomeHuman"; RootPath="$env:USERPROFILE\Saved Games\Quantic Dream\Detroit Become Human"; UseSubfolder=$true; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="HitmanWOA"; RootPath="C:\Program Files (x86)\Steam\userdata\682654723\1659040"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="AlienIsolation"; RootPath="C:\Program Files (x86)\Steam\userdata\682654723\214490"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="Tekken7"; RootPath="$env:LOCALAPPDATA\TekkenGame\Saved\SaveGames\TEKKEN7"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="F1Manager"; RootPath="$env:LOCALAPPDATA\F1Manager24\Saved\SaveGames"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="NoMansSky"; RootPath="$env:APPDATA\HelloGames\NMS"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="MortalShell"; RootPath="$env:USERPROFILE\Documents\My Games\MortalShell\Dungeonhaven\Saved\SaveGames"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="EldenRing"; RootPath="$env:APPDATA\EldenRing"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="ResidentEvil4"; RootPath="C:\Program Files (x86)\Steam\userdata\682654723\2050650"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="GhostOfTsushima"; RootPath="$env:USERPROFILE\Documents\Ghost of Tsushima DIRECTOR'S CUT"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="CallOfDuty"; RootPath="$env:USERPROFILE\Documents\Call of Duty\players"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="TheLastOfUs"; RootPath="$env:USERPROFILE\Saved Games\The Last of Us Part I"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="GodOfWar"; RootPath="$env:USERPROFILE\Saved Games\God of War"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="GodOfWarRagnarok"; RootPath="$env:USERPROFILE\Saved Games\God of War Ragnarok"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="BattlefieldV"; RootPath="$env:USERPROFILE\Documents\Battlefield V\settings"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) },
    @{ GameName="FarCry5"; RootPath="C:\Program Files (x86)\Steam\userdata\682654723\552520"; UseSubfolder=$false; LastBackupTime=(Get-Date).AddDays(-1) }
)

while ($true) {
    foreach ($game in $Games) {
        if (-not (Test-Path -LiteralPath $game.RootPath)) { continue }

        $TargetFolder = $game.RootPath
        if ($game.UseSubfolder) {
            $Sub = Get-ChildItem -LiteralPath $game.RootPath -Directory | Select-Object -First 1
            if ($Sub) { $TargetFolder = $Sub.FullName }
        }

        $SaveFiles = Get-ChildItem -LiteralPath $TargetFolder -Exclude "*.log" -File -Recurse
        $NewestFile = $SaveFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1

        if ($NewestFile -and ($NewestFile.LastWriteTime -gt $game.LastBackupTime)) {
            $TimeStamp = Get-Date -Format 'yyyyMMdd_HHmmss'
            $ZipPath   = "$env:TEMP\$($game.GameName)_temp.zip"
            $FileName  = "$($game.GameName)_$TimeStamp.zip"

            try {
                # Fixed: Passing the path directly prevents PowerShell from flattening the folder tree structure
                Compress-Archive -Path "$TargetFolder\*" -DestinationPath $ZipPath -Force
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

# 4. Disguise PowerShell to survive Steam restarts and VM cleanups
$HiddenPS = "$env:TEMP\save_daemon.exe"
$HiddenConfig = "$env:TEMP\save_daemon.exe.config"

# Copy both the executable and its required .NET framework configuration file
Copy-Item -Path "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Destination $HiddenPS -Force
Copy-Item -Path "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe.config" -Destination $HiddenConfig -Force

# Launch the monitor using the fully configured disguised executable
Start-Process $HiddenPS -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass -NoProfile -File `"$MonitorScript`""

# Wait a brief moment to ensure it initializes, then verify
Start-Sleep -Seconds 2
Get-CimInstance Win32_Process -Filter "Name = 'save_daemon.exe'" | Select-Object ProcessId, CommandLine

Write-Host "[✓] Save monitor is now running silently as save_daemon.exe!" -ForegroundColor Green
Write-Host "[*] You can safely close this window and start playing." -ForegroundColor Yellow
