@description('Specifies the location for resources.')
param location string = 'eastus'

param networkSecurityGroups_6servicework_vm_nsg_name string = '6servicework-vm-nsg'

resource networkSecurityGroups_6servicework_vm_nsg_name_resource 'Microsoft.Network/networkSecurityGroups@2023-06-01' = {
  name: networkSecurityGroups_6servicework_vm_nsg_name
  location: location
  tags: {
    virtualmachine: 'ms365ent'
  }
  properties: {
    securityRules: []
  }
}
