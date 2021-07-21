$ParameterFile = "batchpool.parameters.json"
$templateParamFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $ParameterFile))
$params = get-content $templateParamFile | ConvertFrom-Json
# Submit a New Job and new task
$accountname = $params.batchaccountname
$context = Get-AzBatchAccount -AccountName $accountname
$PoolInformation = New-Object -TypeName "Microsoft.Azure.Commands.Batch.Models.PSPoolInformation" 
$PoolInformation.PoolId = $params.poolname
$jobid = $params.jobid
New-AzBatchJob -Id $jobid  -PoolInformation $PoolInformation -BatchContext $context
$taskid = $params.taskid
$cmd = $params.command
new-azbatchtask -jobid $jobid -id $taskid -BatchContext $context -commandline $cmd


