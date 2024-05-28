#Load SharePoint CSOM Assemblies
Add-Type -Path “C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll”
Add-Type -Path “C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll”


Function Archive-ListItems() {
    param
    (
        [Parameter(Mandatory = $true)] [string] $SourceWebURL,
        [Parameter(Mandatory = $true)] [string] $TargetWebURL,
        [Parameter(Mandatory = $true)] [string] $SourceListTitle,
        [Parameter(Mandatory = $true)] [string] $TargetListTitle
    )
    
    # Create Source Context
    $SourceCredentials = Get-Credential
    $SourceCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($SourceCredentials.UserName, $SourceCredentials.Password)
    $SourceContext = New-Object Microsoft.SharePoint.Client.ClientContext($SourceWebURL)
    $SourceContext.Credentials = $SourceCredentials
    $SourceContext.Load($SourceContext.Web)
    $SourceContext.ExecuteQuery()

    # Create Target Context
    $TargetCredentials = Get-Credential
    $TargetCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($TargetCredentials.UserName, $TargetCredentials.Password)
    $TargetContext = New-Object Microsoft.SharePoint.Client.ClientContext($TargetWebURL)
    $TargetContext.Credentials = $TargetCredentials
    $TargetContext.Load($TargetContext.Web)
    $TargetContext.ExecuteQuery()


    # Get the Source List and Target Lists
    $SourceList = $SourceContext.Web.Lists.GetByTitle($SourceListTitle)
    $SourceContext.Load($SourceList)
    $SourceContext.ExecuteQuery()

    $TargetList = $TargetContext.Web.Lists.GetByTitle($TargetListTitle)
    $TargetContext.Load($TargetList)
    $TargetContext.ExecuteQuery()

    # Get All Items from Source List
    $listItems = $SourceList.GetItems([Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery())
    $SourceContext.Load($listItems)
    $SourceContext.ExecuteQuery()
    
    $counter = 0

    Try {
        #Get each column value from source list and add them to target
        ForEach ($SourceItem in $listItems) {
            $NewItem = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
            $ListItem = $TargetList.AddItem($NewItem)

            #Map each field from source list to target list
            $ListItem[“Name”] = $SourceItem[“Name”]
            $ListItem[“Title”] = $SourceItem[“Title”]
            $ListItem[“SrNo”] = $SourceItem[“SrNo”]
            $ListItem[“Address”] = $SourceItem[“Address”]
            $ListItem[“Designation”] = $SourceItem[“Designation”]
            $ListItem.update()
            $counter++

        }
        $TargetContext.ExecuteQuery()

        write-host -f Green “Total List Items Copied from ‘$SourceListTitle’ to ‘$TargetListTitle’ : $counter”
    }
    Catch {
        Write-Host -f Red “Error Copying List Items!” $_.Exception.Message
    }
}



#Parameters
$SourceWebURL = "https://sharepointistech.sharepoint.com/sites/testTejas"
$TargetWebURL = "https://sharepointistech.sharepoint.com/sites/dstSite"
$SourceListTitle = "List1"
$TargetListTitle = "List1"

#Execute the function to Archive the list items
Archive-ListItems -SourceWebURL $SourceWebURL -TargetWebURL $TargetWebURL -SourceListTitle $SourceListTitle -TargetListTitle $TargetListTitle