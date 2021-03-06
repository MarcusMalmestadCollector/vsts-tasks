[cmdletbinding()]
param
(
	[Parameter(Mandatory=$true)][string] $testAssembly
)

import-module "Microsoft.TeamFoundation.DistributedTask.Task.Internal"
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

$pathToTaskDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$nunitRunner = "$pathToTaskDirectory\runner\nunit3-console.exe"

if (!$testAssembly)
{
    throw (Get-LocalizedString -Key "Test assembly parameter not set on script")
}

# check for solution pattern
if ($testAssembly.Contains("*") -or $testAssembly.Contains("?"))
{
    Write-Host "Calling Find-Files with pattern: $testAssembly"
    $testAssemblyFiles = Find-Files -SearchPattern $testAssembly
    Write-Host "Found files: $testAssemblyFiles"
}
else
{
    Write-Host "No Pattern found in solution parameter."
    $testAssemblyFiles = ,$testAssembly
}

if($testAssemblyFiles)
{
    $artifactsDirectory = Get-TaskVariable -Context $distributedTaskContext -Name "System.ArtifactsDirectory" -Global $FALSE

    $workingDirectory = $artifactsDirectory
    $testResultsDirectory = $workingDirectory + "\" + "TestResults"
	
	$arguments = ""
	Foreach($testAssemblyFile in $testAssemblyFiles)
	{
		$arguments = "$arguments ""$testAssemblyFile"""
	}
	$arguments = "$arguments /framework=net-4.5 /work=$testResultsDirectory"

	Invoke-Tool -Path "$nunitRunner" -Arguments $arguments
}
else
{
    Write-Warning "No test assemblies found matching the pattern: $testAssembly"
}

