#########################################################
#          dbatools: Wheel of Fortune                   #
#          Demo: 10 - Create an Availability Group      #
#          Host:                                        #
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
New-DbaAvailabilityGroup @params

#TODO: Add some failover things and maybe connection test?
