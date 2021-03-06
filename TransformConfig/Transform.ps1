[cmdletbinding()]
param
(
	[Parameter(Mandatory=$true)][string] $transformationType,
	[Parameter(Mandatory=$false)][string] $transformenvironment
)

$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$useSingleTransform = $true
if($transformationType -and $transformationType.Equals("all"))
{
    $useSingleTransform = $false
}
if (-not $Env:BUILD_SOURCESDIRECTORY)
{
    Write-Host ('$Env:BUILD_SOURCESDIRECTORY environment variable is missing.')
    exit 1
}
if (-not (Test-Path $Env:BUILD_SOURCESDIRECTORY))
{
    Write-Host "Env:BUILD_SOURCESDIRECTORY does not exist: $Env:BUILD_SOURCESDIRECTORY"
    exit 1
}

Write-Host "BUILD_SOURCESDIRECTORY: $Env:BUILD_SOURCESDIRECTORY"
Write-Host "useSingleTransform: $useSingleTransform"

function XmlDocTransform($xml, $xdt, $scriptPath, $outputPath)
{
    if (!$xml -or !(Test-Path -path $xml -PathType Leaf)) {
        Write-Host "File not found. $xml";
    }
    if (!$xdt -or !(Test-Path -path $xdt -PathType Leaf)) {
        Write-Host "File not found. $xdt";
    }

    Add-Type -LiteralPath "$scriptPath\Microsoft.Web.XmlTransform.dll"

    $xmldoc = New-Object Microsoft.Web.XmlTransform.XmlTransformableDocument;
    $xmldoc.PreserveWhitespace = $true
    $xmldoc.Load($xml);

    $transf = New-Object Microsoft.Web.XmlTransform.XmlTransformation($xdt);
    if ($transf.Apply($xmldoc) -eq $false)
    {
        Write-Host "Transformation failed for '$xdt'"
    }
    $xmldoc.Save($outputPath);

    Write-Host "Transform finished for '$xdt'"
}

if($useSingleTransform)
{
	$transformFiles = @(Get-ChildItem -Path $Env:BUILD_SOURCESDIRECTORY -Filter "*.$transformenvironment.config" -Recurse | % { $_.FullName })
	
	Foreach($transformFile in $transformFiles)
	{
		$originalConfigPath = $transformFile -replace ".$transformenvironment.config", ".config"

		XmlDocTransform -xml "$originalConfigPath" -xdt "$transformFile" -scriptPath $myDir -outputPath "$originalConfigPath"
	}
}
else
{
	$transformFiles = @(Get-ChildItem -Path $Env:BUILD_SOURCESDIRECTORY -Filter 'app.*.config' -Recurse | % { $_.FullName })
	$transformFiles += @(Get-ChildItem -Path $Env:BUILD_SOURCESDIRECTORY -Filter 'web.*.config' -Recurse | % { $_.FullName })
	
	Foreach($transformFile in $transformFiles)
	{
		$originalConfigPath = $transformFile -replace ".([a-zA-Z0-9]+).config", ".config"

		XmlDocTransform -xml "$originalConfigPath" -xdt "$transformFile" -scriptPath $myDir -outputPath "$transformFile"
	}
}

