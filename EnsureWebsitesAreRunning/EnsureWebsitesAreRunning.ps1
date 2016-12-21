[cmdletbinding()]
param
(
	[Parameter(Mandatory=$true)][string] $weburls
)

$urlsList = $weburls -split '[\r\n]'

foreach ($url in $urlsList)
{
    Write-Host "Checking: $url"
    $result = Invoke-WebRequest -uri $url -UseBasicParsing

    if ($result.StatusCode -eq 200)
    {
        Write-Host "URL: $url returned status 200 OK"
    }
}