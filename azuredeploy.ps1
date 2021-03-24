# template file and params copied to local
$localpath = "C:\projects\github\azbatchspoke\"
$templatefile = $localpath + "azuredeploy.json"
$templateparamfile = $localpath + "azuredeploy.parameters.json"
$location = "East US"
# using template naming conventions for rg, sqlserver and keyvault
$rgname = "azbatchwin-rg"
$rg = get-azresourcegroup -location $location -name $rgname
if ($null -eq $rg)
{
    new-azresourcegroup -location $location -name $rgname
}
New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $templateFile -TemplateParameterFile $templateparamfile 
write-host "ARM Deployment Complete"