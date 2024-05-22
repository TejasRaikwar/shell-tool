#Add the PowerShell snap in code  
Add-PSSnapIn Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue | Out-Null  
#Provide a site collection to load the metadata properties from the SharePoint Central Admin where you metadata Database is connected  
$siteCollectionUrl = "https://sharepointistech.sharepoint.com/sites/testTejas"  
$site =new-object Microsoft.SharePoint.SPSite($siteCollectionUrl)  
#Get the Taxanomy  
$session = New-Object Microsoft.SharePoint.Taxonomy.TaxonomySession($site)  
#Get the Termstore  
$termStore = $session.TermStores[0]  
#Provide the term store group you want to load and get connected  
$group = $termStore.Groups["Test"]  
#Provide the termset you want to load  
$termSet = $group.TermSets["Test1"]  
#Get all the desired terms.  
$terms = $termSet.GetAllTerms()  
Write-Host "SharePoint Database Connected"  
#Load the SharePoint Metadata in a Dataset  
#Create a table  
$tabName = “SampleTable”  
$table = New-Object system.Data.DataTable “$tabName”  
$col1 = New-Object system.Data.DataColumn Test1,([string])  
$col2 = New-Object system.Data.DataColumn Test2,([string])  
#Load the columns  
$table.columns.add($col1)  
$table.columns.add($col2)  
foreach ($term in $terms)  
{  
   $lblid = $term.Labels[1].Value;  
   $termname = $term.Name  
   $row = $table.NewRow()  
   $row.Test1row = $lblid  
   $row. Test2row = $termname  
   $table.Rows.Add($row)  
}  
#You will get all the content in the table  