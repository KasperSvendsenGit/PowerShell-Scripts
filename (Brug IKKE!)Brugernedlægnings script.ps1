# Master script compiled from multiple scripts for disabling users correctly at 3XN.



######## Part 0: Prelude.
$userinit = Read-Host "Please enter the username of the user you'd like to disable."
$UPN = "$userinit@3xn.dk"
Get-ADUser $userinit -Properties Name
Write-Host "Please verify the username is correct!!! Exiting the script after this point will make changes to $UPN"
Write-Host " "
start-sleep (5)
Read-Host -Prompt "Press ENTER to continue or CTRL+C to quit."



######## Part 1: Save previous group memberships in user description.
Write-Host "Part 1: Save previous group memberships in user description."

# Part 1.1: Get current group memberships.
$users=Get-ADUser -filter * -Properties samaccountname,memberof  |select name,samaccountname @{n=’MemberOf’; e= { ( $_.memberof | % { (Get-ADObject $_).Name }) -join “,” }} | Out-GridView -PassThru 
Write-Host " "
Write-Host "Please select the user from the menu, finish with OK."

# Part 1.2: Save curremt group memberships in user description.
Foreach ($user in $users)
{ Set-ADUser $user.samaccountname -Description "Was a member of: $($user.memberof)"}

# Part 1.3: Verify information.
Get-ADUser -Identity $userinit -Properties Description | Select-Object -ExpandProperty Description
Write-Host " "
Write-Host 'Please verify that the output is correct, should look something like this: "Was a member of: Group1,Group2,Group3..."'
Write-Host " "
Read-Host -Prompt "Press ENTER to continue or CTRL+C if the information is incorrect"



######## Part 2: Remove Anja's calendar rights.
Write-Host "Part 2: Remove Anja's calendar rights:"

# Part 2.0: Load Microsoft Exchange Powershell Snapin.
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn 

# Part 2.1: Verify information
Get-ADUser $userinit -Properties Name
Write-Host " "
Write-Host "Please verify the username is correct."
Write-Host " "
Read-Host -Prompt "Press ENTER to continue or CTRL+C if the information is incorrect"

# Part 2.2: Removal of permissions.
Remove-MailboxFolderPermission -identity "$userinit@3XN.DK:\kalender" -User alh@3xn.dk -confirm:$false 
Remove-MailboxFolderPermission -identity "$userinit@3XN.DK:\calendar" -User alh@3xn.dk -confirm:$false

# Part 2.3: Verify permission removal.
Get-MailboxFolderPermission -Identity "$userinit@3XN.DK:\kalender"
Get-MailboxFolderPermission -Identity "$userinit@3XN.DK:\calendar"
Write-Host " "
Write-Host "Please verify permissions has been removed from $userinit"
Write-Host " "
Read-Host -Prompt "Press ENTER to continue or CTRL+C if the information is incorrect"



######## Part 3: Remove user from all groups and distribution groups.
Write-Host "Part 3: Remove user from all groups and distribution groups."

# Part 3.0: Load Microsoft Exchange Powershell Snapin.
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn 

# Part 3.1: Verify information
Get-ADUser $userinit -Properties Name
Write-Host " "
Write-Host "Please verify the username is correct."
Write-Host " "
Read-Host -Prompt "Press ENTER to continue or CTRL+C if the information is incorrect"

# Part 3.2: Remove user from ALL Groups.
Remove-ADGroupMember -Identity "01 3xn alle" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "01 3xn kbh alle" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "02 3xn administration" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "04 3xn kbh chef" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1232_intern" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1256 Bathurst Street" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "3XN Apple ID" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "3XN hovedmail" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "3XN Sydney" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "Aconex" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "Autodesk" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "Competition" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "Digitaltutors admin mail" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "EDB-Alerts" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "EDB-Support" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "GXN" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "Kanonbaadsvej" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "McNeel _ Rhino etc" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "Platanvej" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "Stockholm" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "webmaster" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "00 CAD_change" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "00CAD" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1005 Godsbanen" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1023 KU - BE Frederiksberg" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1041 Vällingby" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1043Lighthouse" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1048Swedbank" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1050 LH-bygning G" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1053UADM_Uppsala" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1057 AAU FIB14" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1061 Amager forbrænding" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1067 LH-bygning L" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1080Odenplan_Stockholm" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1081 La Tour" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1084 Bremen 3 Stockholm" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1089 Rigshospitalet Patienthotel" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1092 Retten i Roskilde" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1100 Orgelpipan" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1100 Reservalternativ" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1108 Arena" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1112Lautrupsgade" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1114 Søborg Hovedgade" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1115GreenSolutionHouse" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1126 Lighthouse X2" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1132 APM Cambrigde" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1133 AAU Institut for læring" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1134 Lautrupsgade EKF" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1137 Riddaren" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1138 Hagalund" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1140 Stenhöga P-hus" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1145 DHBW Stuttgart" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1151 Valparaiso" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1154 IOC Headquarters" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1166 Dream Center" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1167 Eskilstuna Högskola" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1171 QQS" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1192 ICA HQ" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1194Lego" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1196StenhögaHotel" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1204 Knights Road" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1205 Ørestad Gym - Tagprojekt II" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1206 Toronto Waterfront" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1208BourkeStreet" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1210CPHAirportFingerE" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1214 Uppsala Stadshus" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1217 Londonviadukten Stockholm" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1220 Grognon" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1232 Simhall Linköping" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1233 Børneriget" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1237 Weston" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1241 Church Wellesley" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1248 Hallonbergen" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1248 Hallonbergen and Rissne - City Development" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1248 Rissne" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1250 Innovationscampus Freimann" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1251 Sydney Fish Market" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1254 Toronto Bayside" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1263KvHydran-Västerås" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1267 Saxo Bank" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1268_CIE_Alsion" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1274 Centerpoint" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1277 Laanderpoort" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1278 Vasby entre" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1284 Mærsk Cafe" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1290 Klimatorium Lemvig" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1297 Queens Quay Place" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1301 Sportarena Olympiapark Munich" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1307 UNSW" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1309 Hagaporten" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1313 P-hus Arena" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1330 Broadgate London" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1335 Valira Project Andorra" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "1348 Forskaren-11415605231" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "2002Bombardier" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "33300FIH" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "33600WorldOn-line" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "34000Boligerisydfrankrig" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "34300Siemens" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "36500chpatrium" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "36700galleriernehillerød" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "37501søndrefrihavn" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "37901sampension" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "3XN Applications" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "3XN Stockholm Calendar" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "40000EUDP" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "550001_Piccadilly" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "550002_MacquariePark" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "74021fiberline" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "74031skovbrynetiholte" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "74041plejecenteribramdrup" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "74102butikscenterodense" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "74132nytfaengselostfold" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "74162dalbyskoledalbyhus" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "74252syddansk" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "74304800MoLDetermination" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "74452sid-udvidelse" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "74553gymnasiumorestaden" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "74833 Tangen" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "74884nordsoemuseethirtshals" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "75164 AF Arkitekternes Hus Strandgade" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "75294Shanghai_Shui On" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "75304Liverpool" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "75334saxobank" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "75375_Ressort_i_Tyrkiet" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "75545M2Villaprojekt" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "75605MiddelfartSparekasse" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "75865_Stadshuis_Nieuwegein" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "75875Almere" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "75875Almere_ADM" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "76036LightHouse" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "76066BellaHotel" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "76106DLACarlsberg" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "76146HorsensStadion" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "76276Samson" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "76357Munkeengen_i_Hillerod" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "76467Molde" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "76477KPMG" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "76547RambollLAB" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "76577Mandal" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "76637VivicoCube" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "76697 KPMG Glostrup" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "76728 DBP_Ombyg" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "76728DBP" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "76818CortAdelersgade" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "77048DublinConcertHall" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "77099FNByen" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "77100FNetape2" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "77179Retten" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "97241adam" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "98276bruunsgalleri" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "98276hojhuset" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "99295finland" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "99297sparekassenkronjylland" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "99307trekroner" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "99322amerikakaj" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "99330nyapedagogen" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "Database_kontakter-change" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "Database_kontakter-full" -Members $userinit -Confirm:$false
Remove-ADGroupMember -Identity "PF-Fakturering" -Members $userinit -Confirm:$false



######## Part 4: Hide user Global Address lists and other address lists.

# Part 4.1: Verify information
Get-ADUser $userinit -Properties Name
Write-Host " "
Write-Host "Please verify the username is correct."
Write-Host " "
Read-Host -Prompt "Press ENTER to continue or CTRL+C if the information is incorrect"

# Part 4.1: Hide user from address lists.
Set-Mailbox -HiddenFromAddressListsEnabled $true -Identity $userinit


######## Part 5: Disable in Active Directory.

# Part 5.1: Disable the user from Active Directory.
Disable-ADAccount -Identity $userinit



######## Part 6: Remove license from Office 365 account:

# Part 6.1: Warning.
Write-Host "WARNING! This will remove all Office 365 Licenses from $userinit@3xn.dk"
Write-Host " "

# Part 6.2: Get credentials for Office 365.
$Office365Admin = Get-Credential -Credential administrator@3XN.onmicrosoft.com
Connect-MsolService -Credential $Office365Admin

# Part 6.3: Remove licenses assigned to user.
(get-MsolUser -UserPrincipalName $UPN).licenses.AccountSkuId |
foreach{
    Set-MsolUserLicense -UserPrincipalName $UPN -RemoveLicenses $_
}

# Part 6.4: Verification.
Get-MsolUser -UserPrincipalName $UPN | fl Displayname,UserPrincipalName,licenses
Write-Host "Please verify the user doesn't have any licenses assigned."
start-sleep (5)




######## Part X: Postlude
Write-Host "Script is done running."
Write-Host " "
Read-Host -Prompt "Press ENTER to continue..."



<#
Additional features:



connect to adsync server and run sync cycle

#>

<#
User creation script ideas:

copy from other user
connecto to adsync server and run sync cycle
add o365 licence without exch online: https://docs.microsoft.com/en-us/office365/enterprise/powershell/disable-access-to-services-with-office-365-powershell
https://docs.microsoft.com/en-us/office365/enterprise/powershell/assign-licenses-to-user-accounts-with-office-365-powershell


$UsageLocation = Read-Host "Please enter the users location in country code e.g. DK, US, GB, for Denmark, United States, Great Britain"

Set-MsolUser -UserPrincipalName $userinit@3xn.dk -UsageLocation $UsageLocation

#>