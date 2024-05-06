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

