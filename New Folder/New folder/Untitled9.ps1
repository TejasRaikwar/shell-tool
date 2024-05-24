# Get the SPWeb object
$web = Get-PnPWeb

# Display the title of the site
Write-Host "Site Title: $web.Title"