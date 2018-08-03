-- --------------------------------------------
-- Credits: Doom_CooldownPulse
-- --------------------------------------------

local _, ns = ...

local L, C, G = unpack(select(2, ...))

-- ---------------------------------
-- > Config
-- ---------------------------------

local size = 36
local posX, posY = 0, 150
local fontSize = 10

local showSpellName = true
local fadeInTime = 0.3
local fadeOutTime = 0.7
local holdTime = 0.1
local maxAlpha = 1.0
local animScale = 1.25

-- Spells to Ignore
local blacklist = {

}

-- Threshold to watch spells (seconds)
local thresholdByClass = {
	DEATHKNIGHT = 10,
	DEMONHUNTER = 5,
	DRUID = 5,
	HUNTER = 5,
	MAGE = 5,
	MONK = 5,
	PALADIN = 5,
	PRIEST = 3,
	ROGUE = 5,
	SHAMAN = 5,
	WARLOCK = 5,
	WARRIOR = 5
}

local threshold = thresholdByClass[G.playerClass] or 3.0

-- ---------------------------------

local cooldowns, animating, watching, ignoredSpells = { }, { }, { }, { }
local GetTime = GetTime

local f = CreateFrame('Frame', 'lumCDA')
f:SetScript('OnEvent', function(self, event, ...) self[event](self, ...) end)

f:SetSize(size, size)
f:SetPoint('CENTER', UIParent,'CENTER', posX, posY)

f.text = L:createText(f, 'ARTWORK', fontSize, 'OUTLINE', 'CENTER')
f.text:SetTextColor(1, 1, 1)
f.text:SetShadowOffset(1,-1)
f.text:SetShadowColor(0, 0, 0, 1)
f.text:SetPoint('TOP', f, 'BOTTOM', 1, -6)

f.icon = f:CreateTexture(nil, 'BACKGROUND')
f.icon:SetTexCoord(.08, .92, .08, .92)
f.icon:SetAllPoints(f)

f.border = L:CreatePanel(true, true, 'lumCDA', 'lumCDA', f:GetWidth() + 6, f:GetHeight() + 6,
	{{'TOPLEFT', f, 'TOPLEFT', -3, 3}}, 32, 8, 0, 0.6)
f.border:Hide()

-- ---------------------------------

-- Utils
local function tcount(tab)
	local n = 0
	for _ in pairs(tab) do
			n = n + 1
	end
	return n
end

local function setIgnoredSpells()
	for i=1, #blacklist do
		ignoredSpells[strtrim(blacklist[i])] = true
	end
end

-- OnUpdate
local elapsed = 0
local runtimer = 0

local function OnUpdate(_, update)
	elapsed = elapsed + update
	if (elapsed > 0.05) then
		for i,v in pairs(watching) do
			if (GetTime() >= v[1] + 0.5) then
				local start, duration, enabled, texture, isPet, name
				if (v[2] == "spell") then
					name = GetSpellInfo(v[3])
					texture = GetSpellTexture(v[3])
					start, duration, enabled = GetSpellCooldown(v[3])
				elseif (v[2] == "item") then
					name = GetItemInfo(i)
					texture = v[3]
					start, duration, enabled = GetItemCooldown(i)
				end

				if ignoredSpells[name] then
						watching[i] = nil
				else
					if (enabled ~= 0) then
							if (duration and duration > threshold and texture) then
									cooldowns[i] = { texture, isPet, name }
							end
					end
					if (not (enabled == 0 and v[2] == "spell")) then
							watching[i] = nil
					end
				end
			end
		end

		for i,v in pairs(cooldowns) do
				local start, duration = GetSpellCooldown(v[3])
				local remaining = start + duration - GetTime()
				if (remaining <= 0) then
						tinsert(animating, {v[1],v[2],v[3]})
						cooldowns[i] = nil
				end
		end

		elapsed = 0
		if (#animating == 0 and tcount(watching) == 0 and tcount(cooldowns) == 0) then
				f:SetScript("OnUpdate", nil)
				return
		end
	end

	if (#animating > 0) then
		runtimer = runtimer + update
		if (runtimer > (fadeInTime + holdTime + fadeOutTime)) then
				tremove(animating,1)
				runtimer = 0
				f.text:SetText(nil)
				f.icon:SetTexture(nil)
				f.icon:SetVertexColor(1,1,1)
				f.border:Hide()
		else
				if (not f.icon:GetTexture()) then
						if (animating[1][3] ~= nil and showSpellName) then
							f.text:SetText(animating[1][3])
						end
						f.icon:SetTexture(animating[1][1])
						f.border:Show()
						if animating[1][2] then
							f.icon:SetVertexColor(unpack({1, 1, 1}))
						end
				end
				local alpha = maxAlpha
				if (runtimer < fadeInTime) then
						alpha = maxAlpha * (runtimer / fadeInTime)
				elseif (runtimer >= fadeInTime + holdTime) then
						alpha = maxAlpha - ( maxAlpha * ((runtimer - holdTime - fadeInTime) / fadeOutTime))
				end
				f:SetAlpha(alpha)
				local scale = size+(size*((animScale-1)*(runtimer/(fadeInTime+holdTime+fadeOutTime))))
				f:SetWidth(scale)
				f:SetHeight(scale)
				f.border:SetWidth(scale + 6)
				f.border:SetHeight(scale + 6)
		end
	end
end

-- Events --
function f:ADDON_LOADED(addon)
	setIgnoredSpells()
	self:UnregisterEvent("ADDON_LOADED")
end
f:RegisterEvent("ADDON_LOADED")

function f:UNIT_SPELLCAST_SUCCEEDED(unit, lineID, spellID)
	if (unit == 'player') then
		watching[spellID] = {GetTime(), 'spell', spellID}
		if (not self:IsMouseEnabled()) then
				self:SetScript("OnUpdate", OnUpdate)
		end
	end
end
f:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')

function f:PLAYER_ENTERING_WORLD()
	local inInstance, instanceType = IsInInstance()
	if (inInstance and instanceType == "arena") then
			self:SetScript("OnUpdate", nil)
			wipe(cooldowns)
			wipe(watching)
	end
end
f:RegisterEvent("PLAYER_ENTERING_WORLD")

hooksecurefunc("UseAction", function(slot)
	local actionType, itemID = GetActionInfo(slot)
	if (actionType == "item") then
			local texture = GetActionTexture(slot)
			watching[itemID] = {GetTime(), "item", texture}
	end
end)

hooksecurefunc("UseInventoryItem", function(slot)
	local itemID = GetInventoryItemID("player", slot)
	if (itemID) then
			local texture = GetInventoryItemTexture("player", slot)
			watching[itemID] = {GetTime(), "item", texture}
	end
end)

hooksecurefunc("UseContainerItem", function(bag, slot)
	local itemID = GetContainerItemID(bag, slot)
	if (itemID) then
			local texture = select(10, GetItemInfo(itemID))
			watching[itemID] = {GetTime(), "item", texture}
	end
end)
