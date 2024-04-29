#########################################################
#          dbatools: Wheel of Fortune                   #
#          Demo: 7 - Snapshots                          #
#          Host:                                        #
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

# go and make some rogue changes

# kill processes to allow us to revert snapshot
Get-DbaProcess @snapshotSplat | Format-Table SqlInstance, Spid, Login, Host, Database, Command
Get-DbaProcess @snapshotSplat | Stop-DbaProcess

# revert snapshot
Restore-DbaDbSnapshot @snapshotSplat

# clean up snapshot
Get-DbaDbSnapshot @snapshotSplat | Remove-DbaDbSnapshot -Confirm:$false