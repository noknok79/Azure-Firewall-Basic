@description('Specifies the location for resources.')
param location string = 'eastus'

param azureFirewalls_2firewall_ms365ent_name string = '2firewall-ms365ent'
param publicIPAddresses_4firewal_publicip_externalid string = '/subscriptions/fa471bf2-a31c-4a0b-b107-c4cd96c6fa17/resourceGroups/test-network-rg/providers/Microsoft.Network/publicIPAddresses/4firewal-publicip'
param virtualNetworks_1ms365entvnet1fw_externalid string = '/subscriptions/fa471bf2-a31c-4a0b-b107-c4cd96c6fa17/resourceGroups/test-network-rg/providers/Microsoft.Network/virtualNetworks/1ms365entvnet1fw'
param firewallPolicies_3firewall_policy_externalid string = '/subscriptions/fa471bf2-a31c-4a0b-b107-c4cd96c6fa17/resourceGroups/test-network-rg/providers/Microsoft.Network/firewallPolicies/3firewall-policy'

resource azureFirewalls_2firewall_ms365ent_name_resource 'Microsoft.Network/azureFirewalls@2023-06-01' = {
  name: azureFirewalls_2firewall_ms365ent_name
  location: location
  tags: {
    firewall: 'ms365ent'
  }
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    threatIntelMode: 'Alert'
    additionalProperties: {}
    ipConfigurations: [
      {
        name: '4firewal-publicip'
        //id: '${azureFirewalls_2firewall_ms365ent_name_resource.id}/azureFirewallIpConfigurations/4firewal-publicip'
        properties: {
          publicIPAddress: {
            id: publicIPAddresses_4firewal_publicip_externalid
          }
          subnet: {
            id: '${virtualNetworks_1ms365entvnet1fw_externalid}/subnets/AzureFirewallSubnet'
          }
        }
      }
    ]
    networkRuleCollections: []
    applicationRuleCollections: []
    natRuleCollections: []
    firewallPolicy: {
      id: firewallPolicies_3firewall_policy_externalid
    }
  }
}
