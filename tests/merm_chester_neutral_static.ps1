$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$modmain = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\modmain.lua')
$modinfo = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\modinfo.lua')
$readme = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\README.md')

if ($modmain -notmatch 'ENABLE_MERM_IGNORE_CHESTER') {
  throw 'modmain.lua should read the Chester protection config option.'
}

if ($modmain -notmatch 'function IsChester' -or $modmain -notmatch 'prefab == "chester"') {
  throw 'modmain.lua should identify Chester by prefab.'
}

if ($modmain -notmatch 'function MakeMermIgnoreChester') {
  throw 'modmain.lua should define merm Chester target filtering.'
}

if ($modmain -notmatch 'IsChester\(target\)' -or $modmain -notmatch 'return nil') {
  throw 'merm Chester filter should return nil when targetfn selects Chester.'
}

if ($modmain -notmatch 'AddPrefabPostInit\("merm", MakeMermIgnoreChester\)' -or $modmain -notmatch 'AddPrefabPostInit\("mermguard", MakeMermIgnoreChester\)') {
  throw 'modmain.lua should apply Chester protection to merms and merm guards.'
}

if ($modinfo -notmatch 'merm_ignore_chester') {
  throw 'modinfo.lua should expose a config toggle for Chester protection.'
}

if ($readme -notmatch 'Merms and merm guards will not target Chester') {
  throw 'README should document Chester protection.'
}
