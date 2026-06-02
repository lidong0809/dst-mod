$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$modmain = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\modmain.lua')
$modinfo = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\modinfo.lua')
$readme = Get-Content -Raw -Path (Join-Path $root 'wurt-friendly-marsh-life\README.md')

if ($modmain -notmatch 'MERMKING_HUNGER_RATE_MULTIPLIER\s*=\s*0\.2') {
  throw 'modmain.lua should define a 1/5 Merm King hunger-rate multiplier.'
}

if ($modmain -match 'hunger:SetRate\(0\)' -or $modmain -match 'hunger:SetPercent\(1\)') {
  throw 'modmain.lua should slow hunger drain instead of disabling hunger or filling hunger.'
}

if ($modmain -notmatch 'hungerrate') {
  throw 'modmain.lua should scale the existing hunger rate rather than hard-code a replacement.'
}

if ($modinfo -match 'never starves|immortal Merm King hunger|never starve') {
  throw 'modinfo.lua should no longer describe Merm King hunger as disabled.'
}

if ($readme -match 'stays fed|should not lose level from hunger|never starves') {
  throw 'README should describe slower hunger drain, not permanent fullness.'
}
