using '../modules/main.bicep'

param environment = 'dev'

param applicationGatewayConfig = {
  resourceGroupName: 'rg-sql-ag-dev'

  applicationGatewayName: 'appgw-api-dev'

  location: 'centralus'

  skuName: 'Standard_v2'
  skuTier: 'Standard_v2'

  minCapacity: 1
  maxCapacity: 3

  subnetId: '/subscriptions/a98c3501-7e50-4380-a713-b02e7444f4e5/resourceGroups/rg-sql-ag-dev/providers/Microsoft.Network/virtualNetworks/vnet-sql-ag-dev/subnets/appgw-subnet'

  publicIpName: 'pip-appgw-api-dev'

  frontendIpConfigurationName: 'appgw-frontend-ip'

  frontendPorts: [
    {
      name: 'app-http-port'
      port: 80
    }
  ]

  backendPools: [
    {
      name: 'api-backend-pool'
      backendAddresses: []
    }
  ]

  backendHttpSettings: [
    {
      name: 'api-http-settings'
      port: 80
      protocol: 'Http'
      cookieBasedAffinity: 'Disabled'
      requestTimeout: 30
      probeName: 'api-health-probe'
    }
  ]

  healthProbes: [
    {
      name: 'api-health-probe'
      protocol: 'Http'
      host: '127.0.0.1'
      path: '/health'
      interval: 30
      timeout: 30
      unhealthyThreshold: 3

      statusCodes: [
        '200-399'
      ]
    }
  ]

  listeners: [
    {
      name: 'api-http-listener'
      frontendPortName: 'app-http-port'
      protocol: 'Http'
    }
  ]

  routingRules: [
    {
      name: 'api-routing-rule'
      priority: 100
      listenerName: 'api-http-listener'
      backendPoolName: 'api-backend-pool'
      httpSettingName: 'api-http-settings'
    }
  ]

  enableHttp2: true

  tags: {
    Environment: environment
    Project: 'Application-Gateway'
    ManagedBy: 'Bicep'
    Owner: 'Infrastructure'
  }
}
