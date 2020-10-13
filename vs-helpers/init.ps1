$version = $env:VS_VERSION
$architecture = $env:VS_ARCH

Write-Host 'Setup Visual C++ Build Environment ...'
Write-Host "  Version: $version"
Write-Host "  Architecture: $architecture"

$versionHigh = $version + 1
$range = "[$version.0,$versionHigh.0)"
$vs = Get-VSSetupInstance | Select-VSSetupInstance -Version $range -Product *

if (!$vs) {
  exit 1
}

$vsPath = $vs.InstallationPath

if (!$vsPath) {
  exit 1
}

$vcvars = Join-Path $vsPath 'VC/Auxiliary/Build/vcvarsall.bat'

cmd /c """$vcvars"" $architecture & set" | foreach {
  if ($_ -Match "=") {
    $v = $_.Split("=")

    Set-Item -Force -Path "env:\$($v[0])" -Value "$($v[1])"
  }
}

Write-Host 'Done'
Write-Host '------------------------------------------------------------'
Invoke-Expression "$args"
