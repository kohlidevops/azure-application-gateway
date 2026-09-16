@description('Application Gateway name')
param applicationGatewayName string

@description('Azure region')
param location string

@description('Application Gateway SKU name')
param skuName string

@description('Application Gateway SKU tier')
param skuTier string

@description('Minimum Application Gateway capacity')
param minCapacity int

@description('Maximum Application Gateway capacity')
param maxCapacity int

@description('Application Gateway subnet resource ID')
param subnetId string

@description('Public IP resource name')
param publicIpName string

@description('Frontend IP configuration name')
param frontendIpConfigurationName string

@description('Frontend port configurations')
param frontendPorts array

@description('Backend pool configurations')
param backendPools array

@description('Backend HTTP settings configurations')
param backendHttpSettings array

@description('Health probe configurations')
param healthProbes array

@description('HTTP listener configurations')
param listeners array

@description('Routing rule configurations')
param routingRules array

@description('Enable HTTP/2')
param enableHttp2 bool

@description('Resource tags')
param tags object


resource publicIp 'Microsoft.Network/publicIPAddresses@2025-05-01' = {
  name: publicIpName
  location: location

  sku: {
    name: 'Standard'
    tier: 'Regional'
  }

  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}


resource applicationGateway 'Microsoft.Network/applicationGateways@2025-05-01' = {
  name: applicationGatewayName
  location: location
  tags: tags

  properties: {

    sku: {
      name: skuName
      tier: skuTier
    }

    autoscaleConfiguration: {
      minCapacity: minCapacity
      maxCapacity: maxCapacity
    }

    enableHttp2: enableHttp2

    gatewayIPConfigurations: [
      {
        name: 'appgw-ip-config'

        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]

    frontendIPConfigurations: [
      {
        name: frontendIpConfigurationName

        properties: {
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]

    frontendPorts: [
      for frontendPort in frontendPorts: {
        name: frontendPort.name

        properties: {
          port: frontendPort.port
        }
      }
    ]

    backendAddressPools: [
      for backendPool in backendPools: {
        name: backendPool.name

        properties: {
          backendAddresses: backendPool.backendAddresses
        }
      }
    ]

    backendHttpSettingsCollection: [
      for httpSetting in backendHttpSettings: {
        name: httpSetting.name

        properties: {
          port: httpSetting.port
          protocol: httpSetting.protocol
          cookieBasedAffinity: httpSetting.cookieBasedAffinity
          requestTimeout: httpSetting.requestTimeout

          probe: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/probes',
              applicationGatewayName,
              httpSetting.probeName
            )
          }
        }
      }
    ]

    probes: [
      for probe in healthProbes: {
        name: probe.name

        properties: {
          protocol: probe.protocol
          host: probe.host
          path: probe.path
          interval: probe.interval
          timeout: probe.timeout
          unhealthyThreshold: probe.unhealthyThreshold

          match: {
            statusCodes: probe.statusCodes
          }
        }
      }
    ]

    httpListeners: [
      for listener in listeners: {
        name: listener.name

        properties: {
          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendIPConfigurations',
              applicationGatewayName,
              frontendIpConfigurationName
            )
          }

          frontendPort: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendPorts',
              applicationGatewayName,
              listener.frontendPortName
            )
          }

          protocol: listener.protocol
        }
      }
    ]

    requestRoutingRules: [
      for rule in routingRules: {
        name: rule.name

        properties: {
          ruleType: 'Basic'
          priority: rule.priority

          httpListener: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/httpListeners',
              applicationGatewayName,
              rule.listenerName
            )
          }

          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendAddressPools',
              applicationGatewayName,
              rule.backendPoolName
            )
          }

          backendHttpSettings: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
              applicationGatewayName,
              rule.httpSettingName
            )
          }
        }
      }
    ]
  }
}


output applicationGatewayId string = applicationGateway.id

output applicationGatewayName string = applicationGateway.name

output publicIpAddress string = publicIp.properties.ipAddress
