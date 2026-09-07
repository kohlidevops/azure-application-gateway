@description('Application Gateway name')
param applicationGatewayName string

@description('Azure region')
param location string

@description('Application Gateway SKU name')
param skuName string

@description('Application Gateway SKU tier')
param skuTier string

@description('Minimum Application Gateway instances')
param minCapacity int

@description('Maximum Application Gateway instances')
param maxCapacity int

@description('Existing Virtual Network name')
param vnetName string

@description('Dedicated Application Gateway subnet name')
param subnetName string

@description('Standard Public IP name')
param publicIpName string

@description('Frontend IP configuration name')
param frontendIpConfigurationName string

@description('Frontend port resource name')
param frontendPortName string

@description('Frontend listener port')
param frontendPort int

@description('Backend address pool name')
param backendPoolName string

@description('Backend server addresses')
param backendAddresses array

@description('Backend HTTP settings name')
param backendHttpSettingsName string

@description('Backend server port')
param backendPort int

@description('Backend protocol')
param backendProtocol string

@description('Cookie based affinity')
param cookieBasedAffinity string

@description('Backend request timeout')
param requestTimeout int

@description('HTTP listener name')
param listenerName string

@description('HTTP listener protocol')
param listenerProtocol string

@description('Request routing rule name')
param routingRuleName string

@description('Request routing rule priority')
param routingRulePriority int

@description('Enable HTTP/2')
param enableHttp2 bool

@description('Resource tags')
param tags object


var subnetId = resourceId(
  'Microsoft.Network/virtualNetworks/subnets',
  vnetName,
  subnetName
)

var frontendIpConfigurationId = resourceId(
  'Microsoft.Network/applicationGateways/frontendIPConfigurations',
  applicationGatewayName,
  frontendIpConfigurationName
)

var frontendPortId = resourceId(
  'Microsoft.Network/applicationGateways/frontendPorts',
  applicationGatewayName,
  frontendPortName
)

var backendPoolId = resourceId(
  'Microsoft.Network/applicationGateways/backendAddressPools',
  applicationGatewayName,
  backendPoolName
)

var backendHttpSettingsId = resourceId(
  'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
  applicationGatewayName,
  backendHttpSettingsName
)

var listenerId = resourceId(
  'Microsoft.Network/applicationGateways/httpListeners',
  applicationGatewayName,
  listenerName
)


resource publicIp 'Microsoft.Network/publicIPAddresses@2025-05-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  tags: tags
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

    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfiguration'

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
      {
        name: frontendPortName

        properties: {
          port: frontendPort
        }
      }
    ]

    backendAddressPools: [
      {
        name: backendPoolName

        properties: {
          backendAddresses: [
            for backend in backendAddresses: {
              ipAddress: backend.ipAddress
            }
          ]
        }
      }
    ]

    backendHttpSettingsCollection: [
      {
        name: backendHttpSettingsName

        properties: {
          port: backendPort
          protocol: backendProtocol
          cookieBasedAffinity: cookieBasedAffinity
          requestTimeout: requestTimeout
        }
      }
    ]

    httpListeners: [
      {
        name: listenerName

        properties: {
          frontendIPConfiguration: {
            id: frontendIpConfigurationId
          }

          frontendPort: {
            id: frontendPortId
          }

          protocol: listenerProtocol
          requireServerNameIndication: false
        }
      }
    ]

    requestRoutingRules: [
      {
        name: routingRuleName

        properties: {
          ruleType: 'Basic'

          priority: routingRulePriority

          httpListener: {
            id: listenerId
          }

          backendAddressPool: {
            id: backendPoolId
          }

          backendHttpSettings: {
            id: backendHttpSettingsId
          }
        }
      }
    ]

    enableHttp2: enableHttp2
  }
}


output applicationGatewayId string = applicationGateway.id
output applicationGatewayName string = applicationGateway.name
output publicIpId string = publicIp.id
output publicIpAddress string = publicIp.properties.ipAddress
