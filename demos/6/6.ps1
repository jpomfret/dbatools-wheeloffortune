#########################################################
#          dbatools: Wheel of Fortune                   #
#          Demo: 6 - Backups & Backup Testing           #
#          Host: Jess                                   #
#########################################################


## Get the backup history for the dbatools1 server
$instanceSplat = @{
    SqlInstance = 'dbatools1'
}
Get-DbaDbBackupHistory @instanceSplat | Sort-Object Start

## Backup the DatabaseAdmin database
$backupParams = @{
    SqlInstance = 'dbatools1'
    Database    = 'DatabaseAdmin'
}
Backup-DbaDatabase @backupParams

## Offload testing your backups to a second server
$testParams = @{
    SqlInstance = 'dbatools1'
    Database    = "Northwind", "DatabaseAdmin"
    Destination = 'dbatools2'
    Verbose     = $true
    OutVariable = 'results'
}
Test-DbaLastBackup @testParams

## Record your backup tests into a SQL Server table
$writeParams = @{
    SqlInstance     = 'dbatools1'
    Database        = 'DatabaseAdmin'
    Table           = 'TestRestore'
    AutoCreateTable = $true
}
$results | Write-DbaDataTable @writeParams

## Check the results
Invoke-DbaQuery -SqlInstance dbatools1 -Database "DatabaseAdmin" -Query "SELECT * FROM dbo.TestRestore" | Format-Table

# reset and get ready to spin!
Invoke-DemoReset