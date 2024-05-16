$containers = $SQLInstances = $dbatools1, $dbatools2 = 'dbatools1', 'dbatools2'

#region Set up connection
$securePassword = ('dbatools.IO' | ConvertTo-SecureString -AsPlainText -Force)
$containerCredential = New-Object System.Management.Automation.PSCredential('sqladmin', $securePassword)

$Global:PSDefaultParameterValues = @{
    "*dba*:SqlCredential"            = $containerCredential
    "*dba*:SourceSqlCredential"      = $containerCredential
    "*dba*:DestinationSqlCredential" = $containerCredential
    "*dba*:DestinationCredential"    = $containerCredential
    "*dba*:PrimarySqlCredential"     = $containerCredential
    "*dba*:SecondarySqlCredential"   = $containerCredential
}
#endregion

Remove-Item '/var/opt/backups/dbatools1' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item '/shared' -Recurse -Force -ErrorAction SilentlyContinue

Import-Module Pansies

######## POSH-GIT
# with props to https://bradwilson.io/blog/prompt/powershell
# ... Import-Module for posh-git here ...
Import-Module posh-git
Import-Module dbatools
Import-Module dbachecks
Import-Module ImportExcel

# first time it runs it warns about the libraries
$test | Export-Excel -Path .\export\test.xlsx -WarningVariable warn
Remove-Item .\export\test.xlsx 

$ShowError = $false
$ShowKube = $false
$ShowAzure = $false
$ShowAzureCli = $false
$ShowGit = $false
$ShowPath = $true
$ShowDate = $true
$ShowTime = $true
$ShowUser = $true
# Background colors

$GitPromptSettings.AfterStash.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.AfterStatus.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BeforeIndex.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BeforeStash.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BeforeStatus.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BranchAheadStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BranchBehindAndAheadStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BranchBehindStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BranchColor.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BranchGoneStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BranchIdenticalStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.DefaultColor.BackgroundColor = [ConsoleColor]::DarkCyan
$GitPromptSettings.DelimStatus.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.ErrorColor.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.IndexColor.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.LocalDefaultStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.LocalStagedStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.LocalWorkingStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.StashColor.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.WorkingColor.BackgroundColor = [ConsoleColor]::DarkGray

# Foreground colors

$GitPromptSettings.AfterStatus.ForegroundColor = [ConsoleColor]::Blue
$GitPromptSettings.BeforeStatus.ForegroundColor = [ConsoleColor]::Blue
$GitPromptSettings.BranchColor.ForegroundColor = [ConsoleColor]::White
$GitPromptSettings.BranchGoneStatusSymbol.ForegroundColor = [ConsoleColor]::Blue
$GitPromptSettings.BranchIdenticalStatusSymbol.ForegroundColor = [ConsoleColor]::Blue
$GitPromptSettings.DefaultColor.ForegroundColor = [ConsoleColor]::White
$GitPromptSettings.DelimStatus.ForegroundColor = [ConsoleColor]::Blue
$GitPromptSettings.IndexColor.ForegroundColor = [ConsoleColor]::Cyan
$GitPromptSettings.WorkingColor.ForegroundColor = [ConsoleColor]::Yellow
$GitPromptSettings.BranchBehindStatusSymbol.ForegroundColor = [ConsoleColor]::Black
$GitPromptSettings.LocalWorkingStatusSymbol.ForegroundColor = [ConsoleColor]::Black
# Prompt shape

$GitPromptSettings.AfterStatus.Text = " "
$GitPromptSettings.BeforeStatus.Text = "  "
$GitPromptSettings.BranchAheadStatusSymbol.Text = " "
$GitPromptSettings.BranchBehindStatusSymbol.Text = " "
$GitPromptSettings.BranchGoneStatusSymbol.Text = ""
$GitPromptSettings.BranchBehindAndAheadStatusSymbol.Text = ""
$GitPromptSettings.BranchIdenticalStatusSymbol.Text = ""
$GitPromptSettings.BranchUntrackedText = ""
$GitPromptSettings.DelimStatus.Text = " ॥"

$GitPromptSettings.EnableStashStatus = $false
$GitPromptSettings.ShowStatusWhenZero = $false

######## PROMPT
Set-Content Function:prompt {
    if ($ShowDate) {
        Write-Host " $(Get-Date -Format "ddd dd MMM HH:mm:ss")" -ForegroundColor Black -BackgroundColor DarkGray -NoNewline
    }

    # Reset the foreground color to default
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultColor.ForegroundColor

    if ($ShowUser) {
        Write-Host " " -NoNewline
        Write-Host "  " -NoNewline -BackgroundColor DarkYellow -ForegroundColor Black
        Write-Host  (whoami)  -NoNewline -BackgroundColor DarkYellow -ForegroundColor Black
    }
    # Write ERR for any PowerShell errors
    if ($ShowError) {
        if ($Error.Count -ne 0) {
            Write-Host " " -NoNewline
            Write-Host " $($Error.Count) ERR " -NoNewline -BackgroundColor DarkRed -ForegroundColor Yellow
            # $Error.Clear()
        }
    }

    # Write non-zero exit code from last launched process
    if ($LASTEXITCODE -ne "") {
        Write-Host " " -NoNewline
        Write-Host " x $LASTEXITCODE " -NoNewline -BackgroundColor DarkRed -ForegroundColor Yellow
        $LASTEXITCODE = ""
    }

    if ($ShowKube) {
        # Write the current kubectl context
        if ((Get-Command "kubectl" -ErrorAction Ignore) -ne $null) {
            $currentContext = (& kubectl config current-context 2> $null)
            $nodes = kubectl get nodes -o json | ConvertFrom-Json

            $nodename = ($nodes.items.metadata | where labels  -Like '*master*').name
            Write-Host " " -NoNewline
            Write-Host "" -NoNewline -BackgroundColor DarkGray -ForegroundColor Green
            #Write-Host " $currentContext " -NoNewLine -BackgroundColor DarkYellow -ForegroundColor Black
            Write-Host " $([char]27)[38;5;112;48;5;242m  $([char]27)[38;5;254m$currentContext - $nodename $([char]27)[0m" -NoNewline
        }
    }

    if ($ShowAzureCli) {
        # Write the current public cloud Azure CLI subscription
        # NOTE: You will need sed from somewhere (for example, from Git for Windows)
        if (Test-Path ~/.azure/clouds.config) {
            if ((Get-Command "sed" -ErrorAction Ignore) -ne $null) {
                $currentSub = & sed -nr "/^\[AzureCloud\]/ { :l /^subscription[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" ~/.azure/clouds.config
            } else {
                $file = Get-Content ~/.azure/clouds.config
                $currentSub = ([regex]::Matches($file, '^.*subscription\s=\s(.*)').Groups[1].Value).Trim()
            }
            if ($null -ne $currentSub) {
                $currentAccount = (Get-Content ~/.azure/azureProfile.json | ConvertFrom-Json).subscriptions | Where-Object { $_.id -eq $currentSub }
                if ($null -ne $currentAccount) {
                    Write-Host " " -NoNewline
                    Write-Host "" -NoNewline -BackgroundColor DarkCyan -ForegroundColor Yellow
                    $currentAccountName = ($currentAccount.Name.Split(' ') | foreach { $_[0..5] -join '' }) -join ' '
                    Write-Host "$([char]27)[38;5;227;48;5;30m  $([char]27)[38;5;254m$($currentAccount.name) $([char]27)[0m"  -NoNewline -BackgroundColor DarkBlue -ForegroundColor Yellow
                }
            }
        }
    }

    if ($ShowAzure) {
        $context = Get-AzContext
        Write-Host "$([char]27)[38;5;227;48;5;30m  $([char]27)[38;5;254m$($context.Account.Id) in $($context.subscription.name) $([char]27)[0m"  -NoNewline -BackgroundColor DarkBlue -ForegroundColor Yellow
    }
    if ($ShowGit) {
        # Write the current Git information
        if ((Get-Command "Get-GitDirectory" -ErrorAction Ignore) -ne $null) {
            if (Get-GitDirectory -ne $null) {
                Write-Host (Write-VcsStatus) -NoNewline
            }
        }
    }

    if ($ShowPath) {
        # Write the current directory, with home folder normalized to ~
        # $currentPath = (get-location).Path.replace($home, "~")
        # $idx = $currentPath.IndexOf("::")
        # if ($idx -gt -1) { $currentPath = $currentPath.Substring($idx + 2) }
        if ($IsLinux) {
            $currentPath = $($pwd.path.Split('/')[-2..-1] -join '/')
        } else {
            $currentPath = $($pwd.path.Split('\')[-2..-1] -join '\')
        }
        Write-Host " " -NoNewline
        Write-Host "$([char]27)[38;5;227;48;5;28m  $([char]27)[38;5;254m$currentPath $([char]27)[0m " -NoNewline -BackgroundColor DarkGreen -ForegroundColor Black

    }
    # Reset LASTEXITCODE so we don't show it over and over again
    $global:LASTEXITCODE = 0

    if ($ShowTime) {
        try {
            Write-Host " " -NoNewline
            $history = Get-History -ErrorAction Ignore
            if ($history) {
                if (([System.Management.Automation.PSTypeName]'Sqlcollaborative.Dbatools.Utility.DbaTimeSpanPretty').Type) {
                    $timemessage = " " + ( [Sqlcollaborative.Dbatools.Utility.DbaTimeSpanPretty]($history[-1].EndExecutionTime - $history[-1].StartExecutionTime))
                    Write-Host $timemessage -ForegroundColor DarkYellow -BackgroundColor DarkGray -NoNewline
                } else {
                    Write-Host " $([Math]::Round(($history[-1].EndExecutionTime - $history[-1].StartExecutionTime).TotalMilliseconds,2))" -ForegroundColor DarkYellow -BackgroundColor DarkGray  -NoNewline
                }
            }
            Write-Host " " -ForegroundColor DarkBlue -NoNewline
        } catch { }
    }
    # Write one + for each level of the pushd stack
    if ((Get-Location -Stack).Count -gt 0) {
        Write-Host " " -NoNewline
        Write-Host (("+" * ((Get-Location -Stack).Count))) -NoNewline -ForegroundColor Cyan
    }

    # Determine if the user is admin, so we color the prompt green or red
    $isAdmin = $false
    $isDesktop = ($PSVersionTable.PSEdition -eq "Desktop")

    if ($isDesktop -or $IsWindows) {
        $windowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $windowsPrincipal = New-Object 'System.Security.Principal.WindowsPrincipal' $windowsIdentity
        $isAdmin = $windowsPrincipal.IsInRole("Administrators") -eq 1
    } else {
        $isAdmin = ((& id -u) -eq 0)
    }

    if ($isAdmin) { $color = $color = "`e[38;5;9;48;5;237m"; }
    else { $color = "`e[38;5;231;48;5;27m "; }


    # Write PS> for desktop PowerShell, pwsh> for PowerShell Core
    if ($isDesktop) {
        Write-Host " PS5>" -NoNewline -ForegroundColor $color
    } else {
        $version = $PSVersionTable.PSVersion.ToString()
        #Write-Host " pwsh $Version>" -NoNewLine -ForegroundColor $color
        Write-Host "$($color)pwsh $Version>" -NoNewline
    }

    # Always have to return something or else we get the default prompt
    return " "
}

######## wof setup
# change the servernames to be dbatoosl - doesn't seem to work in the container build process right now
Invoke-DbaQuery -SqlInstance $dbatools1 -Query "declare @oldSrv sysname; select @oldSrv = srvname from master.dbo.sysservers; EXEC sp_dropserver @oldSrv; EXEC sp_addserver 'dbatools1', local"
Invoke-DbaQuery -SqlInstance $dbatools2 -Query "declare @oldSrv sysname; select @oldSrv = srvname from master.dbo.sysservers; EXEC sp_dropserver @oldSrv; EXEC sp_addserver 'dbatools2', local"

# clear out the export folder
Get-ChildItem ./Export/ | Remove-item -Recurse

# create DatabaseAdmin database
if(-not (Get-DbaDatabase -SqlInstance $dbatools1 -Database DatabaseAdmin)) {
    $null = New-DbaDatabase -SqlInstance $dbatools1 -Name DatabaseAdmin
}

# Begin ToTestRefresh preparation
if(-not (Get-DbaDatabase -SqlInstance $dbatools1 -Database ToTestRefresh)) {
    $null = New-DbaDatabase -SqlInstance $dbatools1 -Name ToTestRefresh -RecoveryModel Simple
}

if(-not (Get-DbaLogin -SqlInstance $dbatools1 -Login PRODLogin)) {
    $null = New-DbaLogin -SqlInstance $dbatools1 -Login PRODLogin -SecurePassword $securePassword
}

if(-not (Get-DbaDbUser -SqlInstance $dbatools1 -Database ToTestRefresh -Login PRODLogin)) {
    $null = New-DbaDbUser -SqlInstance $dbatools1 -Database ToTestRefresh -Username PRODLogin -Login PRODLogin
}

$toRefreshDemoCode = @"
DROP TABLE IF EXISTS [dbo].[TestTable]

CREATE TABLE [dbo].[TestTable] (
    [ID] INT IDENTITY(1,1) PRIMARY KEY,
    [Name] NVARCHAR(100) NOT NULL
)

INSERT INTO [dbo].[TestTable] ([Name])
SELECT 'Data Grillen'

GRANT SELECT, INSERT, UPDATE, DELETE ON [dbo].[TestTable] TO [PRODLogin]

ALTER ROLE [db_datawriter] ADD MEMBER [PRODLogin]
"@

Invoke-DbaQuery -SqlInstance dbatools1 -Database "ToTestRefresh" -Query $toRefreshDemoCode
# End ToTestRefresh preparation

$dbs = @{
    SqlInstance = $dbatools1
    Database    = 'Northwind','Pubs'
}

# set recovery model to full
if ((Get-DbaDbRecoveryModel @dbs).RecoveryModel -ne 'Full') {
    $null = Set-DbaDbRecoveryModel @dbs -RecoveryModel Full
}

# do some backups - stash the full incase we need to restore
$global:fullBackup = Backup-DbaDatabase @dbs -Type Full
$null = Backup-DbaDatabase @dbs -Type Differential
$null = Backup-DbaDatabase @dbs -Type Log

$startImage = '
_    _ _   _  _____ _____ _                
| |  | | | | ||  ___|  ___| |               
| |  | | |_| || |__ | |__ | |               
| |/\| |  _  ||  __||  __|| |               
\  /\  / | | || |___| |___| |____           
 \/  \/\_| |_/\____/\____/\_____/           
 ___________                                
|  _  |  ___|                               
| | | | |_                                  
| | | |  _|                                 
\ \_/ / |                                   
 \___/\_|                                   
______ ___________ _____ _   _ _   _  _____ 
|  ___|  _  | ___ \_   _| | | | \ | ||  ___|
| |_  | | | | |_/ / | | | | | |  \| || |__  
|  _| | | | |    /  | | | | | | . ` ||  __| 
| |   \ \_/ / |\ \  | | | |_| | |\  || |___ 
\_|    \___/\_| \_| \_/  \___/\_| \_/\____/ 
'
# $startImage = '
#                     .----------------.  .----------------.  .----------------.  .----------------.  .----------------.                                         
#                     | .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |                                        
#                     | | _____  _____ | || |  ____  ____  | || |  _________   | || |  _________   | || |   _____      | |                                        
#                     | ||_   _||_   _|| || | |_   ||   _| | || | |_   ___  |  | || | |_   ___  |  | || |  |_   _|     | |                                        
#                     | |  | | /\ | |  | || |   | |__| |   | || |   | |_  \_|  | || |   | |_  \_|  | || |    | |       | |                                        
#                     | |  | |/  \| |  | || |   |  __  |   | || |   |  _|  _   | || |   |  _|  _   | || |    | |   _   | |                                        
#                     | |  |   /\   |  | || |  _| |  | |_  | || |  _| |___/ |  | || |  _| |___/ |  | || |   _| |__/ |  | |                                        
#                     | |  |__/  \__|  | || | |____||____| | || | |_________|  | || | |_________|  | || |  |________|  | |                                        
#                     | |              | || |              | || |              | || |              | || |              | |                                        
#                     | .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |                                        
#                      .----------------.  .----------------.  .----------------.  .----------------.  .----------------.                                         
#                                                    .----------------.  .----------------.                                                                                                     
#                                                   | .--------------. || .--------------. |                                                                                                    
#                                                   | |     ____     | || |  _________   | |                                                                                                    
#                                                   | |   ..    `.   | || | |_   ___  |  | |                                                                                                    
#                                                   | |  /  .--.  \  | || |   | |_  \_|  | |                                                                                                    
#                                                   | |  | |    | |  | || |   |  _|      | |                                                                                                    
#                                                   | |  \  `--.  /  | || |  _| |_       | |                                                                                                    
#                                                   | |   `.____..   | || | |_____|      | |                                                                                                    
#                                                   | |              | || |              | |                                                                                                    
#                                                   | .--------------. || .--------------. |                                                                                                    
#                                                    .----------------.  .----------------.                                                                                                     
#  .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .-----------------. .----------------. 
# | .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |
# | |  _________   | || |     ____     | || |  _______     | || |  _________   | || | _____  _____ | || | ____  _____  | || |  _________   | |
# | | |_   ___  |  | || |   ..    `.   | || | |_   __ \    | || | |  _   _  |  | || ||_   _||_   _|| || ||_   \|_   _| | || | |_   ___  |  | |
# | |   | |_  \_|  | || |  /  .--.  \  | || |   | |__) |   | || | |_/ | | \_|  | || |  | |    | |  | || |  |   \ | |   | || |   | |_  \_|  | |
# | |   |  _|      | || |  | |    | |  | || |   |  __ /    | || |     | |      | || |  | .    . |  | || |  | |\ \| |   | || |   |  _|  _   | |
# | |  _| |_       | || |  \  `--.  /  | || |  _| |  \ \_  | || |    _| |_     | || |   \ `--. /   | || | _| |_\   |_  | || |  _| |___/ |  | |
# | | |_____|      | || |   `.____..   | || | |____| |___| | || |   |_____|    | || |    `.__..    | || ||_____|\____| | || | |_________|  | |
# | |              | || |              | || |              | || |              | || |              | || |              | || |              | |
# | .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |
#  .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------. '


 ## run the game
function Invoke-StartGame {
    ## run tests
    $tests = Invoke-Pester .\Tests\demo.tests.ps1 -PassThru -Show Failed

    if ($tests.FailedCount -ne 0) {
        Write-Output "Tests failed. Please fix the tests before starting the game."
        return
    } else {
        Clear-Host
        $startImage
        
        # get the highest demo we have
        $numberFolders = (Get-ChildItem ./demos -Directory | Where-Object { $_.Name -match '^\d+$' }).name | measure -Maximum -Minimum
        Write-Output "To start the game, run the following command:"
        [int]$num = Read-Host "Spin the wheel, and enter the number..."
                
        while(-not ([int]$num -ge [int]$numberFolders.Minimum -and [int]$num -le [int]$numberFolders.Maximum)) {
            Write-Host "That demo doesn't exist yet. Please spin again." -ForegroundColor Red
            Start-Sleep -Seconds 1
            
            Write-Output "To start the game, run the following command:"
            [int]$num = Read-Host "Spin the wheel, and enter the number..."
        }

        Get-DemoFile -number $num
    }
}

 # function to open the game file
function Get-DemoFile {
    param (
        $number
    )
    try {
        code "demos/$number/$number.ps1"
    } catch {
        code-insiders "demos/$number/$number.ps1"
    }
    cls
}

# function to open the game file
function Invoke-DemoReset {
    Write-Output "Resetting the demo environment..."
    . /workspace/demos/reset.ps1
    
    Invoke-StartGame
}


## start the game
Invoke-StartGame