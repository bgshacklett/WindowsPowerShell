$RegShellFolders = 'HKCU:\' `
                   | Join-Path -ChildPath 'Software' `
                   | Join-Path -ChildPath 'Microsoft' `
                   | Join-Path -ChildPath 'Windows' `
                   | Join-Path -ChildPath 'CurrentVersion' `
                   | Join-Path -ChildPath 'Explorer' `
                   | Join-Path -ChildPath 'User Shell Folders'

$DocumentsFolder = Get-ItemProperty $RegShellFolders `
                   | Select-Object -ExpandProperty Personal

$PowerShellProfileFolder = $DocumentsFolder `
                           | Join-Path -ChildPath 'WindowsPowerShell'

# Set $env:PATH
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


$userprofile = $env:USERPROFILE

If ($env:HOMESHARE) {

    # Set and force overwrite of the $HOME variable
    Set-Variable -Name HOME -Value $env:HOMESHARE -Force

    # Set the "~" shortcut value for the FileSystem provider
    (get-psprovider 'FileSystem').Home = $env:HOMESHARE
}

# Load posh-git example profile
. "$PowerShellProfileFolder\profile.posh-git.ps1"

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
