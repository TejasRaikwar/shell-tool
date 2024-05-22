$listName = "List1"
$list = Get-PnPList -Identity $listName
$list | Format-List
