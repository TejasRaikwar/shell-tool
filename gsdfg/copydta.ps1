# Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

Function CopyData {
    param(
        [String] $SourceWebURL,
        [pscredential] $SourceCredentials,
        [String] $TargetWebURL,
        [pscredential] $TargetCredentials,
        [String] $ListName
    )

    # Create Source Context
    $SourceCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($SourceCredentials.UserName, $SourceCredentials.Password)
    $SourceContext = New-Object Microsoft.SharePoint.Client.ClientContext($SourceWebURL)
    $SourceContext.Credentials = $SourceCredentials
    $SourceContext.Load($SourceContext.Web)
    $SourceContext.ExecuteQuery()

    # Create Target Context
    $TargetCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($TargetCredentials.UserName, $TargetCredentials.Password)
    $TargetContext = New-Object Microsoft.SharePoint.Client.ClientContext($TargetWebURL)
    $TargetContext.Credentials = $TargetCredentials
    $TargetContext.Load($TargetContext.Web)
    $TargetContext.ExecuteQuery()

    # Get the Source List and Target Lists
    $SourceList = $SourceContext.Web.Lists.GetByTitle($ListName)
    $SourceContext.Load($SourceList)
    $SourceContext.ExecuteQuery()

    $TargetList = $TargetContext.Web.Lists.GetByTitle($ListName)
    $TargetContext.Load($TargetList)
    $TargetContext.ExecuteQuery()

    # Get All Items from Source List
    $listItems = $SourceList.GetItems([Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery())
    $SourceContext.Load($listItems)
    $SourceContext.ExecuteQuery()

    $counter = 0

    # Try {
    #     # Get each column value from source list and add them to target
    #     ForEach ($SourceItem in $listItems) {
    #         $NewItem = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
    #         $ListItem = $TargetList.AddItem($NewItem)

    #         foreach ($field in $SourceItem.FieldValues.GetEnumerator()) {
    #             Write-Host "entered"
    #             $FieldName = $field.Key
    #             $FieldValue = $field.Value

    #             Write-Host "FieldName : $FieldName , FieldValue : $FieldValue"
    #         }
    #         # $ListItem.update()
    #         $counter++
    #     }
    #     # $TargetContext.ExecuteQuery()
    #     # Write-Host -f Green “Total List Items Copied from ‘$SourceListTitle’ to ‘$TargetListTitle’ : $counter”
    # }
    # Catch {
    #     Write-Host -f Red “Error Copying List Items!” $_.Exception.Message
    # }
}

Function CopyList {
    param(
        [String] $SourceWebURL,
        [String] $TargetWebURL,
        [String] $ListName,
        [String] $BackupPath
    )

    # Connect to the source site
    Connect-PnPOnline -Url $SourceWebURL -UseWebLogin

    # Export the list schema (not data) from the source
    $TemplatePath = Join-Path -Path $BackupPath -ChildPath "$ListName.xml"
    Get-PnPProvisioningTemplate -Out $TemplatePath -Handlers Lists -ListsToExtract $ListName

    # Connect to the target site
    Connect-PnPOnline -Url $TargetWebURL -UseWebLogin

    # Apply the schema to the target site
    Apply-PnPProvisioningTemplate -Path $TemplatePath

    # Get the source list items
    Connect-PnPOnline -Url $SourceWebURL -UseWebLogin
    $Items = Get-PnPListItem -List $ListName

    # Add items to the target list
    Connect-PnPOnline -Url $TargetWebURL -UseWebLogin
    foreach ($Item in $Items) {
        $FieldValues = @{}
        foreach ($Field in $Item.FieldValues.Keys) {
            # Skip system/internal fields
            if ($Field -notmatch "(_|Attachments|ContentTypeId|Modified|Created|Author|Editor|ID|GUID|Path)") {
                $Value = $Item[$Field]
                try {
                    # Handle different field types
                    if ($Value -is [DateTime]) {
                        $FieldValues[$Field] = $Value.ToString("yyyy-MM-ddTHH:mm:ssZ")
                    }
                    elseif ($Value -is [Microsoft.SharePoint.Client.FieldUserValue]) {
                        $FieldValues[$Field] = $Value.LookupId
                    }
                    elseif ($Value -is [Microsoft.SharePoint.Client.FieldLookupValue]) {
                        $FieldValues[$Field] = $Value.LookupId
                    }
                    elseif ($Value -is [Microsoft.SharePoint.Client.FieldLookupValue[]]) {
                        $FieldValues[$Field] = $Value | ForEach-Object { $_.LookupId }
                    }
                    else {
                        $FieldValues[$Field] = $Value
                    }
                }
                catch {
                    Write-Host "Failed to process field '$Field' with value '$Value': $($_.Exception.Message)"
                }
            }
        }
    }
}

# Source and target site URLs
$SourceWebURL = "https://sharepointistech.sharepoint.com/sites/testTejas"
$SourceCredentials = Get-Credential
$TargetWebURL = "https://sharepointistech.sharepoint.com/sites/dstSite"
$TargetCredentials = Get-Credential
$BackupPath = "C:\Temp"

# Connect to the source site to get all lists
Connect-PnPOnline -Url $SourceWebURL -UseWebLogin
$Lists = Get-PnPList

foreach ($List in $Lists) {
    Write-Host -f yellow "List : " $List.Title
    # Leave the Hidden Lists and exclude certain Libraries
    if ($List.Hidden -eq $false -and $List.Title -ne "Style Library" -and $List.Title -ne "Site Pages" -and $List.Title -ne "Preservation Hold Library") {
        # Call the function to copy
        CopyList -SourceWebURL $SourceWebURL -TargetWebURL $TargetWebURL -ListName $List.Title -BackupPath $BackupPath
    }
}

Write-Host "Columns Created"
Write-Host "Copying Data"
# ------------ To copy Data ----------------
foreach ($List in $Lists) {
    Write-Host -f yellow "List : " $List.Title
    # Leave the Hidden Lists and exclude certain Libraries
    if ($List.Hidden -eq $false -and $List.Title -ne "Style Library" -and $List.Title -ne "Site Pages" -and $List.Title -ne "Preservation Hold Library") {
        # Call the function to copy
        CopyData -SourceWebURL $SourceWebURL -SourceCredentials $SourceCredentials -TargetWebURL $TargetWebURL -TargetCredentials $TargetCredentials -ListName $List.Title
    }
}
Write-Host -f Green "Completed Copying Lists!"
