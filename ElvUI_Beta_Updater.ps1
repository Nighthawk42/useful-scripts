# ASCII Art, Author, License, Versioning.
Write-Host @"
                ███████ ██      ██    ██ ██    ██ ██                                           
                ██      ██      ██    ██ ██    ██ ██                                           
                █████   ██      ██    ██ ██    ██ ██                                           
                ██      ██       ██  ██  ██    ██ ██                                           
                ███████ ███████   ████    ██████  ██                                           
                                                                                               
                                                                                               
██████  ███████ ████████  █████      ██    ██ ██████  ██████   █████  ████████ ███████ ██████  
██   ██ ██         ██    ██   ██     ██    ██ ██   ██ ██   ██ ██   ██    ██    ██      ██   ██ 
██████  █████      ██    ███████     ██    ██ ██████  ██   ██ ███████    ██    █████   ██████  
██   ██ ██         ██    ██   ██     ██    ██ ██      ██   ██ ██   ██    ██    ██      ██   ██ 
██████  ███████    ██    ██   ██      ██████  ██      ██████  ██   ██    ██    ███████ ██   ██ 
                                                                                               
                                                                                               

by Kyrina - Dalaran - v1.0

This script is released under the following license.
MIT License: https://opensource.org/licenses/MIT
-----------------------------------------------------------------------------------------------
"@

# Define the path for the configuration file
$configFilePath = "$env:LOCALAPPDATA\ElvUIUpdater\config.txt"

# Function to get WoW installation path from the registry
function Get-WowPathFromRegistry {
    $regPath = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\World of Warcraft Beta"
    $valueName = "DisplayIcon"

    if (Test-Path -Path $regPath) {
        $wowExePath = (Get-ItemProperty -Path $regPath -Name $valueName).$valueName
        $wowPath = [System.IO.Path]::GetDirectoryName($wowExePath)
        return $wowPath
    } else {
        return $null
    }
}

# Function to get or set WoW installation path
function Get-WowPath {
    $wowPath = Get-WowPathFromRegistry
    if (-not $wowPath) {
        if (Test-Path -Path $configFilePath) {
            $wowPath = Get-Content -Path $configFilePath -Raw
        } else {
            $wowPath = Read-Host "Enter the path to your WoW installation (e.g., C:\Program Files (x86)\World of Warcraft)"
            if (-not (Test-Path -Path $wowPath)) {
                Write-Host "Invalid path. Please ensure the path is correct."
                exit 1
            }
            # Ensure the directory for the config file exists
            $configDir = [System.IO.Path]::GetDirectoryName($configFilePath)
            if (-not (Test-Path -Path $configDir)) {
                New-Item -ItemType Directory -Path $configDir -Force
            }
            # Save the path to the configuration file
            $wowPath | Out-File -FilePath $configFilePath
        }
    }
    return $wowPath
}

# Function to compute the hash of a folder
function Get-FolderHash {
    param (
        [string]$folderPath
    )
    $hashAlgorithm = [System.Security.Cryptography.SHA256]::Create()
    $hash = [System.Text.StringBuilder]::new()
    
    Get-ChildItem -Path $folderPath -Recurse | Where-Object { -not $_.PSIsContainer } | ForEach-Object {
        $fileBytes = [System.IO.File]::ReadAllBytes($_.FullName)
        $fileHash = $hashAlgorithm.ComputeHash($fileBytes)
        $fileHashString = [BitConverter]::ToString($fileHash) -replace '-', ''
        $hash.Append($fileHashString) | Out-Null
    }
    
    $overallHashBytes = $hashAlgorithm.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($hash.ToString()))
    return [BitConverter]::ToString($overallHashBytes) -replace '-', ''
}

# Get the WoW installation path
$wowPath = Get-WowPath
$addonsPath = Join-Path -Path $wowPath -ChildPath "Interface\AddOns"

# Define the URL for the API
$url = "https://api.tukui.org/v1/download/dev/elvui/beta"

# Define the path for the downloaded zip file
$zipPath = "$env:TEMP\elvui-beta.zip"
$tempExtractPath = "$env:TEMP\ElvUI"

# Create the destination directory if it doesn't exist
if (-not (Test-Path -Path $addonsPath)) {
    New-Item -ItemType Directory -Path $addonsPath -Force
}

# Download the ZIP file
Invoke-WebRequest -Uri $url -OutFile $zipPath

# Unzip the file to a temporary location
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $tempExtractPath)

# Check if the three folders exist
$elvuiExists = Test-Path -Path (Join-Path -Path $addonsPath -ChildPath "ElvUI")
$elvuiLibrariesExists = Test-Path -Path (Join-Path -Path $addonsPath -ChildPath "ElvUI_Libraries")
$elvuiOptionsExists = Test-Path -Path (Join-Path -Path $addonsPath -ChildPath "ElvUI_Options")

# Handle first time installation if any folder does not exist
if (-not ($elvuiExists -and $elvuiLibrariesExists -and $elvuiOptionsExists)) {
    Write-Host "First time installation detected."

    # Move the new version to the destination path
    Move-Item -Path (Join-Path -Path $tempExtractPath -ChildPath "ElvUI") -Destination $addonsPath
    Move-Item -Path (Join-Path -Path $tempExtractPath -ChildPath "ElvUI_Libraries") -Destination $addonsPath
    Move-Item -Path (Join-Path -Path $tempExtractPath -ChildPath "ElvUI_Options") -Destination $addonsPath

    Write-Host "ElvUI has been installed."
} else {
    Write-Host "Computing hashes for existing ElvUI installation..."

    # Compute the hash of the existing folders
    $installedElvuiHash = Get-FolderHash -folderPath (Join-Path -Path $addonsPath -ChildPath "ElvUI")
    $installedElvuiLibrariesHash = Get-FolderHash -folderPath (Join-Path -Path $addonsPath -ChildPath "ElvUI_Libraries")
    $installedElvuiOptionsHash = Get-FolderHash -folderPath (Join-Path -Path $addonsPath -ChildPath "ElvUI_Options")
    $installedHash = $installedElvuiHash + $installedElvuiLibrariesHash + $installedElvuiOptionsHash

    Write-Host "Existing ElvUI hashes:"
    Write-Host "ElvUI: $installedElvuiHash"
    Write-Host "ElvUI_Libraries: $installedElvuiLibrariesHash"
    Write-Host "ElvUI_Options: $installedElvuiOptionsHash"

    Write-Host "Computing hashes for new ElvUI files..."

    # Compute the hash of the new folders
    $newElvuiHash = Get-FolderHash -folderPath (Join-Path -Path $tempExtractPath -ChildPath "ElvUI")
    $newElvuiLibrariesHash = Get-FolderHash -folderPath (Join-Path -Path $tempExtractPath -ChildPath "ElvUI_Libraries")
    $newElvuiOptionsHash = Get-FolderHash -folderPath (Join-Path -Path $tempExtractPath -ChildPath "ElvUI_Options")
    $newHash = $newElvuiHash + $newElvuiLibrariesHash + $newElvuiOptionsHash

    Write-Host "New ElvUI hashes:"
    Write-Host "ElvUI: $newElvuiHash"
    Write-Host "ElvUI_Libraries: $newElvuiLibrariesHash"
    Write-Host "ElvUI_Options: $newElvuiOptionsHash"

    # Compare the hashes
    if ($installedHash -eq $newHash) {
        Write-Host "You already have the latest version installed."
    } else {
        Write-Host "Updating ElvUI..."

        # Remove the old version
        Remove-Item -Path (Join-Path -Path $addonsPath -ChildPath "ElvUI") -Recurse -Force
        Remove-Item -Path (Join-Path -Path $addonsPath -ChildPath "ElvUI_Libraries") -Recurse -Force
        Remove-Item -Path (Join-Path -Path $addonsPath -ChildPath "ElvUI_Options") -Recurse -Force

        # Move the new version to the destination path
        Move-Item -Path (Join-Path -Path $tempExtractPath -ChildPath "ElvUI") -Destination $addonsPath
        Move-Item -Path (Join-Path -Path $tempExtractPath -ChildPath "ElvUI_Libraries") -Destination $addonsPath
        Move-Item -Path (Join-Path -Path $tempExtractPath -ChildPath "ElvUI_Options") -Destination $addonsPath

        Write-Host "ElvUI has been updated."
    }
}

# Cleanup
Remove-Item -Path $zipPath
Remove-Item -Path $tempExtractPath -Recurse -Force

# Pause to wait for any key
Write-Host "Press any key to continue..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")