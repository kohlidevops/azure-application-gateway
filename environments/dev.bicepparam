using '../modules/main.bicep'


param environment = 'dev'

param location = 'centralus'


param applicationGatewayConfig = {

  resourceGroupName: 'rg-sql-ag-dev'

  applicationGatewayName: 'appgw-sql-ag-dev'

  location: location


  skuName: 'Standard_v2'

  skuTier: 'Standard_v2'


  minCapacity: 1

  maxCapacity: 3


  vnetName: 'vnet-sql-ag-dev'

  subnetName: 'appgw-subnet'

  subnetAddressPrefix: '10.10.3.0/24'


  publicIpName: 'pip-appgw-sql-ag-dev'


  frontendIpConfigurationName: 'appgw-frontend-ip'

  frontendPortName: 'appgw-http-port'

  frontendPort: 80


  backendPoolName: 'app-backend-pool'

  backendAddresses: []


  backendHttpSettingsName: 'app-http-settings'

  backendPort: 80

  backendProtocol: 'Http'

  cookieBasedAffinity: 'Disabled'

  requestTimeout: 30


  listenerName: 'app-http-listener'

  listenerProtocol: 'Http'


  routingRuleName: 'app-routing-rule'

  routingRulePriority: 100


  enableHttp2: true


  tags: {
    Environment: environment
    Project: 'Application-Gateway'
    ManagedBy: 'Bicep'
    Owner: 'Infrastructure'
  }
}
