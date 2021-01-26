#####
# Script start.
#####
Write-Host "Script is starting..."
Write-Host "WARNING!!! SAVE AND CLOSE EXCEL BEFORE USE!!!"
Write-Host "The script will continue in 10 seconds any unsaved files in Excel will NOT be saved!!!"

$countdown = 10

do {
    Write-Host $countdown
    Sleep 1
    $countdown--
} while ($countdown -gt 0)

#####
# Modifiable variables. Change $link to the beginning of the web url from Remote Desktop Manager.
#####
$link = "rdm://open?DataSource=F6EC851C-1608-40F3-9E54-3E4474F03252&Repository=00000000-0000-0000-0000-000000000000&Session="

#####
# Static variables.
#####
$name  = Get-RDMSession | select Name
$group = Get-RDMSession | select Group
$id = Get-RDMSession | select ID
# Temporary files used for extracting data from the RDM database.
$name_csv = "$env:TEMP\names.csv"
$group_csv = "$env:TEMP\groups.csv"
$id_csv = "$env:TEMP\ids.csv"

$name_xlsx = "$env:TEMP\names.xlsx"
$group_xlsx = "$env:TEMP\groups.xlsx"
$id_xlsx = "$env:TEMP\ids.xlsx"


#####
# Function for selecting the output directory.
#####
Function Get-Folder($InitialDirectory="")
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")|Out-Null

    $FolderName = New-Object System.Windows.Forms.FolderBrowserDialog
    $FolderName.Description = "Select a folder"
    $FolderName.rootfolder = "MyComputer"
    $FolderName.SelectedPath = $InitialDirectory

    if($FolderName.ShowDialog() -eq "OK")
    {
        $Folder += $FolderName.SelectedPath
    }
    return $Folder
}
$OutputFolder = Get-Folder
$merge_path = "$OutputFolder\RDM_Export.xlsx"

#####
# Foreach loops for extracting objects, converting them to strings, trimming the data to a desirable state, and saving them individually to .csv files.
#####
Write-Host "Extracting data from database..."
Write-Host "Extracting session names from database..."
$names = foreach ($n in $name){
        $aa = [System.String]::Join("", $n).Substring(7).TrimEnd('}') 
        $aa | Out-File $name_csv -Append 
}
Write-Host "Extracting folder paths from database..."
$groups = foreach ($g in $group){
        $aaa = [System.String]::Join("", $g).SubString(8).TrimEnd('}')
        $aaa | Out-File $group_csv -Append
}
Write-Host "Extracting GUIDs from database..."
$ids = foreach ($i in $id) {
        $a = [System.String]::Join("", $i).Substring(5).TrimEnd('}')
        $b = $link+$a
        $b | Out-File $id_csv -Append
}
Write-Host "Data saved..."

#####
# Processes for converting the .csv files to .xlsx files.
#####
Write-Host "Converting .csv files to .xlsx..."
$excel = New-Object -ComObject Excel.Application 
$excel.Visible = $false
$excel.Workbooks.Open("$name_csv").SaveAs("$name_xlsx",51)
$excel.Quit()

$excel = New-Object -ComObject Excel.Application 
$excel.Visible = $false
$excel.Workbooks.Open("$group_csv").SaveAs("$group_xlsx",51)
$excel.Quit()

$excel = New-Object -ComObject Excel.Application 
$excel.Visible = $false
$excel.Workbooks.Open("$id_csv").SaveAs("$id_xlsx",51)
$excel.Quit()
Write-Host "Done..."

#####
# Creating a new .xlsx document where all data will be combined later, saved to previously chosen directory.
#####
Write-Host "Creating output file in '$OutputFolder'..."
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$Workbook = $excel.Workbooks.Add()
$WorkSheet = $Workbook.WorkSheets(1)
$WorkSheet.Cells.Item(1,1) = "Name:"
$WorkSheet.Cells.Item(1,2) = "Folder:"
$WorkSheet.Cells.Item(1,3) = "Link:"
$Workbook.saveas($merge_path)
$Workbook.close
$excel.DisplayAlerts = $false
$excel.Quit()
Write-Host "Done..."

#####
# Process used to copy data from previously created .xlsx files, combining it in the output sheet created previously.
#####
Write-Host "Combining data in '$merge_path'..."
$Excel = New-Object -ComObject Excel.Application
$Excel.Visible = $false

$Workbook_names = $excel.Workbooks.open($name_xlsx)
$Workbook_groups = $excel.Workbooks.Open($group_xlsx)
$Workbook_ids = $excel.Workbooks.Open($id_xlsx)
$Workbook_merge = $excel.Workbooks.Open($merge_path)

$Worksheet_names = $Workbook_names.WorkSheets.item(“names”)
$Worksheet_groups = $Workbook_groups.WorkSheets.item("groups")
$Worksheet_ids = $Workbook_ids.WorkSheets.item("ids")
$Worksheet_merge = $Workbook_merge.WorkSheets.item(1)

$range_names = $Worksheet_names.Range("A1:A10000")
$range_names.Copy() | Out-Null
$merge_names = $Worksheet_merge.Range("A2")
$Worksheet_merge.Paste($merge_names)

$range_groups = $Worksheet_groups.Range("A1:A10000")
$range_groups.Copy() | Out-Null
$merge_groups = $Worksheet_merge.Range("B2")
$Worksheet_merge.Paste($merge_groups)

$range_ids = $Worksheet_ids.Range("A1:A10000")
$range_ids.Copy() | Out-Null
$merge_ids = $Worksheet_merge.Range("C2")
$Worksheet_merge.Paste($merge_ids)

$Workbook_merge.save()
$excel.Quit()
Write-Host "Done..."

#####
# Cleanup.
#####
Write-Host "Cleaning up temporary files..."
Stop-Process -Name "EXCEL"
Remove-Item -Path $name_csv 
Remove-Item -Force -Path $group_csv
Remove-Item -Path $id_csv
Remove-Item -Path $name_xlsx
Remove-Item -Path $group_xlsx
Remove-Item -Path $id_xlsx

Write-Host "Script is done... Output file is located here: '$merge_path'"
Pause