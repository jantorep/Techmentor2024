param (
  [Parameter()]
  [String]$ConnectivitySubscriptionId = "$($env:CONNECTIVITY_SUBSCRIPTION_ID)",

  [Parameter()]
  [String]$ConnectivityResourceGroup = "$($env:CONNECTIVITY_RESOURCE_GROUP)",

  [Parameter()]
  [String]$TemplateFile = "config\custom-modules\FirewallPolicies\wvanhubfirewallpolicyroot.bicep",

  [Parameter()]
  [String]$TemplateParameterFile = "config\custom-parameters\vwanConnectivityfirewallpolicyroot.parameters.all.json",

  [Parameter()]
  [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($($env:IS_PULL_REQUEST))
)

# Parameters necessary for deployment
$inputObject = @{
  DeploymentName        = 'alz-VWANDrootpolicyeploy-{0}' -f ( -join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
  ResourceGroupName     = $ConnectivityResourceGroup
  TemplateFile          = $TemplateFile
  TemplateParameterFile = $TemplateParameterFile
  WhatIf                = $WhatIfEnabled
  Verbose               = $true
}

Select-AzSubscription -SubscriptionId $ConnectivitySubscriptionId

New-AzResourceGroupDeployment @inputObject
