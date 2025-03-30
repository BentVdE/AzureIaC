@description('Specify the name for the container instance')
param containerName string = 'bvde-flask-container'

@description('Specify the location for the resources')
param location string = resourceGroup().location

@description('Specify which container image to deploy')
param image string = 'bvdeass2containerregistry.azurecr.io/bvde-assignment2-flasktask:latest'

@description('Specify which port to open on the container')
param port int = 80

@description('Specify the number of CPU cores for the container')
param cores int = 1

@description('Specify the amount of memory (gigabytes) for the container')
param memory int = 2

@description('Specify the behavior of Azure runtime if the container stops running')
@allowed([
  'Always'
  'Never'
  'OnFailure'
])
param restartPolicy string = 'Always'

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: containerName
  location: location
  properties: {
    containers: [
      {
        name: containerName
        properties: {
          image: image
          ports: [
            {
              port: port
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: cores
              memoryInGB: memory
            }
          }
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: restartPolicy
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: port
          protocol: 'TCP'
        }
      ]
    }
    imageRegistryCredentials: [
      {
        server: 'bvdeass2containerregistry.azurecr.io'
        username: 'pullToken'
        password: 'k4k+7lesHfS24iqRHNJz+8z035c33sDZQXGdg/3TcO+ACRALFzkw'
      }
    ]
  }
}

output name string = containerGroup.name
output resourceGroupName string = resourceGroup().name
output resourceId string = containerGroup.id
output location string = location
output ipAddress string = containerGroup.properties.ipAddress.ip
