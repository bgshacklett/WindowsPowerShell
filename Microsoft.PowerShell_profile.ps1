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

# The 'diff' alias is not analagous to any other diff command. Get rid of it.
Remove-Item Alias:\diff -Force

$UserPrograms = "${env:LOCALAPPDATA}\Programs"
$vimFolder = "$UserPrograms\vim"
$fawsFolder = "$UserPrograms\Rackspace\FAWS"

If (Test-Path $fawsFolder)
{
    $env:PATH = "$env:PATH;$fawsFolder"
}

# Set $env:PATH
If (test-path $vimFolder)
{
    # Get the Vim Directory
    $VimBinPath =
        Get-ChildItem -Path "$vimFolder\vim*\vim.exe" `
        | Select-Object Directory

    $env:PATH = "$($VimBinPath.Directory);${Env:PATH}"
}

If (Test-Path "$Env:APPDATA\npm")
{
    $npmPath = "$Env:APPDATA\npm"

    $env:PATH = "${Env:PATH};$npmPath"
}


If ($env:USERPROFILE) {

    # Set and force overwrite of the $HOME variable
    Set-Variable -Name HOME -Value $env:USERPROFILE -Force

    # Set the "~" shortcut value for the FileSystem provider
    (get-psprovider 'FileSystem').Home = $env:USERPROFILE
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
