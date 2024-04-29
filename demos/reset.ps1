# we'll run this between demos to undo anything we might have done..


# 7. clean up snapshots
$snapshotSplat = @{
    SqlInstance = 'dbatools1'
    Database    = 'Northwind'
}
Get-DbaDbSnapshot @snapshotSplat | Remove-DbaDbSnapshot -Confirm:$false


## 8. migration - bring databases back online on dbatools1
$onlineSplat = @{
    SqlInstance = 'dbatools1'
    Database    = "Northwind", "DatabaseAdmin"
    Online      = $true
    Force       = $true
}
Set-DbaDbState @onlineSplat

# 8. migration - remove databases from dbatools2
$removeSplat = @{
    SqlInstance = 'dbatools2'
    Database    = "Northwind", "DatabaseAdmin", "Pubs"
    Confirm     = $false
}
Remove-DbaDatabase @removeSplat

# 9. compat levels - reset to 130
## Upgrade the compatibility level
$compatSplat = @{
    SqlInstance = 'dbatools1'
    Database    = 'Northwind', 'Pubs'
    Compatibility = 130
}
Set-DbaDbCompatibility @compatSplat

# 10. 
# remove the AG
#TODO: do this