@description('Required. The Virtual Network (vNet) Name.')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param addressPrefixes array

@description('Optional. An Array of subnets to deploy to the Virtual Network.')
param subnets array = []

@description('Optional. DNS Servers associated to the Virtual Network.')
param dnsServers array = []

@description('Optional. Virtual Network Peerings configurations.')
param virtualNetworkPeerings array = []

@description('Optional. Location for all resources.')
param nsgname string 

@allowed([
  ''
  'CanNotDelete'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = ''

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. Enable telemetry via the Customer Usage Attribution ID (GUID).')
param enableDefaultTelemetry bool = true

var dnsServersArray = {
  dnsServers: array(dnsServers)
}

var enableReferencedModulesTelemetry = false

resource defaultTelemetry 'Microsoft.Resources/deployments@2021-04-01' = if (enableDefaultTelemetry) {
  name: 'pid-47ed15a6-730a-4827-bcb4-0fd963ffbd82-${uniqueString(deployment().name, location)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: nsgname
  location: location
  properties: {
    securityRules: []
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    dhcpOptions: !empty(dnsServers) ? dnsServersArray : null
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        addressPrefixes: contains(subnet, 'addressPrefixes') ? subnet.addressPrefixes : []
        applicationGatewayIpConfigurations: contains(subnet, 'applicationGatewayIpConfigurations') ? subnet.applicationGatewayIpConfigurations : []
        delegations: contains(subnet, 'delegations') ? subnet.delegations : []
        ipAllocations: contains(subnet, 'ipAllocations') ? subnet.ipAllocations : []
        natGateway: contains(subnet, 'natGatewayId') ? {
          'id': subnet.natGatewayId
        } : null
        networkSecurityGroup: contains(subnet, 'networkSecurityGroupId') ? {
          'id': subnet.networkSecurityGroupId
        } : null
        privateEndpointNetworkPolicies: contains(subnet, 'privateEndpointNetworkPolicies') ? subnet.privateEndpointNetworkPolicies : null
        privateLinkServiceNetworkPolicies: contains(subnet, 'privateLinkServiceNetworkPolicies') ? subnet.privateLinkServiceNetworkPolicies : null
        routeTable: contains(subnet, 'routeTableId') ? {
          'id': subnet.routeTableId
        } : null
        serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : []
        serviceEndpointPolicies: contains(subnet, 'serviceEndpointPolicies') ? subnet.serviceEndpointPolicies : []
      }
    }]
  }
  dependsOn: [
    networkSecurityGroup
  ]
}

//NOTE Start: ------------------------------------
// The below module (virtualNetwork_subnets) is a duplicate of the child resource (subnets) defined in the parent module (virtualNetwork).
// The reason it exists so that deployment validation tests can be performed on the child module (subnets), in case that module needed to be deployed alone outside of this template.
// The reason for duplication is due to the current design for the (virtualNetworks) resource from Azure, where if the child module (subnets) does not exist within it, causes
//    an issue, where the child resource (subnets) gets all of its properties removed, hence not as 'idempotent' as it should be. See https://github.com/Azure/azure-quickstart-templates/issues/2786 for more details.
// You can safely remove the below child module (virtualNetwork_subnets) in your consumption of the module (virtualNetworks) to reduce the template size and duplication.
//NOTE End  : ------------------------------------

module virtualNetwork_subnets 'subnets/deploy.bicep' = [for (subnet, index) in subnets: {
  name: '${uniqueString(deployment().name, location)}-subnet-${index}'
  params: {
    virtualNetworkName: virtualNetwork.name
    name: subnet.name
    addressPrefix: subnet.addressPrefix
    addressPrefixes: contains(subnet, 'addressPrefixes') ? subnet.addressPrefixes : []
    applicationGatewayIpConfigurations: contains(subnet, 'applicationGatewayIpConfigurations') ? subnet.applicationGatewayIpConfigurations : []
    delegations: contains(subnet, 'delegations') ? subnet.delegations : []
    ipAllocations: contains(subnet, 'ipAllocations') ? subnet.ipAllocations : []
    natGatewayId: contains(subnet, 'natGatewayId') ? subnet.natGatewayId : ''
    networkSecurityGroupId: contains(subnet, 'networkSecurityGroupId') ? subnet.networkSecurityGroupId : ''
    privateEndpointNetworkPolicies: contains(subnet, 'privateEndpointNetworkPolicies') ? subnet.privateEndpointNetworkPolicies : ''
    privateLinkServiceNetworkPolicies: contains(subnet, 'privateLinkServiceNetworkPolicies') ? subnet.privateLinkServiceNetworkPolicies : ''
    roleAssignments: contains(subnet, 'roleAssignments') ? subnet.roleAssignments : []
    routeTableId: contains(subnet, 'routeTableId') ? subnet.routeTableId : ''
    serviceEndpointPolicies: contains(subnet, 'serviceEndpointPolicies') ? subnet.serviceEndpointPolicies : []
    serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : []
    enableDefaultTelemetry: enableReferencedModulesTelemetry
  }
}]

resource virtualNetwork_lock 'Microsoft.Authorization/locks@2017-04-01' = if (!empty(lock)) {
  name: '${virtualNetwork.name}-${lock}-lock'
  properties: {
    level: any(lock)
    notes: lock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: virtualNetwork
}

@description('The resource group the virtual network was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The resource ID of the virtual network.')
output resourceId string = virtualNetwork.id

@description('The name of the virtual network.')
output name string = virtualNetwork.name

@description('The names of the deployed subnets.')
output subnetNames array = [for subnet in subnets: subnet.name]

@description('The resource IDs of the deployed subnets.')
output subnetResourceIds array = [for subnet in subnets: az.resourceId('Microsoft.Network/virtualNetworks/subnets', name, subnet.name)]

@description('The location the resource was deployed into.')
output location string = virtualNetwork.location
