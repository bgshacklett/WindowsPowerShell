[CmdletBinding()]
param()

# Get the path to the current profile
$ProfilePath = $PROFILE | Split-Path -Parent

If (test-path "${Env:ProgramFiles(x86)}\vim")
{
    # Get the Vim Directory
    $VimPath =
        Get-ChildItem -Path 'C:\Program Files (x86)\Vim\vim*\vim.exe' `
        | Select-Object -ExpandProperty Directory

    $env:Path = "$VimPath;$Env:Path"
}

# Add NPM to path if it's not already there
If (Test-Path "$Env:APPDATA\npm")
{
    $npmPath = "$Env:APPDATA\npm"

    if ($env:Path | Select-String -Pattern "$npmPath" -SimpleMatch) {} else
    {
        $env:Path = "${Env:Path};$npmPath"
    }
}


If ($env:HOMESHARE) {

    # Set and force overwrite of the $HOME variable
    Set-Variable -Name HOME -Value $env:HOMESHARE -Force

    # Set the "~" shortcut value for the FileSystem provider
    (get-psprovider 'FileSystem').Home = $env:HOMESHARE
}

# Add C:\Chocolatey\bin to $env:Path
If ((Test-Path "Env:\ChocolateyPath") -and (Test-Path "$env:ChocolateyPath\bin") )
{
    $env:Path = "$env:Path;$env:ChocolateyPath\bin"
}


# Add ~\bin to $env:Path
$HomeBin = "$HOME\bin"
If (Test-Path $HomeBin)
{
    $env:Path = "$env:Path;$HomeBin"
}


# Load posh-git example profile
. "$ProfilePath\profile.posh-git.ps1"

# Load "Stash" module.
import-module PSStash

# Load PSReadline module.
try
{
    import-module PSReadline -ErrorAction Stop
    Set-PSReadlineKeyHandler -Key Tab -Function Complete
}
catch
{
    Write-Warning "Could not load PSReadline module."
}

# Disable List Truncation.
$FormatEnumerationLimit =-1
