#Replace $PSEmailServer value with your email server.
$PSEmailServer = 'gmail.com'
$TotalDisks = $TotalGPUs = $null

$User = Read-Host -Prompt 'Input your LDAP/AD username: '

$Hostname = hostname | Out-String

$ModelType = (Get-CimInstance -ClassName Win32_ComputerSystem).Model

$SerialNumber = (Get-CimInstance CIM_BIOSElement).serialNumber

$Processor = (Get-WmiObject win32_processor | select-object -Property Name).'name'

$Memory = (((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1gb | Out-String).trim()) + "GB"

foreach ($disk in Get-Disk){
	$name = $disk.FriendlyName
	$size = [int](($disk.size)/1gb)
	$TotalDisks += $name + "   " + $size + "GB" + "`n"}

foreach ($GPU in (Get-WmiObject win32_videocontroller | Select-Object -Property 'name')){
    $GPUname = $GPU.Name
    $TotalGPUs += $GPUname + "`n"}

$Addresses = Get-NetAdapter | select MacAddress | Out-String

#Replace 'XXX.YYY' in the -From and -To fields with the email addresses you wish to send From and To, and change instances of $User in both fields as needed.
#Replace ZZZ with your domain 
Send-MailMessage -From "$User <$User@XXX.YYY>" -To '$User <$User@XXX.YYY>' -Subject 'Computer Specs' -Body ("Computer name is " + $Hostname + "`n`n" + "Model is " + $ModelType + "`n`n" + "Serial Number is " + $SerialNumber + "`n`n" + "CPU is " + $Processor + "`n`n" + "RAM is " + $Memory + "`n`n" + "Hard Drive(s) are " + $TotalDisks + "`n`n" + "GPU is " + $TotalGPUs + "`n`n" + $Addresses) -Credential ZZZ\$User
New-Item -Path ~\Desktop -Name "specs.txt" -ItemType "file" -Value ("Serial Number is " + $SerialNumber + "`n`n" + "Model is " + $ModelType + "`n`n" + "Hostname is " + $Hostname + "`n" + "CPU is " + $Processor + "`n`n" + "RAM is " + $Memory + "`n`n" + "Hard Drive(s) are " + $TotalDisks + "`n" + "GPU is " + $TotalGPUs + "`n" + $Addresses)

echo("Email has (likely) been sent. Press enter to exit")

Read-Host
