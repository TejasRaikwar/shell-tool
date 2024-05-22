#SharePoint List Name
$ListName = "List1"
  
#Get the list
$List = $Ctx.Web.Lists.GetByTitle($ListName)

#Read All Items from the list
$ListItems = $List.GetItems([Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery())
$Ctx.Load($ListItems)
$Ctx.ExecuteQuery()
Write-host "Total Number of Items Found in the List:"$ListItems.Count


#Iterate through List Items
ForEach($Item in $ListItems)
{
    #sharepoint online powershell read list items 
    Write-Host ("List Item ID:{0} - Title:{1} -Name:{2} Designation : {3}" -f $Item["ID"], $Item["Title"],$Item["Name"], $Item["Designation"])
}