
function Set-Clipboard 
{

<#

.SYNOPSIS

Sends the given input to the Windows clipboard.

.DESCRIPTION

The code in this function is exepted from the MIT license that
the rest of the repository is licensed under due to lack of
rights to relicense. 

From Windows PowerShell Cookbook
by Lee Holmes (http://www.leeholmes.com/guide)
ISBN-13: 978-1449320683
Publisher: O'Reilly

Modifications by Brian G. Shacklett <brian@digital-traffic.net>
Summary: Converted to Powershell Function.

.EXAMPLE

dir | Set-Clipboard
This example sends the view of a directory listing to the clipboard

.EXAMPLE

Set-Clipboard "Hello World"
This example sets the clipboard to the string, "Hello World".

#>

param(
    ## The input to send to the clipboard
    [Parameter(ValueFromPipeline = $true)]
    [object[]] $InputObject
)

begin
{
    Set-StrictMode -Version Latest
    $objectsToProcess = @()
}

process
{
    ## Collect everything sent to the script either through
    ## pipeline input, or direct input.
    $objectsToProcess += $inputObject
}

end
{
    ## Launch a new instance of PowerShell in STA mode.
    ## This lets us interact with the Windows clipboard.
    $objectsToProcess | PowerShell -NoProfile -STA -Command {
        Add-Type -Assembly PresentationCore

        ## Convert the input objects to a string representation
        $clipText = ($input | Out-String -Stream) -join "`r`n"

        ## And finally set the clipboard text
        [Windows.Clipboard]::SetText($clipText)
    }
}

}





function Get-BDERecoveryPassword
{
<#
.SYNOPSIS
    Retrieves the Bitlocker recovery password for a computer from Active Directory
.DESCRIPTION
  Retrieves the Bitlocker recovery password for a computer from Active Directory. Requires
  permission to the recovery information. Domain administrators have this permission by
  default.
.PARAMETER ComputerName
    The computer whose recovery password you wish to find
.PARAMETER RecoveryGUID
    The RecoveryGUID as shown on the Bitlocker Recovery screen. Only the first 8 characters
    are required.
.PARAMETER Credential
    Optional alternate credential of a user with access to BDE recovery information
    Can be an object of type [PSCredential] or a string containing a username
.PARAMETER All
  Retrieves all recovery passwords for a given computer. If omitted only the most recent
  password is returned. Cannot be used with -RecoveryGUID.

.EXAMPLE
	Get the most recent recovery password for a computer
    Get-BDERecoveryPassword -ComputerName SomeComputer
.EXAMPLE
	Same as above, but using an alternate credential
    Get-BDERecoveryPassword  -Computername SomeComputer -Credential domain\username
.EXAMPLE
	You can also use a credential previously saved in a variable
    $Cred = Get-Credential
    Get-BDERecoveryPassword -ComputerName SomeComputer -Credential $Cred
.EXAMPLE
	If you add the -All switch, it will return all the recoveries for that computer object's lifetime
	Get-BDERecoveryPassword -ComputerName SomeComputer -All
.EXAMPLE
	Using a Recovery ID instead of a computer name
    Get-BDERecoveryPassword -RecoveryGUID 2AE7951F-DE1D-489B-B033-C5FD33994064
.EXAMPLE
	Only the first 8 characters of the ID are required 
	Get-BDERecoveryPassword -RecoveryGUID 2AE7951F
.INPUTS
    [string]
    [Microsoft.ActiveDirectory.Management.ADComputer]
.OUTPUTS
    [BDERecoveryPassword]
.NOTES
    v1.1 1/8/2014
	v1.0 6/10/2014
    Author: Matt McNabb
    DISCLAIMER: This script is provided 'AS IS'. It has been tested for personal use, please 
    test in a lab environment before using in a production environment.

#Requires -Module ActiveDirectory
#Requires -Version 3.0
#>

[CmdletBinding(DefaultParameterSetName='ComputerName')]
param
(
    [parameter(ValueFromPipeline=$true,ParameterSetName='ComputerName',Position=0)]
    [Alias('CN')]
    $ComputerName,
    
    [parameter(ParameterSetName='GUID')]
    [string]
    $RecoveryGUID,

    [System.Management.Automation.CredentialAttribute()]
    $Credential,

    [parameter(ParameterSetName='ComputerName')]
    [switch]
    $All,

    $Server
)

    begin
    {
        $Splat = @{Properties = 'msfve-recoverypassword', 'created'}
    
        if ($PSBoundParameters.ContainsKey('Credential')) {$Splat.Credential = $Credential}
    }
    
    process
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            'ComputerName'
            {
                $ADComputer = Get-ADComputer $ComputerName

                $Splat.SearchBase = $ADComputer.distinguishedname
                $Splat.Filter     = {objectclass -eq 'msFVE-RecoveryInformation'}
                $Splat.Properties = 'msfve-recoverypassword'
                
                $Recoveries = Get-ADObject @Splat 
               # if (!$all) {$Recoveries = $Recoveries| Select-Object -First 1}
            }
    
            'GUID'
            {
                if ($RecoveryGUID.Length -gt 8) {$RecoveryGUID = $RecoveryGUID.Substring(0,8)}
                $Splat.Filter = "objectclass -eq 'msFVE-RecoveryInformation' -and Name -Like '*{$RecoveryGUID-*}'"
                $Recoveries = Get-ADObject @Splat
            }
        }
    
        foreach ($Recovery in $Recoveries)
        {
            $Object = [PSCustomObject]@{
                  ComputerName     = ($Recovery.DistinguishedName -split ',')[1] -replace 'CN=',''
                  TimeStamp        = $Recovery.Created
                  RecoveryPassword = $Recovery.'msfve-RecoveryPassword'
            }

            $Object
            if (!$all) {break}
        }
    }
}
