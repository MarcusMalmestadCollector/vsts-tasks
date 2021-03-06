[cmdletbinding()]
param
(
	[Parameter(Mandatory=$true)][string] $services,
	[Parameter(Mandatory=$true)][string] $stopservices,
	[Parameter(Mandatory=$true)][string] $startservices,
    [Parameter(Mandatory=$true)][string] $servicewaittime
)

import-module "Microsoft.TeamFoundation.DistributedTask.Task.Internal"
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

$runStopServices = Convert-String $stopservices Boolean
$runStartServices = Convert-String $startservices Boolean
$sleepTime = [convert]::ToInt32($servicewaittime)
$serviceList = $services -split '[\r\n]'

if ($runStopServices)
{
    foreach ($serviceName in $serviceList)
    {
        Write-Host "Stopping: $serviceName"
        Stop-Service -displayname $serviceName
    }

	Write-Host "Waiting for $sleepTime seconds for the services to completely stop"
    Start-Sleep $sleepTime
}

if ($runStartServices)
{
    foreach ($serviceName in $serviceList)
    {
        Write-Host "Starting: $serviceName"
        Start-Service -displayname $serviceName
    }

	Write-Host "Waiting for $sleepTime seconds for the services to completely start"
    Start-Sleep $sleepTime
}

