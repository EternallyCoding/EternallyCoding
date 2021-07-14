#Location of the folders you want to scan through
$Start = "\\10.37.1.15\SQL_Backups\Server6"
#Location of where the files are to be moved
$End = "\\10.37.1.15\SQL_Backups\To Remote"

#Change the Filter and Property as needed to find the correct file type and sorting option
Get-ChildItem $Start | ForEach-Object {$Folder = $_} `
{$Item = Get-ChildItem $Start\$Folder -Filter *.bak | Sort-Object -Property LastWriteTime | Select-Object -Last 1} `
{Copy-Item -Path "$Start\$Folder\$Item" -Destination $End} `
-Begin {} -End {}