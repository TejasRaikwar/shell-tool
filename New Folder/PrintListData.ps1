$username = "isriadmin@sharepointistech.onmicrosoft.com"
$password = "Import@2024#"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $(convertto-securestring $Password -asplaintext -force)
 
Connect-SPOService -Url https://sharepointistech-admin.sharepoint.com -Credential $cred
#https://sharepointistech.sharepoint.com/sites/testTejas

# -------------------
#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

#Variables for processing
$SiteURL = "https://sharepointistech.sharepoint.com/sites/testTejas"

$cred = Get-Credential

#setup the context
$Ctx = New-Object Microsoft.Sharepoint.client.clientcontext($SiteURL)
$Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.UserName,$Cred.Password)
# -------------------

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