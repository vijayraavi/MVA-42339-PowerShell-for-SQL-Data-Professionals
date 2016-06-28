#Install Modules
#Must be run from a session with Administrator privileges!
Install-Module Azure
Install-Module AzureRM

#List the modules
Get-Module -ListAvailable *Azure*

#Azure
Import-Module Azure
Add-AzureAccount

#AzureRM
Import-Module AzureRM
Login-AzureRMAccount
