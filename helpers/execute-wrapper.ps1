$errorActionPreference = 'Stop'

Invoke-Expression "$args"

if ($lastExitCode -ne 0 -or -not $?) {
  throw "Command '$args' failed"
}
