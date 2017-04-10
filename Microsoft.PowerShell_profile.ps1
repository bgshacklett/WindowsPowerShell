#
# Important Constants
#
$UserPrograms     = "${env:LOCALAPPDATA}\Programs"
$userVimFolder    = "$UserPrograms\vim"
$systemVimFolder  = "${env:ProgramFiles}\vim"
$PSModulesExtra   = "${env:Home}\PSModules"



#
# Functions
#
function Get-VimPath
{
  # Select a Vim folder, preferring the user's Programs folder
  $vimFolder = (
    $(Get-Item -Path $userVimFolder -ErrorAction Silentlycontinue),
    $(Get-Item -Path $systemVimFolder -ErrorAction Silentlycontinue),
    "notfound" -ne $null
  )[0]

  # Get the exact path to the vim binary
  If (Test-Path $vimFolder)
  {
      # Get the Vim Directory
      Get-ChildItem -Path "$vimFolder\vim*\vim.exe" `
      | Select-Object -ExpandProperty Directory `
      | Select-Object -ExpandProperty FullName
  }
  Else
  {
      Write-Warning 'Vim was not found. It will not be added to Path'
  }
}


# Configure PS Module Path
If ( Test-Path $PSModulesExtra )
{
  $env:PSModulePath += ";$PSModulesExtra"
}

# Configure Node.js Paths
$env:NPM_PACKAGES = $env:HOME | Join-Path -ChildPath '.npm-packages'

$NodeModulesCustomPath = "${env:NPM_PACKAGES}" `
                         | Join-Path -ChildPath 'lib' `
                         | Join-Path -ChildPath 'node_modules'

$env:NODE_PATH = "${NodeModulesCustomPath}:${env:NODE_PATH}"


#
#
# User PATH Config
#
$customPathEntries =
@(
  $env:PATH                             # System Defined Path
  $(Get-VimPath)                        # Vim
  "$UserPrograms\GNU\DiffUtils\bin"     # DiffUtils
  "$UserPrograms\HashiCorp\Packer"      # Packer
  "$UserPrograms\Rackspace\FAWS"        # FAWS CLI
  "$UserPrograms\Rackspace\ffs"        # FAWS CLI
  "$UserPrograms\JMESPath\jp"           # JP from the JMESPath Project
  "${env:ProgramFiles(x86)}\Nmap"       # NMAP
  "C:\Chocolatey\Bin"                   # Packages installed by Chocolatey
  "$env:NPM_PACKAGES"                   # NPM Packages
  "$Env:APPDATA\npm"                    # Global NPM Modules
  "$Env:HOME\go\bin"                    # Go binaries
  "C:\Users\bria0265\node_modules\.bin" # Node binaries
  "C:\MinGW\msys\1.0\bin"               # MSYS Binaries
)
#
# Set $env:PATH
Write-Host "Configuring PATH..."
$env:PATH = $customPathEntries -join ';'






# I always want tilde to point to $env:USERPROFILE
If ($env:USERPROFILE) {

    # Set and force overwrite of the $HOME variable
    Set-Variable -Name HOME -Value $env:USERPROFILE -Force

    # Set the "~" shortcut value for the FileSystem provider
    (get-psprovider 'FileSystem').Home = $env:USERPROFILE
}


#
# Configure Aliases
#

# The diff alias gets in the way of GNU DiffUtils.
Remove-Item Alias:\diff -Force

# Disable List Truncation.
$FormatEnumerationLimit =-1


#
# Load other modules and snippets.
#

# Load posh-git example profile
. "$PSScriptRoot\Modules\Posh-Git\profile.example.ps1"

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

# Configure Golang
$env:GOPATH = "$HOME\go"

# Configure Virtualenv
$env:WORKON_HOME = '~/virtualenvs'



