#########################################################
#          dbatools: Wheel of Fortune                   #
#          Demo: 3 - Deploy sp_WhoIsActive              #
#          Host: Cláudio                                #
#########################################################

# Deploy sp_whoIsActive across instances
# NOTE: I wrote about it in my blog post: New version of sp_WhoIsActive (v11.20) is available – Deployed on 123 instances in less than 1 minute
# https://claudioessilva.eu/2017/12/05/new-version-of-sp_whoisactive-v11-20-is-available-deployed-on-123-instances-in-less-than-1-minute/

# Set variables
$databaseToDeploy = "master"

# Deploy the stored procedure on a list of instances

# If you have internet access
Install-DbaWhoIsActive -SqlInstance dbatools1, dbatools2 -Database $databaseToDeploy -Confirm:$false


#ToDo: Check file permissions: 
# WARNING: [14:32:19][Install-DbaWhoIsActive] Failed to update local cached copy | You do not have sufficient access rights to perform this operation or the item is hidden, system, or read only.
# we have to remove this folder during the demo - something permissions related ¯\_(ツ)_/¯
Remove-Item  '/root/.local/share/PowerShell/dbatools/WhoIsActive' -Recurse -Force

# If you have a file version of it (or without Internet access)
$deploySplat = @{
    SqlInstance = 'dbatools1', 'dbatools2'
    Database = $databaseToDeploy
    LocalFile = "./demos/3/sp_WhoIsActive.sql"
}
# Without internet access but with a version saved on a local file
Install-DbaWhoIsActive @deploySplat

# You can use the dbatools Invoke-DbaWhoIsActive command to run the stored procedure
Invoke-DbaWhoIsActive -SqlInstance dbatools1 -ShowOwnSpid

# reset and get ready to spin!
Invoke-DemoReset