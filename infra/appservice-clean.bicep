param location string = 'westus'
param appName string = 'tourism-website-${uniqueString(resourceGroup().id)}'
param appServicePlanName string = 'tourism-plan-${uniqueString(resourceGroup().id)}'
param acrLoginServer string = 'tourismacrfdphgtf5r6bi4.azurecr.io'
param acrImageName string = 'tourism-website:latest'
param acrUsername string = 'tourismacrfdphgtf5r6bi4'
@secure()
param acrPassword string

// Create App Service Plan (Free Tier - no quota restrictions)
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'F1'
    tier: 'Free'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

// Create Web App
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: appName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrLoginServer}/${acrImageName}'
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrLoginServer}'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: acrUsername
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: acrPassword
        }
        {
          name: 'DOCKER_ENABLE_CI'
          value: 'true'
        }
      ]
    }
    httpsOnly: true
  }
}

// Output
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output webAppName string = webApp.name
output appServicePlanId string = appServicePlan.id
