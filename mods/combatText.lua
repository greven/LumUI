-- ------------------------------------------------------------------------
-- Credits: zork.
-- ------------------------------------------------------------------------

local _, ns = ...

local L, C, G = unpack(select(2, ...))

local font = G.font
local fontSize = 22
local startY = 325
local endY = 500
local scrollSpeed = 2.5

CombatTextFont:SetFont(font, fontSize, "OUTLINE")
CombatTextFont:SetShadowOffset(1,-1)
CombatTextFont:SetShadowColor(0,0,0,0.5)

CombatTextFontOutline:SetFont(font, fontSize, "OUTLINE")
CombatTextFontOutline:SetShadowOffset(1,-1)
CombatTextFontOutline:SetShadowColor(0,0,0,0.5)

COMBAT_TEXT_HEIGHT = fontSize
COMBAT_TEXT_CRIT_MAXHEIGHT = fontSize*1.1
COMBAT_TEXT_CRIT_MINHEIGHT = fontSize*1.1
COMBAT_TEXT_SCROLLSPEED = scrollSpeed

local function UpdateDisplayMessages()
  if COMBAT_TEXT_FLOAT_MODE == "1" then
    COMBAT_TEXT_LOCATIONS.startY = startY or 325
    COMBAT_TEXT_LOCATIONS.endY = endY or 525
  end
end

hooksecurefunc("CombatText_UpdateDisplayedMessages", UpdateDisplayMessages)

-- Set the Font
DAMAGE_TEXT_FONT = font

--Login
local function Login()
  DAMAGE_TEXT_FONT = font
end

-- Callback PLAYER_LOGIN
L:RegisterCallback("PLAYER_LOGIN", Login)