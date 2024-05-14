#########################################################
#          dbatools: Wheel of Fortune                   #
#          Demo: 10 - Create an Availability Group      #
#          Host: Jess                                   #
#########################################################

# setup the variables
$params = @{
    Primary = 'dbatools1'
    Secondary = 'dbatools2'
    Name = "WheelOfFortune"
    Database = "pubs"
    ClusterType = "None"
    SeedingMode = "Automatic"
    FailoverMode = "Manual"
    Confirm = $false
}
# execute the command
New-DbaAvailabilityGroup @params -ConnectionModeInSecondaryRole AllowAllConnections

#TODO: Add some failover things and maybe connection test?

# Add a database to the ag
$addDb = @{
    SqlInstance = 'dbatools1'
    AvailabilityGroup = 'WheelOfFortune'
    Database = 'NorthWind'
}
Add-DbaAgDatabase @addDb

# nice graceful failover
Invoke-DbaAgFailover -SqlInstance dbatools2 -AvailabilityGroup WheelOfFortune

# WARNING: [08:09:17][Invoke-DbaAgFailover] Failure | 
# Cannot failover an availability replica for availability group 'WheelOfFortune' since it has CLUSTER_TYPE = NONE. Only force failover is supported in this version of SQL Server.

# force failover
Invoke-DbaAgFailover -SqlInstance dbatools2 -AvailabilityGroup WheelOfFortune -Force

# reset and get ready to spin!
Invoke-DemoReset