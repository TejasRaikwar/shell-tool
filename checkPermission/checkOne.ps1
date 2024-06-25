# Load necessary modules
Import-Module Microsoft.Online.SharePoint.PowerShell
Import-Module PnP.PowerShell

# Connect to SharePoint Online
$siteUrl = "https://sharepointistech.sharepoint.com/sites/testTejas"
Connect-PnPOnline -Url $siteUrl -UseWebLogin

# Function to get permissions for a web
function Get-WebPermissions {
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.SharePoint.Client.Web]$Web
    )

    $permissions = @()
    $webRoleAssignments = Get-PnPProperty -ClientObject $Web.RoleAssignments -Property RoleAssignments

    foreach ($roleAssignment in $webRoleAssignments) {
        $member = Get-PnPProperty -ClientObject $roleAssignment.Member -Property PrincipalType, Title, LoginName
        $roles = Get-PnPProperty -ClientObject $roleAssignment.RoleDefinitionBindings -Property Name

        foreach ($role in $roles) {
            $permissions += [PSCustomObject]@{
                WebUrl    = $Web.Url
                Principal = $member.Title
                LoginName = $member.LoginName
                Role      = $role.Name
            }
        }
    }
    return $permissions
}

# Function to get permissions for all lists in a web
function Get-ListPermissions {
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.SharePoint.Client.Web]$Web
    )

    $permissions = @()
    $lists = Get-PnPList -Web $Web

    foreach ($list in $lists) {
        $listRoleAssignments = Get-PnPProperty -ClientObject $list.RoleAssignments -Property RoleAssignments

        foreach ($roleAssignment in $listRoleAssignments) {
            $member = Get-PnPProperty -ClientObject $roleAssignment.Member -Property PrincipalType, Title, LoginName
            $roles = Get-PnPProperty -ClientObject $roleAssignment.RoleDefinitionBindings -Property Name

            foreach ($role in $roles) {
                $permissions += [PSCustomObject]@{
                    ListUrl   = $list.DefaultViewUrl
                    ListTitle = $list.Title
                    Principal = $member.Title
                    LoginName = $member.LoginName
                    Role      = $role.Name
                }
            }
        }
    }
    return $permissions
}

# Function to get all subsites recursively and their permissions
function Get-AllWebPermissions {
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.SharePoint.Client.Web]$Web
    )

    $allPermissions = @()
    # Get current web permissions
    $allPermissions += Get-WebPermissions -Web $Web
    $allPermissions += Get-ListPermissions -Web $Web

    # Recursively get permissions for all subsites
    $subWebs = Get-PnPSubWeb -Web $Web
    foreach ($subWeb in $subWebs) {
        $allPermissions += Get-AllWebPermissions -Web $subWeb
    }

    return $allPermissions
}

# Get root web
$rootWeb = Get-PnPWeb

# Get all permissions
$permissions = Get-AllWebPermissions -Web $rootWeb

# Export to Excel
$excelFilePath = "C:\Temp\file.xlsx"
$permissions | Export-Excel -Path $excelFilePath -AutoSize

# Disconnect
Disconnect-PnPOnline