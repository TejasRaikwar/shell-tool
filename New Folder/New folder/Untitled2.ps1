$Cred= Get-Credential
$Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)

#Set parameter values
$SiteURL="https://sharepointistech.sharepoint.com/sites/testTejas"
$ListName="List1"

#Setup the context
$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Ctx.Credentials = $Credentials

#Get the List and list fields
$List = $Ctx.Web.Lists.GetByTitle($ListName)
$Ctx.Load($List)


#sharepoint online powershell get list columns
$Ctx.Load($List.Fields)
$Ctx.ExecuteQuery()
         
#Iterate through each field in the list
Foreach ($Field in $List.Fields)
{   
    #Skip System Fields
    if(($Field.ReadOnlyField -eq $False) -and ($Field.Hidden -eq $False)) 
    {
       #get internal name of sharepoint online list column powershell 
       Write-Host $Field.Title : $Field.InternalName
    }
}