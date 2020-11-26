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

-- Functions
local function Round(number, idp)
    idp = idp or 0
    local mult = 10 ^ idp
    return floor(number * mult + .5) / mult
end

-- !ClassColors addon
if (IsAddOnLoaded("!ClassColors") and CUSTOM_CLASS_COLORS) then
    G.classColor = CUSTOM_CLASS_COLORS[G.playerClass]
end

-- Screen Size and UI Scale
G.ScreenWidth, G.ScreenHeight = GetPhysicalScreenSize()
local function GetBestScale()
    local scale = max(.4, min(1.15, 768 / G.ScreenHeight))
    return Round(scale, 2)
end

local pixel = 1
local scale = GetBestScale()
local ratio = 768 / G.ScreenHeight
G.mult = (pixel / scale) - ((pixel - ratio) / scale)

