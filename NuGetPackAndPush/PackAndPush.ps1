[cmdletbinding()]
param
(
	[Parameter(Mandatory=$true)][string] $packtarget,
	[Parameter(Mandatory=$false)][string] $packagesource,
	[Parameter(Mandatory=$false)][string] $nugetapikey
)

####################################################################################################
# Auto Configuration
####################################################################################################

# Stop the script on error
$ErrorActionPreference = "Stop"

# Relative location of nuget.exe to build agent home directory
$nugetExecutableRelativePath = "Agent\Worker\Tools\nuget.exe"

# These variables are provided by TFS
$buildAgentHomeDirectory = $env:AGENT_HOMEDIRECTORY
$buildSourcesDirectory = $Env:BUILD_SOURCESDIRECTORY
$buildStagingDirectory = $Env:BUILD_STAGINGDIRECTORY
$buildPlatform = $Env:BUILDPLATFORM
$buildConfiguration = $Env:BUILDCONFIGURATION

$packagesOutputDirectory = $buildStagingDirectory

# Determine full path of pack target file
$packTargetFullPath = $packTarget

# Determine full path to nuget.exe
$nugetExecutableFullPath = Join-Path -Path $buildAgentHomeDirectory -ChildPath $nugetExecutableRelativePath

####################################################################################################
# 1 Create package
####################################################################################################

Write-Host "1. Creating NuGet package"

$packCommand = ("pack `"{0}`" -OutputDirectory `"{1}`" -NonInteractive -Symbols" -f $packTargetFullPath, $packagesOutputDirectory)

if($packTargetFullPath.ToLower().EndsWith(".csproj"))
{
   $packCommand += " -IncludeReferencedProjects"

   # Remove spaces from build platform, so 'Any CPU' becomes 'AnyCPU'
   $packCommand += (" -Properties `"Configuration={0};Platform={1}`"" -f    $buildConfiguration, ($buildPlatform -replace '\s',''))
}

Write-Host ("`tPack command: {0}" -f $packCommand)
Write-Host ("`tCreating package...")

$packOutput = Invoke-Expression "&'$nugetExecutableFullPath' $packCommand" | Out-String

Write-Host ("`tPackage successfully created:")

$generatedPackageFullPath = [regex]::match($packOutput,"Successfully created package '(.+(?<!\.symbols)\.nupkg)'").Groups[1].Value
Write-Host `t`t$generatedPackageFullPath

Write-Host ("`tSymbol Package successfully created:")

$generatedSymbolPackageFullPath = [regex]::match($packOutput,"Successfully created package '(.+\.symbols\.nupkg)'").Groups[1].Value
Write-Host `t`t$generatedSymbolPackageFullPath

Write-Host ("`tNote: The created package will be available in the drop location.")

Write-Host "`tOutput from NuGet.exe:"
Write-Host ("`t`t$packOutput" -Replace "`r`n", "`r`n`t`t")

####################################################################################################
# 2 Publish package
####################################################################################################

Write-Host "2. Publish package"
$pushCommand = "push `"{0}`" -Source `"{1}`" -NonInteractive `"{2}`""

Write-Host ("`tPush package '{0}' to '{1}'." -f (Split-Path $generatedPackageFullPath -Leaf), $packagesource)
$regularPackagePushCommand = ($pushCommand -f $generatedPackageFullPath, $packagesource, $nugetapikey)
Write-Host ("`tPush command: {0}" -f $regularPackagePushCommand)
Write-Host "`tPushing..."

$pushOutput = Invoke-Expression "&'$nugetExecutableFullPath' $regularPackagePushCommand" | Out-String

Write-Host "`tSuccess. Package pushed to source."
Write-Host "`tOutput from NuGet.exe:"
Write-Host ("`t`t$pushOutput" -Replace "`r`n", "`r`n`t`t")