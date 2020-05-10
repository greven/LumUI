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
  stats = {
    enable = true,
    showFPS = true,
    showLag = true,
    showMail = true,
    showBags = true,
    showDurability = true,
    showTalentSpec = true,
    width = 430,
    height = 24,
    classColored = true,
    fontSize = 12,
    textColor = {r = 0.92, g = 0.92, b = 0.92, a = 1},
    fontShadow = true,
    clock24 = true
  }
}
