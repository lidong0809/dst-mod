$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$modmain = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\modmain.lua')
$modinfo = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\modinfo.lua')
$readme = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\README.md')

if ($modmain -notmatch 'ENABLE_MERM_NEUTRAL_TO_WORMWOOD') {
  throw 'modmain.lua should read the Merm neutral-to-Wormwood config option.'
}

if ($modmain -notmatch 'function IsWormwood' -or $modmain -notmatch 'prefab == "wormwood"') {
  throw 'modmain.lua should identify Wormwood players by prefab.'
}

if ($modmain -notmatch 'function MakeMermNeutralToWormwood') {
  throw 'modmain.lua should define Merm neutral-to-Wormwood behavior.'
}

if ($modmain -notmatch 'AddPrefabPostInit\("merm", MakeMermNeutralToWormwood\)' -or $modmain -notmatch 'AddPrefabPostInit\("mermguard", MakeMermNeutralToWormwood\)') {
  throw 'modmain.lua should apply Wormwood neutrality to merms and merm guards.'
}

if ($modmain -notmatch 'IsWormwood\(data ~= nil and data\.attacker or nil\)' -or $modmain -notmatch 'IsWormwood\(target\)') {
  throw 'modmain.lua should let merms retaliate against Wormwood only after Wormwood attacks.'
}

if ($modinfo -notmatch 'merm_neutral_to_wormwood') {
  throw 'modinfo.lua should expose a config toggle for Merm neutrality toward Wormwood.'
}

if ($readme -notmatch 'Merms and merm guards are neutral to Wormwood') {
  throw 'README should document Merm neutrality toward Wormwood.'
}
