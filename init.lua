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

G.playerName = UnitName("player")
G.playerClass = select(2, UnitClass("player"))

-- Colors
G.classColor = RAID_CLASS_COLORS[G.playerClass] -- Class Colors

-- !ClassColors addon
if (IsAddOnLoaded("!ClassColors") and CUSTOM_CLASS_COLORS) then
  G.classColor = CUSTOM_CLASS_COLORS[G.playerClass]
end

-- Screen size
G.resolution = GetCVar("gxFullscreenResolution")
G.screenheight = tonumber(string.match(G.resolution, "%d+x(%d+)"))
G.screenwidth = tonumber(string.match(G.resolution, "(%d+)x+%d"))
