$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$modmain = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\modmain.lua')
$modinfo = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\modinfo.lua')
$readme = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\README.md')

if ($modmain -notmatch 'AddUserCommand') {
  throw 'modmain.lua should register a user command.'
}

if ($modmain -notmatch 'dismissmerms') {
  throw 'modmain.lua should register /dismissmerms.'
}

if ($modmain -notmatch 'function DismissCallerMerms') {
  throw 'modmain.lua should define the dismiss command behavior.'
}

if ($modmain -notmatch 'caller\.components\.leader\.followers') {
  throw 'dismiss command should inspect only the caller leader followers.'
}

if ($modmain -notmatch 'RemoveFollower' -or $modmain -notmatch 'SetLeader\(nil\)') {
  throw 'dismiss command should remove merm followers from the caller.'
}

if ($modmain -notmatch 'permission = _G\.COMMAND_PERMISSION\.USER') {
  throw 'dismiss command should be usable by normal players.'
}

if ($modinfo -notmatch 'dismiss_merms_command') {
  throw 'modinfo.lua should expose a config toggle for the dismiss command.'
}

if ($readme -notmatch '/dismissmerms') {
  throw 'README should document the dismiss command.'
}
