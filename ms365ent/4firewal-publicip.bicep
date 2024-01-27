@description('Specifies the location for resources.')
param location string = 'eastus'

param publicIPAddresses_4firewal_publicip_name string = '4firewal-publicip'

resource publicIPAddresses_4firewal_publicip_name_resource 'Microsoft.Network/publicIPAddresses@2023-06-01' = {
  name: publicIPAddresses_4firewal_publicip_name
  location: location
  tags: {
    firewall: 'ms365ent'
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    ipAddress: '23.101.142.188'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}
