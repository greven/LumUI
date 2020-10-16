-- --------------------------------------------
-- > lumUI (Kreoss @ Quel'Thalas EU) <
-- --------------------------------------------

local A, ns = ...

ns[1] = {} -- functions, constants, variables
ns[2] = {} -- config
ns[3] = {} -- globals

local L, C, G = unpack(ns)

L.addonName = A

lumuiDB = {}

G.font = "Interface\\AddOns\\lumUI\\media\\Fonts\\Myriad.ttf"
G.numFont = "Interface\\AddOns\\lumUI\\media\\Fonts\\Expressway.ttf"
G.symbolsFont = "Interface\\AddOns\\lumUI\\media\\Fonts\\FontAwesomeProSolid.otf"
G.symbolsLightFont = "Interface\\AddOns\\lumUI\\media\\Fonts\\FontAwesomeProLight.otf"

G.media = {
  statusbar = "Interface\\AddOns\\lumUI\\media\\Textures\\statusbar",
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
  G.classColor = CUSTOM_CLASS_COLORS[G.playerClass]
end

-- Screen size
G.resolution = GetCVar("gxFullscreenResolution")
G.screenheight = tonumber(string.match(G.resolution, "%d+x(%d+)"))
G.screenwidth = tonumber(string.match(G.resolution, "(%d+)x+%d"))
