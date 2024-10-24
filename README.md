# dbatools Wheel Of Fortune
Jess & Cláudio show off dbatools with a fun game 

## abstract

Ad voice: Want to play Wheel of Fortune dbatools style?

Come and join us on a demo-driven session where you will be the player and we gift you with some next-level demos using dbatools!

Spin the wheel and let luck be with you!

There are so many things we want to show you with dbatools that we couldn't decide - so now you decide!

Demos could include:
- Managing Availability Groups
- Migrating databases
- Refreshing test environments
- Masking sensitive data
- Checking we're meeting best practices
- Managing Logins, Users & Permissions
- Using Database Snapshots for Application Upgrades
- Document your entire SQL environment
- Backups and Restores
- Copy table data around
- Deploy tools including WhoIsActive & Ola maintenance scripts
- Patching SQL Servers
- Finding objects
- and others - who knows where the wheel may take us

## AutoSpin functionality

For when we do this online we can now enable autospin - by setting a global variable
`$global:Autospin = $true`

Also reset the `numbers.json` file with all the numbers we need
`1..20 | ConvertTo-Json | set-content ./Containers/dbatoolswof/Profile/numbers.json`

## Checklist
- dev container built
- `c:\github` folder open in explorer
- be connected to the internet
- open SSMS
- post its for chairs to select people
- zoomit running
- reset the numbers.json
    `1..20 | ConvertTo-Json | set-content ./Containers/dbatoolswof/Profile/numbers.json`
