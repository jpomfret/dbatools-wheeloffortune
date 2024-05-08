#########################################################
#          dbatools: Wheel of Fortune                   #
#          Demo: 15 - Refresh database PROD -> QA       #
#          Host:                                        #
#########################################################

$databaseToRefresh = "ToTestRefresh"

# 1 - Export users on destination
# Export all users from the specific database and its permissions at database-roles and object level
$usersExport = Export-DbaUser -SqlInstance dbatools2 -Database $databaseToRefresh -Passthru


# Variable content
$usersExport

#2 - Backup source database and restore it on destination
$copyDatabaseSplat = @{
    Source = "dbatools1"
    Destination = "dbatools2"
    Database = $databaseToRefresh
    BackupRestore = $true
    SharedPath = "/shared"
    WithReplace = $true
    Verbose = $true
}
Copy-DbaDatabase @copyDatabaseSplat


# Verify the orphan users
# Verify orphan users
Get-DbaDbOrphanUser -SqlInstance $dbatools2 -Database $databaseToRefresh

# Repair Orphan users
Repair-DbaDbOrphanUser -SqlInstance $dbatools2 -Database $databaseToRefresh

# Remove Orphan Users
Remove-DbaDbOrphanUser -SqlInstance $dbatools2 -Database $databaseToRefresh -Verbose


# Recreate users and grant permissions from the exported command
# Run the exported script
$sqlInst = Connect-DbaInstance dbatools2
$sqlInst.Databases["master"].ExecuteNonQuery($usersExport)

# Confirm that we don't have orphan users
Get-DbaDbOrphanUser -SqlInstance dbatools2 -Database $databaseToRefresh -Verbose


# Connect as QALogin and try to select some data
# Test connect as QALogin and select table where it does not have permissions
$cred_QA = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "QALogin", "dbatools.IO"
Invoke-DbaQuery -SqlInstance $dbatools2 -SqlCredential $cred_QA -Database $databaseToRefresh -Query "SELECT TOP 5 SUSER_NAME(), * FROM dbo.ToTestRefress"






# reset and get ready to spin!
Invoke-DemoReset