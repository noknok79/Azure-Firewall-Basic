@description('Specifies the location for resources.')
param location string = 'eastus'

param routeTables_5firewall_route_name string = '5firewall-route'

resource routeTables_5firewall_route_name_resource 'Microsoft.Network/routeTables@2023-06-01' = {
  name: routeTables_5firewall_route_name
  location: location
  tags: {
    route: 'ms365ent'
  }
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'firwall-defaultgateway'
        //id: routeTables_5firewall_route_name_firwall_defaultgateway.id
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.0.1.4'
          hasBgpOverride: false
        }
        type: 'Microsoft.Network/routeTables/routes'
      }
    ]
  }
}

resource routeTables_5firewall_route_name_firwall_defaultgateway 'Microsoft.Network/routeTables/routes@2023-06-01' = {
  parent: routeTables_5firewall_route_name_resource
  name: 'firwall-defaultgateway'
  properties: {
    addressPrefix: '0.0.0.0/0'
    nextHopType: 'VirtualAppliance'
    nextHopIpAddress: '10.0.1.4'
    hasBgpOverride: false
  }
  dependsOn: [
    routeTables_5firewall_route_name_resource
  ]
}
