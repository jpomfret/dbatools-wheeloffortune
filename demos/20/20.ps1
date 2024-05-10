#########################################################
#          dbatools: Wheel of Fortune                   #
#          Demo: 20 - Import-DbaCsv                     #
#          Host: Cláudio                                #
#########################################################

$database = "tempdb"
$table = "authors"
$csvPath = "./demos/20/authors.csv"
$delimitier = "|"

# Import the csv file to a table into the database

$splatImportCSV = @{
	SqlInstance = "dbatools1"
	Database = $database
    Table = $table
    Path = $csvPath
    Delimiter = $delimitier
    AutoCreateTable = $true
}
Import-DbaCsv @splatImportCSV


#Check if the data is there
$splatInvokeQuery = @{
	SqlInstance = "dbatools1"
	Database = $database
	Query = "SELECT * FROM $table"
}
Invoke-DbaQuery @splatInvokeQuery | Format-Table


# Not impressed? 
# Let's check with a file that contains 200K rows

$csvPathBigger = "./demos/20/authors_bigger.csv"

$splatImportCSV = @{
	SqlInstance = "dbatools1"
	Database = $database
    Table = "$table-2"
    Path = $csvPathBigger
    Delimiter = $delimitier
    AutoCreateTable = $true
}
Import-DbaCsv @splatImportCSV

#NOTE:
# I suggest that you create the table with the datatypes that better match your data.
# By default columns will be created as VARCHAR(MAX).


# reset and get ready to spin!
Invoke-DemoReset