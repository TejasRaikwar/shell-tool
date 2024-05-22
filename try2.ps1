Import-Module SharePointPnPPowerShellOnline -DisableNameChecking;

# $sourceSiteUrl = Read-Host "Enter Source Site URL";
# $sourceSiteCreds = Get-Credential
try {
    # Connect-PnPOnline -url $sourceSiteUrl -Credentials $sourceSiteCreds
    Write-Host "Connected SuccessFully."
    # Get-PnpListItem -list "Tejas List"
    # $list = Get-PnpListItem -List "Tejas List"
    # Write-Host $list.EmpName

    Get-PnPListItem -List "List1" -Fields "Title", "Name" #, "Designation", "Address" 

}
catch {
    throw "Error : $($_.exception.message)"
}