
$userprofile = $env:USERPROFILE

If ($env:HOMESHARE) {

    # Set and force overwrite of the $HOME variable
    Set-Variable -Name HOME -Value $env:HOMESHARE -Force

    # Set the "~" shortcut value for the FileSystem provider
    (get-psprovider 'FileSystem').Home = $env:HOMESHARE
}

# Load posh-git example profile
. "$userprofile\Documents\WindowsPowerShell\profile.posh-git.ps1"

# Load "Stash" module.
import-module PSStash

# Disable List Truncation.
$FormatEnumerationLimit =-1
