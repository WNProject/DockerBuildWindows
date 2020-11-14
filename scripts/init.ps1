$errorActionPreference = 'Stop'
$version = $env:VS_VERSION
$debug = $env:DEBUG
$versionHigh = $version + 1
$range = "[$version.0,$versionHigh.0)"
$vs = Get-VSSetupInstance | Select-VSSetupInstance -Version $range -Product *

if (!$vs) {
  throw 'Unable to get installed Visual Studio info'
}

$vsPath = $vs.InstallationPath

if (!$vsPath) {
  throw 'Unable to get installed Visual Studio path'
}

$vcvars = Join-Path $vsPath 'VC/Auxiliary/Build/vcvarsall.bat'

if (!(Test-Path $vcvars)) {
  throw 'Expected path for Visual Studio vsvarsall does not exist'
}

if ($debug -Eq 1) {
  $operatingSystemInfo = Get-CimInstance Win32_OperatingSystem
  $physicalMemory = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
  $visibleMemory = $operatingSystemInfo.TotalVisibleMemorySize
  $freeMemory = $operatingSystemInfo.FreePhysicalMemory

  Write-Host 'Setup Visual C++ Build Environment ...'
  Write-Host "  Version: $version"
  Write-Host "  Full Version: $($vs.InstallationVersion)"
  Write-Host "  Name: $($vs.DisplayName)"
  Write-Host "  Path: $vsPath"
  Write-Host "  VCVars Path: $vcvars"
  Write-Host "  Total Physical Memory (KB): $($physicalMemory / 1KB)"
  Write-Host "  Total Visible Memory (KB): $($visibleMemory)"
  Write-Host "  Free Physical Memory (KB): $($freeMemory)"
}

cmd /c """$vcvars"" amd64 & set" | foreach {
  if ($_ -Match "=") {
    $v = $_.Split("=")

    Set-Item -Force -Path "env:\$($v[0])" -Value "$($v[1])"
  }
}

if ($debug -Eq 1) {
  Write-Host 'Done'
  Write-Host '------------------------------------------------------------'
}

Invoke-Expression "$args"

if ($lastExitCode -Ne 0 -Or -Not $?) {
  throw "Command '$args' failed"
}
