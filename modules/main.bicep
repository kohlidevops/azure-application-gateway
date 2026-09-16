targetScope = 'subscription'

@description('Deployment environment')
param environment string

@description('Application Gateway configuration')
param applicationGatewayConfig object

module applicationGatewayModule './networking/applicationGateway.bicep' = {
  name: 'appgw-${applicationGatewayConfig.applicationGatewayName}-${environment}'
  scope: resourceGroup(applicationGatewayConfig.resourceGroupName)

  params: {
    applicationGatewayName: applicationGatewayConfig.applicationGatewayName
    location: applicationGatewayConfig.location
    skuName: applicationGatewayConfig.skuName
    skuTier: applicationGatewayConfig.skuTier
    minCapacity: applicationGatewayConfig.minCapacity
    maxCapacity: applicationGatewayConfig.maxCapacity

    subnetId: applicationGatewayConfig.subnetId

    publicIpName: applicationGatewayConfig.publicIpName

    frontendIpConfigurationName: applicationGatewayConfig.frontendIpConfigurationName
    frontendPorts: applicationGatewayConfig.frontendPorts

    backendPools: applicationGatewayConfig.backendPools
    backendHttpSettings: applicationGatewayConfig.backendHttpSettings
    healthProbes: applicationGatewayConfig.healthProbes

    listeners: applicationGatewayConfig.listeners
    routingRules: applicationGatewayConfig.routingRules

    enableHttp2: applicationGatewayConfig.enableHttp2

    tags: applicationGatewayConfig.tags
  }
}
