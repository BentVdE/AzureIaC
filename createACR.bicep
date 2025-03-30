@minLength(5)
@maxLength(50)
@description('Specify a unique name for the Azure Container Registry')
param acrName string = 'acr${uniqueString(resourceGroup().id)}'

@description('Specify the location for the registry')
param location string = resourceGroup().location

@description('Specify the tier for the registry')
param acrSku string = 'Basic'

@description('Specify the name for the repository within the ACR.')
param repositoryName string = 'bvde-assignment2-flasktask'

@description('Specify the name for the scope map that defines repository permissions.')
param scopeMapName string = 'pullScopeMap'

@description('Specify the name for the token associated with the scope map.')
param tokenName string = 'pullToken'

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
  }
}

resource scopeMap 'Microsoft.ContainerRegistry/registries/scopeMaps@2023-01-01-preview' = {
  parent: acr
  name: scopeMapName
  properties: {
    description: 'Scope map for pull access to a specific repository'
    actions: [
      'repositories/${repositoryName}/content/read'
    ]
  }
}

resource token 'Microsoft.ContainerRegistry/registries/tokens@2023-01-01-preview' = {
  parent: acr
  name: tokenName
  properties: {
    scopeMapId: scopeMap.id
    status: 'enabled'
  }
}

@description('Output the login server property for later use')
output loginServer string = acr.properties.loginServer
