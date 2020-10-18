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
  auras = true,
  buttons = true,
  combatText = true,
  minimap = true,
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

-- Action Bar

local actionBars = {
  buttonSize = 33,
  buttonMargin = 3,
  padding = 2,
  fader = {
    fadeInAlpha = 1,
    fadeInDuration = 0.2,
    fadeInSmooth = "OUT",
    fadeOutAlpha = 0,
    fadeOutDuration = 0.2,
    fadeOutSmooth = "OUT"
  }
}

-- actionBars.bar1.framePoint = {"BOTTOM", UIParent, "BOTTOM", 0, 22}
-- actionBars.bar2.framePoint = {"BOTTOM", A .. "Bar1", "TOP", 0, 0}
-- actionBars.petbar.framePoint = {"BOTTOMRIGHT", A .. "Bar2", "TOPRIGHT", 0, 10}

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
  framePoint = {"BOTTOMRIGHT", A .. "Bar1", "BOTTOMLEFT", -8, 10},
  frameScale = 0.8,
  framePadding = actionBars.padding,
  buttonWidth = actionBars.buttonSize,
  buttonHeight = actionBars.buttonSize,
  buttonMargin = actionBars.buttonMargin,
  numCols = 6,
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