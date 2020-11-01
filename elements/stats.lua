-- ------------------------------------------------------
-- Credits: Lyn (LynStats), Katae (LiteStats) and Tekkub
-- ------------------------------------------------------
local _, ns = ...

local L, C, G = unpack(select(2, ...))

local ls = CreateFrame("Button", "lumStats", UIParent)

ls:SetScript(
	"OnEvent",
	function(self, event, ...)
		if self[event] then
			return self[event](self, event, ...)
		end
	end
)

-- ---------------------------------
-- > Variables
-- ---------------------------------

local cfg = C.settings.stats

local UPDATE_TIME = 1
local SPECIALIZATION_LEVEL = 10
local FIRST_TALENTS_LEVEL = 15
local DUAL_SPEC_LEVEL = 30

local PlayerLevel = UnitLevel("PLAYER")

-- Copy Global functions to speed references
local floor, pairs, format, wipe = math.floor, pairs, string.format, wipe
local GetInventorySlotInfo,
	GetMoney,
	GetTime,
	GetFramerate,
	GetNetStats,
	HasNewMail,
	UnitLevel,
	GetNumUnspentTalents,
	GetLatestThreeSenders,
	GetTime,
	GetAverageItemLevel,
	GetAchievementInfo,
	GetCritChance,
	GetHaste,
	GetMasteryEffect,
	GetCombatRatingBonus,
	BNConnected =
	GetInventorySlotInfo,
	GetMoney,
	GetTime,
	GetFramerate,
	GetNetStats,
	HasNewMail,
	UnitLevel,
	GetNumUnspentTalents,
	GetLatestThreeSenders,
	GetTime,
	GetAverageItemLevel,
	GetAchievementInfo,
	GetCritChance,
	GetHaste,
	GetMasteryEffect,
	GetCombatRatingBonus,
	BNConnected

local GetNumFriends, GetFriendInfo = GetNumFriends, GetFriendInfo
local BNGetNumFriends, BNGetFriendInfo, BNGetGameAccountInfo, BNet_GetValidatedCharacterName =
	BNGetNumFriends,
	BNGetFriendInfo,
	BNGetGameAccountInfo,
	BNet_GetValidatedCharacterName

local refreshTimer, gotMail = 0, 0
local durability, slotsFree, time, mail, fps, lag, spec = "-", "-"
local FriendsTable = {}
local BNetTable = {}
local totalOnlineFriends, numLocalOnline, numBNetOnline, numBNetFavoriteOnline = 0, 0, 0, 0, 0

local width = cfg.width
local height = cfg.height - 10

-- Font Strings
local LeftText, CenterText, RightText

-- Class color
local classColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

-- Repair Slots
local SLOTS = {}
for _, slot in pairs({"Head", "Shoulder", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "MainHand", "SecondaryHand"}) do
	SLOTS[slot] = GetInventorySlotInfo(slot .. "Slot")
end

-- ---------------------------------
-- > Functions
-- ---------------------------------

-- ClassColors addon
if (IsAddOnLoaded("!ClassColors") and CUSTOM_CLASS_COLORS) then
	classColor = CUSTOM_CLASS_COLORS[select(2, UnitClass("player"))]
end

function ls:GetDurability()
	local d = L:GetLowerDurability(SLOTS)
	return format("%s%d|r", L:Gradient(d), d * 100)
end

function ls:GetFreeBagSlots()
	return L:BagsSlotsFree()
end

function ls:GetSpecInfo()
	local unspentTalents = 0

	-- Spec Name
	specName = "No Spec"
	if PlayerLevel >= SPECIALIZATION_LEVEL then
		specName = L:GetCurrentSpec()
	end

	-- Unspent Talents
	if PlayerLevel >= FIRST_TALENTS_LEVEL then
		unspentTalents = GetNumUnspentTalents()
	end

	if (PlayerLevel >= FIRST_TALENTS_LEVEL and unspentTalents > 0 and specName) then
		return ("%s%s|r|cffB2B2B2 (%d)|r"):format(L:ToHex(classColor), specName, unspentTalents)
	end

	return specName
end

-- iLevel
function ls:GetiLevel()
	local achievementID = {10764, 9708} -- (Legion) Brokenly Superior / Epic
	local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel()
	local isRare = select(13, GetAchievementInfo(achievementID[1]))
	local isEpic = select(13, GetAchievementInfo(achievementID[2]))
	local rareColor, epicColor = ITEM_QUALITY_COLORS[4].hex, ITEM_QUALITY_COLORS[3].hex
	local color = isRare and rareColor or isEpic and epicColor or "|cffeeeeee"

	if (floor(avgItemLevel) ~= floor(avgItemLevelEquipped)) then
		return format("%s%d|r |cffc0c0c0(%d)|r", color, avgItemLevelEquipped, avgItemLevel)
	else
		return format("%s%d|r", color, avgItemLevelEquipped)
	end
end

-- TODO This is not a real session as reload resets it!
function ls:GetSessionTime()
	return GetTime() - LumuiDB.stats.loginTime
end

function ls:GetPlayerMoney()
	local money = GetMoney()
	return L:FormatMoney(money)
end

-- TODO This is not a real session as reload resets it!
function ls:GetSessionProfit()
	local profit = GetMoney() - LumuiDB.stats.initialMoney
	local output = L:FormatMoney(profit)

	if profit ~= 0 then
		return output
	else
		return format("|cffaaaaaa0|r")
	end
end

-- TODO This is not a real Per Hour Value as reload resets it!
function ls:GetGoldPerHour()
	local profit = GetMoney() - LumuiDB.stats.initialMoney

	if profit ~= 0 then
		local goldPerHour = profit / (ls:GetSessionTime() / 3600)
		if (goldPerHour) then
			return L:FormatMoney(goldPerHour)
		end
	else
		return format("|cffaaaaaa0|r")
	end
end

local function SortAlphabeticName(a, b)
	if a[1] and b[1] then
		return a[1] < b[1]
	end
end

-- Build a table with the friends list (local)
function ls:BuildFriendsTable()
	wipe(FriendsTable)
	local totalFriends = GetNumFriends()
	local name, level, class, area, connected, status

	for i = 1, totalFriends do
		local name, level, class, area, connected, status = GetFriendInfo(i)

		if status == "<" .. AFK .. ">" then
			status = "|cffFFFFFF[|r|cffFF0000" .. "AFK" .. "|r|cffFFFFFF]|r"
		elseif status == "<" .. DND .. ">" then
			status = "|cffFFFFFF[|r|cffFF0000" .. "DND" .. "|r|cffFFFFFF]|r"
		end

		if connected then
			FriendsTable[i] = {name, level, class, area, connected, status}
		end
	end
end

-- Build a table with the BNet friends list
function ls:BuildBNetFriendsTable()
	wipe(BNetTable)
	local totalFriends = BNGetNumFriends()
	local presenceID, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isAFK, isDND, noteText
	local realmName, faction, race, class, zoneName, level

	for i = 1, totalFriends do
		presenceID, accountName, battleTag, _, characterName, bnetIDGameAccount, client, isOnline, _, isAFK, isDND, _, noteText = BNGetFriendInfo(i)

		if isOnline then
			BNetTable[i] = {
				presenceID,
				accountName,
				accountName,
				bnetIDGameAccount,
				isOnline,
				isOnline,
				bnetIDGameAccount
			}
		end

		-- if bnetIDGameAccount then
		-- 	_, _, _, realmName, _, faction, race, class, _, zoneName, level = BNGetGameAccountInfo(bnetIDGameAccount)

		-- 	if isOnline then
		-- 		characterName = BNet_GetValidatedCharacterName(characterName, battleTag, client) or ""

		-- 		BNetTable[i] = {
		-- 			presenceID,
		-- 			accountName,
		-- 			characterName,
		-- 			client,
		-- 			isOnline,
		-- 			isAFK,
		-- 			isDND,
		-- 			realmName,
		-- 			faction,
		-- 			zoneName,
		-- 			level
		-- 		}
		-- 	end
		-- end
	end

	-- sort(BNetTable, SortAlphabeticName)
end

function ls:GetFriendsList()
	-- If there are no online friends, exit
	if totalOnlineFriends == 0 then
		return
	end

	if numLocalOnline > 0 then
		ls:BuildFriendsTable()
	end

	if numBNetOnline > 0 then
		ls:BuildBNetFriendsTable()
	end
end

function ls:UpdateFriendsList()
	numLocalOnline = L:GetLocalNumFriends()

	if BNConnected() then
		numBNetOnline, numBNetFavoriteOnline = L:GetBNetNumFriends()
	end

	totalOnlineFriends = numBNetOnline + numLocalOnline

	ls:GetFriendsList()
end

function ls:SetupFrames()
	local margin = 4

	self:SetWidth(width)
	self:SetHeight(height)
	self:SetPoint("CENTER", "UIParent", "BOTTOM", 0, 8)

	if not self.leftFrame then
		self.leftFrame = CreateFrame("Button", nil, self)
	end
	self.leftFrame:SetHeight(height)
	self.leftFrame:SetPoint("LEFT", self, margin, 0)
	self.leftFrame:SetWidth(width / 3 - margin * 2)

	if not self.centerFrame then
		self.centerFrame = CreateFrame("Button", nil, self)
	end
	self.centerFrame = CreateFrame("Button", nil, self)
	self.centerFrame:SetHeight(height)
	self.centerFrame:SetWidth(width / 3 - margin * 2)
	self.centerFrame:SetPoint("CENTER", self, margin, 0)

	if not self.rightFrame then
		self.rightFrame = CreateFrame("Button", nil, self)
	end
	self.rightFrame = CreateFrame("Button", nil, self)
	self.rightFrame:SetHeight(height)
	self.rightFrame:SetWidth(width / 3 - margin * 2)
	self.rightFrame:SetPoint("RIGHT", self, -margin, 0)

	-- Create Left Text
	LeftText = L:createText(self.leftFrame, "OVERLAY", cfg.fontSize, "THINOUTLINE", "LEFT", cfg.fontShadow)
	LeftText:SetPoint("LEFT", self.leftFrame, margin, 0)
	LeftText:SetTextColor(cfg.textColor.r, cfg.textColor.g, cfg.textColor.b)

	-- Create Center Text
	CenterText = L:createText(self.centerFrame, "OVERLAY", cfg.fontSize, "THINOUTLINE", "CENTER", cfg.fontShadow)
	CenterText:SetPoint("CENTER", self.centerFrame, 0, 0)
	CenterText:SetTextColor(cfg.textColor.r, cfg.textColor.g, cfg.textColor.b)

	-- Create Right Text
	RightText = L:createText(self.rightFrame, "OVERLAY", cfg.fontSize, "THINOUTLINE", "RIGHT", cfg.fontShadow)
	RightText:SetPoint("RIGHT", self.rightFrame, -margin, 0)
	RightText:SetTextColor(cfg.textColor.r, cfg.textColor.g, cfg.textColor.b)
end

function ls:SetLeftTooltip()
	if not InCombatLockdown() then
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -4, 8)

		GameTooltip:AddLine("Stats", classColor.r, classColor.g, classColor.b)
		GameTooltip:AddLine(" ")

		GameTooltip:AddDoubleLine("iLevel", ls:GetiLevel(), 0.75, 0.7, 0.45, 1, 1, 1)
		GameTooltip:AddLine("--------------------------------", 0.3, 0.3, 0.3)
		GameTooltip:AddDoubleLine("Crit", format("%d%%", (floor(GetCritChance() + 0.5))), 1, 1, 1, 0.75, 0.75, 0.75)
		GameTooltip:AddDoubleLine("Haste", format("%d%%", (floor(GetHaste() + 0.5))), 1, 1, 1, 0.75, 0.75, 0.75)
		GameTooltip:AddDoubleLine("Mastery", format("%d%%", select(1, GetMasteryEffect())), 1, 1, 1, 0.75, 0.75, 0.75)
		GameTooltip:AddDoubleLine("Versatility", format("%d%% / %d%%", GetCombatRatingBonus(29), GetCombatRatingBonus(31)), 1, 1, 1, 0.75, 0.75, 0.75)

		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("Left click to open Talents")
		GameTooltip:AddLine("Right click to open Spellbook")

		GameTooltip:Show()
	end
end

function ls:SetCenterTooltip()
	if not InCombatLockdown() then
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 8)

		GameTooltip:AddLine("Online Friends", classColor.r, classColor.g, classColor.b)

		if totalOnlineFriends == 0 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine("You have no friends... online :(", 0.5, 0.5, 0.5)
		else
			local friendInfo

			-- WoW Friends
			if numLocalOnline > 0 then
				GameTooltip:AddLine(" ")
				GameTooltip:AddDoubleLine("WoW Friends", numLocalOnline, 0.1, 0.95, 0.25, 1, 1, 1)
				GameTooltip:AddLine("-------------", 0.3, 0.3, 0.3)

				for i = 1, #FriendsTable do
					friendInfo = FriendsTable[i]
					GameTooltip:AddDoubleLine(format("%s (%s)", friendInfo[1], friendInfo[2]), friendInfo[4], 1, 1, 1)
				end
			end

			-- BNet friends
			if numBNetOnline > 0 then
				GameTooltip:AddLine(" ")
				GameTooltip:AddDoubleLine("BNet Friends", format("%s (%s)", numBNetOnline, numBNetFavoriteOnline), 0, 0.6, 0.9, 1, 1, 1)
				GameTooltip:AddLine("-------------", 0.3, 0.3, 0.3)

			-- for i = 1, #BNetTable do
			-- friendInfo = BNetTable[i]
			-- GameTooltip:AddDoubleLine(friendInfo[3], friendInfo[4], 1, 1, 1)
			-- end
			end
		end

		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("Left click to open Social List")
		GameTooltip:AddLine("Right Click to open all Bags")

		GameTooltip:Show()
	end
end

function ls:SetRightTooltip()
	if not InCombatLockdown() then
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 4, 8)

		GameTooltip:AddLine(date("%A, %d %B"), classColor.r, classColor.g, classColor.b)
		GameTooltip:AddLine(" ")

		-- Mail
		local newMessages = GetLatestThreeSenders()
		if (newMessages) then
			local s1, s2, s3 = newMessages
			local senders = {s1, s2, s3}

			GameTooltip:AddLine("New mail from: \n", 1, 0, 0.42)

			for i, sender in ipairs(senders) do
				if sender == nil then
					break
				end
				GameTooltip:AddLine("- " .. sender, 0.75, 0.75, 0.75)
			end
			GameTooltip:AddLine(" ")
		end

		-- Money
		GameTooltip:AddDoubleLine("Gold", ls:GetPlayerMoney(), 1, 1, 1)
		GameTooltip:AddDoubleLine("Profit", ls:GetSessionProfit(), 0.6, 0.6, 0.6)
		GameTooltip:AddDoubleLine("Gold/Hour", ls:GetGoldPerHour(), 0.4, 0.4, 0.4)
		GameTooltip:AddLine(" ")

		-- Session Time
		GameTooltip:AddDoubleLine("Session", L:FormatTime(ls:GetSessionTime()), 0, 0.6, 0.9, 0, 0.8, 0.9)

		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("Left click to show the Calendar")

		GameTooltip:Show()
	end
end

function ls:HideTooltips()
	GameTooltip:Hide()
end

function ls:SetupTooltips()
	-- Left
	self.leftFrame:SetScript("OnEnter", self.SetLeftTooltip)
	self.leftFrame:SetScript("OnLeave", self.HideTooltips)
	self.leftFrame:RegisterForClicks("AnyUp")
	self.leftFrame:SetScript(
		"OnClick",
		function(self, button)
			if button == "LeftButton" then
				ToggleTalentFrame()
			elseif button == "RightButton" then
				ToggleFrame(SpellBookFrame)
			end
		end
	)

	-- Center
	self.centerFrame:SetScript("OnEnter", self.SetCenterTooltip)
	self.centerFrame:SetScript("OnLeave", self.HideTooltips)
	self.centerFrame:RegisterForClicks("AnyUp")
	self.centerFrame:SetScript(
		"OnClick",
		function(self, button)
			if button == "LeftButton" then
				ToggleFriendsFrame()
			elseif button == "RightButton" then
				OpenAllBags()
			end
		end
	)

	-- Right
	self.rightFrame:SetScript("OnEnter", self.SetRightTooltip)
	self.rightFrame:SetScript("OnLeave", self.HideTooltips)
	self.rightFrame:RegisterForClicks("AnyUp")
	self.rightFrame:SetScript(
		"OnClick",
		function(self, button)
			if button == "LeftButton" then
				ToggleCalendar()
			end
		end
	)
end

-- Init Function
function ls:Init()
	-- Create the left, center and right text frames
	ls:SetupFrames()
	-- Tooltips
	ls:SetupTooltips()

	-- Create the Panel
	L:CreatePanel(cfg.classColored, true, "Stats", ls, width, cfg.height, {{"BOTTOM", "UIParent", "BOTTOM", 0, -4}}, 32, 12, 0, 0.5)

	self:SetScript("OnUpdate", self.Update)
end

-- Update Function
function ls:Update(elapsed)
	local dur, talentSpec

	-- Clock
	if cfg.clock24 then
		-- Time 24H Format
		time = date("%H:%M")
	else
		-- Time 12H Format
		time = date("%I:%M |cff919191%p|r")
	end

	-- Main Update
	refreshTimer = refreshTimer + elapsed
	-- Updates each UPDATE_SECONDS
	if refreshTimer > UPDATE_TIME then
		-- FPS
		if cfg.showFPS then
			fps = GetFramerate()
			fps = (floor(fps) .. "%sfps|r  "):format(L:ToHex(classColor))
		else
			fps = ""
		end

		-- Latency
		if cfg.showLag then
			lag = select(3, GetNetStats())
			lag = (lag .. "%sms|r  "):format(L:ToHex(classColor))
		else
			lag = ""
		end

		-- Durability
		if cfg.showDurability then
			dur = (durability .. "%sdur|r   "):format(L:ToHex(classColor))
		end

		-- Bags
		if cfg.showBags then
			bags = (slotsFree .. "%sbag|r   "):format(L:ToHex(classColor))
		end

		-- Mail
		if cfg.showMail then
			if gotMail then
				mail = ("  |cffff0054Mail!|r")
			else
				mail = ""
			end
		else
			mail = ""
		end

		-- Talent Spec
		if cfg.showTalentSpec then
			talentSpec = spec
		end

		LeftText:SetText(talentSpec)
		CenterText:SetText(fps .. lag .. bags .. dur)
		RightText:SetText(time .. mail)

		-- Reset Timer
		refreshTimer = 0
	end
end

function ls:PLAYER_TALENT_UPDATE(event, ...)
	spec = ls:GetSpecInfo()
end

function ls:CHARACTER_POINTS_CHANGED(event, ...)
	spec = ls:GetSpecInfo()
end

function ls:UPDATE_INVENTORY_DURABILITY(event, ...)
	durability = ls:GetDurability()
end

function ls:BAG_UPDATE(event, ...)
	slotsFree = ls:GetFreeBagSlots()
end

function ls:UPDATE_PENDING_MAIL(event, ...)
	gotMail = (HasNewMail() or nil)
end

function ls:MAIL_CLOSED(event, ...)
	gotMail = (HasNewMail() or nil)
end

-- function ls:CVAR_UPDATE(event, value)
-- 	print(event, value)
-- 	bottomLeftState, bottomRightState, sideRightState, sideRight2State = GetActionBarToggles()
-- 	print(bottomRightState)
-- end

-- function ls:CALENDAR_UPDATE_PENDING_INVITES(event, ...)
-- end

function ls:PLAYER_ENTERING_WORLD(event, ...)
	durability = ls:GetDurability()
	slotsFree = ls:GetFreeBagSlots()
	spec = ls:GetSpecInfo()
	ls:UpdateFriendsList()
end

function ls:PLAYER_LOGIN(event, ...)
	durability = ls:GetDurability()
	slotsFree = ls:GetFreeBagSlots()
	spec = ls:GetSpecInfo()

	-- Saved variables
	LumuiDB = LumuiDB or {}
	LumuiDB.stats = {
		initialMoney = GetMoney(),
		loginTime = GetTime()
	}
end

function ls:ADDON_LOADED(event, ...)
	ls:RegisterEvent("PLAYER_LOGIN")
	ls:RegisterEvent("PLAYER_ENTERING_WORLD")
	ls:RegisterEvent("BAG_UPDATE")
	ls:RegisterEvent("UPDATE_PENDING_MAIL")
	ls:RegisterEvent("PLAYER_TALENT_UPDATE")
	ls:RegisterEvent("CHARACTER_POINTS_CHANGED")
	ls:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	ls:RegisterEvent("MAIL_CLOSED")
	-- ls:RegisterEvent("CVAR_UPDATE")
	-- ls:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")
	ls:UnregisterEvent("ADDON_LOADED")

	-- Frame Visibility
	RegisterStateDriver(ls, "visibility", C.settings.stats.frameVisibility)
end

ls:Init() -- Begins the Magic!

ls:RegisterEvent("ADDON_LOADED")
