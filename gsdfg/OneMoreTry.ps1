#Load SharePoint CSOM Assemblies
Add-Type -Path “C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll”
Add-Type -Path “C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll”

Function Archive-ListItems() {
    param
    (
        [Parameter(Mandatory = $true)] [string] $SiteURL,
        [Parameter(Mandatory = $true)] [string] $SourceListTitle,
        [Parameter(Mandatory = $true)] [string] $TargetListTitle
    )

    #Setup Credentials to connect
    $Credentials = Get-Credential
    $Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Credentials.UserName, $Credentials.Password)

    #Setup the context
    $Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
    $Context.Credentials = $Credentials
    $Context.Load($Context.Web)
    $Context.ExecuteQuery()

    #Get the Source List and Target Lists
    $SourceList = $Context.Web.Lists.GetByTitle($SourceListTitle)
    $TargetList = $Context.Web.Lists.GetByTitle($TargetListTitle)
    $Context.Load($SourceList)
    $Context.Load($TargetList)
    $Context.ExecuteQuery()

    #Get All Items from Source List
    $listItems = $SourceList.GetItems([Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery())
    $Context.Load($listItems)
    $Context.ExecuteQuery()

    $counter = 0

    Try {
        #Get each column value from source list and add them to target
        ForEach ($SourceItem in $listItems) {
            $NewItem = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
            $ListItem = $TargetList.AddItem($NewItem)
            Write-Host $SourceItem.Title
            #Map each field from source list to target list
            $ListItem[“Name”] = $SourceItem[“Name”]
            $ListItem[“Title”] = $SourceItem[“Title”]
            $ListItem[“SrNo”] = $SourceItem[“SrNo”]
            $ListItem[“Address”] = $SourceItem[“Address”]
            $ListItem[“Designation”] = $SourceItem[“Designation”]
            $ListItem.update()
            $counter++

        }
        #$Context.ExecuteQuery()
        write-host -f Green “Total List Items Copied from ‘$SourceListTitle’ to ‘$TargetListTitle’ : $counter”
    }
    Catch {
        write-host -f Red “Error Copying List Items!” $_.Exception.Message
    }
}

#Parameters
$SiteURL = “https://sharepointistech.sharepoint.com/sites/testTejas”
$SourceListTitle = "List1"
$TargetListTitle = "List1"

#Execute the function to Archive the list items
Archive-ListItems -siteURL $SiteURL -SourceListTitle $SourceListTitle -TargetListTitle $TargetListTitle