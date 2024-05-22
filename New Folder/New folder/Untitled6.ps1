# Copy All Lists from One Site to Another
#Import-Module Microsoft.Online.SharePoint.PowerShell -Verbose
#Add-PSSnapin Microsoft.sharepoint.PowerShell -ErrorAction SilentlyContinue

Function CopyList([String] $SourceWebURL, [string]$TargetWebURL, [String]$ListName, [string]$BackupPath)
{
    # Get Source List
    $SourceList = (Get-PnPWeb $SourceWebURL).Lists[$ListName]

    #Export the list fro, source web
    Export-SPweb $SourceWebURL -ItemUrl $SourceList.defaultViewUrl -IncludeuserSecurity _IncludeVersions All -path ($BackupPath + $ListName +".cmp") -nologfile -Force

    #Import the List to Target Web
    import-spweb $TargetWebURL -IncludeUserSecurity -path ($BackupPath + $ListName + ".cmp") -nologfile -UpdateVersions Overwrite
    
}

#Get All List Names
$Lists = @($(Get-PnPWeb $SourceWebURL).lists)

foreach($List in $Lists)
{
    #Leave the Hidden Lists and exclude certain Libraries
    if($List.Hidden -eq $false -and $List.Title -ne "Style Library" -and $List.Title -ne "Site Pages")
    {
      #Call the function to copy
      CopyList "https://sharepointistech.sharepoint.com/sites/testTejas" "https://sharepointistech.sharepoint.com/sites/dstSite" $List.Title "C:\Temp\"
    }
}
Write-Host "Completed Copying Lists!"