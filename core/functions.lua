local _, ns = ...

local L, C, G = unpack(select(2, ...))

-- -----------------------------------
-- > VARS
-- -----------------------------------

local min, pairs, sort = math.min, pairs, table.sort

local GetInventoryItemDurability, GetContainerNumFreeSlots = GetInventoryItemDurability, GetContainerNumFreeSlots

local GetSpecialization,
  GetSpecializationInfo,
  GetLootSpecialization,
  GetSpecializationInfoByID,
  GetNumFriends,
  BNGetNumFriends =
  GetSpecialization,
  GetSpecializationInfo,
  GetLootSpecialization,
  GetSpecializationInfoByID,
  GetNumFriends,
  BNGetNumFriends

-- -----------------------------------
-- > FUNCTIONS
-- -----------------------------------

function L:GetLowerDurability(slots)
  local lowest = 1
  for slit, id in pairs(slots) do
    local dur, maxDur = GetInventoryItemDurability(id)
    if dur and maxDur and maxDur ~= 0 then
      lowest = min(dur / maxDur, lowest)
    end
  end
  return lowest
end

-- Count Free Bags Free Slots
function L:BagsSlotsFree()
  local free = 0
  for i = 0, NUM_BAG_SLOTS do
    local bagFree = select(1, GetContainerNumFreeSlots(i))
    free = free + bagFree
  end
  return free
end

-- Get Current Specialization
function L:GetCurrentSpec()
  local specName = "-"
  local specID = GetSpecialization()

  if (specID) then
    specName = select(2, GetSpecializationInfo(specID))
  end

  return specName
end

-- Loot Specialization
function L:GetLootSpec()
  local specName = L:GetCurrentSpec()
  local lootSpecId = GetLootSpecialization()

  if lootSpecId ~= 0 then
    specName = select(2, GetSpecializationInfoByID(lootSpecId))
  end

  return specName
end

-- Return Number of total Bnet Friends and Favorites
-- FIX: 9.01 Broken
function L:GetBNetNumFriends()
  -- local _, numBNetOnline, _, numBNetFavoriteOnline = BNGetNumFriends()
  -- return numBNetOnline, numBNetFavoriteOnline
  return 0
end

-- FIX: 9.01 Broken
function L:GetLocalNumFriends()
  -- return select(2, GetNumFriends())
  return 0
end

function L:IsBottomRightActionBarEnabled()
  _, bottomRightState = GetActionBarToggles()

  if bottomRightState then
    return true
  end
  return false
end
