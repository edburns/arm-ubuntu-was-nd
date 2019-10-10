# Deploy IBM WebSphere Application Server Netwrok Deployment Traditional with Azure ARM template and CLI

## Prerequisites
 - Register Azure subscription
 - Register IBM user id in IBM website
 - Download IBM Installation Manager install kit from IBM website
 - Install [Azure CLI](https://github.com/Azure/azure-cli)

 ## Before using sample parameters.json
 - Replace "GEN-UNIQUE" with valid user id or password
 
 ## Deploy using template, parameters & script
 With the provided ARM template and parameters, 
 - Using deploy.azcli to deploy
     ```
     deploy.azcli -f <imInstallKitFile> -i <subscriptionId> -g <resourceGroupName> -l <resourceGroupLocation> -n <deploymentName>
     ```

## After deployment
- If you check the resource group in [azure portal](https://portal.azure.com/), you will see related resources created
- Open VM resource blade and copy its domain name, then open admin console by browsing https://<domain_name>:9043/ibm/console