# .\azuredeploy.ps1 -Location "East US"
Param(
    [string] [parameter(Mandatory=$true)] $Location
)
$ParameterFile = 'azuredeploy.parameters.json'
$templateFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, 'azuredeploy.json'))
$templateParamFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $ParameterFile))
# using template naming conventions for rg, sqlserver and keyvault
$params = get-content $templateParamFile | ConvertFrom-Json
$prefix = $params.parameters.deploymentPrefix.value
$rgname = $prefix + "-rg"
# Create the resource group only when it doesn't already exist
if ($null -eq (Get-AzResourceGroup -Name $rgname -Location $Location -Verbose -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $rgname -Location $Location -Verbose -Force -ErrorAction Stop
}
New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $templateFile -TemplateParameterFile $templateparamfile 
write-host "ARM Deployment Complete"