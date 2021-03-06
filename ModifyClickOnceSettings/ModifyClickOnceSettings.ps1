[cmdletbinding()]
param
(
	[Parameter(Mandatory=$true)][string] $csProjPath,
	[Parameter(Mandatory=$true)][string] $publishUrl,
	[Parameter(Mandatory=$true)][string] $applicationVersion,
	[Parameter(Mandatory=$true)][string] $minimumApplicationVersion
)

$xml = New-Object XML
$xml.Load($csProjPath)
$xml.Project.PropertyGroup[0].PublishUrl = $publishUrl
$xml.Project.PropertyGroup[0].ApplicationVersion = $applicationVersion
$xml.Project.PropertyGroup[0].MinimumRequiredVersion = $minimumApplicationVersion
$xml.Save($csProjPath)
Write-Host "Updated $csProjPath with the publish URL: $publishUrl, ApplicationVersion to: $applicationVersion and minimum application version to: $minimumApplicationVersion"