
$userprofile = $env:USERPROFILE


# Load posh-git example profile
. "$userprofile\Documents\WindowsPowerShell\posh-git\profile.example.ps1"

# Load "Stash" module.
import-module Stash

# Disable List Truncation.
$FormatEnumerationLimit =-1
