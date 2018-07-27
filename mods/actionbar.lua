
-- rActionBar_Lum: layout
-- zork, 2016

-- Lumen Bar Layout for rActionBar

-----------------------------
-- Variables
-----------------------------

local A, L = ...

-----------------------------
-- Fader
-----------------------------

local fader = {
  fadeInAlpha = 1,
  fadeInDuration = 0.2,
  fadeInSmooth = "OUT",
  fadeOutAlpha = 0,
  fadeOutDuration = 0.2,
  fadeOutSmooth = "OUT",
}

-----------------------------
-- BagBar
-----------------------------

local bagbar = {
  framePoint      = { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -5, 5 },
  frameScale      = 1,
  framePadding    = 5,
  buttonWidth     = 33,
  buttonHeight    = 33,
  buttonMargin    = 3,
  numCols         = 6, --number of buttons per column
  startPoint      = "BOTTOMRIGHT", --start postion of first button: BOTTOMLEFT, TOPLEFT, TOPRIGHT, BOTTOMRIGHT
  fader           = nil,
}
--create
-- rActionBar:CreateBagBar(A, bagbar)

-----------------------------
-- MicroMenuBar
-----------------------------

local micromenubar = {
  framePoint      = { "TOP", UIParent, "TOP", 0, 0 },
  frameScale      = 0.8,
  framePadding    = 5,
  buttonWidth     = 28,
  buttonHeight    = 40,
  buttonMargin    = 0,
  numCols         = 12,
  startPoint      = "BOTTOMLEFT",
  fader           = fader,
}
--create
rActionBar:CreateMicroMenuBar(A, micromenubar)

-----------------------------
-- Bar1
-----------------------------

local bar1 = {
  framePoint      = { "BOTTOM", UIParent, "BOTTOM", 0, 22 },
  frameScale      = 1,
  framePadding    = 2,
  buttonWidth     = 33,
  buttonHeight    = 33,
  buttonMargin    = 3,
  numCols         = 12,
  startPoint      = "BOTTOMLEFT",
  fader           = nil,
  frameVisibility = "[combat][mod][@target,exists,nodead][@vehicle,exists][overridebar][shapeshift][vehicleui][possessbar] show; hide"
}
--create
rActionBar:CreateActionBar1(A, bar1)

-----------------------------
-- Bar2
-----------------------------

local bar2 = {
  framePoint      = { "BOTTOM", A.."Bar1", "TOP", 0, 0 },
  frameScale      = 1,
  framePadding    = 2,
  buttonWidth     = 33,
  buttonHeight    = 33,
  buttonMargin    = 3,
  numCols         = 12,
  startPoint      = "BOTTOMLEFT",
  fader           = nil,
  frameVisibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; [combat][mod][@target,exists,nodead] show; hide"
}
--create
rActionBar:CreateActionBar2(A, bar2)

-----------------------------
-- Bar3
-----------------------------

local bar3 = {
  framePoint      = { "BOTTOM", A.."Bar2", "TOP", 0, 0 },
  frameScale      = 1,
  framePadding    = 2,
  buttonWidth     = 33,
  buttonHeight    = 33,
  buttonMargin    = 3,
  numCols         = 12,
  startPoint      = "BOTTOMLEFT",
  fader           = nil,
  frameVisibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; [combat][mod][@target,exists,nodead] show; hide"
}
--create
rActionBar:CreateActionBar3(A, bar3)

-----------------------------
-- Bar4
-----------------------------

local bar4 = {
  framePoint      = { "RIGHT", UIParent, "RIGHT", -5, 0 },
  frameScale      = 1,
  framePadding    = 2,
  buttonWidth     = 33,
  buttonHeight    = 33,
  buttonMargin    = 3,
  numCols         = 1,
  startPoint      = "TOPRIGHT",
  fader           = fader,
}
--create
rActionBar:CreateActionBar4(A, bar4)

-----------------------------
-- Bar5
-----------------------------

local bar5 = {
  framePoint      = { "RIGHT", A.."Bar4", "LEFT", 0, 0 },
  frameScale      = 1,
  framePadding    = 2,
  buttonWidth     = 33,
  buttonHeight    = 33,
  buttonMargin    = 3,
  numCols         = 1,
  startPoint      = "TOPRIGHT",
  fader           = fader,
}
--create
rActionBar:CreateActionBar5(A, bar5)

-----------------------------
-- StanceBar
-----------------------------

local stancebar = {
  framePoint      = { "BOTTOM", A.."Bar3", "TOP", 0, 18 },
  frameScale      = 0.8,
  framePadding    = 2,
  buttonWidth     = 33,
  buttonHeight    = 33,
  buttonMargin    = 3,
  numCols         = 12,
  startPoint      = "BOTTOMLEFT",
  fader           = nil,
  frameVisibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift][nomod] hide; show"
}
--create
rActionBar:CreateStanceBar(A, stancebar)

-----------------------------
-- PetBar
-----------------------------

--petbar
local petbar = {
  framePoint      = { "BOTTOM", A.."Bar3", "TOP", 0, 18 },
  frameScale      = 0.8,
  framePadding    = 2,
  buttonWidth     = 33,
  buttonHeight    = 33,
  buttonMargin    = 3,
  numCols         = 12,
  startPoint      = "BOTTOMLEFT",
  fader           = fader,
  frameVisibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; [pet,mod] show; hide"
}
--create
rActionBar:CreatePetBar(A, petbar)

-----------------------------
-- ExtraBar
-----------------------------

local extrabar = {
  framePoint      = { "BOTTOMRIGHT", A.."Bar1", "BOTTOMLEFT", -5, 0 },
  frameScale      = 1,
  framePadding    = 2,
  buttonWidth     = 33,
  buttonHeight    = 33,
  buttonMargin    = 3,
  numCols         = 1,
  startPoint      = "BOTTOMLEFT",
  fader           = nil,
}
--create
rActionBar:CreateExtraBar(A, extrabar)

-----------------------------
-- VehicleExitBar
-----------------------------

local vehicleexitbar = {
  framePoint      = { "BOTTOMLEFT", A.."Bar1", "BOTTOMRIGHT", 5, 0 },
  frameScale      = 1,
  framePadding    = 2,
  buttonWidth     = 33,
  buttonHeight    = 33,
  buttonMargin    = 3,
  numCols         = 1,
  startPoint      = "BOTTOMLEFT",
  fader           = nil,
}
--create
rActionBar:CreateVehicleExitBar(A, vehicleexitbar)

-----------------------------
-- PossessExitBar
-----------------------------

local possessexitbar = {
  framePoint      = { "BOTTOMLEFT", A.."Bar1", "BOTTOMRIGHT", 5, 0 },
  frameScale      = 1,
  framePadding    = 2,
  buttonWidth     = 33,
  buttonHeight    = 33,
  buttonMargin    = 3,
  numCols         = 1,
  startPoint      = "BOTTOMLEFT",
  fader           = nil,
}
--create
rActionBar:CreatePossessExitBar(A, possessexitbar)