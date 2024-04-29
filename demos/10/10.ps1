#########################################################
#          dbatools: Wheel of Fortune                   #
#          Demo: 10 - Create an Availability Group      #
#          Host:                                        #
#########################################################

#TODO: This isn't working

# setup the variables
$params = @{
    Primary = 'dbatools1'
    Secondary = 'dbatools2'
    Name = "test-ag"
    Database = "pubs"
    ClusterType = "None"
    SeedingMode = "Automatic"
    FailoverMode = "Manual"
    Confirm = $false
}
# execute the command
New-DbaAvailabilityGroup @params