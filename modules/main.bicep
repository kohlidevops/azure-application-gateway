targetScope = 'subscription'

@description('Deployment environment')
param environment string

@description('Azure region')
param location string

@description('Application Gateway configuration')
param applicationGatewayConfig object


module applicationGatewaySubnetModule './networking/applicationGatewaySubnet.bicep' = {
  name: 'appgw-subnet-${environment}'
  scope: resourceGroup(applicationGatewayConfig.resourceGroupName)

  params: {
    vnetName: applicationGatewayConfig.vnetName
    subnetName: applicationGatewayConfig.subnetName
    subnetAddressPrefix: applicationGatewayConfig.subnetAddressPrefix
  }
}


module applicationGatewayModule './networking/applicationGateway.bicep' = {
  name: 'appgw-${applicationGatewayConfig.applicationGatewayName}-${environment}'
  scope: resourceGroup(applicationGatewayConfig.resourceGroupName)

  dependsOn: [
    applicationGatewaySubnetModule
  ]

  params: {
    applicationGatewayName: applicationGatewayConfig.applicationGatewayName
    location: applicationGatewayConfig.location
    skuName: applicationGatewayConfig.skuName
    skuTier: applicationGatewayConfig.skuTier

    minCapacity: applicationGatewayConfig.minCapacity
    maxCapacity: applicationGatewayConfig.maxCapacity

    vnetName: applicationGatewayConfig.vnetName
    subnetName: applicationGatewayConfig.subnetName

    publicIpName: applicationGatewayConfig.publicIpName

    frontendIpConfigurationName: applicationGatewayConfig.frontendIpConfigurationName
    frontendPortName: applicationGatewayConfig.frontendPortName
    frontendPort: applicationGatewayConfig.frontendPort

    backendPoolName: applicationGatewayConfig.backendPoolName
    backendAddresses: applicationGatewayConfig.backendAddresses

    backendHttpSettingsName: applicationGatewayConfig.backendHttpSettingsName
    backendPort: applicationGatewayConfig.backendPort
    backendProtocol: applicationGatewayConfig.backendProtocol
    cookieBasedAffinity: applicationGatewayConfig.cookieBasedAffinity
    requestTimeout: applicationGatewayConfig.requestTimeout

    listenerName: applicationGatewayConfig.listenerName
    listenerProtocol: applicationGatewayConfig.listenerProtocol

    routingRuleName: applicationGatewayConfig.routingRuleName
    routingRulePriority: applicationGatewayConfig.routingRulePriority

    enableHttp2: applicationGatewayConfig.enableHttp2

    tags: applicationGatewayConfig.tags
  }
}
