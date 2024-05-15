#import module
Import-Module Microsoft.Online.SharePoint.Powershell -DisableNameChecking

#source and destination Site URLs
$sourceSiteUrl = "https://sharepointistech.sharepoint.com/sites/testTejas";
$destinationSiteURL = "https://sharepointistech.sharepoint.com/sites/dstSite";

#set-Credentials
# $credential = Get-Credential

try {
    # Connect to sharepoint online
    # Connect-PnPOnline -url $sourceSiteUrl -Credentials $credential

    #get-List
    $lists = Get-PnPList 

    foreach ($list in $lists) {
        $listTitle = $list.Title
        $listId = $list.Id

        #Get list Items from the list 
        $items = Get-PnPListItem -list $listTitle

        # Loop through each item and copy it to the destination list
        foreach ($item in $items) {
            Write-Host "$item"
            Add-PnPListItem -List $listTitle -Values $item.FieldValues -Web $destinationSiteUrl
        }

    }
    Write-Host "List '$listTitle' copied successfully."
}
catch {
    Write-Warning "Please Give Valid Creds, Error :$($_.exception.message)"
}
