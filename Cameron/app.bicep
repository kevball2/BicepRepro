@description('Storage Account type')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
param storageAccountType string = 'Standard_LRS'
@description('The name of the Storage Account')
param storageAccountName string = 'hbsdev'
param containerName string = 'hbsprojects'
param containerName2 string = 'files'
param searchServiceName string = 'sch-hbsservice-dev'
param searchServiceResourceGroup string = 'rg-hbsservice-dev'
param vnetName string = 'net-inproDocumentManagment-dev'
param vnetResourceGroup string = 'rg-documentManagement-dev'
param vnetSubscriptionId string = '2230cc79-7b29-46c2-9df8-83823f0b2df7'
param subnetName string = 'default'
param webAppName string = 'app-hbsservice-dev'
param sku string = 'S1' // The SKU of App Service Plan
param linuxFxVersion string = 'DOTNETCORE|7.0' // The runtime stack of web app
param location string = resourceGroup().location // Location for all resources
param applicationInsightsName string = 'ai-hbsservice-dev' // The name of Application Insights
param appServicePlanName string = 'asp-hbs-dev'
module netModule 'network-module.bicep' = {
  scope: resourceGroup(vnetSubscriptionId, vnetResourceGroup)
  name: 'netMod'
  params: {
    vnetName: vnetName, vnetResourceGroup: vnetResourceGroup, vnetSubscriptionId: vnetSubscriptionId, subnetName: subnetName
  }
}
resource search 'Microsoft.Search/searchServices@2020-08-01' existing = {
  name: searchServiceName
  scope: resourceGroup(searchServiceResourceGroup)
}
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    DisableIpMasking: false
    DisableLocalAuth: false
    Flow_Type: 'Bluefield'
    ForceCustomerStorageForProfiler: false
    ImmediatePurgeDataOn30Days: true
    IngestionMode: 'ApplicationInsights'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    Request_Source: 'rest'
  }
}
resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: sku
  }
  kind: 'linux'
}
resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    virtualNetworkSubnetId: netModule.outputs.subnetId
    vnetRouteAllEnabled: true
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
        {
          name: 'SearchApiKey'
          value: search.listAdminKeys().primaryKey
        }
        {
          name: 'SearchEndPoint'
          value: 'https://${searchServiceName}.search.windows.net'
        }
        {
          name: 'SearchIdField'
          value: 'metadata_storage_path'
        }
        {
          name: 'SearchIndexName'
          value: 'hbs-index-alpha'
        }
      ]
    }
  }
}
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: 'DocumentManagementPrivateEndpoint'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'DocumentManagementPrivateLinkServiceConnection'
        properties: {
          privateLinkServiceId: appService.id
          groupIds: [
            'appService'
          ]
        }
      }
    ]
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
    }
  }
}
resource sa 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}
resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: '${sa.name}/default/${containerName}'
}
resource container2 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: '${sa.name}/default/${containerName2}'
}