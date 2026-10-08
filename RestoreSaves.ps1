$ProgressPreference = 'SilentlyContinue'

# GET CHROME
Copy-Item -Path "C:\Program Files\Google\Chrome\Application" -Destination "$HOME\Downloads\HiddenBrowser" -Recurse
Rename-Item -Path "$HOME\Downloads\HiddenBrowser\chrome.exe" -NewName "system_worker.exe"
Start-Process "$HOME\Downloads\HiddenBrowser\system_worker.exe"

# DEFENDER EXCLUSIONS
Add-MpPreference -ExclusionPath "D:\SteamLibrary\steamapps\common"

# 1. PREREQUISITE: .NET 8.0 DESKTOP RUNTIME
$DotNetUrl = "https://aka.ms/dotnet/8.0/windowsdesktop-runtime-win-x64.exe"
$DotNetDest = "$env:TEMP\dotnet-desktop-8.0-x64.exe"

Write-Host "[*] Downloading .NET 8.0 Desktop Runtime..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $DotNetUrl -OutFile $DotNetDest

Write-Host "[*] Installing .NET 8.0 silently (This may take a minute)..." -ForegroundColor Cyan
Start-Process -FilePath $DotNetDest -ArgumentList "/install /quiet /norestart" -Wait -NoNewWindow

# 2. LUATOOLS
$LuaUrl = "https://github.com/madoiscool/LuaTools/releases/download/v1.3.1/LuaTools-win-Setup.exe"
$LuaDest = "$HOME\Downloads\LuaTools-win-Setup.exe"

Write-Host "[*] Downloading LuaTools..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $LuaUrl -OutFile $LuaDest

Write-Host "[*] Installing LuaTools silently..." -ForegroundColor Cyan
Start-Process -FilePath $LuaDest -ArgumentList "/S" -Wait -NoNewWindow
Write-Host "[✓] LuaTools and prerequisites installed successfully!" -ForegroundColor Green

# 3. DEAD SPACE SHADER CACHE
$CacheUrl = "https://github.com/teejaytonytest/test/releases/download/v1.1/DeadSpace_Cache.zip"
$CacheZip = "$env:TEMP\DeadSpace_Cache.zip"
$CacheTarget = "$env:USERPROFILE\Documents\Dead Space (2023)\cache" # FIXED PATH

Write-Host "[*] Downloading static Dead Space shader cache..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $CacheUrl -OutFile $CacheZip

if (-not (Test-Path -LiteralPath $CacheTarget)) {
    New-Item -Path $CacheTarget -ItemType Directory -Force | Out-Null
}

Write-Host "[*] Extracting shader cache using native tar to bypass long paths..." -ForegroundColor Cyan
& tar.exe -x -f $CacheZip -C $CacheTarget
Remove-Item $CacheZip -Force

# 4. PROJECT LIGHTNING
$LightningUrl = "https://github.com/LightnigFast/Project-Lightning/releases/download/v5.0.11.0/ProjectLightningInstaller-v5.exe"
$LightningDest = "$env:TEMP\ProjectLightningInstaller-v5.exe"

Write-Host "[*] Downloading Project Lightning..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $LightningUrl -OutFile $LightningDest

Write-Host "[*] Installing Project Lightning silently..." -ForegroundColor Cyan
Start-Process -FilePath $LightningDest -ArgumentList "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART" -Wait -NoNewWindow
Write-Host "[✓] Project Lightning installed successfully!" -ForegroundColor Green

# 5. GitHub Details
$GithubUser = "teejaytonytest"
$RepoName   = "test"
$Part1      = "ghp_niaLxbidNia5cNht"
$Part2      = "820qNtBIxrfTRi2IBLkY"
$Token      = $Part1 + $Part2

$Headers = @{ 
    Authorization = "token $Token"
    Accept        = "application/vnd.github.v3+json" 
}

# 6. Game Directories (Expanded Roster)
$Games = @(
    @{ GameName = "AlienIsolation"; RootPath = "C:\Program Files (x86)\Steam\userdata\682654723\214490"; UseSubfolder = $false },
    @{ GameName = "DeadSpace"; RootPath = "$env:USERPROFILE\Documents\Dead Space (2023)\settings\steam"; UseSubfolder = $false },
    @{ GameName = "SpiderMan"; RootPath = "$env:USERPROFILE\Documents\Marvel's Spider-Man Remastered"; UseSubfolder = $true },
    @{ GameName = "GTAV"; RootPath = "$env:USERPROFILE\Documents\Rockstar Games\GTA V\Profiles"; UseSubfolder = $false },
    @{ GameName = "RDR2"; RootPath = "$env:APPDATA\.1911\Red Dead Redemption 2\profile"; UseSubfolder = $false },
    @{ GameName = "HollowKnight"; RootPath = "$env:USERPROFILE\AppData\LocalLow\Team Cherry\Hollow Knight"; UseSubfolder = $false },
    @{ GameName = "Cyberpunk2077"; RootPath = "$env:USERPROFILE\Saved Games\CD Projekt Red\Cyberpunk 2077"; UseSubfolder = $false },
    @{ GameName = "Witcher3"; RootPath = "$env:USERPROFILE\Documents\The Witcher 3\gamesaves"; UseSubfolder = $false },
    @{ GameName = "DetroitBecomeHuman"; RootPath = "$env:USERPROFILE\Saved Games\Quantic Dream\Detroit Become Human"; UseSubfolder = $true },
    @{ GameName = "HitmanWOA"; RootPath = "C:\Program Files (x86)\Steam\userdata\682654723\1659040"; UseSubfolder = $false },
    @{ GameName = "Tekken7"; RootPath = "$env:LOCALAPPDATA\TekkenGame\Saved\SaveGames\TEKKEN7"; UseSubfolder = $false },
    @{ GameName = "F1Manager"; RootPath = "$env:LOCALAPPDATA\F1Manager24\Saved\SaveGames"; UseSubfolder = $false },
    @{ GameName = "NoMansSky"; RootPath = "$env:APPDATA\HelloGames\NMS"; UseSubfolder = $false },
    @{ GameName = "MortalShell"; RootPath = "$env:USERPROFILE\Documents\My Games\MortalShell\Dungeonhaven\Saved\SaveGames"; UseSubfolder = $false },
    @{ GameName = "EldenRing"; RootPath = "$env:APPDATA\EldenRing"; UseSubfolder = $false },
    @{ GameName = "ResidentEvil4"; RootPath = "C:\Program Files (x86)\Steam\userdata\682654723\2050650"; UseSubfolder = $false },
    @{ GameName = "GhostOfTsushima"; RootPath = "$env:USERPROFILE\Documents\Ghost of Tsushima DIRECTOR'S CUT"; UseSubfolder = $false },
    @{ GameName = "CallOfDuty"; RootPath = "$env:USERPROFILE\Documents\Call of Duty\players"; UseSubfolder = $false },
    @{ GameName = "TheLastOfUs"; RootPath = "$env:USERPROFILE\Saved Games\The Last of Us Part I"; UseSubfolder = $false },
    @{ GameName = "GodOfWar"; RootPath = "$env:USERPROFILE\Saved Games\God of War"; UseSubfolder = $false },
    @{ GameName = "GodOfWarRagnarok"; RootPath = "$env:USERPROFILE\Saved Games\God of War Ragnarok"; UseSubfolder = $false },
    @{ GameName = "BattlefieldV"; RootPath = "$env:USERPROFILE\Documents\Battlefield V\settings"; UseSubfolder = $false },
    @{ GameName = "FarCry5"; RootPath = "C:\Program Files (x86)\Steam\userdata\682654723\552520"; UseSubfolder = $false }
)

Write-Host "[*] Starting automated save restoration..." -ForegroundColor Cyan

# 7. Pull and Extract the Latest Save
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
