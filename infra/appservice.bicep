param location string = resourceGroup().location
param appName string = 'tourism-website-${uniqueString(resourceGroup().id)}'
param appServicePlanName string = 'tourism-plan-${uniqueString(resourceGroup().id)}'
param acrLoginServer string = 'tourismacrfdphgtf5r6bi4.azurecr.io'
param acrImageName string = 'tourism-website:latest'
param acrUsername string = 'tourismacrfdphgtf5r6bi4'
@secure()
param acrPassword string

// Create App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
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
      scmType: 'None'
      appCommandLine: ''
    }
    httpsOnly: true
  }
}

// Configure Docker settings
resource webAppConfig 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: webApp
  name: 'web'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'index.html'
    ]
    netFrameworkVersion: 'v4.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: true
    detailedErrorLoggingEnabled: true
    publishingUsername: 'publisher'
    scmType: 'None'
    use32BitWorkerProcess: false
    webSocketsEnabled: false
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: true
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    cors: {
      allowedOrigins: [
        '*'
      ]
      supportCredentials: false
    }
    localMySqlEnabled: false
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 1
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 1
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: true
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.0'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    fileChangeAuditEnabled: false
    functionAppScaleLimit: 0
    healthCheckPath: '/'
    fileSystemHttpLoggingRetentionDays: 4
    containerLogsRetentionInDays: 0
  }
}

// Create App Settings for ACR Authentication
resource webAppAppSettings 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: webApp
  name: 'appsettings'
  properties: {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
    DOCKER_REGISTRY_SERVER_URL: 'https://${acrLoginServer}'
    DOCKER_REGISTRY_SERVER_USERNAME: acrUsername
    DOCKER_REGISTRY_SERVER_PASSWORD: acrPassword
    DOCKER_ENABLE_CI: 'true'
  }
}

// Output
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output webAppName string = webApp.name
output appServicePlanId string = appServicePlan.id
