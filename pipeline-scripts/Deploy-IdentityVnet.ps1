param (
  [Parameter()]
  [String]$IdentitySubscriptionId = "$($env:IDENTITY_SUBSCRIPTION_ID)",

  [Parameter()]
  [String]$IdentityResourceGroup = "$($env:IDENTITY_RESOURCE_GROUP)",

  [Parameter()]
  [String]$TemplateFile = "config\custom-modules\VirtualNetworks\CustomVnets\deploy.bicep",

  [Parameter()]
  [String]$TemplateParameterFile = "config\custom-parameters\vnet.identity.parameters.json",

  [Parameter()]
  [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($($env:IS_PULL_REQUEST))
)

# Parameters necessary for deployment
$inputObject = @{
  DeploymentName        = 'alz-IdentityvNetDeploy-{0}' -f ( -join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
  ResourceGroupName     = $IdentityResourceGroup
  TemplateFile          = $TemplateFile
  TemplateParameterFile = $TemplateParameterFile
  WhatIf                = $WhatIfEnabled
  Verbose               = $true
}

Select-AzSubscription -SubscriptionId $IdentitySubscriptionId

New-AzResourceGroupDeployment @inputObject