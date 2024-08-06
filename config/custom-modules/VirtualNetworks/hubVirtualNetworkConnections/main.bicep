@maxLength(36)
param vnetsubscriptionId string

@description('Required. The connection name.')
param virtualWanHubConnectionName string

@maxLength(36)
param virtualWanHubSubscriptionId string

@maxLength(90)
@sys.description('The name of the resource group to create the virtual network in.')
param virtualNetworkResourceGroupName string = ''

@maxLength(64)
@sys.description('The name of the virtual network. The string must consist of a-z, A-Z, 0-9, -, _, and . (period) and be between 2 and 64 characters in length.')
param virtualNetworkName string = ''

@description('Conditional. The name of the resource group for the parent virtual hub. Required if the template is used in a standalone deployment.')
param virtualWanHubResourceGroupName string

@sys.description('The resource ID of the virtual network or virtual wan hub in the hub to which the created virtual network will be peered/connected to via vitrual network peering or a vitrual hub connection.')
param hubNetworkResourceId string = ''

@sys.description('Enables the ability for the Virtual WAN Hub Connection to learn the default route 0.0.0.0/0 from the Hub.')
param virtualNetworkVwanEnableInternetSecurity bool = true

@sys.description('The resource ID of the virtual hub route table to associate to the virtual hub connection (this virtual network). If left blank/empty default route table will be associated.')
param virtualNetworkVwanAssociatedRouteTableResourceId string = ''

@sys.description('An array of virtual hub route table resource IDs to propogate routes to. If left blank/empty default route table will be propogated to only.')
param virtualNetworkVwanPropagatedRouteTablesResourceIds array = []

@sys.description('An array of virtual hub route table labels to propogate routes to. If left blank/empty default label will be propogated to only.')
param virtualNetworkVwanPropagatedLabels array = []

@sys.description('Indicates whether routing intent is enabled on the Virtual HUB within the virtual WAN.')
param vHubRoutingIntentEnabled bool = false

@sys.description('Disable telemetry collection by this module. For more information on the telemetry collected by this module, that is controlled by this parameter, see this page in the wiki: [Telemetry Tracking Using Customer Usage Attribution (PID)](https://github.com/Azure/bicep-lz-vending/wiki/Telemetry)')
param disableTelemetry bool = false

var deploymentNames = {
  createLzVirtualWanConnection: take('alz-custom-vhc-create-${uniqueString(virtualWanHubSubscriptionId, deployment().name)}', 64)
}

var virtualHubResourceIdChecked = (!empty(hubNetworkResourceId) && contains(hubNetworkResourceId, '/providers/Microsoft.Network/virtualHubs/') ? hubNetworkResourceId : '')


// Virtual WAN data
var virtualWanHubName = (!empty(virtualHubResourceIdChecked) ? split(virtualHubResourceIdChecked, '/')[8] : '')
var virtualWanHubConnectionAssociatedRouteTable = !empty(virtualNetworkVwanAssociatedRouteTableResourceId) ? virtualNetworkVwanAssociatedRouteTableResourceId : '${virtualHubResourceIdChecked}/hubRouteTables/defaultRouteTable'

var virutalWanHubDefaultRouteTableId = {
  id: '${virtualHubResourceIdChecked}/hubRouteTables/defaultRouteTable'
}

var virtualWanHubConnectionPropogatedRouteTables = !empty(virtualNetworkVwanPropagatedRouteTablesResourceIds) ? virtualNetworkVwanPropagatedRouteTablesResourceIds : array(virutalWanHubDefaultRouteTableId)
var virtualWanHubConnectionPropogatedLabels = !empty(virtualNetworkVwanPropagatedLabels) ? virtualNetworkVwanPropagatedLabels : [ 'default' ]

// Telemetry for CARML flip
var enableTelemetryForCarml = !disableTelemetry

module createLzVirtualWanConnection 'deploy.bicep' = {
  scope: resourceGroup(virtualWanHubSubscriptionId, virtualWanHubResourceGroupName)
  name: deploymentNames.createLzVirtualWanConnection
  params: {
    name: virtualWanHubConnectionName
    virtualHubName: virtualWanHubName
    remoteVirtualNetworkId: '/subscriptions/${vnetsubscriptionId}/resourceGroups/${virtualNetworkResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}'
    enableInternetSecurity: virtualNetworkVwanEnableInternetSecurity
    routingConfiguration: !vHubRoutingIntentEnabled ? {
      associatedRouteTable: {
        id: virtualWanHubConnectionAssociatedRouteTable
      }
      propagatedRouteTables: {
        ids: virtualWanHubConnectionPropogatedRouteTables
        labels: virtualWanHubConnectionPropogatedLabels
        }
    } : {}
    enableDefaultTelemetry: enableTelemetryForCarml
  }
}
