local _G = GLOBAL

local GetModConfigData = GetModConfigData
local AddPrefabPostInit = AddPrefabPostInit

local ENABLE_PIG_KING_TRADE = GetModConfigData("pig_king_trade")
local ENABLE_PIG_NEUTRAL = GetModConfigData("pig_neutral")
local ENABLE_MERMKING_NO_HUNGER = GetModConfigData("mermking_no_hunger_loss")
local ENABLE_WET_SNOW_COLD_PROTECTION = GetModConfigData("wet_snow_cold_protection")

local WURT_FREEZE_FLOOR = 1
local PIG_RETALIATE_WINDOW = 8
local MERMKING_HUNGER_RATE_MULTIPLIER = 0.2

local function IsMasterSim()
  return _G.TheWorld ~= nil and _G.TheWorld.ismastersim
end

local function IsWurt(inst)
  return inst ~= nil and inst.prefab == "wurt"
end

local function SafeGetTime()
  return _G.GetTime ~= nil and _G.GetTime() or 0
end

local function CallWithTagsTemporarilyRemoved(inst, tags, fn)
  if inst == nil then
    return fn()
  end

  local removed = {}
  for _, tag in ipairs(tags) do
    if inst:HasTag(tag) then
      inst:RemoveTag(tag)
      table.insert(removed, tag)
    end
  end

  local ok, result = pcall(fn)

  for _, tag in ipairs(removed) do
    inst:AddTag(tag)
  end

  if not ok then
    error(result)
  end
  return result
end

local function MakePigKingAcceptWurtTrades(inst)
  if not IsMasterSim() then
    return
  end

  inst:DoTaskInTime(0, function(inst)
    local trader = inst.components ~= nil and inst.components.trader or nil
    if trader == nil or trader._wurt_friendly_marsh_life_wrapped then
      return
    end

    local old_test = trader.test
    trader._wurt_friendly_marsh_life_wrapped = true

    trader:SetAcceptTest(function(inst, item, giver)
      if IsWurt(giver) then
        return CallWithTagsTemporarilyRemoved(giver, { "monster", "merm" }, function()
          return old_test == nil or old_test(inst, item, giver)
        end)
      end

      return old_test == nil or old_test(inst, item, giver)
    end)
  end)
end

local function MakePigNeutralToWurt(inst)
  if not IsMasterSim() then
    return
  end

  inst:ListenForEvent("attacked", function(inst, data)
    if IsWurt(data ~= nil and data.attacker or nil) then
      inst._wurt_friendly_marsh_life_retaliate_until = SafeGetTime() + PIG_RETALIATE_WINDOW
    end
  end)

  inst:DoTaskInTime(0, function(inst)
    local combat = inst.components ~= nil and inst.components.combat or nil
    if combat == nil or combat.targetfn == nil or combat._wurt_friendly_marsh_life_wrapped then
      return
    end

    local old_targetfn = combat.targetfn
    combat._wurt_friendly_marsh_life_wrapped = true

    combat.targetfn = function(inst, ...)
      local target = old_targetfn(inst, ...)
      if IsWurt(target) then
        local retaliate_until = inst._wurt_friendly_marsh_life_retaliate_until or 0
        if SafeGetTime() > retaliate_until then
          return nil
        end
      end
      return target
    end
  end)
end

local function SlowMermKingHunger(inst)
  if not IsMasterSim() then
    return
  end

  local function slow_hunger(king)
    local hunger = king.components ~= nil and king.components.hunger or nil
    if hunger == nil or hunger.SetRate == nil then
      return
    end

    if king._wurt_friendly_marsh_life_original_hunger_rate == nil then
      king._wurt_friendly_marsh_life_original_hunger_rate = hunger.hungerrate or 0
    end

    hunger:SetRate(king._wurt_friendly_marsh_life_original_hunger_rate * MERMKING_HUNGER_RATE_MULTIPLIER)
  end

  inst:DoTaskInTime(0, slow_hunger)
  inst:DoPeriodicTask(10, slow_hunger)
end

local function IsWurtWetOrSnowing(inst)
  local moisture = inst.components ~= nil and inst.components.moisture or nil
  local wet = moisture ~= nil and moisture.GetMoisture ~= nil and moisture:GetMoisture() > 0
  local snowing = _G.TheWorld ~= nil and _G.TheWorld.state ~= nil and _G.TheWorld.state.issnowing
  return wet or snowing
end

local function ProtectWurtFromWetCold(inst)
  if not IsMasterSim() then
    return
  end

  local function update(player)
    if not IsWurtWetOrSnowing(player) then
      return
    end

    local temperature = player.components ~= nil and player.components.temperature or nil
    if temperature == nil or temperature.GetCurrent == nil or temperature.SetTemperature == nil then
      return
    end

    local current = temperature:GetCurrent()
    if current ~= nil and current < WURT_FREEZE_FLOOR then
      temperature:SetTemperature(WURT_FREEZE_FLOOR)
    end
  end

  inst:DoPeriodicTask(1, update)
  inst:WatchWorldState("issnowing", function(player)
    update(player)
  end)
end

if ENABLE_PIG_KING_TRADE then
  AddPrefabPostInit("pigking", MakePigKingAcceptWurtTrades)
end

if ENABLE_PIG_NEUTRAL then
  AddPrefabPostInit("pigman", MakePigNeutralToWurt)
  AddPrefabPostInit("pigguard", MakePigNeutralToWurt)
end

if ENABLE_MERMKING_NO_HUNGER then
  AddPrefabPostInit("mermking", SlowMermKingHunger)
end

if ENABLE_WET_SNOW_COLD_PROTECTION then
  AddPrefabPostInit("wurt", ProtectWurtFromWetCold)
end
