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
1 | azuredeploy.json <br\> azuredeploy.parameters.json | ARM Template that deploys Azure Resources: Azure Batch Account, Storage Account, File Share, VNet. <br\> After deploying this template, the batch files to be processed have to be copied to the Azure File Share via another process or manually through the Azure Portal.
2 | Content in the second column | more content

<table>
<tr>
<th></th>
<th>Files</th>
<th>Description</th>
</tr>
<tr>
<td>1</td><td>azuredeploy.json<br/>azuredeploy.parameters.json</td><td>ARM Template that deploys Azure Resources: Azure Batch Account, Storage Account, File Share, VNet
At the end of this template, the batch files to be processed have to be copied to the Azure File Share via another process or manually through the Azure Portal.</td>
</tr>
<tr>
<td>2</td><td></td><td>Uploading an application can be done through the portal or running:<br/><br/>
New-AzBatchApplicationPackage -AccountName "azbatchwin" -ResourceGroupName "azbatchwin-rg" -ApplicationName "BatchApp" -ApplicationVersion "1" -FilePath "c:\batch\app\batchapp.zip" -Format "zip"
<br/><br/>
A sample application that reads a file, counts the characters and writes the resukt to a database is here: <br/>
https://github.com/azuregomez/batchapp
</td>
</tr>
<tr>
<td>3</td><td>batchpool.ps1<br/>batchpool.parameters.json</td><td>Powershell Script that deploys a pool of worker nodes in a VNet, and copies applications and versions specified in the parameters file. The script also mounts the Azure File Share in all the pool nodes. The script reads parameters from the json file.</td>
</tr>
<tr>
<td>4</td><td>batchjob.ps1<br/>batchjob.parameters.json</td><td>Powershell script that submits a job with a task. The job will be executed in the specified worker pool. The parameter file includes tasks to be executed, which is usually an invocation to the application installed in step 3.</td>
</tr>
</table>
<h2>Hybrid solution with HPC Pack</h2>
This solution can be deployed in a peered spoke and leverage S2S VPN or ExpressRoute to reach out back to the data center, for example, to save results to an un-prem database.<br/>
<img src="https://storagegomez.blob.core.windows.net/public/images/hybrid.png"/>
<h2>References</h2>
https://docs.microsoft.com/en-us/azure/batch/
https://docs.microsoft.com/en-us/azure/batch/batch-virtual-network
https://docs.microsoft.com/en-us/azure/batch/virtual-file-mount
https://github.com/Azure/azure-powershell/tree/master/src/Batch
