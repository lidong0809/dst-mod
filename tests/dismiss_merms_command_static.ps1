$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$modmain = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\modmain.lua')
$modinfo = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\modinfo.lua')
$readme = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\README.md')

if ($modmain -notmatch 'Networking_Say') {
  throw 'modmain.lua should intercept server chat messages for server-only dismiss support.'
}

if ($modmain -notmatch '#dismissmerms') {
  throw 'modmain.lua should support #dismissmerms as a normal chat command.'
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

if ($modmain -notmatch 'UserToPlayer' -or $modmain -notmatch '_G\.Ents\[guid\]') {
  throw 'dismiss command should resolve the chat sender on the server.'
}

if ($modinfo -notmatch 'dismiss_merms_command') {
  throw 'modinfo.lua should expose a config toggle for the dismiss command.'
}

if ($readme -notmatch '#dismissmerms') {
  throw 'README should document the dismiss command.'
}
