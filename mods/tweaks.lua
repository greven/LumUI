-- --------------------------------------------
-- Credits: AltzUI.
-- --------------------------------------------

local _, ns = ...

local L, C, G = unpack(select(2, ...))

local eventframe = CreateFrame('Frame')
eventframe:SetScript('OnEvent', function(self, event, ...)
	eventframe[event](self, ...)
end)

-- ---------------------------------
-- > Config
-- ---------------------------------

local autoRepair = true
local autoRepairGuild = true
local autoSell = true
local saySapped = true
local acceptRes = true
local battlegroundRes = true
local acceptFriendlyInvites = true

-- ----------------------------------
-- > Auto repair and sell grey items
-- ----------------------------------
local IDs = {}
for _, slot in pairs({"Head", "Shoulder", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "MainHand", "SecondaryHand"}) do
	IDs[slot] = GetInventorySlotInfo(slot .. "Slot")
end

local greylist = {
	[129158] = true,
}
eventframe:RegisterEvent('MERCHANT_SHOW')
function eventframe:MERCHANT_SHOW()
	if CanMerchantRepair() and autoRepair then
		local gearRepaired = true -- to work around bug when there's not enough money in guild bank
		local cost = GetRepairAllCost()
		if cost > 0 and CanGuildBankRepair() and autoRepairGuild then
			if GetGuildBankWithdrawMoney() > cost then
				RepairAllItems(1)
				for slot, id in pairs(IDs) do
					local dur, maxdur = GetInventoryItemDurability(id)
					if dur and maxdur and dur < maxdur then
						gearRepaired = false
						break
					end
				end
				if gearRepaired then
					print(format("Repair Cost: %s ("..GUILD..")", L:FormatMoney(cost)))
				end
			elseif cost > 0 and GetMoney() > cost then
				RepairAllItems()
				print(format("Repair Cost: %s", L:FormatMoney(cost)))
			end
		elseif cost > 0 and GetMoney() > cost then
			RepairAllItems()
			print(format("Repair Cost: ".." %s", L:FormatMoney(cost)))
		end
	end
	if autoSell then
		for bag = 0, 4 do
			for slot = 0, GetContainerNumSlots(bag) do
				local link = GetContainerItemLink(bag, slot)
				local id = GetContainerItemID(bag, slot)
				if link and (select(3, GetItemInfo(link))==0) and not greylist[id] then
					UseContainerItem(bag, slot)
				end
			end
		end
  end
end

-- ---------------------------------
-- > Say Sapped!
-- ---------------------------------
if saySapped then
	eventframe:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	function eventframe:COMBAT_LOG_EVENT_UNFILTERED(...)
		local timestamp, etype, hideCaster,
        sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID = ...
		if (etype == "SPELL_AURA_APPLIED" or etype == "SPELL_AURA_REFRESH") and destName == G.playerName and spellID == 6770 then
			SendChatMessage("Sapped!", "SAY")
			DEFAULT_CHAT_FRAME:AddMessage("Sapped by:".." "..(select(7,...) or "(unknown)"))
		end
	end
end

-- ---------------------------------
-- > Accept Res
-- ---------------------------------
if acceptRes then
	eventframe:RegisterEvent('RESURRECT_REQUEST')
	function eventframe:RESURRECT_REQUEST(name)
		if UnitAffectingCombat('player') then return end
		if IsInGroup() then
			if IsInRaid() then
				for i = 1, 39 do
					if UnitAffectingCombat(format('raid%d', i)) then
						return
					end
				end
			else
				for i = 1, 4 do
					if UnitAffectingCombat(format('party%d', i)) then
						return
					end
				end
			end
		end

		local delay = GetCorpseRecoveryDelay()
		if delay == 0 then
			AcceptResurrect()
			StaticPopup_Hide("RESURRECT")
		end
	end
end

-- ---------------------------------
-- > Battleground Res
-- ---------------------------------
if battlegroundRes then
	eventframe:RegisterEvent('PLAYER_DEAD')
	function eventframe:PLAYER_DEAD()
		if ( select(2, GetInstanceInfo()) =='pvp' ) or (GetRealZoneText()=='Wintergrasp') or (GetRealZoneText()=='TolBarad') then
			RepopMe()
		end
	end
end

-- ---------------------------------
-- > Accept Friendly Invites
-- ---------------------------------
if acceptFriendlyInvites then
	eventframe:RegisterEvent('PARTY_INVITE_REQUEST')
	function eventframe:PARTY_INVITE_REQUEST(arg1)
		if QueueStatusMinimapButton:IsShown() then return end
        if IsInGroup() then return end
		local accept = false
		for index = 1, GetNumFriends() do
			if GetFriendInfo(index) == arg1 then
				accept = true
				break
			end
		end
		if not accept and IsInGuild() then
			GuildRoster()
			for index = 1, GetNumGuildMembers() do
				if GetGuildRosterInfo(index) == arg1 then
					accept = true
					break
				end
			end
		end
		if not accept then
			for index = 1, BNGetNumFriends() do
				local toonName = select(5, BNGetFriendInfo(index))
				if toonName == arg1 then
					accept = true
					break
				end
			end
		end
		if accept then
			local pop = StaticPopup_Visible('PARTY_INVITE')
			if pop then
				StaticPopup_OnClick(_G[pop], 1)
				return
			end
		end
	end
end

-- ---------------------------------
-- > Other Stuff
-- ---------------------------------

-- Move Archeology Frame
local function moveArcheologyFrame()
	ArcheologyDigsiteProgressBar:SetPoint("BOTTOM", 0, 700)
	ArcheologyDigsiteProgressBar.ignoreFramePositionManager = true
end

-- Add Total Quest Count in WorldMap (Why Blizzard why...)
local WMTQC = CreateFrame('Frame')
WMTQC:SetParent(QuestScrollFrame)
WMTQC:SetHeight(25)
WMTQC:SetWidth(75)
WMTQC.text = L:createText(WMTQC, 'OVERLAY', 13, 'OUTLINE', 'LEFT')
WMTQC.text:SetPoint('TOPRIGHT', QuestScrollFrame, 'TOPRIGHT', -28, 19)

local function updateTotalQuestCount()
	local _, k = GetNumQuestLogEntries()
	WMTQC.text:SetText(QUESTS_COLON.." "..k.."/25")
	-- Conditional color
	if k < 20 then
		WMTQC.text:SetTextColor(237/255, 251/255, 119/255)
	elseif k < 25 then
		WMTQC.text:SetTextColor(251/255, 211/255, 119/255)
	else
		WMTQC.text:SetTextColor(251/255, 119/255, 119/255)
	end
end

-- -----------------------------
-- Character Frame items iLevel
-- -----------------------------

local iLvlF = CreateFrame('Frame')
local slotStrings = {}
local slotIDs = {
	[1] = "HeadSlot",
	[2] = "NeckSlot",
	[3] = "ShoulderSlot",
	[5] = "ChestSlot",
	[6] = "WaistSlot",
	[7] = "LegsSlot",
	[8] = "FeetSlot",
	[9] = "WristSlot",
	[10] = "HandsSlot",
	[11] = "Finger0Slot",
	[12] = "Finger1Slot",
	[13] = "Trinket0Slot",
	[14] = "Trinket1Slot",
	[15] = "BackSlot",
	[16] = "MainHandSlot",
	[17] = "SecondaryHandSlot"
}

function iLvlF:GetSlot(slotID)
	return _G["Character" .. slotIDs[slotID]]
end

function iLvlF:GetSlotString(id, slot)
	if not slotStrings[id] then
		if not slot then
			slot = iLvlF:GetSlot(id)
		end
		slotStrings[id] = L:createText(slot, 'OVERLAY', 17, 'OUTLINE', 'CENTER')
		slotStrings[id]:SetPoint("TOP", slot, "TOP", 1, -6)
	end
	return slotStrings[id]
end

function iLvlF:Update(id, item)
	if item then
		local slotString = iLvlF:GetSlotString(id)
		local itemRarity = select(3, GetItemInfo(item))
		local iLevel = GetDetailedItemLevelInfo(item)
		if itemRarity and iLevel then
			local r, g, b = GetItemQualityColor(itemRarity)
			slotString:SetText(iLevel)
			slotString:SetTextColor(r, g, b)
			slotString:Hide()
		end
	else
		local slotString = iLvlF:GetSlotString(id)
		slotString:SetText('')
		return
	end
end

function iLvlF:UpdateAll()
	for id, _ in pairs(slotIDs) do
		local slotString = iLvlF:GetSlotString(id)
		iLvlF:Update(id, GetInventoryItemLink("player", id), slotString)
	end
end

function iLvlF:Toggle()
	for id, string in pairs(slotStrings) do
		local slot = iLvlF:GetSlot(id)
		if IsShiftKeyDown() and PaperDollItemsFrame:IsShown() then
			string:Show()
		else
			string:Hide()
		end
	end
end

-- ---------------------------------
-- > Other Events
-- ---------------------------------

eventframe:RegisterEvent('ADDON_LOADED')
function eventframe:ADDON_LOADED(addon)
	if adddon == 'LumUI' then
		-- Items iLevel
		iLvlF:UpdateAll()
	end

	if addon == 'Blizzard_ArchaeologyUI' then
		moveArcheologyFrame()
	end
end

eventframe:RegisterEvent('QUEST_LOG_UPDATE')
function eventframe:QUEST_LOG_UPDATE()
	-- Update Quest Count
	updateTotalQuestCount()
end

eventframe:RegisterEvent('PLAYER_ENTERING_WORLD')
function eventframe:PLAYER_ENTERING_WORLD()
	-- Update Quest Count
	updateTotalQuestCount()
	-- Items iLevel
	CharacterFrame:HookScript("OnShow", function()
		eventframe:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
		C_Timer.After(.2, function()
			iLvlF:UpdateAll()
		end)
	end)

	eventframe:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function eventframe:PLAYER_EQUIPMENT_CHANGED(slotID)
	-- Update items iLevel
	iLvlF:Update(slotID, GetInventoryItemLink("player", slotID))
end

eventframe:RegisterEvent('MODIFIER_STATE_CHANGED')
function eventframe:MODIFIER_STATE_CHANGED(key)
	-- Toggle items iLevel
	iLvlF:Toggle()
end
