#########################################################
#          dbatools: Wheel of Fortune                   #
#          Demo: 13 - Execute a folder of scripts       #
#          Host: Jess                                   #
#########################################################

$folderPath = './export/'
$SqlInstance = 'dbatools1'
$sourceDatabase = 'Pubs'
$destinationDatabase = 'PubsV2'

######################################
# Setup - create a folder of scripts #
######################################

# create the output path if it doesn't exist
if (!(Test-Path $folderPath)) {
    $null = New-Item -Path $folderPath -ItemType Directory
}

# Export create statements for tables
# Using a foreach loop so we can control the name of each file separately
$so = New-DbaScriptingOption
$so.ConvertUserDefinedDataTypesToBaseType = $true

Get-DbaDbTable -SqlInstance $SqlInstance -Database $sourceDatabase |
ForEach-Object -PipelineVariable obj -Process { $_ } |
ForEach-Object { Export-DbaScript -InputObject $obj -ScriptingOptionsObject $so -FilePath ('{0}\{1}_{2}.sql' -f $folderPath, $obj.Schema, $obj.Name) }


# See how many sql files we have to execute
Get-ChildItem $folderPath *.sql | Measure-Object | Select-Object Count
<#
Count
-----
11
#>

# Create a new empty database
$splatCreate = @{
    SqlInstance = $SqlInstance
    Name        = $destinationDatabase
}
New-DbaDatabase @splatCreate

###############################
# Execute a folder of scripts #
###############################


(Get-ChildItem $folderPath *.sql).Foreach{
    Invoke-DbaQuery -SqlInstance $SqlInstance -Database $destinationDatabase -File $psitem.FullName
}

# Had a great question about error handling, so if you want the first error to stop all scripts from executing
# wrap the whole thing in a try/catch block and use the -EnableException switch on Invoke-DbaQuery.
try {
    (Get-ChildItem $folderPath *.sql).Foreach{
        Invoke-DbaQuery -SqlInstance $SqlInstance -Database $destinationDatabase -File $psitem.FullName -EnableException
    }
} catch {
    Write-Error "Something went wrong executing the scripts: $_"
}

# and if you want just the script to throw an error but the rest to continue
# you can use a try/catch block inside the loop instead. Still use the -EnableException switch on Invoke-DbaQuery.
(Get-ChildItem $folderPath *.sql).Foreach{
        try {
        Invoke-DbaQuery -SqlInstance $SqlInstance -Database $destinationDatabase -File $psitem.FullName -EnableException
    } catch {
        Write-Error "Something went wrong executing the scripts: $_"
    }
}

# Check the data
Invoke-DbaQuery -SqlInstance $SqlInstance -Database $destinationDatabase -Query "SELECT name, create_date from sys.tables" | Format-Table

# clean up files
Get-ChildItem $folderPath *.sql | Remove-Item

# reset and get ready to spin!
Invoke-DemoReset