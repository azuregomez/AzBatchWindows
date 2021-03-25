# Azure Batch Windows nodes with Azure File Share
## Business Case
Many organizations have the need to use HPC to process files, matching the following requirements:
* Process files in a pool of Windows VMs
* Pool nodes deployed in a Virtual Network
* Files available in a file share, accesible through SMB protocol
## Solution
* Deploy an Azure Batch Pool in a VNet
* Mount an Azure File Share in all the nodes.
The solution works for
* Cloud-only HPC file processing
* Burst out from on-prem HPC Pack to Azure Batch
## Architecture
![Architecture](https://storagegomez.blob.core.windows.net/public/images/azbatchwin.png)
## Implementation Steps
1. Deploy Core Infrastructure: Azure Batch Account, File Share, Virtual Network.
2. Upload an Application to Batch Account storage.
3. Create a Worker pool of Windows nodes in the VNet, with the application installed and the file share mounted.
4. Submit a batch Job with a Task that runs the application.
<table>
<tr>
<th>Step</th>
<th>Files</th>
<th>Description</th>
</tr>
<tr>
<td>1</td><td>azuredeploy.json</td><td>ok</td>
</tr>
</table>