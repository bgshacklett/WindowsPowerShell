
$userprofile = $env:USERPROFILE


# Load posh-git example profile
. "$userprofile\Documents\WindowsPowerShell\profile.posh-git.ps1"

# Load "Stash" module.
import-module PSStash

# Disable List Truncation.
$FormatEnumerationLimit =-1
