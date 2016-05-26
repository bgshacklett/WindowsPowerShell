
# Get the path to the current profile
$ProfilePath = $PROFILE | Split-Path -Parent

# Set $env:PATH
$HomeBin = "${env:HOME\bin}"
If (Test-Path $HomeBin)
{
    $env:PATH = "${$env:PATH};$HomeBin"
}


If (test-path "${Env:ProgramFiles(x86)}\vim")
{
    # Get the Vim Directory
    $VimPath =
        Get-ChildItem -Path 'C:\Program Files (x86)\Vim\vim*\vim.exe' `
        | Select-Object Directory

    $env:PATH = "$($VimPath.Directory);${Env:PATH}"
}

If (Test-Path "$Env:APPDATA\npm")
{
    $npmPath = "$Env:APPDATA\npm"

    $env:PATH = "${Env:PATH};$npmPath"
}


If ($env:HOMESHARE) {

    # Set and force overwrite of the $HOME variable
    Set-Variable -Name HOME -Value $env:HOMESHARE -Force

    # Set the "~" shortcut value for the FileSystem provider
    (get-psprovider 'FileSystem').Home = $env:HOMESHARE
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
