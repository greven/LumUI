local _, ns = ...

local L, C, G = unpack(select(2, ...))

C.color = {
  bg = {r = 0, g = 0, b = 0, a = 0.8}, -- background color
  border = {r = 0.3, g = 0.3, b = 0.3, a = 1} -- default border color
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
  stats = true
}
