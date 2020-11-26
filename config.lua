local A, ns = ...

local L, C, G = unpack(select(2, ...))

-- ------------------------------------------------------------------------
-- > Your configuration here (will override the defaults.lua settings)
-- ------------------------------------------------------------------------

-- Important: Override each property individually or copy all the defaults

-- Example: Disable a LumUI module
-- C.settings.actionbar = false

-- local actionBars = {
--   buttonSize = 33,
--   buttonMargin = 3,
--   padding = 2,
--   keybindsAlpha = 1,
--   macroTextAlpha = 0,
--   fader = {
--     fadeInAlpha = 1,
--     fadeInDuration = 0.2,
--     fadeInSmooth = "OUT",
--     fadeOutAlpha = 0,
--     fadeOutDuration = 0.2,
--     fadeOutSmooth = "OUT"
--   }
-- }

-- Example: Compact UI
-- C.settings.stats.width = 430
-- C.settings.actionBars.bar1.framePoint = {"BOTTOM", UIParent, "BOTTOM", 0, 22}
-- C.settings.actionBars.bar2.framePoint = {"BOTTOM", A .. "Bar1", "TOP", 0, 0}
-- C.settings.actionBars.bar3.framePoint = {"BOTTOM", A .. "Bar2", "TOP", 0, 0}
-- C.settings.actionBars.bar3.startPoint = "BOTTOMLEFT"
-- C.settings.actionBars.bar3.numCols = 12
-- C.settings.actionBars.stancebar.framePoint = {"BOTTOMLEFT", A .. "Bar3", "TOPLEFT", 1, 7}
-- C.settings.actionBars.petbar.framePoint = {"BOTTOMRIGHT", A .. "Bar3", "TOPRIGHT", -1, 7}

-- Example: Set the Minimap to the top right
-- local AurasbuffSize = 30
-- local AurasPosX = -20
-- local AurasPosY = 4

-- C.settings.minimap.parentPoint = "TOPRIGHT"
-- C.settings.minimap.point = "TOPRIGHT"
-- C.settings.minimap.posX = -20
-- C.settings.minimap.posY = -20
-- C.settings.minimap.questTrackerPosX = -64
-- C.settings.minimap.questTrackerPosY = -300
-- C.settings.auras.buffAnchor = {"TOPRIGHT", "Minimap", "TOPLEFT", AurasPosX, AurasPosY}
-- C.settings.auras.buffAnchor2ndRow = {"TOPRIGHT", "Minimap", "TOPLEFT", AurasPosX, AurasPosY - AurasbuffSize - 20}
-- C.settings.auras.debuffAnchor = {"BOTTOMRIGHT", "Minimap", "BOTTOMLEFT", AurasPosX, -AurasPosY}

-- ------------------------------------------------------------------------
