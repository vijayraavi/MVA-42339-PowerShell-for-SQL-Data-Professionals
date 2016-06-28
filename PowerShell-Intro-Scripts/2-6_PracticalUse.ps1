#Practical use

#collect server inventory info
$instances = @(’PICARD’,’RIKER’)
$instances | 
    ForEach-Object {Get-Item “SQLSERVER:\SQL\$_\DEFAULT”} | 
    Select-Object Name,VersionString,Edition,ServiceAccount |
    ConvertTo-Csv -Delimiter '|' -NoTypeInformation |
    Out-File C:\Temp\Inventory.csv

(Get-Content C:\Temp\Inventory.csv) | ForEach-Object {$_ -replace '"',''} | Out-File C:\Temp\Inventory.csv

notepad C:\Temp\Inventory.csv

#Check SQL Server Connection
$instances = @('PICARD','RIKER','NotValid')
$return = @()
$sql = "SELECT @@SERVERNAME as Name,Create_Date FROM sys.databases WHERE name = 'TempDB'"
foreach($instance in $instances){
    try{    
        $row = New-Object –TypeName PSObject –Prop @{'InstanceName'=$instance;'StartupTime'=$null}
        $check=Invoke-Sqlcmd -ServerInstance $instance -Database TempDB -Query $sql -ErrorAction Stop -ConnectionTimeout 3
        $row.InstanceName = $check.Name
        $row.StartupTime = $check.Create_Date
    } catch {
        #do nothing
    } finally {
        $return += $row
    }
}
$return | Format-Table


#Create a Point in Time restore
Set-Location C:\Temp
$LastFull= Get-ChildItem '\\PICARD\C$\Backups\WideWorldImporters\*.bak' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$logs = Get-ChildItem '\\PICARD\C$\Backups\WideWorldImporters\*.trn' | Where-Object {$_.LastWriteTime -gt $LastFull.LastWriteTime} | Sort-Object LastWriteTime

$MoveFiles = @()
$MoveFiles += New-Object Microsoft.SqlServer.Management.Smo.RelocateFile ('WWI_Data','C:\DBFiles\data\WWI2_Data.mdf')
$MoveFiles += New-Object Microsoft.SqlServer.Management.Smo.RelocateFile ('WWI_Log','C:\DBFiles\log\WWI2_Log.ldf')
$MoveFiles += New-Object Microsoft.SqlServer.Management.Smo.RelocateFile ('WWI_InMemory_Data_1','C:\DBFiles\data\WWI2_InMemory_Data_1.ldf')


$db = 'WideWorldImporters2'
Restore-SqlDatabase -ServerInstance 'PICARD' -Database $db -RelocateFile $MoveFiles -BackupFile $LastFull.FullName -RestoreAction Database -NoRecovery -Script | Out-File 'C:\Temp\Restore.sql'
foreach($log in $logs){
    if($log -eq $logs[$logs.Length -1]){
        Restore-SqlDatabase -ServerInstance 'PICARD' -Database $db -BackupFile $log.FullName -RestoreAction Log -Script | Out-File 'C:\Temp\Restore.sql' -Append
    }
    else{
        Restore-SqlDatabase -ServerInstance 'PICARD' -Database $db -BackupFile $log.FullName -RestoreAction Log -NoRecovery -Script | Out-File 'C:\Temp\Restore.sql' -Append
    }
}

notepad C:\Temp\Restore.sql

#execute a restore
$db = 'WideWorldImporters2'
Restore-SqlDatabase -ServerInstance 'PICARD' -Database $db -RelocateFile $MoveFiles -BackupFile $LastFull.FullName -RestoreAction Database -NoRecovery 
foreach($log in $logs){
    if($log -eq $logs[$logs.Length -1]){
        Restore-SqlDatabase -ServerInstance 'PICARD' -Database $db -BackupFile $log.FullName -RestoreAction Log 
    }
    else{
        Restore-SqlDatabase -ServerInstance 'PICARD' -Database $db -BackupFile $log.FullName -RestoreAction Log -NoRecovery
    }
}