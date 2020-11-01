$errorActionPreference = 'Stop'

Invoke-Expression "$args"

if ($lastExitCode -Ne 0 -Or -Not $?) {
  throw "Command '$args' failed"
}
