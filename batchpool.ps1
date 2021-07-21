# Your Local path where the pool solution files are saved
$ParameterFile = "batchpool.parameters.json"
$poolParamFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $ParameterFile))
$params = get-content $poolParamFile | ConvertFrom-Json
$vmsku = $params.vmsku
$poolnodes = $params.poolnodes
$poolname = $params.poolname
# Variables from naming conventions, could be parameters if desired
$accountname = $params.batchaccountname
$vnetname = $params.vnet
$subnetname = $params.subnet
# Get Batch context
$context = Get-AzBatchAccount -AccountName $accountname
# Create Batch Pool
# -- with windows image
$imageReference = New-Object -TypeName "Microsoft.Azure.Commands.Batch.Models.PSImageReference" -ArgumentList @("WindowsServer", "MicrosoftWindowsServer", "2019-datacenter")
$configuration = New-Object -TypeName "Microsoft.Azure.Commands.Batch.Models.PSVirtualMachineConfiguration" -ArgumentList @($imageReference, "batch.node.windows amd64")
# -- deployed to a Virtual Network
$networkConfig = New-Object Microsoft.Azure.Commands.Batch.Models.PSNetworkConfiguration
$vnet = get-azvirtualnetwork -name $vnetname
$subnet = $vnet.Subnets | where-object name -eq $subnetname
$networkConfig.SubnetId = $subnet.Id
# -- with Applications deployed in the nodes
# -- only if the applications have been uploaded
# -- apps can be uploaded in the portal or with Powershell:
# -- New-AzBatchApplicationPackage -AccountName "azbatch0721" -ResourceGroupName "azbatch0721-rg" -ApplicationName "BatchApp" -ApplicationVersion "1" -FilePath "c:\batch\app\batchapp.zip" -Format "zip"
[Microsoft.Azure.Commands.Batch.Models.PSApplicationPackageReference[]]$appRefs = @()
$appPackageReference = New-Object Microsoft.Azure.Commands.Batch.Models.PSApplicationPackageReference
$appPackageReference.ApplicationId = $params.appid
$appPackageReference.Version = $params.appversion
$appRefs += $appPackageReference
# -- mount file share
$filesharedir = $params.filesharedir
$azfileshareurl = $params.azfileshareurl
$account = $params.storageaccount
$rgname = $params.resourcegroup
$keys = get-azstorageaccountkey -resourcegroupname $rgname -accountname $account
$accountKey = $keys[0].value
# -- mountoptions is some Linux secret sauce hard to find: https://docs.microsoft.com/en-us/azure/batch/virtual-file-mount#examples
# $mountoptions = "-o vers=3.0,dir_mode=0777,file_mode=0777,sec=ntlmssp"                 
$afsconfig = New-Object Microsoft.Azure.Commands.Batch.Models.PSAzureFileShareConfiguration($account,$azfileshareurl,$filesharedir,$accountKey)
# ,$mountoptions)
[Microsoft.Azure.Commands.Batch.Models.PSMountConfiguration[]]$mountConfigs = @()
$mountConfigs += $afsconfig
# -- Create batch pool 
New-AzBatchPool -Id $poolname -VirtualMachineSize $vmsku -VirtualMachineConfiguration $configuration -TargetDedicatedComputeNodes $poolnodes -NetworkConfiguration $networkConfig -BatchContext $Context -ApplicationPackageReferences $appRefs -MountConfiguration $mountConfigs
Get-AzBatchPool -BatchContext $context -Id $poolname
