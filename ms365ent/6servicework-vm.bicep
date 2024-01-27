@description('Specifies the location for resources.')
param location string = 'eastus'
param adminUsername string = 'azureuser'
param virtualMachines_6servicework_vm_name string = '6servicework-vm'
param disks_6servicework_vm_disk1_9eeeeb78527f4130b03b188a4017c7ca_externalid string = '/subscriptions/6cfaa4da-a4b7-4bbe-91ba-2c23438b894c/resourceGroups/test-network-rg/providers/Microsoft.Compute/disks/6servicework-vm_disk1_9eeeeb78527f4130b03b188a4017c7ca'
param networkInterfaces_6servicework_vm236_externalid string = '/subscriptions/6cfaa4da-a4b7-4bbe-91ba-2c23438b894c/resourceGroups/test-network-rg/providers/Microsoft.Network/networkInterfaces/6servicework-vm236'

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
        name: '${virtualMachines_6servicework_vm_name}_disk1_9eeeeb78527f4130b03b188a4017c7ca'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
          id: disks_6servicework_vm_disk1_9eeeeb78527f4130b03b188a4017c7ca_externalid
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
      requireGuestProvisionSignal: true
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
          id: networkInterfaces_6servicework_vm236_externalid
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
