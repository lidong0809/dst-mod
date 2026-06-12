$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$modmain = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\modmain.lua')
$modinfo = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\modinfo.lua')
$readme = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\README.md')

if ($modmain -match 'pig_king_trade' -or $modmain -match 'MakePigKingAcceptWurtTrades' -or $modmain -match 'AddPrefabPostInit\("pigking"') {
  throw 'modmain.lua should not contain Pig King trading hooks or config reads.'
}

if ($modmain -match 'CallWithTagsTemporarilyRemoved') {
  throw 'modmain.lua should remove the tag-stripping helper used only for Pig King trading.'
}

if ($modinfo -match 'pig_king_trade' -or $modinfo -match 'Pig King trading' -or $modinfo -match 'Wurt can trade with Pig King') {
  throw 'modinfo.lua should not expose Pig King trading config or description.'
}

if ($readme -match 'Pig King' -or $readme -match 'pig king') {
  throw 'README should not mention Pig King trading.'
}
