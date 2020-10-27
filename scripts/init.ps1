$errorActionPreference = 'Stop'
$version = $env:VS_VERSION
$architecture = $env:VS_ARCH
$debug = $env:DEBUG
$versionHigh = $version + 1
$range = "[$version.0,$versionHigh.0)"
$vs = Get-VSSetupInstance | Select-VSSetupInstance -Version $range -Product *

if (!$vs) {
  Write-Error 'Unable to get installed Visual Studio info'

  exit 1
}

$vsPath = $vs.InstallationPath

if (!$vsPath) {
  Write-Error 'Unable to get installed Visual Studio path'

  exit 1
}

$vcvars = Join-Path $vsPath 'VC/Auxiliary/Build/vcvarsall.bat'

if (!(Test-Path $vcvars)) {
  Write-Error 'Expected path for Visual Studio vsvarsall does not exist'

  exit 1
}

if ($debug -eq 1) {
  $operatingSystemInfo = Get-CimInstance Win32_OperatingSystem
  $physicalMemory = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
  $visibleMemory = $operatingSystemInfo.TotalVisibleMemorySize
  $freeMemory = $operatingSystemInfo.FreePhysicalMemory

  Write-Host 'Setup Visual C++ Build Environment ...'
  Write-Host "  Version: $version"
  Write-Host "  Full Version: $($vs.InstallationVersion)"
  Write-Host "  Architecture: $architecture"
  Write-Host "  Name: $($vs.DisplayName)"
  Write-Host "  Path: $vsPath"
  Write-Host "  VCVars Path: $vcvars"
  Write-Host "  Total Physical Memory: $physicalMemory"
  Write-Host "  Total Visible Memory: $visibleMemory"
  Write-Host "  Free Physical Memory: $freeMemory"
}

cmd /c """$vcvars"" $architecture & set" | foreach {
  if ($_ -Match "=") {
    $v = $_.Split("=")

    Set-Item -Force -Path "env:\$($v[0])" -Value "$($v[1])"
  }
}

if ($debug -eq 1) {
  Write-Host 'Done'
  Write-Host '------------------------------------------------------------'
}

Invoke-Expression "$args"

if ($lastExitCode -ne 0 -or -not $?) {
  throw "Command '$args' failed"
}
