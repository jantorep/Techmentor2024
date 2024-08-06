param (
  [Parameter()]
  [String]$ManagementSubscriptionId = "$($env:MANAGEMENT_SUBSCRIPTION_ID)",

  [Parameter()]
  [String]$ManagementResourceGroup = "$($env:MANAGEMENT_RESOURCE_GROUP)",

  [Parameter()]
  [String]$TemplateFile = "config\custom-modules\VirtualNetworks\CustomVnets\deploy.bicep",

  [Parameter()]
  [String]$TemplateParameterFile = "config\custom-parameters\vnet.management.parameters.json",

  [Parameter()]
  [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($($env:IS_PULL_REQUEST))
)

# Parameters necessary for deployment
$inputObject = @{
  DeploymentName        = 'alz-ManagementVnetDeploy-{0}' -f ( -join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
  ResourceGroupName     = $ManagementResourceGroup
  TemplateFile          = $TemplateFile
  TemplateParameterFile = $TemplateParameterFile
  WhatIf                = $WhatIfEnabled
  Verbose               = $true
}

Select-AzSubscription -SubscriptionId $ManagementSubscriptionId

New-AzResourceGroupDeployment @inputObject
