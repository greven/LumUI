local _, ns = ...

local L, C, G = unpack(select(2, ...))

-----------------------------
-- Config
-----------------------------

local cfg = {
	fontFamily = STANDARD_TEXT_FONT,
	pos = {"TOPRIGHT", "Minimap", "TOPLEFT", -16, 4}, -- "ANCHOR_CURSOR"
	scale = 1,
	textColor = {0.4, 0.4, 0.4},
	bossColor = {1, 0, 0},
	eliteColor = {1, 0, 0.5},
	rareeliteColor = {1, 0.5, 0},
	rareColor = {1, 0.5, 0},
	levelColor = {0.8, 0.8, 0.5},
	deadColor = {0.5, 0.5, 0.5},
	targetColor = {1, 0.5, 0.5},
	guildColor = {1, 0, 1},
	afkColor = {0, 1, 1},
	statusbarHeight = 4,
	showSpellID = true,
	talents = {
		show = true,
		onlyParty = false
	},
	backdrop = {
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = [[Interface\AddOns\lumUI\media\Textures\border_squared]],
		tiled = true,
		edgeSize = 10,
		insets = {left = 0, right = 0, top = 0, bottom = 0},
		bgColor = {0.05, 0.05, 0.05, 0.96},
		borderColor = {0.1, 0.1, 0.1, 1}
	}
}

-----------------------------
-- Variables
-----------------------------

local _G = _G
local pairs = pairs
local unpack = unpack
local RAID_CLASS_COLORS, FACTION_BAR_COLORS = RAID_CLASS_COLORS, FACTION_BAR_COLORS

local hooksecurefunc = hooksecurefunc
local IsModifierKeyDown = IsModifierKeyDown
local IsShiftKeyDown = IsShiftKeyDown

local GameTooltip, GameTooltipStatusBar = _G.GameTooltip, _G.GameTooltipStatusBar
local ItemRefTooltip = _G.ItemRefTooltip

local classColorHex, factionColorHex = {}, {}

-- ---------------------------
-- Functions
-- ---------------------------

local function GetTarget(unit)
	if UnitIsUnit(unit, "player") then
		return ("|cffff0000%s|r"):format("<YOU>")
	elseif UnitIsPlayer(unit, "player") then
		local _, class = UnitClass(unit)
		return ("%s%s|r"):format(classColorHex[class], UnitName(unit))
	elseif UnitReaction(unit, "player") then
		return ("%s%s|r"):format(factionColorHex[UnitReaction(unit, "player")], UnitName(unit))
	else
		return ("|cffffffff%s|r"):format(UnitName(unit))
	end
end

local function TooltipAddSpellID(self, spellid)
	if self:IsForbidden() or not spellid then
		return
	end

	if IsModifierKeyDown() then
		local spellidText = format("|cff0099ffSpell %s|r |cffdefcff%d|r", _G.ID, spellid)

		for i = 3, self:NumLines() do
			local line = _G[format("GameTooltipTextLeft%d", i)]
			local text = line and line:GetText()
			if text and strfind(text, spellidText) then
				return -- this is called twice on talents for some reason?
			end
		end

		self:AddLine(spellidText)
		self:Show()
	end
end

local function SetColors()
	-- class colors
	for class, color in next, RAID_CLASS_COLORS do
		classColorHex[class] = L:ToHex(color)
	end

	-- reaction colors
	for i = 1, #FACTION_BAR_COLORS do
		factionColorHex[i] = L:ToHex(FACTION_BAR_COLORS[i])
	end

	cfg.targetColorHex = L:ToHex(cfg.targetColor)
	cfg.afkColorHex = L:ToHex(cfg.afkColor)
end

local function SetBackdropStyle(self, style)
	if self.IsEmbedded then
		return
	end

	if self.TopOverlay then
		self.TopOverlay:Hide()
	end

	if self.BottomOverlay then
		self.BottomOverlay:Hide()
	end

	self:SetBackdrop(cfg.backdrop)
	self:SetBackdropColor(unpack(cfg.backdrop.bgColor))

	local _, itemLink = self:GetItem()

	if itemLink then
		local azerite =
			C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(itemLink) or C_AzeriteItem.IsAzeriteItemByID(itemLink) or false
		local _, _, itemRarity = GetItemInfo(itemLink)
		local r, g, b = 1, 1, 1
		if itemRarity then
			r, g, b = GetItemQualityColor(itemRarity)
		end

		-- Use azerite coloring or item rarity
		if azerite and cfg.backdrop.azeriteBorderColor then
			self:SetBackdropBorderColor(unpack(cfg.backdrop.azeriteBorderColor))
		else
			self:SetBackdropBorderColor(r, g, b, 1)
		end
	else
		-- no item, use default border
		self:SetBackdropBorderColor(unpack(cfg.backdrop.borderColor))
	end
end

local function SetTooltipFonts()
	GameTooltipHeaderText:SetFont(cfg.fontFamily, 14, "NONE")
	GameTooltipHeaderText:SetShadowOffset(1, -1)
	GameTooltipHeaderText:SetShadowColor(0, 0, 0, 0.9)
	GameTooltipText:SetFont(cfg.fontFamily, 12, "NONE")
	GameTooltipText:SetShadowOffset(1, -1)
	GameTooltipText:SetShadowColor(0, 0, 0, 0.9)
	Tooltip_Small:SetFont(cfg.fontFamily, 11, "NONE")
	Tooltip_Small:SetShadowOffset(1, -1)
	Tooltip_Small:SetShadowColor(0, 0, 0, 0.9)
end

local function SetTooltipStatusBar()
	GameTooltip.StatusBar = GameTooltipStatusBar
	GameTooltip.StatusBar:SetStatusBarTexture(G.media.statusbar)
	GameTooltip.StatusBar:ClearAllPoints()
	GameTooltip.StatusBar:SetPoint("LEFT", 5, 0)
	GameTooltip.StatusBar:SetPoint("RIGHT", -5, 0)
	GameTooltip.StatusBar:SetPoint("TOP", 0, -2.5)
	GameTooltip.StatusBar:SetHeight(cfg.statusbarHeight)

	local Background = GameTooltipStatusBar.bg
	Background = GameTooltipStatusBar:CreateTexture(nil, "BACKGROUND", nil, -8)
	Background:SetAllPoints()
	Background:SetColorTexture(1, 1, 1)
	Background:SetVertexColor(0, 0, 0, 0.3)

	-- GameTooltip Statusbar text
	-- GameTooltip.StatusBar.text = GameTooltip.StatusBar:CreateFontString(nil, 'OVERLAY')
	-- GameTooltip.StatusBar.text:Point('CENTER', GameTooltip.StatusBar, 0, 0)
	-- GameTooltip.StatusBar.text:SetFont(cfg.fontFamily, 11, "NONE")
end

local function SetStatusBarColor(self, r, g, b)
	if not cfg.barColor then
		return
	end
	if r == cfg.barColor.r and g == cfg.barColor.g and b == cfg.barColor.b then
		return
	end

	self:SetStatusBarColor(cfg.barColor.r, cfg.barColor.g, cfg.barColor.b)
end

local function SetStyle(self)
	if not self or (self.IsEmbedded or not self.SetBackdrop) or self:IsForbidden() then
		return
	end

	self:SetScale(cfg.scale)

	if self:HasScript("OnTooltipCleared") then
		self:HookScript("OnTooltipCleared", SetBackdropStyle)
	end
end

local function StyleTooltips()
	for _, tt in pairs(
		{
			_G.ItemRefTooltip,
			_G.ItemRefShoppingTooltip1,
			_G.ItemRefShoppingTooltip2,
			_G.FriendsTooltip,
			_G.WarCampaignTooltip,
			_G.EmbeddedItemTooltip,
			_G.ReputationParagonTooltip,
			_G.GameTooltip,
			_G.ShoppingTooltip1,
			_G.ShoppingTooltip2,
			_G.QuestScrollFrame.StoryTooltip,
			_G.QuestScrollFrame.CampaignTooltip
		}
	) do
		SetStyle(tt)
	end
end

-- ---------------------------
-- Talents (Credit: TipTac)
-- ---------------------------

local tt = CreateFrame("Frame", "TooltipTalents", UIParent)
tt:SetScript(
	"OnEvent",
	function(self, event, ...)
		if self[event] then
			return self[event](self, event, ...)
		end
	end
)

local cache = {}
local current = {}

-- String Constants
local TALENTS_PREFIX = TALENTS .. ":|cffffffff " -- MoP: Could be changed from TALENTS to SPECIALIZATION
local TALENTS_NA = NOT_APPLICABLE:lower()
local TALENTS_NONE = NO .. " " .. TALENTS

-- Option Constants
local CACHE_SIZE = 25 -- Change cache size here (Default 25)
local INSPECT_DELAY = 0.2 -- The time delay for the scheduled inspection
local INSPECT_FREQ = 2 -- How often after an inspection are we allowed to inspect again?
local lastInspectRequest = 0

tt:Hide()

local function IsInspectFrameOpen()
	return (InspectFrame and InspectFrame:IsShown()) or (Examiner and Examiner:IsShown())
end

local function GatherTalents(isInspect)
	local spec = isInspect and GetInspectSpecialization(current.unit) or GetSpecialization()
	if (not spec or spec == 0) then
		current.format = TALENTS_NONE
	elseif (isInspect) then
		local _, specName = GetSpecializationInfoByID(spec)
		current.format = specName or TALENTS_NA
	else
		local _, specName = GetSpecializationInfo(spec)
		current.format = specName or TALENTS_NA
	end

	if (not isInspect) then
		GameTooltip:AddLine(TALENTS_PREFIX .. current.format)
	elseif (GameTooltip:GetUnit()) then
		for i = 2, GameTooltip:NumLines() do
			if ((_G["GameTooltipTextLeft" .. i]:GetText() or ""):match("^" .. TALENTS_PREFIX)) then
				_G["GameTooltipTextLeft" .. i]:SetFormattedText("%s%s", TALENTS_PREFIX, current.format)
				if (not GameTooltip.fadeOut) then
					GameTooltip:Show()
				end
				break
			end
		end
	end

	-- Organise Cache
	local cacheSize = CACHE_SIZE
	for i = #cache, 1, -1 do
		if (current.name == cache[i].name) then
			tremove(cache, i)
			break
		end
	end
	if (#cache > cacheSize) then
		tremove(cache, 1)
	end
	-- Cache the new entry
	if (cacheSize > 0) then
		cache[#cache + 1] = CopyTable(current)
	end
end

-----------------------------
-- Hook's Callbacks
-----------------------------

local function OnTooltipSetUnit(self)
	local unitName, unit = self:GetUnit()
	if not unit then
		return
	end

	if not UnitIsPlayer(unit) then
		-- unit is not a player
		local reaction = UnitReaction(unit, "player")
		if reaction then
			local color = FACTION_BAR_COLORS[reaction]
			if color then
				cfg.barColor = color
				GameTooltipStatusBar:SetStatusBarColor(color.r, color.g, color.b)
				GameTooltipTextLeft1:SetTextColor(color.r, color.g, color.b)
			end
		end

		local unitClassification = UnitClassification(unit)

		local levelLine
		if string.find(GameTooltipTextLeft2:GetText() or "empty", "%a%s%d") then
			levelLine = GameTooltipTextLeft2
		end

		if levelLine then
			local l = UnitLevel(unit)
			local color = GetCreatureDifficultyColor((l > 0) and l or 999)
			levelLine:SetTextColor(color.r, color.g, color.b)
		end

		if unitClassification == "worldboss" or UnitLevel(unit) == -1 then
			self:AppendText(" |cffff0000{B}|r")
			GameTooltipTextLeft2:SetTextColor(unpack(cfg.bossColor))
		elseif unitClassification == "rare" then
			self:AppendText(" |cffff9900{R}|r")
		elseif unitClassification == "rareelite" then
			self:AppendText(" |cffff0000{R+}|r")
		elseif unitClassification == "elite" then
			self:AppendText(" |cffff6666{E}|r")
		end
	else
		-- unit is any player
		local _, unitClass = UnitClass(unit)

		local color = RAID_CLASS_COLORS[unitClass]
		cfg.barColor = color
		GameTooltipStatusBar:SetStatusBarColor(color.r, color.g, color.b)
		GameTooltipTextLeft1:SetTextColor(color.r, color.g, color.b)

		local unitGuild = GetGuildInfo(unit)
		if unitGuild then
			GameTooltipTextLeft2:SetText("<" .. unitGuild .. ">")
			GameTooltipTextLeft2:SetTextColor(unpack(cfg.guildColor))
		end

		local levelLine = unitGuild and GameTooltipTextLeft3 or GameTooltipTextLeft2
		local l = UnitLevel(unit)
		local color = GetCreatureDifficultyColor((l > 0) and l or 999)
		levelLine:SetTextColor(color.r, color.g, color.b)
		-- afk?
		if UnitIsAFK(unit) then
			self:AppendText((" %s<AFK>|r"):format(cfg.afkColorHex))
		end
	end

	-- dead?
	if UnitIsDeadOrGhost(unit) then
		GameTooltipTextLeft1:SetTextColor(unpack(cfg.deadColor))
	end

	-- target line
	if (UnitExists(unit .. "target")) then
		GameTooltip:AddDoubleLine(("%s%s|r"):format(cfg.targetColorHex, "Target"), GetTarget(unit .. "target") or "Unknown")
	end

	-- Talents --
	if not cfg.talents.show or not IsShiftKeyDown() then
		return
	end

	tt:Hide() -- Abort any delayed inspect in progress

	if (not unit) then
		local mFocus = GetMouseFocus()
		if (mFocus) and (mFocus.unit) then
			unit = mFocus.unit
		end
	end

	-- No Unit or not a Player
	if (not unit) or (not UnitIsPlayer(unit)) then
		return
	end

	-- Show only talents for people in your party/raid
	if (cfg.talents.onlyParty and not UnitInParty(unit) and not UnitInRaid(unit)) then
		return
	end

	-- Only bother for players over level 15 (Updated: Shadowlands)
	local level = UnitLevel(unit)

	if (level >= 15 or level == -1) then
		-- Wipe Current Record
		wipe(current)
		current.unit = unit
		current.name = UnitName(unit)
		current.guid = UnitGUID(unit)

		-- No need for inspection on the player
		if (UnitIsUnit(unit, "player")) then
			GatherTalents()
			return
		end

		-- Show Cached Talents, If Available
		local cacheLoaded = false
		for _, entry in ipairs(cache) do
			if (current.name == entry.name) then
				self:AddLine(TALENTS_PREFIX .. entry.format)
				current.format = entry.format
				cacheLoaded = true
				break
			end
		end

		-- Queue an inspect request
		if (CanInspect(unit)) and (not IsInspectFrameOpen()) then
			local lastInspectTime = (GetTime() - lastInspectRequest)
			tt.nextUpdate =
				(lastInspectTime > INSPECT_FREQ) and INSPECT_DELAY or (INSPECT_FREQ - lastInspectTime + INSPECT_DELAY)
			tt:Show()
			if (not cacheLoaded) then
				self:AddLine(TALENTS_PREFIX .. "Loading...")
			end
		end
	end
end

local function SetDefaultAnchor(self, parent)
	if not cfg.pos then
		return
	end
	if type(cfg.pos) == "string" then
		self:SetOwner(parent, cfg.pos)
	else
		self:SetOwner(parent, "ANCHOR_NONE")
		self:ClearAllPoints()
		self:SetPoint(unpack(cfg.pos))
	end
end

local function SetItemRef(link)
	local type, value = link:match("(%a+):(.+)")
	if type == "spell" then
		TooltipAddSpellID(ItemRefTooltip, value:match("([^:]+)"))
	end
end

local function SetUnitBuff(self, ...)
	TooltipAddSpellID(self, select(10, UnitBuff(...)))
end

local function SetUnitDebuff(self, ...)
	TooltipAddSpellID(self, select(10, UnitDebuff(...)))
end

local function SetUnitAura(self, ...)
	TooltipAddSpellID(self, select(10, UnitAura(...)))
end

local function OnTooltipSetSpell(self)
	local _, id = self:GetSpell()
	if not id then
		return
	end

	TooltipAddSpellID(self, id)
end

local function SetTooltipSpellID()
	if not cfg.showSpellID then
		return
	end

	hooksecurefunc("SetItemRef", SetItemRef)
	hooksecurefunc(GameTooltip, "SetUnitBuff", SetUnitBuff)
	hooksecurefunc(GameTooltip, "SetUnitDebuff", SetUnitDebuff)
	hooksecurefunc(GameTooltip, "SetUnitAura", SetUnitAura)
	GameTooltip:HookScript("OnTooltipSetSpell", OnTooltipSetSpell)
end

-----------------------------
-- Init
-----------------------------

if not C.settings.tooltip then
	return
end

StyleTooltips()

SetTooltipFonts()

SetColors()

SetTooltipStatusBar()

SetTooltipSpellID()

-- Hooks

hooksecurefunc("GameTooltip_SetDefaultAnchor", SetDefaultAnchor)
hooksecurefunc("SharedTooltip_SetBackdropStyle", SetBackdropStyle)
hooksecurefunc(GameTooltipStatusBar, "SetStatusBarColor", SetStatusBarColor)
GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)
