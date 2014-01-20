
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


Function Send-NetMessage{ 
<#   
.SYNOPSIS   
    Sends a message to network computers 
  
.DESCRIPTION   
    Allows the administrator to send a message via a pop-up textbox to multiple computers 
  
.EXAMPLE   
    Send-NetMessage "This is a test of the emergency broadcast system.  This is only a test." 
  
    Sends the message to all users on the local computer. 
  
.EXAMPLE   
    Send-NetMessage "Updates start in 15 minutes.  Please log off." -Computername testbox01 -Seconds 30 -VerboseMsg -Wait 
  
    Sends a message to all users on Testbox01 asking them to log off.   
    The popup will appear for 30 seconds and will write verbose messages to the console.  
 
.EXAMPLE 
    ".",$Env:Computername | Send-NetMessage "Fire in the hole!" -Verbose 
     
    Pipes the computernames to Send-NetMessage and sends the message "Fire in the hole!" with verbose output 
     
    VERBOSE: Sending the following message to computers with a 5 delay: Fire in the hole! 
    VERBOSE: Processing . 
    VERBOSE: Processing MyPC01 
    VERBOSE: Message sent. 
     
.EXAMPLE 
    Get-ADComputer -filter * | Send-NetMessage "Updates are being installed tonight. Please log off at EOD." -Seconds 60 
     
    Queries Active Directory for all computers and then notifies all users on those computers of updates.   
    Notification stays for 60 seconds or until user clicks OK. 
     
.NOTES   
    Author: Rich Prescott   
    Blog: blog.richprescott.com 
    Twitter: @Rich_Prescott 

	Source: http://gallery.technet.microsoft.com/scriptcenter/Send-NetMessage-Net-Send-0459d235 
	License: TechNet terms of use; See source web page.

MICROSOFT LIMITED PUBLIC LICENSE
This license governs use of code marked as “sample” or “example” available on this web site without a license agreement, as provided under the section above titled “NOTICE SPECIFIC TO SOFTWARE AVAILABLE ON THIS WEB SITE.” If you use such code (the “software”), you accept this license. If you do not accept the license, do not use the software. 
1. Definitions 
The terms “reproduce,” “reproduction,” “derivative works,” and “distribution” have the same meaning here as under U.S. copyright law. 
A “contribution” is the original software, or any additions or changes to the software. 
A “contributor” is any person that distributes its contribution under this license. 
“Licensed patents” are a contributor’s patent claims that read directly on its contribution. 
2. Grant of Rights 
(A) Copyright Grant - Subject to the terms of this license, including the license conditions and limitations in section 3, each contributor grants you a non-exclusive, worldwide, royalty-free copyright license to reproduce its contribution, prepare derivative works of its contribution, and distribute its contribution or any derivative works that you create. 
(B) Patent Grant - Subject to the terms of this license, including the license conditions and limitations in section 3, each contributor grants you a non-exclusive, worldwide, royalty-free license under its licensed patents to make, have made, use, sell, offer for sale, import, and/or otherwise dispose of its contribution in the software or derivative works of the contribution in the software. 
3. Conditions and Limitations 
(A) No Trademark License- This license does not grant you rights to use any contributors’ name, logo, or trademarks. 
(B) If you bring a patent claim against any contributor over patents that you claim are infringed by the software, your patent license from such contributor to the software ends automatically. 
(C) If you distribute any portion of the software, you must retain all copyright, patent, trademark, and attribution notices that are present in the software. 
(D) If you distribute any portion of the software in source code form, you may do so only under this license by including a complete copy of this license with your distribution. If you distribute any portion of the software in compiled or object code form, you may only do so under a license that complies with this license. 
(E) The software is licensed “as-is.” You bear the risk of using it. The contributors give no express warranties, guarantees or conditions. You may have additional consumer rights under your local laws which this license cannot change. To the extent permitted under your local laws, the contributors exclude the implied warranties of merchantability, fitness for a particular purpose and non-infringement. 
(F) Platform Limitation - The licenses granted in sections 2(A) and 2(B) extend only to the software or derivative works that you create that run on a Microsoft Windows operating system product.
#> 
 
Param( 
    [Parameter(Mandatory=$True)] 
    [String]$Message, 
     
    [String]$Session="*", 
     
    [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)] 
    [Alias("Name")] 
    [String[]]$Computername=$env:computername, 
     
    [Int]$Seconds="5", 
    [Switch]$VerboseMsg, 
    [Switch]$Wait 
    ) 
     
Begin 
    { 
    Write-Verbose "Sending the following message to computers with a $Seconds second delay: $Message" 
    } 
     
Process 
    { 
    ForEach ($Computer in $ComputerName) 
        { 
        Write-Verbose "Processing $Computer" 
        $cmd = "msg.exe $Session /Time:$($Seconds)" 
        if ($Computername){$cmd += " /SERVER:$($Computer)"} 
        if ($VerboseMsg){$cmd += " /V"} 
        if ($Wait){$cmd += " /W"} 
        $cmd += " $($Message)" 
 
        Invoke-Expression $cmd 
        } 
    } 
End 
    { 
    Write-Verbose "Message sent." 
    } 
}
