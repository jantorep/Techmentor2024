param (
  [Parameter()]
  [String]$Location,
  
  [Parameter()]
  [String]$TopLevelMGPrefix,

  [Parameter()]
  [String]$TemplateFile,

  [Parameter()]
  [String]$TemplateParameterFile,

  [Parameter()]
  [String]$AddressPrefix

  # [Parameter()]
  # [String]$VnetTag
)

# $VnetTag

# $IpamResIdTag = @{
#     'ipam-res-id' = $VnetTag
#   }

#   $IpamResIdTag

  $inputObject = @{
    DeploymentName                = 'ALZ-vending-{0}' -f ( -join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
    Location                      = $Location
    ManagementGroupId             = $TopLevelMGPrefix
    TemplateFile                  = $TemplateFile
    TemplateParameterFile         = $TemplateParameterFile
    VirtualNetworkAddressSpace    = $AddressPrefix
    Verbose                       = $true
  }
  New-AzManagementGroupDeployment @inputObject