#########################################################
#          dbatools: Wheel of Fortune                   #
#          Demo: 11 - Snapshots                         #
#          Host: Jess                                   #
#########################################################

## Take a snapshot
$snapshotSplat = @{
    SqlInstance = 'dbatools1'
    Database    = 'Northwind'
}
New-DbaDbSnapshot @snapshotSplat

# read-only copy of your database at the time the snapshot was taken
# changes stored in a sparse files

# view snapshots
Get-DbaDbSnapshot @snapshotSplat

#################################
# go and make some rogue changes

Invoke-DbaQuery @snapshotSplat -Query "SELECT top 10 CustomerID, CompanyName, Phone FROM customers" | Format-Table 
Invoke-DbaQuery @snapshotSplat -Query "UPDATE customers SET Phone = '330-329-6691'"
Invoke-DbaQuery @snapshotSplat -Query "SELECT top 10 CustomerID, CompanyName, Phone FROM customers" | Format-Table  

#################################

# kill processes to allow us to revert snapshot
Get-DbaProcess @snapshotSplat | Format-Table SqlInstance, Spid, Login, Host, Database, Command
Get-DbaProcess @snapshotSplat | Stop-DbaProcess

# revert snapshot
Restore-DbaDbSnapshot @snapshotSplat

# check the data
Invoke-DbaQuery @snapshotSplat -Query "SELECT top 10 CustomerID, CompanyName, Phone FROM customers" | Format-Table  

$snapshotSplat = @{
    SqlInstance = 'dbatools1'
    Database    = 'Northwind_20251004_120925'
}
Invoke-DbaQuery @snapshotSplat -Query "SELECT top 10 CustomerID, CompanyName, Phone FROM customers" | Format-Table  

# clean up snapshot
Get-DbaDbSnapshot @snapshotSplat | Remove-DbaDbSnapshot -Confirm:$false

# reset and get ready to spin!
Invoke-DemoReset