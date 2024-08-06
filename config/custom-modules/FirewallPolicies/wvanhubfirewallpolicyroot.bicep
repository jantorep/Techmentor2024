metadata name = 'ALZ Bicep - Azure vWAN Connectivity Module'
metadata description = 'Module used to set up vWAN Connectivity'

@sys.description('Region in which the resource group was created.')
param parLocation string = resourceGroup().location

@sys.description('Azure Firewall Tier associated with the Firewall to deploy.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param parAzFirewallTier string = 'Standard'

@sys.description('The Azure Firewall Threat Intelligence Mode. If not set, the default value is Alert.')
@allowed([
  'Alert'
  'Deny'
  'Off'
])
param parAzFirewallIntelMode string = 'Alert'

@sys.description('Switch to enable/disable Azure Firewall DNS Proxy.')
param parAzFirewallDnsProxyEnabled bool = true

@sys.description('Array of custom DNS servers used by Azure Firewall')
param parAzFirewallDnsServers array = []

@sys.description('Azure Firewall Policies Name.')
param parrootAzFirewallPoliciesName string = ''

@sys.description('Azure Firewall Policies Name.')
param parchildAzFirewallPoliciesName string = ''

@sys.description('Tags you would like to be applied to all resources in this module.')
param parTags object = {}

// @sys.description('Set Parameter to true to Opt-out of deployment telemetry')
// param parTelemetryOptOut bool = false

// Customer Usage Attribution Id Telemetry
// var varCuaid = '7f94f23b-7a59-4a5c-9a8d-2a253a566f61'

// Azure Firewalls in Hubs
// Virtual WAN resource

resource resrootFirewallPolicies 'Microsoft.Network/firewallPolicies@2023-02-01' =  {
  name: parrootAzFirewallPoliciesName
  location: parLocation
  tags: parTags
  properties: (parAzFirewallTier == 'Basic') ? {
    sku: {
      tier: parAzFirewallTier
    }
    threatIntelMode: 'Alert'
  } : {
    dnsSettings: {
      enableProxy: parAzFirewallDnsProxyEnabled
      servers: parAzFirewallDnsServers
    }
    sku: {
      tier: parAzFirewallTier
    }
    threatIntelMode: parAzFirewallIntelMode
  }
}

resource reschildFirewallPolicies 'Microsoft.Network/firewallPolicies@2023-02-01' =  {
  dependsOn: [
    resrootFirewallPolicies
  ]
  name: parchildAzFirewallPoliciesName
  location: parLocation
  tags: parTags
  properties: {
    basePolicy: {
      id: resrootFirewallPolicies.id
    }
    dnsSettings: {
      enableProxy: parAzFirewallDnsProxyEnabled
      servers: parAzFirewallDnsServers
    }
    sku: {
      tier: parAzFirewallTier
    }
    threatIntelMode: parAzFirewallIntelMode
  }   
}


// Optional Deployments for Customer Usage Attribution
// module modCustomerUsageAttribution '../../CRML/customerUsageAttribution/cuaIdResourceGroup.bicep' = if (!parTelemetryOptOut) {
//   name: 'pid-${varCuaid}-${uniqueString(parLocation)}'
//   params: {}
// }

// module modCustomerUsageAttributionZtnP1 '../../CRML/customerUsageAttribution/cuaIdResourceGroup.bicep' = if (!parTelemetryOptOut && varZtnP1Trigger) {
//   name: 'pid-${varZtnP1CuaId}-${uniqueString(parLocation)}'
//   params: {}
// }

// Output Virtual WAN name and ID
output outresrootFirewallPolicies string = resrootFirewallPolicies.name

output outreschildFirewallPolicies string = reschildFirewallPolicies.name
