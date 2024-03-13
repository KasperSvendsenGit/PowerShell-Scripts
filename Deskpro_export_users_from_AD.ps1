$CustomerName = "Customer" # Has to match Deskpro Organization name
$SearchBase = "OU=users,DC=example,DC=local" # Insert the SearchBase path to limit results
$Language = "en-US"

$CustomerFileName = $CustomerName.Replace(" ","")
$Date = Get-Date -Format "yyyy-mm-dd_HH-mm"
$OutFileTemp = "C:\temp\Deskpro-powershell-temp.txt" # Change the path if you want the output in a different directory
$OutFileFinal = "C:\temp\$CustomerFileName-DeskproUsers-$Date.csv" # Change the path if you want the output in a different directory
New-Item -ItemType File -Path $OutFileFinal

# Get AD users' properties
$Users = Get-ADUser -LDAPFilter "(&(objectCategory=person)(objectClass=user)( !(userAccountControl:1.2.840.113556.1.4.803:=2)(mail=*)))" -SearchBase $SearchBase -Properties * | `
Select @{Name = 'Name'; Expression = {$_.displayname}}, `
@{Name = 'Email'; Expression = {$_.mail}}, `
@{Name = 'Phone'; Expression = {$_.mobile.replace(" ","")}}, `
@{Name = 'Phone2'; Expression = {$_.telephoneNumber.replace(" ","")}}, 
@{Name = 'Organization Position'; Expression = {$_.Title.replace(',','')}}, `
@{Name = 'Organization'; Expression = {$CustomerName}}, `
@{Name = 'Language'; Expression = {$Language}} |
Export-Csv -Path $OutFileTemp -Delimiter "," -NoTypeInformation -Force -Encoding UTF8

# Remove " from file
(Get-Content $OutFileTemp -Encoding UTF8) -replace '"','' | Set-Content $OutFileFinal -Encoding utf8 

# Cleanup temp file after use
Remove-Item $OutFileTemp







