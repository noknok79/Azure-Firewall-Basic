@description('Specifies the location for resources.')
param location string = 'eastus'

param networkInterfaces_6servicework_vm236_name string = '6servicework-vm236'
param virtualNetworks_1ms365entvnet1fw_externalid string = '/subscriptions/6cfaa4da-a4b7-4bbe-91ba-2c23438b894c/resourceGroups/test-network-rg/providers/Microsoft.Network/virtualNetworks/1ms365entvnet1fw'
param networkSecurityGroups_6servicework_vm_nsg_externalid string = '/subscriptions/6cfaa4da-a4b7-4bbe-91ba-2c23438b894c/resourceGroups/test-network-rg/providers/Microsoft.Network/networkSecurityGroups/6servicework-vm-nsg'

resource networkInterfaces_6servicework_vm236_name_resource 'Microsoft.Network/networkInterfaces@2023-06-01' = {
  name: networkInterfaces_6servicework_vm236_name
  location: location
  tags: {
    virtualmachine: 'ms365ent'
  }
  kind: 'Regular'
  properties: { ipConfigurations: [
    {
      name: 'ipconfig1'
      //id: '${networkInterfaces_6servicework_vm236_name_resource.id}/ipConfigurations/ipconfig1'
      etag: 'W/"e5063e4f-f9d9-487b-87cb-686f422a80f0"'
      type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
      properties: {
        provisioningState: 'Succeeded'
        privateIPAddress: '10.0.2.4'
        privateIPAllocationMethod: 'Dynamic'
        subnet: {
          id: '${virtualNetworks_1ms365entvnet1fw_externalid}/subnets/WorkloadSubnet'
        }
        primary: true
        privateIPAddressVersion: 'IPv4'
      }
    }
  ], dnsSettings: {
      dnsServers: [
        '209.244.0.3'
        '209.244.0.4'
      ]
    }, enableAcceleratedNetworking: true, enableIPForwarding: false, disableTcpStateTracking: false, networkSecurityGroup: {
      id: networkSecurityGroups_6servicework_vm_nsg_externalid
    }, nicType: 'Standard', auxiliaryMode: 'None', auxiliarySku: 'None' }
}
