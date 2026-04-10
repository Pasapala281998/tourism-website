param location string = resourceGroup().location
param acrName string = 'tourismacr${uniqueString(resourceGroup().id)}'
param skuName string = 'Basic'

// Create Azure Container Registry
resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  sku: {
    name: skuName
  }
  properties: {
    adminUserEnabled: true
    publicNetworkAccess: 'Enabled'
    anonymousPullEnabled: false
    networkRuleBypassOptions: 'AzureServices'
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
    }
  }
}

// Output the ACR details
output acrLoginServer string = acr.properties.loginServer
output acrResourceId string = acr.id
output acrName string = acr.name
