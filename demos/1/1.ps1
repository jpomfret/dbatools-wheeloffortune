#########################################################
#          dbatools: Wheel of Fortune                   #
#          Demo: 1 - Get database information           #
#          Host: Jess                                   #
#########################################################

# get a list of databases on an instance
Get-DbaDatabase -SqlInstance dbatools1 

# get a list of databases on an instance and filter by name
Get-DbaDatabase -SqlInstance dbatools1 -Database DatabaseAdmin

# get a list of databases on multiple instances
Get-DbaDatabase -SqlInstance dbatools1, dbatools2

# get a list of databases on multiple instances and select just a couple of properties
Get-DbaDatabase -SqlInstance dbatools1, dbatools2 | Select-Object SqlInstance, Name, RecoveryModel

# get a list of databases on multiple instances and filter by name
Get-DbaDatabase -SqlInstance dbatools1, dbatools2 -Database msdb | Select-Object SqlInstance, Name, RecoveryModel

# but there is more
Get-DbaDatabase -SqlInstance dbatools1 -Database DatabaseAdmin | Get-Member

# and if we view all the properties
Get-DbaDatabase -SqlInstance dbatools1 -Database DatabaseAdmin | Format-List *
