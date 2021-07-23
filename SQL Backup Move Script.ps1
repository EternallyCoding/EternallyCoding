#Location of the folders you want to scan through
$Start = "\\Server\Share\Folder\Subfolder"

#Location of where the files are to be moved
$End = "\\Server\Share\Folder\Subfolder"

#Deletes all files in destination folder, does not remove folders
Remove-Item -Path $End\*.*

#Change the Filter and Property as needed to find the correct file type and sorting option
Get-ChildItem $Start | ForEach-Object {$Folder = $_} `
{$Item = Get-ChildItem $Start\$Folder -Filter *.bak | Sort-Object -Property LastWriteTime | Select-Object -Last 1} `
{Copy-Item -Path "$Start\$Folder\$Item" -Destination $End} `
-Begin {} -End {}
