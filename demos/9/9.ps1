#########################################################
#          dbatools: Wheel of Fortune                   #
#          Demo: 9 - Check compatibility levels         #
#          Host: Jess                                   #
#########################################################

$instanceSplat = @{
    SqlInstance   = 'dbatools1', 'dbatools2'
}

## Test the compatibility level
Test-DbaDbCompatibility @instanceSplat |
Select-Object SqlInstance, ServerLevel, Database, DatabaseCompatibility, IsEqual |
Format-Table

## Upgrade the compatibility level
$compatSplat = @{
    SqlInstance = 'dbatools1'
    Database    = 'Northwind', 'Pubs'
}
Set-DbaDbCompatibility @compatSplat

# reset and get ready to spin!
Invoke-DemoReset