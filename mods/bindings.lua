-- -------------------------
-- Keybindings (Credits: p3lim)
-- -------------------------

local addon, ns = ...

local L, C, G = unpack(select(2, ...))

local b = CreateFrame("Frame")

b:SetScript(
	"OnEvent",
	function(self, event, ...)
		b[event](self, ...)
	end
)

-- Virtual Buttons
CreateFrame("Button", addon .. "ReloadButton"):SetScript("OnClick", ReloadUI)
CreateFrame("Button", addon .. "SummonRandomMount"):SetScript(
	"OnClick",
	function()
		C_MountJournal.SummonByID(0)
	end
)

-- Mount
local YakID = 0 -- Fallback to Random Mounts
for i, v in pairs(C_MountJournal.GetMountIDs()) do
	if C_MountJournal.GetMountInfoByID(v) == "Grand Expedition Yak" then
		YakID = v
	end
end
CreateFrame("Button", addon .. "SummonYak"):SetScript(
	"OnClick",
	function()
		C_MountJournal.SummonByID(YakID)
	end
)

-- Hearthstone
local toys = {}
local hearthstoneToys = {
	93672, -- Dark Portal
	54452, -- Ethereal Portal
	142542, -- Tome of Town Portal
	64488, -- The Innkeeper's Daughter
	163045, -- Headless Horeseman's Hearthstone
	162973, -- Greatfather Winter's Hearthstone
	165669, -- Lunar Elder's Hearthstone
	166747, -- Brewfest Reveler's Hearthstone
	166746, -- Fire Eater's Hearthstone
	168907, -- Holographic Digitalization Hearthstone
	165802, -- Noble Gardener's Hearthstone
	165670, -- Peddlefeet's Lovely Hearthstone
	172179 -- Eternal Traveler's Hearthstone
}

local Button = CreateFrame("Button", addon .. "HearthstoneButton", nil, "SecureActionButtonTemplate")
Button:SetAttribute("type", "macro")
Button:SetScript(
	"PreClick",
	function()
		if (InCombatLockdown()) then
			return
		end

		table.wipe(toys)
		for _, itemID in next, hearthstoneToys do
			if (PlayerHasToy(itemID)) then
				table.insert(toys, itemID)
			end
		end

		if (#toys > 0) then
			-- /castrandom is broken, has been for years
			-- Pick a random toy
			Button:SetAttribute("macrotext", "/cast item:" .. toys[math.random(#toys)])
		else
			-- Hearthstone
			Button:SetAttribute("macrotext", "/cast item:" .. 6948)
		end
	end
)

-- Bind keys
function b:PLAYER_LOGIN()
	-- Keybinds
	SetBinding("END", "DISMOUNT") -- Dismount

	-- Buttons
	SetBindingClick("ALT-w", addon .. "SummonRandomMount") -- Summon Random Mount
	SetBindingClick("ALT-x", addon .. "SummonYak") -- Summon Grand Expedition Yak
	SetBindingClick("HOME", addon .. "HearthstoneButton") -- Hearthstone
	SetBindingClick("F12", addon .. "ReloadButton") -- Reload UI

	-- Spells
	SetBindingSpell("ALT-`", GetSpellInfo(131474)) -- Fishing
	SetBindingSpell("CTRL-`", GetSpellInfo(80451)) -- Survey (Archaelogy)
end

b:RegisterEvent("PLAYER_LOGIN")
