# Azure Batch Windows nodes with Azure File Share
## Business Case
Many organizations have the need to use HPC to process files, matching the following requirements:
* Process files in a pool of Windows VMs
* Pool nodes deployed in a Virtual Network
* Files available in a file share, accesible through SMB protocol
## Solution
* Deploy an Azure Batch Pool in a VNet
* Mount an Azure File Share in all the nodes.
* This solution works for both a cloud-only HPC file processing or burst out from on-prem HPC Pack to Azure Batch.
## Architecture
![Architecture](https://storagegomez.blob.core.windows.net/public/images/azbatchwin.png)
## Implementation Steps
1. Deploy Core Infrastructure: Azure Batch Account, File Share, Virtual Network.
2. Upload an Application to Batch Account storage.
3. Create a Worker pool of Windows nodes in the VNet, with the application installed and the file share mounted.
4. Submit a batch Job with a Task that runs the application.

Step | Files | Description 
------------ | ------------- | -------------
1 | azuredeploy.json  azuredeploy.parameters.json azuredeploy.ps1 | ARM Template that deploys Azure Resources: Azure Batch Account, Storage Account, File Share, VNet.  After deploying this template, the batch files to be processed have to be copied to the Azure File Share via another process or manually through the Azure Portal. The template is deployed by cloning this repo and running azuredeploy.ps1
2 | | Uploading an application can be done through the portal or running: New-AzBatchApplicationPackage -AccountName "azbatchwin" -ResourceGroupName "azbatchwin-rg" -ApplicationName "BatchApp" -ApplicationVersion "1" -FilePath "c:\batch\app\batchapp.zip" -Format "zip"
3 | batchpool.ps1  batchpool.parameters.json | Powershell Script that deploys a pool of worker nodes in a VNet, and copies applications and versions specified in the parameters file. The script also mounts the Azure File Share in all the pool nodes. The script reads parameters from the json file.
4 | batchjob.ps1 batchjob.parameters.json | Powershell script that submits a job with a task. The job will be executed in the specified worker pool. The parameter file includes tasks to be executed, which is usually an invocation to the application installed in step 3.

## Parameters
### azuredeploy.paramaters.json
Parameter file for the ARM Template
Parameter | Description
--------- | -----------
deploymentPrefix | This prefix is used in the ARM template for naming all resources. Alternatively, you can provide all the resource names.
### batchpool.parameters.json
Parameter file for batchpool.ps1
Parameter | Description
--------- | -----------
resourcegroup | Resource Group where the Batch Account was created
batchaccountname | Azure Batch Account Name created in step 1
poolname | Azure Batch pool name to be created by the script
poolnodes | Number of nodes to be created in the pool
vmsku | SKU for the Node VMs that will be created in the pool
vnet | Name of the Virtual Network where the nodes will be created
subnet | Name of the subnet where the nodes will be created
filesharedir | Drive letter for the file share to be mounted on each node of the pool
azfileshareurl | URL for the Azure File Share that was created in step 1
storageaccount | Name of the storage account where the Azure File Share was created
appid | Application ID for the application that will be deployed to the pool nodes. Uploaded in step 2.
appversion | Application version for the application that will be deployed to the pool nodes.
### batchjob.parameters.json
Parameter file for batchjob.ps1
Parameter | Description
--------- | -----------
batchaccountname | Azure Batch Account Name created in step 1.
poolname | Azure Batch pool namecreated in step 3.
jobid | Name of the Job to be created.
taskid | Name of teh Task to be created.
command | Command of the task. For a Windows task, commands must start with cmd /c to start the shell. To execute an application that was loaded, it is necessary to use the right environment variable that has the path of the application.  The variable has the following format: `%AZ_BATCH_APP_PACKAGE_{Application Name}#{Application Version}%/{Executable}`. For example, to execute BatchApp, version 1 with BatcxhApp.exe, the command would be `%AZ_BATCH_APP_PACKAGE_BatchApp#1%/batchapp.exe`
## Hybrid solution with HPC Pack
This solution can be deployed in a peered spoke and leverage S2S VPN or ExpressRoute to reach out back to the data center, for example, to save results to an on-prem database.

![Architecture](https://storagegomez.blob.core.windows.net/public/images/hybrid.png)

## References
https://docs.microsoft.com/en-us/azure/batch/
https://docs.microsoft.com/en-us/azure/batch/batch-virtual-network
https://docs.microsoft.com/en-us/azure/batch/virtual-file-mount
https://github.com/Azure/azure-powershell/tree/master/src/Batch
