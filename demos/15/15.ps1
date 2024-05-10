#########################################################
#          dbatools: Wheel of Fortune                   #
#          Demo: 15 - Find Objects Owned by a user      #
#          Host: Cláudio                                #
#########################################################

# If you want to read more about a real use case, check this blog post: 
# https://claudioessilva.eu/2020/09/03/When-one-of-your-DBA-colleagues-leaves-the-company-what-is-your-checklist/

# Normally you would like to search for some AD account
$pattern = 'sqladmin'

#Find objects owned by a specific user
Find-DbaUserObject -SqlInstance dbatools1 -Pattern $pattern

# Format as table
Find-DbaUserObject -SqlInstance dbatools1 -Pattern $pattern | Format-Table

# Output as Console GridView
Find-DbaUserObject -SqlInstance dbatools1 -Pattern $pattern | Out-ConsoleGridView


<#
What will it search?
    - Database Owner
    - Agent Job Owner
    - Used in Credential
    - Used in Proxy
    - SQL Agent Steps using a Proxy
    - Endpoints
    - Server Roles
    - Database Schemas
    - Database Roles
    - Database Assembles
    - Database Synonyms
#>


# reset and get ready to spin!
Invoke-DemoReset