@description('Specifies the location for resources.')
param location string = 'eastus'

param virtualNetworks_1ms365entvnet1fw_name string = '1ms365entvnet1fw'
param routeTables_5firewall_route_externalid string = '/subscriptions/6cfaa4da-a4b7-4bbe-91ba-2c23438b894c/resourceGroups/test-network-rg/providers/Microsoft.Network/routeTables/5firewall-route'

resource virtualNetworks_1ms365entvnet1fw_name_resource 'Microsoft.Network/virtualNetworks@2023-06-01' = {
  name: virtualNetworks_1ms365entvnet1fw_name
  location: location
  tags: {
    subnet: 'ms365ent'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    encryption: {
      enabled: false
      enforcement: 'AllowUnencrypted'
    }
    subnets: [
      {
        name: 'AzFWManagementSubnet'
        //id: virtualNetworks_1ms365entvnet1fw_name_AzFWManagementSubnet.id
        properties: {
          addressPrefixes: [
            '10.0.0.0/26'
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          defaultOutboundAccess: true
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: 'AzureFirewallSubnet'
        //id: virtualNetworks_1ms365entvnet1fw_name_AzureFirewallSubnet.id
        properties: {
          addressPrefix: '10.0.1.0/24'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: 'WorkloadSubnet'
        //id: virtualNetworks_1ms365entvnet1fw_name_WorkloadSubnet.id
        properties: {
          addressPrefixes: [
            '10.0.2.0/24'
          ]
          routeTable: {
            id: routeTables_5firewall_route_externalid
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          defaultOutboundAccess: true
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource virtualNetworks_1ms365entvnet1fw_name_AzFWManagementSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-06-01' = {
  name: '${virtualNetworks_1ms365entvnet1fw_name}/AzFWManagementSubnet'
  properties: {
    addressPrefixes: [
      '10.0.0.0/26'
    ]
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    defaultOutboundAccess: true
  }
  dependsOn: [
    virtualNetworks_1ms365entvnet1fw_name_resource
  ]
}

resource virtualNetworks_1ms365entvnet1fw_name_AzureFirewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-06-01' = {
  name: '${virtualNetworks_1ms365entvnet1fw_name}/AzureFirewallSubnet'
  properties: {
    addressPrefix: '10.0.1.0/24'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    virtualNetworks_1ms365entvnet1fw_name_resource
  ]
}

resource virtualNetworks_1ms365entvnet1fw_name_WorkloadSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-06-01' = {
  name: '${virtualNetworks_1ms365entvnet1fw_name}/WorkloadSubnet'
  properties: {
    addressPrefixes: [
      '10.0.2.0/24'
    ]
    routeTable: {
      id: routeTables_5firewall_route_externalid
    }
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    defaultOutboundAccess: true
  }
  dependsOn: [
    virtualNetworks_1ms365entvnet1fw_name_resource
  ]
}
