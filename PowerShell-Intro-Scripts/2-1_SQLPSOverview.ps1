#Load the SQLPS module
Import-Module SQLPS

#What's in it?
Get-Command -Module SQLPS

#Where does it live?
Get-Module -ListAvailable SQLPS

<#
Gotchas
 - Warning Message!
 Prior to SQL 2016, two cmdlets (Encode-SqlName and Decode-SqlName) would cause this
 because they are not approved verbs. This does not affect using/loading the module

 - Starting in SQLSERVER:\
 Also prior to SQL 2016, loading the SQLPS module would automatically change your 
 location to the SQLSERVER:\ provider "drive".
#>