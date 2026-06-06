local _G = GLOBAL

local GetModConfigData = GetModConfigData
local AddPrefabPostInit = AddPrefabPostInit

local ENABLE_PIG_KING_TRADE = GetModConfigData("pig_king_trade")
local ENABLE_PIG_NEUTRAL = GetModConfigData("pig_neutral")
local ENABLE_MERMKING_NO_HUNGER = GetModConfigData("mermking_no_hunger_loss")
local ENABLE_WET_SNOW_COLD_PROTECTION = GetModConfigData("wet_snow_cold_protection")
local ENABLE_MERM_NEUTRAL_TO_WORMWOOD = GetModConfigData("merm_neutral_to_wormwood")
local ENABLE_DISMISS_MERMS_COMMAND = GetModConfigData("dismiss_merms_command")
local ENABLE_MERM_IGNORE_CHESTER = GetModConfigData("merm_ignore_chester")
local MERM_LOYALTY_MULTIPLIER = GetModConfigData("merm_loyalty_multiplier") or 1

local PIG_RETALIATE_WINDOW = 8
local MERM_RETALIATE_WINDOW = 8
local MERMKING_HUNGER_RATE_MULTIPLIER = 0.2

local function IsMasterSim()
  return _G.TheWorld ~= nil and _G.TheWorld.ismastersim
end

local function IsWurt(inst)
  return inst ~= nil and inst.prefab == "wurt"
end

local function IsWormwood(inst)
  return inst ~= nil and inst.prefab == "wormwood"
end

local function IsChester(inst)
  return inst ~= nil and inst.prefab == "chester"
end

local function IsRecruitableMerm(inst)
  return inst ~= nil and (inst.prefab == "merm" or inst.prefab == "mermguard")
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

local function MakeMermNeutralToWormwood(inst)
  if not IsMasterSim() then
    return
  end

  inst:ListenForEvent("attacked", function(inst, data)
    if IsWormwood(data ~= nil and data.attacker or nil) then
      inst._wurt_friendly_marsh_life_wormwood_retaliate_until = SafeGetTime() + MERM_RETALIATE_WINDOW
    end
  end)

  inst:DoTaskInTime(0, function(inst)
    local combat = inst.components ~= nil and inst.components.combat or nil
    if combat == nil or combat.targetfn == nil or combat._wurt_friendly_marsh_life_wormwood_wrapped then
      return
    end

    local old_targetfn = combat.targetfn
    combat._wurt_friendly_marsh_life_wormwood_wrapped = true

    combat.targetfn = function(inst, ...)
      local target = old_targetfn(inst, ...)
      if IsWormwood(target) then
        local retaliate_until = inst._wurt_friendly_marsh_life_wormwood_retaliate_until or 0
        if SafeGetTime() > retaliate_until then
          return nil
        end
      end
      return target
    end
  end)
end

local function MakeMermIgnoreChester(inst)
  if not IsMasterSim() then
    return
  end

  inst:DoTaskInTime(0, function(inst)
    local combat = inst.components ~= nil and inst.components.combat or nil
    if combat == nil or combat.targetfn == nil or combat._wurt_friendly_marsh_life_chester_wrapped then
      return
    end

    local old_targetfn = combat.targetfn
    combat._wurt_friendly_marsh_life_chester_wrapped = true

    combat.targetfn = function(inst, ...)
      local target = old_targetfn(inst, ...)
      if IsChester(target) then
        return nil
      end
      return target
    end
  end)
end

local function ExtendMermLoyalty(inst)
  if not IsMasterSim() or MERM_LOYALTY_MULTIPLIER <= 1 then
    return
  end

  inst:DoTaskInTime(0, function(inst)
    local follower = inst.components ~= nil and inst.components.follower or nil
    if follower == nil or follower.AddLoyaltyTime == nil or follower._wurt_friendly_marsh_life_loyalty_wrapped then
      return
    end

    if follower.maxfollowtime ~= nil then
      follower._wurt_friendly_marsh_life_original_maxfollowtime = follower.maxfollowtime
      follower.maxfollowtime = follower.maxfollowtime * MERM_LOYALTY_MULTIPLIER
    end

    local old_add_loyalty_time = follower.AddLoyaltyTime
    follower._wurt_friendly_marsh_life_loyalty_wrapped = true

    follower.AddLoyaltyTime = function(self, time, ...)
      return old_add_loyalty_time(self, time * MERM_LOYALTY_MULTIPLIER, ...)
    end
  end)
end

local function DismissCallerMerms(caller)
  local leader = caller ~= nil and caller.components ~= nil and caller.components.leader or nil
  if leader == nil or leader.followers == nil then
    return 0
  end

  local followers_to_dismiss = {}
  for follower in pairs(caller.components.leader.followers) do
    if IsRecruitableMerm(follower) then
      table.insert(followers_to_dismiss, follower)
    end
  end

  for _, follower in ipairs(followers_to_dismiss) do
    if leader.RemoveFollower ~= nil then
      leader:RemoveFollower(follower)
    end
    if follower.components ~= nil and follower.components.follower ~= nil and follower.components.follower.SetLeader ~= nil then
      follower.components.follower:SetLeader(nil)
    end
    if follower.components ~= nil and follower.components.combat ~= nil then
      follower.components.combat:SetTarget(nil)
    end
  end

  return #followers_to_dismiss
end

local function GetChatSender(guid, userid)
  if guid ~= nil and _G.Ents ~= nil and _G.Ents[guid] ~= nil then
    return _G.Ents[guid]
  end

  if userid ~= nil and _G.UserToPlayer ~= nil then
    return _G.UserToPlayer(userid)
  end

  return nil
end

local function RegisterDismissMermsCommand()
  if _G.Networking_Say == nil then
    return
  end

  local old_networking_say = _G.Networking_Say
  _G.Networking_Say = function(guid, userid, name, prefab, message, colour, whisper, ...)
    if message == "#dismissmerms" or message == "/dismissmerms" then
      local caller = GetChatSender(guid, userid)
      DismissCallerMerms(caller)
      return
    end

    return old_networking_say(guid, userid, name, prefab, message, colour, whisper, ...)
  end
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

local function RemoveWurtWetnessColdPenalty(inst)
  if not IsMasterSim() then
    return
  end

  inst:DoTaskInTime(0, function(player)
    local temperature = player.components ~= nil and player.components.temperature or nil
    if temperature == nil or temperature.GetMoisturePenalty == nil or temperature._wurt_friendly_marsh_life_wrapped then
      return
    end

    local old_get_moisture_penalty = temperature.GetMoisturePenalty
    temperature._wurt_friendly_marsh_life_wrapped = true

    temperature.GetMoisturePenalty = function(self, ...)
      if IsWurt(self.inst) then
        return 0
      end

      return old_get_moisture_penalty(self, ...)
    end
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
  AddPrefabPostInit("wurt", RemoveWurtWetnessColdPenalty)
end

if ENABLE_MERM_NEUTRAL_TO_WORMWOOD then
  AddPrefabPostInit("merm", MakeMermNeutralToWormwood)
  AddPrefabPostInit("mermguard", MakeMermNeutralToWormwood)
end

if ENABLE_MERM_IGNORE_CHESTER then
  AddPrefabPostInit("merm", MakeMermIgnoreChester)
  AddPrefabPostInit("mermguard", MakeMermIgnoreChester)
end

if MERM_LOYALTY_MULTIPLIER > 1 then
  AddPrefabPostInit("merm", ExtendMermLoyalty)
  AddPrefabPostInit("mermguard", ExtendMermLoyalty)
end

if ENABLE_DISMISS_MERMS_COMMAND then
  RegisterDismissMermsCommand()
end
