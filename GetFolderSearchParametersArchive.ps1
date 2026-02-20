#########################################################################################################
# This PowerShell script will prompt you for:                                #
#    * Admin credentials for a user with permissions to run Get-MailboxFolderStatistics in Exchange    #
#      Online and eDiscovery Manager rights in Microsoft Purview.                        #
# The script will then:                                            #
#    * If an email address is supplied: list the folders from the ONLINE ARCHIVE of the target mailbox.    #
#    * The script supplies the search property (folderid:) with the encoded FolderId for use in a        #
#      Content Search.                                            #
# Notes:                                                #
#    * Only the specified folder is searched; sub-folders are not included.                    #
#########################################################################################################

# Collect the target email address
$emailAddress = Read-Host "Enter the email address of the online archive mailbox"

# Authenticate with Exchange Online
if ($emailAddress.IndexOf("@") -ige 0) {
    # Connect to Exchange Online PowerShell
    if (-not (Get-Command Get-MailboxFolderStatistics -ErrorAction SilentlyContinue)) {
        Import-Module ExchangeOnlineManagement
        Connect-ExchangeOnline -ShowBanner:$false -CommandName Get-MailboxFolderStatistics
    }

    # Retrieve folder statistics from the ONLINE ARCHIVE
    $folderStatistics = Get-MailboxFolderStatistics $emailAddress -Archive

    # Process folders to extract and encode FolderIds
    $folderQueries = @()
    foreach ($folderStatistic in $folderStatistics) {
        $folderId = $folderStatistic.FolderId
        $folderPath = $folderStatistic.FolderPath

        # Encode FolderId for Content Search syntax (folderid:)
        $encoding = [System.Text.Encoding]::GetEncoding("us-ascii")
        $nibbler = $encoding.GetBytes("0123456789ABCDEF")
        $folderIdBytes = [Convert]::FromBase64String($folderId)
        $indexIdBytes = New-Object byte[] 48
        $indexIdIdx = 0

        $folderIdBytes | Select-Object -Skip 23 -First 24 | ForEach-Object {
            $indexIdBytes[$indexIdIdx++] = $nibbler[$_ -shr 4]
            $indexIdBytes[$indexIdIdx++] = $nibbler[$_ -band 0xF]
        }

        $folderQuery = "folderid:$($encoding.GetString($indexIdBytes))"
        $folderQueries += [PSCustomObject]@{
            FolderPath  = $folderPath
            FolderQuery = $folderQuery
        }
    }

    # Output results
    Write-Host "-----Online Archive Folders-----"
    $folderQueries | Format-Table -AutoSize
} else {
    Write-Error "Invalid email address: $emailAddress"
}