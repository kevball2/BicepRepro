param vnetName string
param vnetResourceGroup string
param vnetSubscriptionId string
param subnetName string
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetSubscriptionId, vnetResourceGroup)
}
output vnet object = vnet
var subnetId = resourceId(vnetSubscriptionId, vnetResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
output subnetId string = subnetId