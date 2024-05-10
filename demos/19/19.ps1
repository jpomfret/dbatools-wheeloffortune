#########################################################
#          dbatools: Wheel of Fortune                   #
#          Demo: 19 - HTML Report                       #
#          Host: Jess                                   #
#########################################################

## Using PSHTML to create great looking email reports
## Blog post with more information: https://jesspomfret.com/pshtml-email-reports

## Email details
# $emailTo = 'me@jesspomfret.com'
# $emailFrom = 'reports@jesspomfret.com'
# $emailSubject = ('Authors: {0}' -f (get-date -f yyyy-MM-dd))
# $smtpServer = 'smtp.server.address'

## Query details
$sqlInstance = 'dbatools1'
$database = 'pubs '
$query = @"
SELECT TOP (10) [au_id]
      ,[au_lname]
      ,[au_fname]
      ,[phone]
      ,[address]
      ,[city]
      ,[state]
      ,[zip]
  FROM [dbo].[authors]
"@

$querySplat = @{
    SqlInstance     = $sqlInstance
    Database        = $database
    Query           = $query
    EnableException = $true
}
$results = Invoke-DbaQuery @querySplat

if ($results) {

    $reportCss = "
    table {
        border-collapse: collapse;
    }
    td, th {
        border: 1px solid #ddd;
        padding: 8px;
    }
    tr:nth-child(even){background-color: #f2f2f2;}
    tr:hover {background-color: #ddd;}
    th {
        padding-top: 12px;
        padding-bottom: 12px;
        text-align: left;
        background-color: #13a3a8;
        color: white;
    }
    .fail th {
        padding-top: 12px;
        padding-bottom: 12px;
        text-align: left;
        background-color: #ff6347;
        color: white;
    }
    "

    $html = html {
        head {
            style {
                $reportCss
            }
        }
        body {
            Header {
                h1 {"Author Report: {0}" -f (Get-Date -f 'yyyy-MM-dd')}
            }

            h2 {"Full results:"}
            p {
                "Here are the authors."
            }
            ConvertTo-PSHTMLTable -Object ($results | Sort-Object au_lname, au_fname
            ) -properties au_id, au_lname,au_fname, phone, address, city, state, zip
            
            h2 {"Full results - but bad:"}
            p {
                "Here are the authors."
            }
            ConvertTo-PSHTMLTable -Object ($results | Sort-Object au_lname, au_fname
            ) -properties au_id, au_lname,au_fname, phone, address, city, state, zip -TableClass fail

        }
    }

    # You can output it as a html file to review how it looks
    $html > ./export/test.HTML

   # try {
   #     $emailSplat = @{
   #         To = $emailTo
   #         From = $emailFrom
   #         SmtpServer = $smtpServer
   #         Subject = $emailSubject
   #         Body = $html
   #         BodyAsHtml = $true
   #     }
   #     Send-MailMessage @emailSplat
   # } catch {
   #     Stop-PSFFunction -Message ('Failed to send email') -ErrorRecord $_
   # }
}


# reset and get ready to spin!
Invoke-DemoReset