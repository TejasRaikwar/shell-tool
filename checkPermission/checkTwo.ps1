# Load necessary modules
Import-Module PnP.PowerShell
Import-Module ImportExcel

# Connect to SharePoint Online
$siteUrl = "https://sharepointistech.sharepoint.com/sites/testTejas"
Connect-PnPOnline -Url $siteUrl -Interactive

# Function to get permissions for a web
function Get-WebPermissions {
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.SharePoint.Client.Web]$Web
    )

    $permissions = @()
    $webContext = $Web.Context
    $webContext.Load($Web.RoleAssignments)
    $webContext.ExecuteQuery()

    foreach ($roleAssignment in $Web.RoleAssignments) {
        $webContext.Load($roleAssignment.Member)
        $webContext.Load($roleAssignment.RoleDefinitionBindings)
        $webContext.ExecuteQuery()

        foreach ($role in $roleAssignment.RoleDefinitionBindings) {
            $permissions += [PSCustomObject]@{
                WebUrl    = $Web.Url
                Principal = $roleAssignment.Member.Title
                LoginName = $roleAssignment.Member.LoginName
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
    $lists = Get-PnPList

    foreach ($list in $lists) {
        $listContext = $list.Context
        $listContext.Load($list.RoleAssignments)
        $listContext.ExecuteQuery()

        foreach ($roleAssignment in $list.RoleAssignments) {
            $listContext.Load($roleAssignment.Member)
            $listContext.Load($roleAssignment.RoleDefinitionBindings)
            $listContext.ExecuteQuery()

            foreach ($role in $roleAssignment.RoleDefinitionBindings) {
                $permissions += [PSCustomObject]@{
                    ListUrl   = $list.DefaultViewUrl
                    ListTitle = $list.Title
                    Principal = $roleAssignment.Member.Title
                    LoginName = $roleAssignment.Member.LoginName
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
    $subWebs = Get-PnPSubWeb
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
