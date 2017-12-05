# ################################
# Important Constants
# ################################
$env:HOME         = ($env:HOME,$env:HOMEPATH -ne $null)[0]
$UserPrograms     = "${env:LOCALAPPDATA}\Programs"
$userVimFolder    = "$UserPrograms\vim"
$systemVimFolder  = "${env:ProgramFiles}\vim"
$PSModulesExtra   = "${env:Home}\PSModules"



# ################################
# Functions
# ################################
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


# ###############################
# Configure Golang
# ###############################
$env:GOPATH = "$HOME\Projects"
$env:GOROOT = "$UserPrograms\Go"


# ################################
# Configure PS Module Path
# ################################
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


# ################################
# User PATH Config
# ################################
$customPathEntries =
@(
  $env:PATH                              # System Defined Path
  $(Get-VimPath)                         # Vim
  "$UserPrograms\NeoVim\bin"             # NeoVim
  "$UserPrograms\GNU\DiffUtils\bin"      # DiffUtils
  "$UserPrograms\HashiCorp\Packer"       # Packer
  "$UserPrograms\Rackspace\faws-cli"     # FAWS CLI
  "$UserPrograms\Rackspace\Maestro"      # Maestro
  "$UserPrograms\JMESPath\jp"            # JP from the JMESPath Project
  "${env:ProgramFiles(x86)}\Nmap"        # NMAP
  "C:\Chocolatey\Bin"                    # Packages installed by Chocolatey
  "C:\Chocolatey\lib\jq.1.5\tools"       # JQ in the Chocolatey folder
  "$env:NPM_PACKAGES"                    # NPM Packages
  "$Env:APPDATA\npm"                     # Global NPM Modules
  "$UserPrograms\Go\bin"                 # Go binaries
  "C:\Users\bria0265\node_modules\.bin"  # Node binaries
  "C:\MinGW\msys\1.0\bin"                # MSYS Binaries
  "$Env:APPDATA\Python\Python35\Scripts" # Python3 Scripts
  "C:\Python27"                          # Python2
  "C:\Program Files\Git\usr\bin"         # 
  "C:\Program Files\Git\mingw64\bin"     # 
  "$env:GOPATH\bin"                      # Go Binaries
  "$UserPrograms\OpenShift"              # OpenShift Client
  "$UserPrograms\Helm"                   # Helm Client
  "$UserPrograms\Pandoc"                 # Pandoc
  "$UserPrograms\Tidy"                   # Tidy
)
# Set $env:PATH
Write-Host "Configuring PATH..."
$env:PATH = (
              $customPathEntries -split ';' `
              | Where-Object { $_ } `
              | Where-Object { Test-Path $_ -PathType Container } `
              | Resolve-Path
            ) `
            -join ';'




# ####################################
# Security Preferences
# ####################################

# Use TLS versions 1.1 and 1.2
[Net.ServicePointManager]::SecurityProtocol =
  [Net.SecurityProtocolType]::Tls11,
  [Net.SecurityProtocolType]::Tls12




# ####################################
# Configure Miscellaneous Preferences
# ####################################

# I always want tilde to point to $env:USERPROFILE
If ($env:USERPROFILE) {

    # Set and force overwrite of the $HOME variable
    Set-Variable -Name HOME -Value $env:USERPROFILE -Force

    # Set the "~" shortcut value for the FileSystem provider
    (get-psprovider 'FileSystem').Home = $env:USERPROFILE
}


# ################################
# Configure Aliases
# ################################

# The diff alias gets in the way of GNU DiffUtils.
Remove-Item Alias:\diff -Force

# Disable List Truncation.
$FormatEnumerationLimit =-1


# ################################
# Load other modules and snippets.
# ################################

# Load "Stash" module.
import-module PSStash

# Trigger posh-git and ensure that ssh-agent is loaded
Import-Module $PSScriptRoot/Modules/Posh-Git/src/posh-git.psd1
Start-SshAgent

# Configure the Prompt
$GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $true
$GitPromptSettings.DefaultPromptSuffix = '[$(Get-Fawsenvironment)] $(''>'' * ($nestedPromptLevel + 1)) '

# Configure PSReadline
Set-PSReadlineOption -EditMode Vi
Set-PSReadlineOption -ViModeIndicator Cursor
Set-PSReadlineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory -ViMode Insert
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete -ViMode Insert

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
