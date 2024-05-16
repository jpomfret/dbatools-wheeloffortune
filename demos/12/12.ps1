#########################################################
#          dbatools: Wheel of Fortune                   #
#          Demo: 12 - Generate Login/Users report       #
#          Host: Cláudio                                #
#########################################################

$excludeDatabase = "myDB", "myDB2"
$excludeLogin = "renamedSA"
$excludeLoginFilter = "NT *", "##*"
$SQLInstance = "dbatools1", "dbatools2"

# To be used on Export-Excel command
$excelFilepath = "./export/$($SQLInstance -replace ',', '')_$((Get-Date).ToFileTime()).xlsx"
$freezeTopRow = $true
$tableStyle = "Medium6"


#Region Get data
# Get all instance logins
$Logins = Get-DbaLogin -SqlInstance $SQLInstance -ExcludeLogin $excludeLogin -ExcludeFilter $excludeLoginFilter

# Get all server roles and its members
$instanceRoleMembers = Get-DbaServerRoleMember -SqlInstance $SQLInstance -Login $Logins.Name

# Get all database roles and its members
$dbRoleMembers = Get-DbaDbRoleMember -SqlInstance $SQLInstance -ExcludeDatabase $excludeDatabase | Where-Object UserName -in $logins.Name
#EndRegion


# Remove the report file if exists
Remove-Item -Path $excelFilepath -Force -ErrorAction SilentlyContinue


#Export result to excel. It uses ImportExcel PowerShell Module from Doug Finke

#Region Export Data to Excel
# Export data to Excel
## Export Logins
$excelLoginSplatting = @{
    Path = $excelFilepath 
    WorkSheetname = "Logins"
    TableName = "Logins"
    FreezeTopRow = $freezeTopRow
    TableStyle = $tableStyle
}
$Logins | Select-Object "ComputerName", "InstanceName", "SqlInstance", "Name", "LoginType", "CreateDate", "LastLogin", "HasAccess", "IsLocked", "IsDisabled" | Export-Excel @excelLoginSplatting

## Export instance roles and its members
$excelinstanceRoleMembersOutput = @{
    Path = $excelFilepath 
    WorkSheetname = "InstanceLevel"
    TableName = "InstanceLevel"
    TableStyle = $tableStyle
    FreezeTopRow = $freezeTopRow
}
$instanceRoleMembers | Export-Excel @excelinstanceRoleMembersOutput

## Export database roles and its members
$exceldbRoleMembersOutput = @{
    Path = $excelFilepath 
    WorkSheetname = "DatabaseLevel"
    TableName = "DatabaseLevel"
    TableStyle = $tableStyle
    FreezeTopRow = $freezeTopRow
}
$excel = $dbRoleMembers | Export-Excel @exceldbRoleMembersOutput -PassThru 


# Add some RED background to sysadmin entries
$rulesparam = @{
    Range   = $excel.Workbook.Worksheets["InstanceLevel"].Dimension.Address
    WorkSheet = $excel.Workbook.Worksheets["InstanceLevel"]
    RuleType  = "Expression"
    ConditionValue = 'NOT(ISERROR(FIND("sysadmin",$D1)))'
    BackgroundColor = "LightPink"
    Bold = $true
}

Add-ConditionalFormatting @rulesparam
Close-ExcelPackage -ExcelPackage $excel #-Show

#EndRegion



# reset and get ready to spin!
Invoke-DemoReset