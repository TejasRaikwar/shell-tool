#import module
Import-Module Microsoft.Online.SharePoint.Powershell -DisableNameChecking

#source and destination Site URLs
$sourceSiteUrl = "https://sharepointistech.sharepoint.com/sites/testTejas";

#set-Credentials
# $credential = Get-Credential

try {
    # Connect to sharepoint online
    # Connect-PnPOnline -url $sourceSiteUrl -Credentials $credential


    
}
catch {
    Write-Host "Something went wrong. Error : $($_.exception.message)"
}