$SourceSiteURL = "https://sharepointistech.sharepoint.com/sites/testTejas"
$DestinationSiteURL = "https://sharepointistech.sharepoint.com/sites/dstSite"
$ListName = "ListToCopy"
$NewListName = "CopiedList"

$SourceContext = New-Object Microsoft.SharePoint.Client.ClientContext($SourceSiteURL)
$DestinationContext = New-Object Microsoft.SharePoint.Client.ClientContext($DestinationSiteURL)

$SourceList = $SourceContext.Web.Lists.GetByTitle($ListName)
$DestinationList = $DestinationContext.Web.Lists.GetByTitle($NewListName)

$SourceContext.Load($SourceList)
$DestinationContext.Load($DestinationList)

$SourceContext.ExecuteQuery()
$DestinationContext.ExecuteQuery()

$ListItemEnumerator = $SourceList.GetItems([Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery())
$SourceContext.Load($ListItemEnumerator)
$SourceContext.ExecuteQuery()

while ($ListItemEnumerator.MoveNext())
{
    $ListItem = $ListItemEnumerator.Current
    $ListItemType = $ListItem["ContentTypeId"]
    $NewItem = $DestinationList.AddItem([Microsoft.SharePoint.Client.ListItemCreationInformation]::CreateDefault())

    foreach ($Field in $ListItem.FieldValues.Keys)
    {
        $NewItem[$Field] = $ListItem[$Field]
    }

    $NewItem.Update()
    $DestinationContext.ExecuteQuery()
}


