[cmdletbinding()]
param
(
	[Parameter(Mandatory=$true)][string] $filePaths,
	[Parameter(Mandatory=$true)][string] $pattern,
	[Parameter(Mandatory=$true)][string] $replacement
)


function Get-FileEncoding {
    param ( [string] $filePath )
    $sr = New-Object System.IO.StreamReader($filePath, $true)
	[char[]] $buffer = new-object char[] 3
	$sr.Read($buffer, 0, 3) | Out-Null
	$encoding = $sr.CurrentEncoding
	
	$sr.Close()
	return $encoding
}

Write-Host "Replacing $pattern with $replacement"

foreach ($filePath in $filePaths -split '[\r\n]')
{
	$fullPath = (Resolve-Path $filePath).Path
	$encoding = Get-FileEncoding($fullPath)

	$filecontent = [IO.File]::ReadAllText($fullPath, $encoding)
    
    $filecontent = $filecontent -replace $pattern, $replacement
	
	[IO.File]::WriteAllText($fullPath, $filecontent, $encoding)
    
	Write-Host "$fullPath - contents modified"
}