local A, ns = ...

local L, C, G = unpack(select(2, ...))

C.color = {
  bg = {r = 0, g = 0, b = 0, a = 0.8}, -- background color
  border = {r = 0.1, g = 0.1, b = 0.1, a = 1} -- default border color
}

-- Default Settings
C.settings = {
  -- Mods
  actionbar = true,
  buttons = true,
  combatText = true,
  tooltip = true,
  tweaks = true,
  -- Elements
  cooldownsCount = true,
  cooldownsPulse = true,
  stats = {
    enable = true,
    showFPS = true,
    showLag = true,
    showMail = true,
    showBags = true,
    showDurability = true,
    showTalentSpec = true,
    width = 646,
    height = 24,
    fontSize = 12,
    classColored = true,
    textColor = {r = 0.92, g = 0.92, b = 0.92, a = 1},
    fontShadow = true,
    clock24 = true
  }
}

-- Minimap

C.settings.minimap = {
  enabled = true,
  width = 200, -- Minimap Width
  height = 200, -- Minimap Height
  scale = 1.0, -- Minimap Scale
  font = G.font, -- Font type
  fontSize = 14, -- Font Size
  fontOutline = "THINOUTLINE", -- Font Outline
  parent = "UIParent", -- Minimap Parent
  parentPoint = "BOTTOMRIGHT", -- Minimap Anchor
  point = "BOTTOMRIGHT", -- Minimap Set Point
  posX = -20, -- Minimap Horizontal Position
  posY = 38, -- Minimap Vertical Position
  showZone = true, -- Shows the Zone Location
  pvpColor = true, -- Colors the Location zone based on zone pvp info
  locationTextOnHover = false, -- Location text is hidden, shows on mouse hover
  clockOnHover = true, -- Clock is hidden, shows on mouse hover
  customizeQuestTracker = true, -- Move and customize the quest tracker frame
  questTrackerAnchor = "TOPRIGHT", -- Quest Tracker anchor point
  questTrackerAnchorParent = "TOPRIGHT", -- Quest Tracker parent anchor point
  questTrackerPosX = -64, -- Quest Tracker Horizontal Position
  questTrackerPosY = -52 -- Quest Tracker Vertical Position
}

-- Auras
local AurasbuffSize = 30
local AurasPosX = -20
local AurasPosY = -4

C.settings.auras = {
  enabled = true,
  font = G.font,
  shadow_tex = G.media.glow,
  border_tex = G.media.buffsBorder,
  outline = "THINOUTLINE", -- Font Outline
  borderColor = C.color.border, -- Default Border Color
  scale = 1,
  buffSize = AurasbuffSize, -- Size of the Buff Icons
  debuffSize = 30, -- Size of the Debuff Icons
  iconsPerRow = 12, -- Number of Icons per Row
  iconSpacing = 8, -- Spacing between buffs
  iconborder = 3, -- Icon Texture Border Size
  shadowAlpha = 0.5, -- The Alpha of The buttons shadow
  buffAnchor = {"BOTTOMRIGHT", "Minimap", "BOTTOMLEFT", AurasPosX, AurasPosY},
  buffAnchor2ndRow = {"BOTTOMRIGHT", "Minimap", "BOTTOMLEFT", AurasPosX, AurasPosY + AurasbuffSize + 20},
  debuffAnchor = {"BOTTOMRIGHT", "Minimap", "TOPRIGHT", 4, 28}
}

-- Action Bar

local actionBars = {
  buttonSize = 33,
  buttonMargin = 3,
  padding = 2,
  keybindsAlpha = 0,
  macroTextAlpha = 0,
  fader = {
    fadeInAlpha = 1,
    fadeInDuration = 0.2,
    fadeInSmooth = "OUT",
    fadeOutAlpha = 0,
    fadeOutDuration = 0.2,
    fadeOutSmooth = "OUT"
  }
}

-- Bags
-- Main Actionbar
actionBars.bar1 = {
  framePoint = {"BOTTOM", UIParent, "BOTTOM", -108, 22}, -- {"BOTTOM", UIParent, "BOTTOM", 0, 22},
  frameScale = 1,
  framePadding = actionBars.padding,
  buttonWidth = actionBars.buttonSize,
  buttonHeight = actionBars.buttonSize,
  buttonMargin = actionBars.buttonMargin,
  numCols = 12,
  startPoint = "BOTTOMLEFT",
  fader = nil
}

-- MultiActionBar Bottom Left
actionBars.bar2 = {
  framePoint = {"BOTTOM", A .. "Bar1", "TOP", 0, 0},
  frameScale = 1,
  framePadding = actionBars.padding,
  buttonWidth = actionBars.buttonSize,
  buttonHeight = actionBars.buttonSize,
  buttonMargin = actionBars.buttonMargin,
  numCols = 12,
  startPoint = "BOTTOMLEFT",
  fader = nil
}

-- MultiActionBar Bottom Right
actionBars.bar3 = {
  framePoint = {"TOPLEFT", A .. "Bar2", "TOPRIGHT", -0.5, 0},
  frameScale = 1,
  framePadding = actionBars.padding,
  buttonWidth = actionBars.buttonSize,
  buttonHeight = actionBars.buttonSize,
  buttonMargin = actionBars.buttonMargin,
  numCols = 6,
  startPoint = "TOPLEFT",
  fader = nil
}

-- MultiActionBar Right 1
actionBars.bar4 = {
  framePoint = {"RIGHT", UIParent, "RIGHT", -5, 0},
  frameScale = 1,
  framePadding = actionBars.padding,
  buttonWidth = actionBars.buttonSize,
  buttonHeight = actionBars.buttonSize,
  buttonMargin = actionBars.buttonMargin,
  numCols = 1,
  startPoint = "TOPRIGHT",
  fader = actionBars.fader
}

-- MultiActionBar Right 2
actionBars.bar5 = {
  framePoint = {"RIGHT", A .. "Bar4", "LEFT", 0, 0},
  frameScale = 1,
  framePadding = actionBars.padding,
  buttonWidth = actionBars.buttonSize,
  buttonHeight = actionBars.buttonSize,
  buttonMargin = actionBars.buttonMargin,
  numCols = 1,
  startPoint = "TOPRIGHT",
  fader = actionBars.fader
}

-- StanceBar
actionBars.stancebar = {
  framePoint = {"BOTTOMLEFT", A .. "Bar2", "TOPLEFT", 1, 7},
  frameScale = 0.8,
  framePadding = actionBars.padding,
  buttonWidth = actionBars.buttonSize,
  buttonHeight = actionBars.buttonSize,
  buttonMargin = actionBars.buttonMargin,
  numCols = 12,
  startPoint = "BOTTOMLEFT",
  fader = nil,
  frameVisibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift][nomod] hide; show"
}

-- PetBar
actionBars.petbar = {
  framePoint = {"BOTTOMRIGHT", A .. "Bar3", "TOPRIGHT", -1, 7},
  frameScale = 0.8,
  framePadding = actionBars.padding,
  buttonWidth = actionBars.buttonSize,
  buttonHeight = actionBars.buttonSize,
  buttonMargin = actionBars.buttonMargin,
  numCols = 12,
  startPoint = "BOTTOMLEFT",
  frameVisibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift][channeling] hide; [pet,mod][harm][combat] show; hide"
}

-- ExtraBar
actionBars.extrabar = {
  framePoint = {"BOTTOMRIGHT", A .. "Bar1", "BOTTOMLEFT", -5, 0},
  frameScale = 1,
  framePadding = actionBars.padding,
  buttonWidth = actionBars.buttonSize,
  buttonHeight = actionBars.buttonSize,
  buttonMargin = actionBars.buttonMargin,
  numCols = 1,
  startPoint = "BOTTOMLEFT",
  fader = nil
}

-- VechicleExitBar
actionBars.vehicleexitbar = {
  framePoint = {"BOTTOMLEFT", A .. "Bar1", "BOTTOMRIGHT", 5, 0},
  frameScale = 1,
  framePadding = actionBars.padding,
  buttonWidth = actionBars.buttonSize,
  buttonHeight = actionBars.buttonSize,
  buttonMargin = actionBars.buttonMargin,
  numCols = 1,
  startPoint = "BOTTOMLEFT",
  fader = nil
}

-- PossessExitBar
actionBars.possessexitbar = {
  framePoint = {"BOTTOMLEFT", A .. "Bar1", "BOTTOMRIGHT", 5, 0},
  frameScale = 1,
  framePadding = actionBars.padding,
  buttonWidth = actionBars.buttonSize,
  buttonHeight = actionBars.buttonSize,
  buttonMargin = actionBars.buttonMargin,
  numCols = 1,
  startPoint = "BOTTOMLEFT",
  fader = nil
}

actionBars.bagbar = {
  framePoint = {"TOPRIGHT", UIParent, "TOPRIGHT", -6, -6},
  frameScale = 0.8,
  framePadding = 5,
  buttonWidth = actionBars.buttonSize,
  buttonHeight = actionBars.buttonSize,
  buttonMargin = actionBars.buttonMargin,
  numCols = 6, -- number of buttons per column
  startPoint = "BOTTOMRIGHT", -- start postion of first button: BOTTOMLEFT, TOPLEFT, TOPRIGHT, BOTTOMRIGHT
  fader = actionBars.fader
}

-- Game Menu
actionBars.micromenubar = {
  framePoint = {"TOPLEFT", "UIParent", "TOPLEFT", 8, -8},
  frameScale = 0.8,
  framePadding = 5,
  buttonWidth = 28,
  buttonHeight = 40,
  buttonMargin = 0,
  numCols = 12,
  startPoint = "BOTTOMLEFT",
  fader = actionBars.fader
}

C.settings.actionBars = actionBars
