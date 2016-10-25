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

$UserPrograms    = "${env:LOCALAPPDATA}\Programs"
$DiffUtilsFolder = "$UserPrograms\GNU\DiffUtils\bin"
$userVimFolder   = "$UserPrograms\vim"
$systemVimFolder = "${env:ProgramFiles}\vim"
$PackerFolder    = "$UserPrograms\HashiCorp\Packer"
$fawsFolder      = "$UserPrograms\Rackspace\FAWS"
$nmapFolder      = "${env:ProgramFiles(x86)}\Nmap"

If (Test-Path $DiffUtilsFolder)
{
    $env:PATH = "$env:PATH;$DiffUtilsFolder"
}

If (Test-Path $PackerFolder)
{
    $env:PATH = "$env:PATH;$PackerFolder"
}

If (Test-Path $fawsFolder)
{
    $env:PATH = "$env:PATH;$fawsFolder"
}

If (Test-Path $nmapFolder)
{
    $env:PATH = "$env:PATH;$nmapFolder"
}

# Set $env:PATH

# Add vim to the path, preferring the user folder
$vimFolder = ($(get-item -Path $userVimFolder -ErrorAction Silentlycontinue),$(Get-Item $systemVimFolder -ErrorAction Silentlycontinue),"notfound" -ne $null)[0]

If (test-path $vimFolder)
{
    # Get the Vim Directory
    $vimBinPath =
        Get-ChildItem -Path "$vimFolder\vim*\vim.exe" `
        | Select-Object Directory

    "Vim was found at '$($vimBinPath.Directory)'. Adding to Path."

    $env:PATH = "${Env:PATH};$($vimBinPath.Directory)"
}
Else
{
    Write-Warning 'Vim was not found. It will not be added to Path'
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
. "$PowerShellProfileFolder\Modules\Posh-Git\profile.example.ps1"

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
