// ----------
// Parameters
// ----------

// param config object = loadJsonContent('configs/main.json')
var config = loadJsonContent('configs/main.json')

// merged config variable that merges the main with the application/version config
var mergedConfig = union(loadJsonContent('defaults.json'), config)

var config2019 = union(loadJsonContent('configs/main.json'),
{ 
  initScript: loadTextContent('scripts/2019/config.ps1')
  numberVms: 1
})

var configDC = union(loadJsonContent('configs/main.json'),
{ 
  numberVms: 1
})

var configBastion= union(loadJsonContent('configs/main.json'),
{ 
  initScript: loadTextContent('scripts/bastion/bastion.ps1')
  numberVms: 1
})

param imagesRefs array = loadJsonContent('configs/imagerefs.json')

// ------
// Scopes
// ------

targetScope = 'subscription'

// -------
// Modules
// -------

module groups './modules/groups/resources.bicep' = {
  name: 'Microsoft.Resources.AppMigWorkshopGroups'
  scope: subscription()
  params: {
    config: mergedConfig
  }
}

module domainController './modules/components/domain-controller/VirtualMachine.bicep' = [for number in range(1,configDC.numberVms): {
  name: 'Microsoft.Resources.VM2022${number}'
  scope: resourceGroup(configDC.resourceGroup)
  params: {
    config: configDC
    imageRef: imagesRefs[7]
    year: '2022'
    number: string(number)
  }
  dependsOn: [
    groups
  ]
}]

// Legacy Apps from repo: Classifieds, TimeTracker, and Jobs on Server 2019
module components2019 './modules/components/2019/VirtualMachine.bicep' = [for number in range(1,config2019.numberVms): {
  name: 'Microsoft.Resources.VM2019${number}'
  scope: resourceGroup(config2019.resourceGroup)
  params: {
    config: config2019
    imageRef: imagesRefs[3]
    year: '2019'
    number: string(number)
  }
  dependsOn: [
    groups
    domainController
  ]
}]


// Bastion VM
module bastion './modules/components/bastion/Bastion.bicep' = [for number in range(1,configBastion.numberVms): {
  name: 'Microsoft.Resources.bastion${number}'
  scope: resourceGroup(configBastion.resourceGroup)
  params: {
    config: configBastion
    imageRef: imagesRefs[8]
  }
  dependsOn: [
    groups
    domainController
  ]
}]

// ----------
// Outputs
// ----------
