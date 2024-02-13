targetScope = 'managementGroup'

module sub001 'br/public:lz/sub-vending:1.2.2' = {
  name: 'sub001'
  params: {
    subscriptionAliasEnabled: true
    subscriptionBillingScope: '/providers/Microsoft.Billing/billingAccounts/1234567/enrollmentAccounts/123456'
    subscriptionAliasName: 'sub-test-001'
    subscriptionDisplayName: 'sub-test-001'
    subscriptionTags: {
      example: 'true'
    }
    subscriptionWorkload: 'Production'
    subscriptionManagementGroupAssociationEnabled: true
    subscriptionManagementGroupId: 'corp'
  }
}

module storageSample 'br/public:storage/storage-account:0.0.1' = {
  scope: 
  name: 
  params: {
    location: 
  }
}