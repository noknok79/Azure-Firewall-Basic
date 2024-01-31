@description('Specifies the location for resources.')
param location string = 'eastus'
param numberOfPublicIPAddresses int = 1
param firewallPolicies_3firewall_policy_name string = '3firewall-policy'
//param publicIPAddresses_4firewal_publicip_name string = '4firewal-publicip'
var vnetAddressPrefix = '10.0.0.0/24'
var azureFirewallSubnetPrefix = '10.0.2.0/24'
var publicIPNamePrefix = 'publicIP'
var azurepublicIpname = publicIPNamePrefix
var azureFirewallSubnetName = 'AzureFirewallSubnet'
/**/
var azureFirewallSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, azureFirewallSubnetName)
var azureFirewallPublicIpId = resourceId('Microsoft.Network/publicIPAddresses', publicIPNamePrefix)
var azureFirewallIpConfigurations = [for i in range(0, numberOfPublicIPAddresses): {
  name: 'IpConf${i}'
  properties: {
    subnet: ((i == 0) ? json('{"id": "${azureFirewallSubnetId}"}') : json('null'))
    publicIPAddress: {
      id: '${azureFirewallPublicIpId}${i + 1}'
    }
  }
}]

resource firewallPolicies_3firewall_policy_name_resource 'Microsoft.Network/firewallPolicies@2023-06-01' = {
  name: firewallPolicies_3firewall_policy_name
  location: location
  properties: {
    sku: {
      tier: 'Standard'
    }
    threatIntelMode: 'Alert'
  }
}

resource publicIPAddresses_4firewal_publicip_name_resource 'Microsoft.Network/publicIPAddresses@2023-06-01' = [for i in range(0, numberOfPublicIPAddresses): {
  name: '${azurepublicIpname}${i + 1}'
  location: location
  tags: {
    firewall: 'ms365ent'
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
    ddosSettings: {
      protectionMode: 'VirtualNetworkInherited'
    }
  }
}]
/*
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
    ipAddress: ''
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
    ddosSettings: {
      protectionMode: 'VirtualNetworkInherited'
    }
  }
}
*/
resource firewallPolicies_3firewall_policy_name_DefaultApplicationRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-06-01' = {
  parent: firewallPolicies_3firewall_policy_name_resource
  name: 'DefaultApplicationRuleCollectionGroup'
  location: location
  properties: {
    priority: 300
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'Allow-Google'
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            webCategories: []
            targetFqdns: [
              'www.google.com'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '10.0.2.0/24'
            ]
            destinationAddresses: []
            sourceIpGroups: []
            httpHeadersToInsert: []
          }
        ]
        name: 'app-collection01'
        priority: 200
      }
    ]
  }
}

resource firewallPolicies_3firewall_policy_name_DefaultDnatRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-06-01' = {
  parent: firewallPolicies_3firewall_policy_name_resource
  name: 'DefaultDnatRuleCollectionGroup'
  location: location
  properties: {
    priority: 100
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyNatRuleCollection'
        action: {
          type: 'Dnat'
        }
        rules: [
          {
            ruleType: 'NatRule'
            name: 'NatRule'
            translatedAddress: '10.0.2.4'
            translatedPort: '3389'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              publicIPAddresses_4firewal_publicip_name_resource[0].properties.ipAddress
            ]
            destinationPorts: [
              '3389'
            ]
          }
        ]
        name: 'dnat-collection01'
        priority: 100
      }
    ]
  }
}

resource firewallPolicies_3firewall_policy_name_DefaultNetworkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-06-01' = {
  parent: firewallPolicies_3firewall_policy_name_resource
  name: 'DefaultNetworkRuleCollectionGroup'
  location: location
  properties: {
    priority: 200
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'Allow-DNS'
            ipProtocols: [
              'UDP'
            ]
            sourceAddresses: [
              '10.0.2.0/24'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '209.244.0.3'
              '209.244.0.4'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '53'
            ]
          }
        ]
        name: 'net-collection01'
        priority: 200
      }
    ]
  }
}
