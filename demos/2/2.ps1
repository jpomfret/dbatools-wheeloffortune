#########################################################
#          dbatools: Wheel of Fortune                   #
#          Demo: 2 - Test instance compliance           #
#          Host:                                        #
#########################################################

# Test compliance of 1 instance
Test-DbaBuild -SqlInstance dbatools1 -Latest

# Test compliance for 2 instances
Test-DbaBuild -SqlInstance dbatools1, dbatools2 -Latest | FT

# Test if we aren't more than 1CU behind
Test-DbaBuild -SqlInstance dbatools1 -MaxBehind 1CU

# Example when compliant
Test-DbaBuild -SqlInstance dbatools1 -MaxBehind 8CU

#Example using more specific versions
$mapping = @{
    # '2008'   = '10.0.6556'
    # '2008R2' = '10.50.6560'
    # '2012'   = '11.0.7462'
    # '2014'   = '12.0.5571'
    # '2016'   = '13.0.4466'
    # '2017'   = '14.0.3015'
    '2019'   = '15.0.4261' # CU18
    '2022'   = '16.0.1000' # RTM
}
foreach($inst in @('dbatools1', 'dbatools2')) {
    $ref = Get-DbaBuildReference -SqlInstance $inst
    Test-DbaBuild -SqlInstance $inst -MinimumBuild $mapping[$ref.NameLevel]
}


# Export result to excel. It uses ImportExcel PowerShell Module from Doug Finke
    # Need to be run outside of the container
    # $excelFilePath = "D:\temp\Compliance_$((Get-Date).ToFileTime()).xlsx"#

# JP: if you write to the workspace folder here and remove the -Show parameter - you can then just open from the windows side:
$excelFilePath = "/workspace/export/compliance_$((Get-Date).ToFileTime()).xlsx"
$results = Test-DbaBuild -SqlInstance dbatools1, dbatools2 -Latest
$results | Export-Excel -Path $excelFilePath -TableName "data" -TableStyle Medium10 -AutoSize

# open from the cloned folder  on the windows side
# e.g. C:\GitHub\dbatools-wheeloffortune\export 

# reset and get ready to spin!
Invoke-DemoReset