# Techmentor2024

# Give Service Principal Gorrect permissions on root tenant group

Connect-AzAccount -UseDeviceAuthentication

$spndisplayname = "Github-ALZ-SP"
$spn = (Get-AzADServicePrincipal -DisplayName $spndisplayname).id
New-AzRoleAssignment -Scope '/' -RoleDefinitionName 'Owner' -ObjectId $spn