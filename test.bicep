@description('Virtual network name')
param virtualNetworkName string = 'vnet${uniqueString(resourceGroup().id)}'

@description('Azure Firewall name')
param firewallName string = 'fw${uniqueString(resourceGroup().id)}'

@description('Number of public IP addresses for the Azure Firewall')
@minValue(1)
@maxValue(100)
param numberOfPublicIPAddresses int = 1

@description('Zone numbers e.g. 1,2,3.')
param availabilityZones array = []

@description('Location for all resources.')
param location string = resourceGroup().location
param infraIpGroupName string = '${location}-infra-ipgroup-${uniqueString(resourceGroup().id)}'
param workloadIpGroupName string = '${location}-workload-ipgroup-${uniqueString(resourceGroup().id)}'
param firewallPolicyName string = '${firewallName}-firewallPolicy'

var vnetAddressPrefix = '10.10.0.0/16'
var azureFirewallSubnetPrefix = '10.10.2.0/24'
var publicIPNamePrefix = 'publicIP'
var azurepublicIpname = publicIPNamePrefix
var azureFirewallSubnetName = 'AzureFirewallSubnet'
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


resource workloadIpGroup 'Microsoft.Network/ipGroups@2022-01-01' = {
  name: workloadIpGroupName
  location: location
  properties: {
    ipAddresses: [
      '10.20.0.0/24'
      '10.30.0.0/24'
    ]
  }
}

resource infraIpGroup 'Microsoft.Network/ipGroups@2022-01-01' = {
  name: infraIpGroupName
  location: location
  properties: {
    ipAddresses: [
      '10.40.0.0/24'
      '10.50.0.0/24'
    ]
  }
}


resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: virtualNetworkName
  location: location
  tags: {
    displayName: virtualNetworkName
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: azureFirewallSubnetName
        properties: {
          addressPrefix: azureFirewallSubnetPrefix
        }
      }
    ]
    enableDdosProtection: false
  }
}

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-01-01' = [for i in range(0, numberOfPublicIPAddresses): {
  name: '${azurepublicIpname}${i + 1}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}]

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2022-01-01'= {
  name: firewallPolicyName
  location: location
  properties: {
    threatIntelMode: 'Alert'
  }
}

resource networkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-01-01' = {
  parent: firewallPolicy
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

resource dnatRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-06-01' = {
  parent: firewallPolicy
  name: 'DefaultNatRuleCollectionGroup'
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
              publicIpAddress[0].properties.ipAddress
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

resource applicationRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-01-01' = {
  parent: firewallPolicy
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


resource firewall 'Microsoft.Network/azureFirewalls@2021-03-01' = {
  name: firewallName
  location: location
  zones: ((length(availabilityZones) == 0) ? null : availabilityZones)
  dependsOn: [
    //vnet
    publicIpAddress
    dnatRuleCollectionGroup
    networkRuleCollectionGroup
    applicationRuleCollectionGroup
  ]
  properties: {
    ipConfigurations: azureFirewallIpConfigurations
    firewallPolicy: {
      id: firewallPolicy.id
    }
  }
}

