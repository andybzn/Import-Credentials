<#
    Script: Import-Credentials.ps1
    Author: Dark-Coffee
    Version: 1.1
    Updated: 2020-09-30
    Description: Retrieves secure credentials from an XML file for use in other functions.
#>

function Import-Credentials(){
<#
.SYNOPSIS
Retrieves secure credentials from an XML file for use in other functions.

.DESCRIPTION
Retrieves secure credentials from an XML file for use in other functions.
Will retrieve a <username>, an <emailaddress>, and a securestring <encryptedpass> from an XML filein the below format:

<credential>
    <username></username>
    <emailaddress></emailaddress>
    <encryptedpass></encryptedpass>
</credential>

.PARAMETER XMLPath
Specifies the path to the XML Credential file.

.PARAMETER CredentialSelect
If specified (from AD or Email), will return the appropriate credential only.

.INPUTS
None. You cannot pipe objects to Import-Credentials.

.OUTPUTS
Both or either of:
(AD) string UserName securestring Password
(Email) string UserName securestring Password

.EXAMPLE
PS>  Import-Credentials -XMLPath "Credential.xml"

UserName                                      Password
--------                                      --------
user.name                 System.Security.SecureString
user.name@email.address   System.Security.SecureString

.EXAMPLE
PS>  Import-Credentials -XMLPath "Credential.xml" -CredentialSelect Email

UserName                                      Password
--------                                      --------
user.name@email.address   System.Security.SecureString
#>
    
    #Params
    param (
        [Parameter(Mandatory=$True)][ValidateScript({If(Test-Path $_){$True}else{Throw "Invalid Path to XML File: $_"}})][String]$XMLPath,
        [Parameter(Mandatory=$False)][ValidateSet('AD', 'Email')][String]$CredentialSelect
    )

    #Path To Credential XML
    $CredentialPath = $XMLPath

    #Select Credentials from XML and convert where Necessary
    $CredentialUsername = (Select-Xml -Path $CredentialPath -Xpath "//username").node.InnerXML
    $CredentialEmailAddress = (Select-Xml -Path $CredentialPath -Xpath "//email").node.InnerXML
    $CredentialPassword = (Select-Xml -Path $CredentialPath -Xpath "//encryptedpass").node.InnerXML | ConvertTo-SecureString

    #Set Outputs
    $Credential_AD = New-Object System.Management.Automation.PSCredential -ArgumentList $CredentialUsername, $CredentialPassword
    $Credential_Email = New-Object System.Management.Automation.PSCredential -ArgumentList $CredentialEmailAddress, $CredentialPassword

    #Return
    if($CredentialSelect -eq 'AD'){
         $Credential_AD
    }elseif($CredentialSelect -eq 'EMAIL'){
        $Credential_Email
    }else{
        $Credential_AD
        $Credential_Email
    }
    
}

Export-ModuleMember -Function Import-Credentials