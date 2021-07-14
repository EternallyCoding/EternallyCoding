#Script finds every computer in AD that has not been logged in to for the past year and moves them to the Obsoleted Computers OU

#Increase the absolute value of -365 to go back farther

#Change Get-ADComputer to Get-ADUser and OU=Obsoleted Computers to OU=Obsoleted Users for Users

import-module activedirectory

$datecutoff = (Get-Date).AddDays(-365)

Get-ADComputer -Properties LastLogonDate -Filter {LastLogonDate -lt $datecutoff} | Move-ADObject -TargetPath "OU=Obsoleted Computers,DC=mddomain,DC=local"
