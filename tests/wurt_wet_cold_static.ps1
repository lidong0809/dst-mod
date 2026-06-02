$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$modmain = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\modmain.lua')
$modinfo = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\modinfo.lua')
$readme = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\README.md')

if ($modmain -match 'WURT_FREEZE_FLOOR' -or $modmain -match 'SetTemperature\(WURT_FREEZE_FLOOR\)') {
  throw 'modmain.lua should not hard-clamp Wurt temperature for wet/snow cold protection.'
}

if ($modmain -notmatch 'GetMoisturePenalty') {
  throw 'modmain.lua should remove Wurt wetness cold by wrapping GetMoisturePenalty.'
}

if ($modmain -notmatch 'old_get_moisture_penalty') {
  throw 'modmain.lua should preserve and wrap the original GetMoisturePenalty method.'
}

if ($modmain -notmatch 'return 0') {
  throw 'modmain.lua should make Wurt wetness cold penalty zero.'
}

if ($modinfo -notmatch 'Wetness cold penalty protection') {
  throw 'modinfo.lua should describe wetness cold penalty protection instead of freeze clamping.'
}

if ($readme -notmatch 'wetness cold penalty' -or $readme -match 'will not freeze from wetness') {
  throw 'README should describe removing wetness cold penalty, not full freezing immunity.'
}
