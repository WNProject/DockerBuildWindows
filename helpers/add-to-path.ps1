param([Parameter(Mandatory=$true)][string] $path)

$errorActionPreference = 'Stop'

Write-Host "Adding $path to PATH"

$oldPath = [Environment]::GetEnvironmentVariable('PATH', 'Machine')
$newPath = "$oldPath;$path"

[Environment]::SetEnvironmentVariable('PATH', $newPath, 'Machine');
