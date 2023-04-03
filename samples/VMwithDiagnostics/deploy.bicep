targetScope = 'resourceGroup'

@description('The name of the candidate')
param candidateName string = 'kevin'

@description('Name of the Network Security Group assigned to the VM Subnet')
param vmSubnetNsgName string = '${environmentName}NSG-${candidateName}'

@description('Environment for deployment')
param environmentName string = 'Test'

@description('Name of the virtual machine')
param vmName string = '${environmentName}VM-${candidateName}'

@description('SKU used for VM deployment')
param vmSku string = 'Standard_B2s'

@description('SKU used for VM deployment')
param vmOsDisk string = 'StandardSSD_LRS'

@description('Admin User for Virtual Machine')
@maxLength(20)
@minLength(1)
param vmAdminUsername string = '${environmentName}VM-${candidateName}'

@description('Admin password for Virtual Machine')
@secure()
@maxLength(123)
@minLength(12)
param vmAdminPassword string = 'kyu2wdj!RWQ8wbc.zxh'



@description('Name of the virtual network')
param vnetName string = '${environmentName}VNET-${candidateName}'

@description('Virtual Network Address prefix name')
param vnetAddressPrefixes array = [
  '10.10.10.0/24'
]

@description('Name of the virtual machine subnet')
param subnetName string = '${environmentName}Subnet'

param subnetAddressPrefix string = '10.10.10.0/28'


@description('The location for the deployment')
param location string = resourceGroup().location

@description('Resource specific tags')
param tags object = {
environment: 'Test'
candidate: 'Kevin'
lastDeployment: '${utcNow('yyyy')}-${utcNow('MM')}-${utcNow('dd')}'
}

@maxLength(24)
@minLength(3)
param storageAccountName string = 'logstorage${candidateName}'

var wadStart = '<WadCfg> <DiagnosticMonitorConfiguration overallQuotaInMB="4096" xmlns="http://schemas.microsoft.com/ServiceHosting/2010/10/DiagnosticsConfiguration"> <DiagnosticInfrastructureLogs scheduledTransferLogLevelFilter="Error"/> '
var iisLogs = '<Directories scheduledTransferPeriod="PT5M"><IISLogs containerName="weblogs" /> </Directories>'
var wadMetrics = '<Metrics resourceId="${windowsVM.id}"><MetricAggregation scheduledTransferPeriod="PT1H"/><MetricAggregation scheduledTransferPeriod="PT1M"/></Metrics>'
var wadEnd = '</DiagnosticMonitorConfiguration></WadCfg>'
var wadCfg = '${wadStart}${iisLogs}${wadMetrics}${wadEnd}'


resource vmSubnetNsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: vmSubnetNsgName
  location: location
  tags: tags

  properties: {
    securityRules: [
      // Inbound Rules
      {
        name: 'AllowHttpInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 120
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
        }
      }
      {
        name: 'AllowRDPInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 130
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: location
  tags:tags
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefixes
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
          networkSecurityGroup: {
            id: vmSubnetNsg.id
          }
        }
      }
    ]
  }
}

resource windowsVM 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSku
    }
    osProfile: {
      computerName: vmName
      adminUsername: vmAdminUsername
      adminPassword: vmAdminPassword
    }
    storageProfile: {
      imageReference: {
      offer: 'WindowsServer'
      publisher: 'MicrosoftWindowsServer'
      sku: '2019-datacenter'
      version: 'latest'
      }
      osDisk: {
        name: '${vmName}-OSdisk'
        createOption: 'FromImage'
        deleteOption: 'Delete'
        managedDisk:{
          storageAccountType: vmOsDisk
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNetworkInterface.id
          properties:{
            deleteOption: 'Delete'
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


resource vmNetworkInterface 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: '${vmName}-Nic01'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${virtualNetwork.id}/subnets/${subnetName}'
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}


resource vmEnableIIS 'Microsoft.Compute/virtualMachines/runCommands@2022-03-01' = {
  name: '${vmName}-EnableIIS-Script'
  location: location
  parent: windowsVM
  properties: {
    asyncExecution: false
    source: {
      script:'''
Install-WindowsFeature -name Web-Server -IncludeManagementTools;
$htmlpage = '<!DOCTYPE html><html><head><title>Azure Test - kevin</title></head><body><h1>Welcome to the Azure Test Web Server!</h1><p>Created by: kevin</p></body></html>';
Add-Content -Path 'C:\\inetpub\\wwwroot\\index.html' -Value $htmlpage
'''
    }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = {
  parent: storageAccount
  name: 'default'
}

resource blobContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: 'weblogs'
  parent:blobService
  properties: {
    publicAccess: 'None'
  }
}


resource Microsoft_Insights_VMDiagnosticsSettings 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  name: 'Microsoft.Insights.VMDiagnosticsSettings'
  parent: windowsVM
  location: location
    tags: {
    displayName: 'AzureDiagnostics'
  }
  properties: {
    publisher: 'Microsoft.Azure.Diagnostics'
    type: 'IaaSDiagnostics'
    typeHandlerVersion: '1.5'
    autoUpgradeMinorVersion: true
    settings: {
      xmlCfg: base64(wadCfg)
      storageAccount: storageAccount
    }
    protectedSettings: {
      storageAccountName: storageAccount.name
      storageAccountKey: storageAccount.listKeys().keys[0].value
      storageAccountEndPoint: 'https://${environment().suffixes.storage}'
    }
  }
}

output vmResourceId string = windowsVM.id
output vnetResourceId string = virtualNetwork.id
output storageResourceId string = storageAccount.id
