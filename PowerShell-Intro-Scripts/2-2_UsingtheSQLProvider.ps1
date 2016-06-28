#List all of your current providers
Get-PSDrive

#Change to the SQL Server Provider
CD SQLSERVER:\
dir

#We can browse our SQL Servers as if they were directories
CD SQL\PICARD\
dir

CD DEFAULT
dir

#Let's list our databases
dir databases | format-table -AutoSize

dir databases -Force | format-table -AutoSize

#Everything is an object! What objects are we looking at?
dir databases | Get-Member

dir databases -Force | Select-Object name,createdate,@{name='DataSizeMB';expression={$_.dataspaceusage/1024}},LastBackupDate | Format-Table -AutoSize

#We can drill further down
dir databases\WideWorldImporters\Tables

#Practical use
$instances = @(’PICARD’,’RIKER’)

#Check your databases for last backup
$instances | ForEach-Object {Get-ChildItem “SQLSERVER:\SQL\$_\DEFAULT\Databases” -Force} |
    Sort-Object Size -Descending | 
    Select-Object @{n='Server';e={$_.parent.Name}},Name,LastBackupDate,Size