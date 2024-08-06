param (
  [Parameter()]
  [String]$ProductionSubscriptionId = "$($env:PRODUCTION_SUBSCRIPTION_ID)",

  [Parameter()]
  [String]$ProductionResourceGroup = "$($env:PRODUCTION_RESOURCE_GROUP)",

  [Parameter()]
  [String]$TemplateFile = "config\custom-modules\VirtualNetworks\CustomVnets\deploy.bicep",

  [Parameter()]
  [String]$TemplateParameterFile = "config\custom-parameters\vnet.production.parameters.json",

  [Parameter()]
  [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($($env:IS_PULL_REQUEST))
)

# Parameters necessary for deployment
$inputObject = @{
  DeploymentName        = 'alz-ProductionVnetDeploy-{0}' -f ( -join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
  ResourceGroupName     = $ProductionResourceGroup
  TemplateFile          = $TemplateFile
  TemplateParameterFile = $TemplateParameterFile
  WhatIf                = $WhatIfEnabled
  Verbose               = $true
}

Select-AzSubscription -SubscriptionId $ProductionSubscriptionId

New-AzResourceGroupDeployment @inputObject
