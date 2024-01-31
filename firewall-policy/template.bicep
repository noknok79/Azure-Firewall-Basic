@description('Specifies the location for resources.')
param location string = 'eastus'

param firewallPolicies_3firewall_policy_name string = '3firewall-policy'

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
          type: 'Application'
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
          type: 'DNAT'
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
              '20.231.87.40'
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
          type: 'Network'
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
