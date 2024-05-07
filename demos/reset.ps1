# we'll run this between demos to undo anything we might have done..


## 8. migration - bring databases back online on dbatools1
$onlineSplat = @{
    SqlInstance = 'dbatools1'
    Database    = "Northwind", "DatabaseAdmin"
    Online      = $true
    Force       = $true
}
$null = Set-DbaDbState @onlineSplat

# 8. migration - remove databases from dbatools2
$removeSplat = @{
    SqlInstance = 'dbatools2'
    Database    = "Northwind", "DatabaseAdmin", "Pubs"
    Confirm     = $false
}
$null = Remove-DbaDatabase @removeSplat

# 9. compat levels - reset to 130
## Upgrade the compatibility level
$compatSplat = @{
    SqlInstance = 'dbatools1'
    Database    = 'Northwind', 'Pubs'
    Compatibility = 130
}
$null = Set-DbaDbCompatibility @compatSplat

# 10. 
$null = Remove-DbaAvailabilityGroup -SqlInstance dbatools1, dbatools2 -AvailabilityGroup test-ag -Confirm:$false
$null = Remove-DbaDatabase -SqlInstance dbatools2 -Database Pubs -Confirm:$false

# 11. clean up snapshots
$snapshotSplat = @{
    SqlInstance = 'dbatools1'
    Database    = 'Northwind'
}
$null = Get-DbaDbSnapshot @snapshotSplat | Remove-DbaDbSnapshot -Confirm:$false

#13. run a folder of scripts
$null = Remove-DbaDatabase -SqlInstance dbatools1 -Database PubsV2 -Confirm:$false
$null = Get-ChildItem ./demos/13 *.sql | Remove-Item

# 16. truncate all the tables
$null = Restore-DbaDatabase -SqlInstance dbatools1 -Path ($global:fullBackup | Where-Object database -eq 'pubs').path -DatabaseName pubs -WithReplace

#18 - remove users
$null = Remove-DbaDbUser -SqlInstance dbatools1 -User JessP -Database DatabaseAdmin -Confirm:$false
$null = Remove-DbaLogin -SqlInstance dbatools1 -Login JessP -Confirm:$false

(Import-Csv ./demos/18/users.csv).foreach{
    $null = Remove-DbaDbUser -SqlInstance $psitem.Server -User $psitem.User -Database $psitem.Database -Confirm:$false
    $null = Remove-DbaLogin -SqlInstance $psitem.Server -Login $psitem.User -Confirm:$false
}

# 19. remove file
Get-ChildItem ./demos/19/test.HTML | Remove-Item