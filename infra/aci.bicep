param location string = resourceGroup().location
param containerGroupName string = 'tourism-${uniqueString(resourceGroup().id)}'
param acrLoginServer string = 'tourismacrfdphgtf5r6bi4.azurecr.io'
param acrImageName string = 'tourism-website:latest'
param acrUsername string = 'tourismacrfdphgtf5r6bi4'
@secure()
param acrPassword string
param containerPort int = 80

// Create Container Instance
resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: containerGroupName
  location: location
  properties: {
    containers: [
      {
        name: 'tourism-website'
        properties: {
          image: '${acrLoginServer}/${acrImageName}'
          ports: [
            {
              port: containerPort
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: '1.0'
              memoryInGb: '1.5'
            }
          }
          environmentVariables: []
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: 'Always'
    imageRegistryCredentials: [
      {
        server: acrLoginServer
        username: acrUsername
        password: acrPassword
      }
    ]
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: containerPort
          protocol: 'TCP'
        }
      ]
      dnsNameLabel: containerGroupName
    }
  }
}

// Output
output publicUrl string = 'http://${containerGroup.properties.ipAddress.fqdn}:${containerPort}'
output ipAddress string = containerGroup.properties.ipAddress.ip
output fqdn string = containerGroup.properties.ipAddress.fqdn
