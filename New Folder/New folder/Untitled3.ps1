
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $(convertto-securestring $Password -asplaintext -force)
 
Connect-SPOService -Url https://sharepointistech-admin.sharepoint.com -Credential $cred
#https://sharepointistech.sharepoint.com/sites/testTejas