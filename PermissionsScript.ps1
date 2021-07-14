write-host "Run as Administrator!" -foregroundcolor red
$username = read-host -prompt 'Username '
$Server = read-host -prompt "Location of server and share where User Folders are located in '\\Server\Share' format"
$Administrator = read-host -prompt "Domain admin account in 'domain\administrator' format"

Try  {

  $Path = "$Server\$username"

  #Start the job that will reset permissions for each file, don't even start if there are no direct sub-files
  $SubFiles = Get-ChildItem $Path 
  If ($SubFiles)  {
    $Job = Start-Job -ScriptBlock {$args[0] | %{icacls $_.FullName /Reset /C}} -ArgumentList $SubFiles
  }

  #Now go through each $Path's direct folder (if there's any) and start a process to reset the permissions, for each folder.
  $Processes = @()
  $SubFolders = Get-ChildItem $Path
  If ($SubFolders)  {
    Foreach ($SubFolder in $SubFolders)  {
      #Start a process rather than a job, icacls should take way less memory than Powershell+icacls
      $Processes += Start-Process icacls -WindowStyle Hidden -ArgumentList """$($SubFolder.FullName)"" /Reset /T /C" -PassThru
    }
  }

  #Now that all processes/jobs have been started, let's wait for them (first check if there was any subfile/subfolder)
  #Wait for $Job
  If ($SubFiles)  {
    Wait-Job $Job -ErrorAction SilentlyContinue | Out-Null
    Remove-Job $Job
  }

  #Wait for all the processes to end, if there's any still active
}
Catch  {
  $ErrorMessage = $_.Exception.Message
  Throw "There was an error during the script: $($ErrorMessage)"
  $username = read-host -prompt 'username '

}

$acl = Get-Acl $Server\$username

$acl.SetAccessRuleProtection($true,$false)

$usersid = New-Object System.Security.Principal.Ntaccount ($Administrator)

$acl.SetOwner($usersid)



$acl = Get-Acl -Path "$Server\$username"
$acl.SetAccessRuleProtection($true,$false)
$acl.Access | ForEach-Object { $acl.RemoveAccessRule($_) | Out-Null }
$ace = New-Object System.Security.Accesscontrol.FileSystemAccessRule ($username,"modify","Allow")

$acl.AddAccessRule($ace)
Set-Acl -Path "$Server\$username" -AclObject $acl

$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($Administrator,"FullControl","Allow")

$acl.SetAccessRule($AccessRule)

$acl | Set-Acl $Server\$username

$ace = New-Object System.Security.Accesscontrol.FileSystemAccessRule ($Administrator, "FullControl", "ContainerInherit,ObjectInherit", "InheritOnly", "Allow")
$acl.AddAccessRule($ace)

$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$username","modify","Allow")

$acl.SetAccessRule($AccessRule)

$acl | Set-Acl -Path "$Server\$username"

$ace = New-Object System.Security.Accesscontrol.FileSystemAccessRule ("$username", "modify", "ContainerInherit,ObjectInherit", "InheritOnly", "Allow")
$acl.AddAccessRule($ace)

Set-Acl -Path $Server\$username -AclObject $acl
write-host "Process has completed!" -foregroundcolor green
start-sleep 10
