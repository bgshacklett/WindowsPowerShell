# Load posh-git example profile
. "$HOME\My Documents\WindowsPowerShell\posh-git\profile.example.ps1"

# Load posh-hg example profile
. "$HOME\My Documents\WindowsPowerShell\posh-hg\profile.example.ps1"

# Load "Stash" module.
import-module Stash

# Disable List Truncation.
$FormatEnumerationLimit =-1
