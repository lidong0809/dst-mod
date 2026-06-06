$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$modmain = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\modmain.lua')
$modinfo = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\modinfo.lua')
$readme = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\README.md')

if ($modmain -notmatch 'MERM_LOYALTY_MULTIPLIER') {
  throw 'modmain.lua should read the merm loyalty multiplier config.'
}

if ($modmain -notmatch 'function ExtendMermLoyalty') {
  throw 'modmain.lua should define merm loyalty extension behavior.'
}

if ($modmain -notmatch 'AddLoyaltyTime' -or $modmain -notmatch 'old_add_loyalty_time') {
  throw 'modmain.lua should wrap AddLoyaltyTime to lengthen recruited merm loyalty.'
}

if ($modmain -notmatch 'maxfollowtime') {
  throw 'modmain.lua should also scale maxfollowtime so the longer loyalty is not capped by the original max.'
}

if ($modmain -notmatch 'AddPrefabPostInit\("merm", ExtendMermLoyalty\)' -or $modmain -notmatch 'AddPrefabPostInit\("mermguard", ExtendMermLoyalty\)') {
  throw 'modmain.lua should apply longer loyalty to merms and merm guards.'
}

if ($modinfo -notmatch 'merm_loyalty_multiplier') {
  throw 'modinfo.lua should expose a merm loyalty multiplier config option.'
}

if ($modinfo -notmatch '2x' -or $modinfo -notmatch '3x' -or $modinfo -notmatch '5x') {
  throw 'modinfo.lua should offer useful merm loyalty multiplier choices.'
}

if ($readme -notmatch 'Merm recruitment loyalty can last longer') {
  throw 'README should document longer merm recruitment loyalty.'
}
