#########################################################
#          dbatools: Wheel of Fortune                   #
#          Demo: 5 - Copy data between tables           #
#          Host: Cláudio                                #
#########################################################

# Set some variables
$sourceDB = "Northwind"
$destinationDB = "EmptyNorthwind"
$table = "[dbo].[Order Details]"

# Create empty database on destination instance
New-DbaDatabase -SqlInstance dbatools2 -Name $destinationDB

# Check table's content on source
Invoke-DbaQuery -SqlInstance dbatools1 -Database $sourceDB -Query "SELECT TOP 10 * FROM $table" | Format-Table

# Prove the destination table is does not exists
Invoke-DbaQuery -SqlInstance dbatools2 -Database $destinationDB -Query "SELECT TOP 10 * FROM $table" | Format-Table


<#
Copy data
    Note: Table does not exist so it will be created. However without PK, FK, UQ, (non)Clustered indexes..etc.
    If you need to keep all the objects take a look at the following blog post to understand how you can create 
the object with same structure/properties before copying the data.
        “UPS…I HAVE DELETED SOME DATA. CAN YOU PUT IT BACK?” – DBATOOLS FOR THE RESCUE 
        (https://claudioessilva.eu/2019/05/17/Ups...I-have-deleted-some-data.-Can-you-put-it-back-dbatools-for-the-rescue/)
#>

# Copy all data within "dbo.Order Details" to another instance
$copySplat = @{
    SqlInstance = "dbatools1"
    Destination = "dbatools2"
    Database = $sourceDB
    DestinationDatabase = $destinationDB
    Table = $table
    AutoCreateTable = $true 
    BatchSize = 1000
}
Copy-DbaDbTableData @copySplat

# Prove that now, we have data on the destination table
Invoke-DbaQuery -SqlInstance dbatools2 -Database $destinationDB -Query "SELECT TOP 10 * FROM $table" | Format-Table



# Another example

# Copy data based on a query

# Copy specific data (see query parameter) from [dbo].[Order Details] to [dbo].[CopyOf_Order Details]
$copySplat = @{
    SqlInstance = "dbatools1"
    Destination = "dbatools2"
    Database = $sourceDB
    DestinationDatabase = $destinationDB
    Table = $table
    DestinationTable = "[dbo].[CopyOf_Order Details]"
    AutoCreateTable = $true 
    BatchSize = 1000
    Query = "SELECT * FROM $sourceDB.$table WHERE Quantity > 70 "
}
Copy-DbaDbTableData @copySplat


#Confirm that data is there
Invoke-DbaQuery -SqlInstance dbatools2 -Database $destinationDB -Query "SELECT * FROM [dbo].[CopyOf_Order Details]" | Format-Table

# reset and get ready to spin!
Invoke-DemoReset