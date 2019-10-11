# Deploy IBM WebSphere Application Server Netwrok Deployment Traditional with Azure ARM template and CLI

## Prerequisites
 - Register an [Azure subscription](https://azure.microsoft.com/en-us/)
 - Register an [IBM id](https://idaas.iam.ibm.com/idaas/mtfim/sps/authsvc?PolicyId=urn:ibm:security:authentication:asf:basicldapuser)
 - Download [IBM Installation Manager Installation Kit](https://www-945.ibm.com/support/fixcentral/swg/downloadFixes?parent=ibm%7ERational&product=ibm/Rational/IBM+Installation+Manager&release=1.9.0.0&platform=Linux&function=fixId&fixids=1.9.0.0-IBMIM-LINUX-X86_64-20190715_0328&useReleaseAsTarget=true&includeRequisites=1&includeSupersedes=0&downloadMethod=http)
 - Install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

 ## Before using sample parameters.json
 - Replace "GEN-UNIQUE" with valid user id or password
 
 ## Deploy using template, parameters & script
 With the provided ARM template and parameters, 
 - Using deploy.azcli to deploy
     ```
     deploy.azcli -n <deploymentName> -f <imInstallKitFile> -i <subscriptionId> -g <resourceGroupName> -l <resourceGroupLocation>
     ```

## After deployment
- If you check the resource group in [azure portal](https://portal.azure.com/), you will see related resources created
- Open VM resource blade and copy its DNS name, then open IBM WebSphere Integrated Solutions Console for further administration by browsing https://<dns_name>:9043/ibm/console
