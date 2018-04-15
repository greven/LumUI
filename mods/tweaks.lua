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

local collect = true
local autoRepair = true
local autoRepairGuild = true
local autoSell = true
local saySapped = true
local acceptRes = true
local battlegroundRes = true
local acceptFriendlyInvites = true

-- ---------------------------------
-- > Collect Garbage
-- ---------------------------------
if collect then
	local eventcount = 0 
	local a = CreateFrame("Frame") 
	a:RegisterAllEvents() 
	a:SetScript("OnEvent", function(self, event) 
		eventcount = eventcount + 1 
		if InCombatLockdown() then return end 
		if eventcount > 6000 or event == "PLAYER_ENTERING_WORLD" then 
			collectgarbage("collect") 
			eventcount = 0
		end 
	end)
end

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
