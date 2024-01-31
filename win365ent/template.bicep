@description('Specifies the location for resources.')
param location string = 'eastus'
param adminUsername string = 'azureuser'
param adminPassword string = 'm@rkV!0912345678'
param routeTables_5firewall_route_name string = '5firewall-route'
param virtualMachines_6servicework_vm_name string = '6servicework-vm'
param virtualNetworks_1ms365entvnet1fw_name string = '1ms365entvnet1fw'
param azureFirewalls_2firewall_ms365ent_name string = '2firewall-ms365ent'
param firewallPolicies_3firewall_policy_name string = '3firewall-policy'
param publicIPAddresses_4firewal_publicip_name string = '4firewal-publicip'
param networkInterfaces_6servicework_vm236_name string = '6servicework-vm236'
param networkSecurityGroups_6servicework_vm_nsg_name string = '6servicework-vm-nsg'
param schedules_shutdown_computevm_6servicework_vm_name string = 'shutdown-computevm-6servicework-vm'

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
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

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

resource virtualMachines_6servicework_vm_name_resource 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: virtualMachines_6servicework_vm_name
  location: location
  tags: {
    virtualmachine: 'ms365ent'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    additionalCapabilities: {
      hibernationEnabled: false
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter-gensecond'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: '${virtualMachines_6servicework_vm_name}_disk1'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        deleteOption: 'Delete'
        diskSizeGB: 127
      }
      dataDisks: []
      diskControllerType: 'SCSI'
    }
    osProfile: {
      computerName: virtualMachines_6servicework_vm_name
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
        enableVMAgentPlatformUpdates: false
      }
      secrets: []
      allowExtensionOperations: true
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    networkProfile: {
      networkInterfaces: [
        {
          //id: networkInterfaces_6servicework_vm236_name_resource.id
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource schedules_shutdown_computevm_6servicework_vm_name_resource 'microsoft.devtestlab/schedules@2018-09-15' = {
  name: schedules_shutdown_computevm_6servicework_vm_name
  location: location
  tags: {
    virtualmachine: 'ms365ent'
  }
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '1900'
    }
    timeZoneId: 'UTC'
    notificationSettings: {
      status: 'Disabled'
      timeInMinutes: 30
      notificationLocale: 'en'
    }
    targetResourceId: virtualMachines_6servicework_vm_name_resource.id
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
  name: 'DefaultDNATRuleCollectionGroup'
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
            name: 'RDP-NAT'
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
              publicIPAddresses_4firewal_publicip_name_resource.properties.ipAddress
            ]
            destinationPorts: [
              '3389'
            ]
          }
        ]
        name: 'RDP'
        priority: 200
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
            id: routeTables_5firewall_route_name_resource.id
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
  parent: virtualNetworks_1ms365entvnet1fw_name_resource
  name: 'AzFWManagementSubnet'
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

resource networkInterfaces_6servicework_vm236_name_resource 'Microsoft.Network/networkInterfaces@2023-06-01' = {
  name: networkInterfaces_6servicework_vm236_name
  location: location
  tags: {
    virtualmachine: 'ms365ent'
  }
  kind: 'Regular'
  properties: {
    ipConfigurations: [
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
            id: virtualNetworks_1ms365entvnet1fw_name_WorkloadSubnet.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: [
        '209.244.0.3'
        '209.244.0.4'
      ]
    }
    enableAcceleratedNetworking: true
    enableIPForwarding: false
    disableTcpStateTracking: false
    networkSecurityGroup: {
      id: networkSecurityGroups_6servicework_vm_nsg_name_resource.id
    }
    nicType: 'Standard'
    auxiliaryMode: 'None'
    auxiliarySku: 'None'
  }
}

resource virtualNetworks_1ms365entvnet1fw_name_WorkloadSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-06-01' = {
  parent: virtualNetworks_1ms365entvnet1fw_name_resource
  name: 'WorkloadSubnet'
  properties: {
    addressPrefixes: [
      '10.0.2.0/24'
    ]
    routeTable: {
      id: routeTables_5firewall_route_name_resource.id
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
            id: publicIPAddresses_4firewal_publicip_name_resource.id
          }
          subnet: {
            id: virtualNetworks_1ms365entvnet1fw_name_AzureFirewallSubnet.id
          }
        }
      }
    ]
    networkRuleCollections: []
    applicationRuleCollections: []
    natRuleCollections: []
    firewallPolicy: {
      id: firewallPolicies_3firewall_policy_name_resource.id
    }
  }
}

output publicIpAddress string = publicIPAddresses_4firewal_publicip_name_resource.properties.ipAddress
