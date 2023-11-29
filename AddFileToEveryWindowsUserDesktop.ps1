$profilelist = Resolve-Path C:\Users\* | select -ExpandProperty Path
foreach ($listing in $profilelist)
{
    if ($listing -match 'C\:\\Users\\(?!Administrator|Public)')
    {
    Copy-Item -Path "FILE TO BE DEPLOYED" -Destination $listing"\Desktop"
    }
}
