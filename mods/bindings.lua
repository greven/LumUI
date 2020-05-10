-- -------------------------
-- Keybindings
-- -------------------------

local addon, ns = ...

local L, C, G = unpack(select(2, ...))

local b = CreateFrame("Frame")

b:SetScript('OnEvent', function(self, event, ...)
	b[event](self, ...)
end)

-- Virtual Buttons
CreateFrame('Button', addon .. 'ReloadButton'):SetScript('OnClick', ReloadUI)

-- Bind keys
function b:PLAYER_LOGIN()
	SetBinding('END', 'DISMOUNT')
	SetBindingSpell('CTRL-F', GetSpellInfo(80451)) -- Survey
	SetBindingClick('F12', addon .. 'ReloadButton')
end

b:RegisterEvent("PLAYER_LOGIN")
