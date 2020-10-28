$errorActionPreference = 'Stop'

if (!(Test-Path "$args")) {
  throw "Path '$args' does not exist"
}

Write-Host "Adding '$args' to local and user PATH"

$env:PATH += ";$args"
$oldPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
$newPath = "$oldPath;$args"

[Environment]::SetEnvironmentVariable('PATH', $newPath, 'User');
