#########################################################
#          dbatools: Wheel of Fortune                   #
#          Demo: 4 - Export-DbaInstance                 #
#          Host: Cláudio                                #
#########################################################

$path = "./export/4"

# Export instance configuration
$splatExportInstance = @{
    SqlInstance = "dbatools1"
    Path = $path
    Exclude = @("LinkedServers", "Credentials", "CentralManagementServer", "BackupDevices", "Endpoints", "Databases", "ReplicationSettings", "PolicyManagement")
    ExcludePassword = $true
}
Export-DbaInstance @splatExportInstance

# Show folder output
# Show that passwords aren't scripted in plain text at logins.sql file


<#
    Other/optional
     - replace suffix 
     - put on git
    NOTE: You can read more about this approach on my blog posts:
        Backup your SQL instances configurations to GIT with dbatools – Part 1 (https://claudioessilva.eu/2020/06/02/Backup-your-SQL-instances-configurations-to-GIT-with-dbatools-Part-1/)
        Backup your SQL instances configurations to GIT with dbatools – Part 2 – Add parallelism (https://claudioessilva.eu/2020/06/04/backup-your-sql-instances-configurations-to-git-with-dbatools-part-2-add-parallelism/)
#>
# If you want to versioning it, example put on GIT

# 1. Find .sql files where the name starts with a number and rename files to exclude numeric part "#-<NAME>.sql" (remove the "#-")
Get-ChildItem -Path $path -Recurse -Filter "*.sql" | Where-Object {$_.Name -match '^[0-9]+.*'} | Foreach-Object {Rename-Item -Path $_.FullName -NewName $($_ -split '-')[1] -Force}

# 2. Remove the suffix "-datetime" 
Get-ChildItem -Path $path | ForEach-Object {Rename-Item -Path $_.FullName -NewName $_.Name.Substring(0, $_.Name.LastIndexOf('-')) -Force}

# 3. Copy and overwrite the files within your GIT folder. (This way you will keep the history)
Copy-Item -Path "$path\*" -Destination $(Split-Path -Path $path -Parent) -Recurse -Force

<#
    When working with GIT you can run the following example:
    
    git commit -m "Export-DbaInstance @ $((Get-Date).ToString("yyyyMMdd-HHmmss"))"
    git push
#>

# reset and get ready to spin!
Invoke-DemoReset