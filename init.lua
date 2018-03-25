-- --------------------------------------------
-- > lumUI (Kreoss @ Quel'Thalas EU) <
-- --------------------------------------------

local _, ns = ...

ns[1] = {} -- functions, constants, variables
ns[2] = {} -- config
ns[3] = {} -- globals

local L, C, G = unpack(select(2, ...))

G.font = "Interface\\AddOns\\lumUI\\media\\Fonts\\Myriad.ttf"
G.numFont = "Interface\\AddOns\\lumUI\\media\\Fonts\\Expressway.ttf"

G.media = {
  bg = "Interface\\AddOns\\lumUI\\media\\Textures\\background_flat",
	border = "Interface\\AddOns\\lumUI\\media\\Textures\\border_squared",
  glow = "Interface\\AddOns\\lumUI\\media\\Textures\\texture_glow",
  buffsBorder = "Interface\\AddOns\\lumUI\\media\\Textures\\border_buffs"
}

G.playerName = UnitName("player")
G.playerClass = select(2, UnitClass("player"))

-- Colors
G.classColor = RAID_CLASS_COLORS[G.playerClass] -- Class Colors

-- !ClassColors addon
if(IsAddOnLoaded('!ClassColors') and CUSTOM_CLASS_COLORS) then
  G.cColor = CUSTOM_CLASS_COLORS[G.playerClass]
end