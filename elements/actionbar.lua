-- rActionBar: core
-- zork, 2016

-----------------------------
-- Variables
-----------------------------

local A, ns = ...
local L, C, G = unpack(ns)

local settings = C.settings
local _G = _G

L.dragFrames = {}

local cfg = {}

local hiddenFrame = CreateFrame("Frame")
hiddenFrame:Hide()

local scripts = {
  "OnShow",
  "OnHide",
  "OnEvent",
  "OnEnter",
  "OnLeave",
  "OnUpdate",
  "OnValueChanged",
  "OnClick",
  "OnMouseDown",
  "OnMouseUp"
}

local framesToHide = {
  MainMenuBar,
  OverrideActionBar
}

local framesToDisable = {
  MainMenuBar,
  MicroButtonAndBagsBar,
  MainMenuBarArtFrame,
  StatusTrackingBarManager,
  ActionBarDownButton,
  ActionBarUpButton,
  MainMenuBarVehicleLeaveButton,
  OverrideActionBar,
  OverrideActionBarExpBar,
  OverrideActionBarHealthBar,
  OverrideActionBarPowerBar,
  OverrideActionBarPitchFrame
}

local keyButton = gsub(KEY_BUTTON4, "%d", "")
local keyNumpad = gsub(KEY_NUMPAD1, "%d", "")

local keysText = {
  {"(" .. keyButton .. ")", "M"},
  {"(" .. keyNumpad .. ")", "N"},
  {"(a%-)", "A"},
  {"(c%-)", "C"},
  {"(s%-)", "S"},
  {KEY_BUTTON3, "M3"},
  {KEY_MOUSEWHEELUP, "MU"},
  {KEY_MOUSEWHEELDOWN, "MD"},
  {KEY_SPACE, "Sp"},
  {CAPSLOCK_KEY_TEXT, "CL"},
  {"BUTTON", "M"},
  {"NUMPAD", "N"},
  {"(ALT%-)", "A"},
  {"(CTRL%-)", "C"},
  {"(SHIFT%-)", "S"},
  {"MOUSEWHEELUP", "MU"},
  {"MOUSEWHEELDOWN", "MD"},
  {"SPACE", "Sp"},
  {"PAGEUP", "PU"},
  {"PAGEDOWN", "PD"}
}

-----------------------------
-- rActionBar Global
-----------------------------

rActionBar = {}
rActionBar.addonName = A
rActionBar.addonShortcut = "rab"
rActionBar.addonColor = "0000FF00"

-----------------------------
-- Functions
-----------------------------

-- DisableAllScripts
local function DisableAllScripts(frame)
  for i, script in next, scripts do
    if frame:HasScript(script) then
      frame:SetScript(script, nil)
    end
  end
end

-- L:HideMainMenuBar
function L:HideMainMenuBar()
  -- bring back the currency
  local function OnEvent(self, event)
    TokenFrame_LoadUI()
    TokenFrame_Update()
    BackpackTokenFrame_Update()
  end
  hiddenFrame:SetScript("OnEvent", OnEvent)
  hiddenFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
  for i, frame in next, framesToHide do
    frame:SetParent(hiddenFrame)
  end
  for i, frame in next, framesToDisable do
    frame:UnregisterAllEvents()
    DisableAllScripts(frame)
  end
end

-- fix blizzard cooldown flash
local function FixCooldownFlash(self)
  if not self then
    return
  end
  if self:GetEffectiveAlpha() > 0 then
    self:Show()
  else
    self:Hide()
  end
end
hooksecurefunc(getmetatable(ActionButton1Cooldown).__index, "SetCooldown", FixCooldownFlash)

-- Core

function L:UpdateHotKey()
  local hotkey = _G[self:GetName() .. "HotKey"]
  local text = hotkey:GetText()

  if not text then
    return
  end

  for _, value in pairs(keysText) do
    text = gsub(text, value[1], value[2])
  end

  if text == RANGE_INDICATOR then
    hotkey:SetText("")
  else
    hotkey:SetText(text)
  end
end

function L:HookHotKey(button)
  L.UpdateHotKey(button)
  if button.UpdateHotkeys then
    hooksecurefunc(button, "UpdateHotkeys", L.UpdateHotKey)
  end
end

function L:GetButtonList(buttonName, numButtons)
  local buttonList = {}
  for i = 1, numButtons do
    local button = _G[buttonName .. i]
    if not button then
      break
    end
    table.insert(buttonList, button)
  end
  return buttonList
end

--points
--1. p1, f, fp1, fp2
--2. p2, rb-1, p3, bm1, bm2
--3. p4, b-1, p5, bm3, bm4
local function SetupButtonPoints(frame, buttonList, buttonWidth, buttonHeight, numCols, p1, fp1, fp2, p2, p3, bm1, bm2, p4, p5, bm3, bm4)
  for index, button in next, buttonList do
    if not frame.__blizzardBar then
      button:SetParent(frame)
    end
    button:SetSize(buttonWidth, buttonHeight)
    button:ClearAllPoints()
    if index == 1 then
      button:SetPoint(p1, frame, fp1, fp2)
    elseif numCols == 1 or mod(index, numCols) == 1 then
      button:SetPoint(p2, buttonList[index - numCols], p3, bm1, bm2)
    else
      button:SetPoint(p4, buttonList[index - 1], p5, bm3, bm4)
    end
  end
end

local function SetupButtonFrame(frame, framePadding, buttonList, buttonWidth, buttonHeight, buttonMargin, numCols, startPoint)
  local numButtons = #buttonList
  numCols = min(numButtons, numCols)
  local numRows = ceil(numButtons / numCols)
  local frameWidth = numCols * buttonWidth + (numCols - 1) * buttonMargin + 2 * framePadding
  local frameHeight = numRows * buttonHeight + (numRows - 1) * buttonMargin + 2 * framePadding
  frame:SetSize(frameWidth, frameHeight)
  -- TOPLEFT
  -- 1. TL, f, p, -p
  -- 2. T, rb-1, B, 0, -m
  -- 3. L, b-1, R, m, 0
  if startPoint == "TOPLEFT" then
    -- end
    -- TOPRIGHT
    -- 1. TR, f, -p, -p
    -- 2. T, rb-1, B, 0, -m
    -- 3. R, b-1, L, -m, 0
    SetupButtonPoints(
      frame,
      buttonList,
      buttonWidth,
      buttonHeight,
      numCols,
      startPoint,
      framePadding,
      -framePadding,
      "TOP",
      "BOTTOM",
      0,
      -buttonMargin - 1, -- FIX Subtract 1 so spacing is consistent
      "LEFT",
      "RIGHT",
      buttonMargin,
      0
    )
  elseif startPoint == "TOPRIGHT" then
    -- end
    -- BOTTOMRIGHT
    -- 1. BR, f, -p, p
    -- 2. B, rb-1, T, 0, m
    -- 3. R, b-1, L, -m, 0
    SetupButtonPoints(
      frame,
      buttonList,
      buttonWidth,
      buttonHeight,
      numCols,
      startPoint,
      -framePadding,
      -framePadding,
      "TOP",
      "BOTTOM",
      0,
      -buttonMargin,
      "RIGHT",
      "LEFT",
      -buttonMargin,
      0
    )
  elseif startPoint == "BOTTOMRIGHT" then
    -- end
    -- BOTTOMLEFT
    -- 1. BL, f, p, p
    -- 2. B, rb-1, T, 0, m
    -- 3. L, b-1, R, m, 0
    -- elseif startPoint == "BOTTOMLEFT" then
    SetupButtonPoints(
      frame,
      buttonList,
      buttonWidth,
      buttonHeight,
      numCols,
      startPoint,
      -framePadding,
      framePadding,
      "BOTTOM",
      "TOP",
      0,
      buttonMargin,
      "RIGHT",
      "LEFT",
      -buttonMargin,
      0
    )
  else
    startPoint = "BOTTOMLEFT"
    SetupButtonPoints(
      frame,
      buttonList,
      buttonWidth,
      buttonHeight,
      numCols,
      startPoint,
      framePadding,
      framePadding,
      "BOTTOM",
      "TOP",
      0,
      buttonMargin,
      "LEFT",
      "RIGHT",
      buttonMargin,
      0
    )
  end
end

function L:CreateButtonFrame(cfg, buttonList, delaySetup)
  -- create new parent frame for buttons
  local frame = CreateFrame("Frame", cfg.frameName, cfg.frameParent, cfg.frameTemplate)
  frame:SetPoint(unpack(cfg.framePoint))
  frame:SetScale(cfg.frameScale)
  frame.__blizzardBar = cfg.blizzardBar
  if delaySetup then
    local function OnLogin(...)
      SetupButtonFrame(frame, cfg.framePadding, buttonList, cfg.buttonWidth, cfg.buttonHeight, cfg.buttonMargin, cfg.numCols, cfg.startPoint)
    end
    L:RegisterCallback("PLAYER_LOGIN", OnLogin)
  else
    SetupButtonFrame(frame, cfg.framePadding, buttonList, cfg.buttonWidth, cfg.buttonHeight, cfg.buttonMargin, cfg.numCols, cfg.startPoint)
  end
  -- reparent the Blizzard bar
  if cfg.blizzardBar then
    cfg.blizzardBar:SetParent(frame)
    cfg.blizzardBar:EnableMouse(false)
  end
  -- show/hide the frame on a given state driver
  if cfg.frameVisibility then
    frame.frameVisibility = cfg.frameVisibility
    frame.frameVisibilityFunc = cfg.frameVisibilityFunc
    RegisterStateDriver(frame, cfg.frameVisibilityFunc or "visibility", cfg.frameVisibility)
  end
  -- add drag functions
  L:CreateDragFrame(frame, L.dragFrames, -2, true)
  -- hover animation
  if cfg.fader then
    L:CreateButtonFrameFader(frame, buttonList, cfg.fader)
  end
  return frame
end

-- create slash commands
L:CreateSlashCmd(L.addonName, rActionBar.addonShortcut, L.dragFrames, rActionBar.addonColor)

-- ------
-- Bars
-- ------

local function buttonShowGrid(name, showgrid)
  for i = 1, 12 do
    local button = _G[name .. i]
    if button then
      button:SetAttribute("showgrid", showgrid)
      button:ShowGrid(ACTION_BUTTON_SHOW_GRID_REASON_CVAR)
    end
  end
end

local function ToggleButtonGrid()
  if InCombatLockdown() then
    print("Grid toggle for actionbar1 is not possible in combat.")
    return
  end

  local showgrid = tonumber(GetCVar("alwaysShowActionBars"))
  buttonShowGrid("ActionButton", showgrid)
  buttonShowGrid("MultiBarBottomRightButton", showgrid)
  buttonShowGrid("NDui_CustomBarButton", showgrid)
  if updateAfterCombat then
    B:UnregisterEvent("PLAYER_REGEN_ENABLED", toggleButtonGrid)
    updateAfterCombat = false
  end
end

-- Bar1
function L:CreateActionBar1(addonName, cfg)
  L:HideMainMenuBar()
  cfg.blizzardBar = nil
  cfg.frameName = addonName .. "Bar1"
  cfg.frameParent = cfg.frameParent or UIParent
  cfg.frameTemplate = "SecureHandlerStateTemplate"
  cfg.frameVisibility = cfg.frameVisibility or "[petbattle] hide; show"
  cfg.actionPage =
    cfg.actionPage or
    "[bar:6]6;[bar:5]5;[bar:4]4;[bar:3]3;[bar:2]2;[overridebar]14;[shapeshift]13;[vehicleui]12;[possessbar]12;[bonusbar:5]11;[bonusbar:4]10;[bonusbar:3]9;[bonusbar:2]8;[bonusbar:1]7;1"
  local buttonName = "ActionButton"
  local numButtons = NUM_ACTIONBAR_BUTTONS
  local buttonList = L:GetButtonList(buttonName, numButtons)
  local frame = L:CreateButtonFrame(cfg, buttonList)

  hooksecurefunc("MultiActionBar_UpdateGridVisibility", ToggleButtonGrid)

  for i, button in next, buttonList do
    frame:SetFrameRef(buttonName .. i, button)
  end
  frame:Execute(([[
    buttons = table.new()
    for i=1, %d do
      table.insert(buttons, self:GetFrameRef("%s"..i))
    end
  ]]):format(numButtons, buttonName))
  frame:SetAttribute(
    "_onstate-page",
    [[
    --print("_onstate-page","index",newstate)
    for i, button in next, buttons do
      button:SetAttribute("actionpage", newstate)
    end
  ]]
  )
  RegisterStateDriver(frame, "page", cfg.actionPage)
end

-- Bar2
function L:CreateActionBar2(addonName, cfg)
  cfg.blizzardBar = MultiBarBottomLeft
  cfg.frameName = addonName .. "Bar2"
  cfg.frameParent = cfg.frameParent or UIParent
  cfg.frameTemplate = "SecureHandlerStateTemplate"
  cfg.frameVisibility = cfg.frameVisibility or "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; show"
  local buttonName = "MultiBarBottomLeftButton"
  local numButtons = NUM_ACTIONBAR_BUTTONS
  local buttonList = L:GetButtonList(buttonName, numButtons)
  local frame = L:CreateButtonFrame(cfg, buttonList)
end

-- Bar3
function L:CreateActionBar3(addonName, cfg)
  cfg.blizzardBar = MultiBarBottomRight
  cfg.frameName = addonName .. "Bar3"
  cfg.frameParent = cfg.frameParent or UIParent
  cfg.frameTemplate = "SecureHandlerStateTemplate"
  cfg.frameVisibility = cfg.frameVisibility or "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; show"
  local buttonName = "MultiBarBottomRightButton"
  local numButtons = NUM_ACTIONBAR_BUTTONS
  local buttonList = L:GetButtonList(buttonName, numButtons)
  local frame = L:CreateButtonFrame(cfg, buttonList)
end

-- Bar4
function L:CreateActionBar4(addonName, cfg)
  cfg.blizzardBar = MultiBarRight
  cfg.frameName = addonName .. "Bar4"
  cfg.frameParent = cfg.frameParent or UIParent
  cfg.frameTemplate = "SecureHandlerStateTemplate"
  cfg.frameVisibility = cfg.frameVisibility or "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; show"
  local buttonName = "MultiBarRightButton"
  local numButtons = NUM_ACTIONBAR_BUTTONS
  local buttonList = L:GetButtonList(buttonName, numButtons)
  local frame = L:CreateButtonFrame(cfg, buttonList)
end

-- Bar5
function L:CreateActionBar5(addonName, cfg)
  cfg.blizzardBar = MultiBarLeft
  cfg.frameName = addonName .. "Bar5"
  cfg.frameParent = cfg.frameParent or UIParent
  cfg.frameTemplate = "SecureHandlerStateTemplate"
  cfg.frameVisibility = cfg.frameVisibility or "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; show"
  local buttonName = "MultiBarLeftButton"
  local numButtons = NUM_ACTIONBAR_BUTTONS
  local buttonList = L:GetButtonList(buttonName, numButtons)
  local frame = L:CreateButtonFrame(cfg, buttonList)
end

-- StanceBar
function L:CreateStanceBar(addonName, cfg)
  cfg.blizzardBar = StanceBarFrame
  cfg.frameName = addonName .. "StanceBar"
  cfg.frameParent = cfg.frameParent or UIParent
  cfg.frameTemplate = "SecureHandlerStateTemplate"
  cfg.frameVisibility = cfg.frameVisibility or "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; show"
  local buttonName = "StanceButton"
  local numButtons = NUM_STANCE_SLOTS
  local buttonList = L:GetButtonList(buttonName, numButtons)
  local frame = L:CreateButtonFrame(cfg, buttonList)
  --special
  StanceBarLeft:SetTexture(nil)
  StanceBarMiddle:SetTexture(nil)
  StanceBarRight:SetTexture(nil)
end

-- PetBar
function L:CreatePetBar(addonName, cfg)
  cfg.blizzardBar = PetActionBarFrame
  cfg.frameName = addonName .. "PetBar"
  cfg.frameParent = cfg.frameParent or UIParent
  cfg.frameTemplate = "SecureHandlerStateTemplate"
  cfg.frameVisibility = cfg.frameVisibility or "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; [pet] show; hide"
  local buttonName = "PetActionButton"
  local numButtons = NUM_PET_ACTION_SLOTS
  local buttonList = L:GetButtonList(buttonName, numButtons)
  local frame = L:CreateButtonFrame(cfg, buttonList)
  --special
  SlidingActionBarTexture0:SetTexture(nil)
  SlidingActionBarTexture1:SetTexture(nil)
end

-- ExtraBar
function L:CreateExtraBar(addonName, cfg)
  cfg.blizzardBar = ExtraActionBarFrame
  cfg.frameName = addonName .. "ExtraBar"
  cfg.frameParent = cfg.frameParent or UIParent
  cfg.frameTemplate = "SecureHandlerStateTemplate"
  cfg.frameVisibility = cfg.frameVisibility or "[extrabar] show; hide"
  local buttonName = "ExtraActionButton"
  local numButtons = NUM_ACTIONBAR_BUTTONS
  local buttonList = L:GetButtonList(buttonName, numButtons)
  local frame = L:CreateButtonFrame(cfg, buttonList)
  --special
  ExtraActionBarFrame.ignoreFramePositionManager = true
end

-- VehicleExitBar
function L:CreateVehicleExitBar(addonName, cfg)
  cfg.blizzardBar = nil
  cfg.frameName = addonName .. "VehicleExitBar"
  cfg.frameParent = cfg.frameParent or UIParent
  cfg.frameTemplate = "SecureHandlerStateTemplate"
  cfg.frameVisibility = cfg.frameVisibility or "[canexitvehicle]c;[mounted]m;n"
  cfg.frameVisibilityFunc = "exit"
  --create vehicle exit button
  local button = CreateFrame("CHECKBUTTON", A .. "VehicleExitButton", nil, "ActionButtonTemplate, SecureHandlerClickTemplate")
  button.icon:SetTexture("interface\\addons\\" .. A .. "\\media\\Textures\\vehicleexit")
  button:RegisterForClicks("AnyUp")
  local function OnClick(self)
    if UnitOnTaxi("player") then
      TaxiRequestEarlyLanding()
    else
      VehicleExit()
    end
    self:SetChecked(false)
  end
  button:SetScript("OnClick", OnClick)
  local buttonList = {button}
  local frame = L:CreateButtonFrame(cfg, buttonList)
  --[canexitvehicle] is not triggered on taxi, exit workaround
  frame:SetAttribute("_onstate-exit", [[ if CanExitVehicle() then self:Show() else self:Hide() end ]])
  if not CanExitVehicle() then
    frame:Hide()
  end
end

-- PossessExitBar, this is the two button bar to cancel a possess in progress
function L:CreatePossessExitBar(addonName, cfg)
  cfg.blizzardBar = PossessBarFrame
  cfg.frameName = addonName .. "PossessExitBar"
  cfg.frameParent = cfg.frameParent or UIParent
  cfg.frameTemplate = "SecureHandlerStateTemplate"
  cfg.frameVisibility = cfg.frameVisibility or "[possessbar] show; hide"
  local buttonName = "PossessButton"
  local numButtons = NUM_POSSESS_SLOTS
  local buttonList = L:GetButtonList(buttonName, numButtons)
  local frame = L:CreateButtonFrame(cfg, buttonList)
  -- special
  PossessBackground1:SetTexture(nil)
  PossessBackground2:SetTexture(nil)
end

-- BagBar
function L:CreateBagBar(addonName, cfg)
  cfg.blizzardBar = nil
  cfg.frameName = addonName .. "BagBar"
  cfg.frameParent = cfg.frameParent or UIParent
  cfg.frameTemplate = "SecureHandlerStateTemplate"
  cfg.frameVisibility = cfg.frameVisibility or "[petbattle] hide; show"
  local buttonList = {
    MainMenuBarBackpackButton,
    CharacterBag0Slot,
    CharacterBag1Slot,
    CharacterBag2Slot,
    CharacterBag3Slot
  }
  local frame = L:CreateButtonFrame(cfg, buttonList)
end

-- MicroMenuBar
function L:CreateMicroMenuBar(addonName, cfg)
  cfg.blizzardBar = nil
  cfg.frameName = addonName .. "MicroMenuBar"
  cfg.frameParent = cfg.frameParent or UIParent
  cfg.frameTemplate = "SecureHandlerStateTemplate"
  cfg.frameVisibility = cfg.frameVisibility or "[petbattle] hide; show"
  local buttonList = {}
  for idx, buttonName in next, MICRO_BUTTONS do
    local button = _G[buttonName]
    if button and button:IsShown() then
      table.insert(buttonList, button)
    end
  end
  local frame = L:CreateButtonFrame(cfg, buttonList)
  -- special
  PetBattleFrame.BottomFrame.MicroButtonFrame:SetScript("OnShow", nil)
  OverrideActionBar:SetScript("OnShow", nil)
  MainMenuBar:SetScript("OnShow", nil)
end

-----------------------------
-- rButtonTemplate Global
-- rButtonTemplate: core
-----------------------------

rButtonTemplate = {}
rButtonTemplate.addonName = A

-----------------------------
-- Init
-----------------------------

local function CallButtonFunctionByName(button, func, ...)
  if button and func and button[func] then
    button[func](button, ...)
  end
end

local function ResetAlpha(self, a)
  if not self.__alpha then
    return
  end
  if a == self.__alpha then
    return
  end
  self:SetAlpha(self.__alpha)
  print(self:GetName(), a)
end

local function ResetNormalTexture(self, file)
  if not self.__normalTextureFile then
    return
  end
  if file == self.__normalTextureFile then
    return
  end
  self:SetNormalTexture(self.__normalTextureFile)
end

local function ResetTexture(self, file)
  if not self.__textureFile then
    return
  end
  if file == self.__textureFile then
    return
  end
  self:SetTexture(self.__textureFile)
end

local function ResetVertexColor(self, r, g, b, a)
  if not self.__vertexColor then
    return
  end
  local r2, g2, b2, a2 = unpack(self.__vertexColor)
  if not a2 then
    a2 = 1
  end
  if r ~= r2 or g ~= g2 or b ~= b2 or a ~= a2 then
    self:SetVertexColor(r2, g2, b2, a2)
  end
end

local function ApplyPoints(self, points)
  if not points then
    return
  end
  self:ClearAllPoints()
  for i, point in next, points do
    self:SetPoint(unpack(point))
  end
end

local function ApplyTexCoord(texture, texCoord)
  if not texCoord then
    return
  end
  texture:SetTexCoord(unpack(texCoord))
end

local function ApplyBlendMode(texture, blendMode)
  if not blendMode then
    return
  end
  texture:SetBlendMode(blendMode)
end

local function ApplySizeFactor(texture, sizeFactor)
  if not sizeFactor then
    return
  end
  local w, h = texture:GetParent():GetSize()
  texture:SetSize(w * sizeFactor, h * sizeFactor)
end

local function ApplyVertexColor(texture, color)
  if not color then
    return
  end
  texture.__vertexColor = color
  texture:SetVertexColor(unpack(color))
  hooksecurefunc(texture, "SetVertexColor", ResetVertexColor)
end

local function ApplyAlpha(region, alpha)
  if not alpha then
    return
  end
  --region.__alpha = alpha
  region:SetAlpha(alpha)
  --hooksecurefunc(region, "SetAlpha", ResetAlpha)
end

local function ApplyFont(fontString, font)
  if not font then
    return
  end
  fontString:SetFont(unpack(font))
end

local function ApplyHorizontalAlign(fontString, align)
  if not align then
    return
  end
  fontString:SetJustifyH(align)
end

local function ApplyVerticalAlign(fontString, align)
  if not align then
    return
  end
  fontString:SetJustifyV(align)
end

local function ApplyTexture(texture, file)
  if not file then
    return
  end
  texture.__textureFile = file
  texture:SetTexture(file)
  hooksecurefunc(texture, "SetTexture", ResetTexture)
end

local function ApplyNormalTexture(button, file)
  if not file then
    return
  end
  button.__normalTextureFile = file
  button:SetNormalTexture(file)
  hooksecurefunc(button, "SetNormalTexture", ResetNormalTexture)
end

local function SetupTexture(texture, cfg, func, button)
  if not texture or not cfg then
    return
  end

  ApplyTexCoord(texture, cfg.texCoord)
  ApplyBlendMode(texture, cfg.blendMode)
  ApplySizeFactor(texture, cfg.sizeFactor)
  ApplyPoints(texture, cfg.points)
  ApplyVertexColor(texture, cfg.color)
  ApplyAlpha(texture, cfg.alpha)
  if func == "SetTexture" then
    ApplyTexture(texture, cfg.file)
  elseif func == "SetNormalTexture" then
    ApplyNormalTexture(button, cfg.file)
  elseif cfg.file then
    CallButtonFunctionByName(button, func, cfg.file)
  end
end

local function SetupFontString(fontString, cfg)
  if not fontString or not cfg then
    return
  end
  ApplyPoints(fontString, cfg.points)
  ApplyFont(fontString, cfg.font)
  ApplyAlpha(fontString, cfg.alpha)
  ApplyHorizontalAlign(fontString, cfg.halign)
  ApplyVerticalAlign(fontString, cfg.valign)
end

local function SetupCooldown(cooldown, cfg)
  if not cooldown or not cfg then
    return
  end
  cooldown:SetFrameLevel(cooldown:GetParent():GetFrameLevel())
  ApplyPoints(cooldown, cfg.points)
end

local function SetupBackdrop(button, backdrop)
  if not backdrop then
    return
  end
  local bg = CreateFrame("Frame", nil, button, "BackdropTemplate")
  ApplyPoints(bg, backdrop.points)
  bg:SetFrameLevel(button:GetFrameLevel() - 1)
  bg:SetBackdrop(backdrop)
  if backdrop.backgroundColor then
    bg:SetBackdropColor(unpack(backdrop.backgroundColor))
  end
  if backdrop.borderColor then
    bg:SetBackdropBorderColor(unpack(backdrop.borderColor))
  end
end

function rButtonTemplate:StyleActionButton(button, cfg)
  if not button then
    return
  end
  if button.__styled then
    return
  end

  local buttonName = button:GetName()
  local icon = _G[buttonName .. "Icon"]
  local flash = _G[buttonName .. "Flash"]
  local flyoutBorder = _G[buttonName .. "FlyoutBorder"]
  local flyoutBorderShadow = _G[buttonName .. "FlyoutBorderShadow"]
  local flyoutArrow = _G[buttonName .. "FlyoutArrow"]
  local hotkey = _G[buttonName .. "HotKey"]
  local count = _G[buttonName .. "Count"]
  local name = _G[buttonName .. "Name"]
  local border = _G[buttonName .. "Border"]
  local NewActionTexture = button.NewActionTexture
  local cooldown = _G[buttonName .. "Cooldown"]
  local normalTexture = button:GetNormalTexture()
  local pushedTexture = button:GetPushedTexture()
  local highlightTexture = button:GetHighlightTexture()
  -- normal buttons do not have a checked texture, but checkbuttons do and normal actionbuttons are checkbuttons
  local checkedTexture = nil
  if button.GetCheckedTexture then
    checkedTexture = button:GetCheckedTexture()
  end
  local floatingBG = _G[buttonName .. "FloatingBG"]

  -- hide stuff
  if floatingBG then
    floatingBG:Hide()
  end

  -- backdrop
  SetupBackdrop(button, cfg.backdrop)

  -- textures
  SetupTexture(icon, cfg.icon, "SetTexture", icon)
  SetupTexture(flash, cfg.flash, "SetTexture", flash)
  SetupTexture(flyoutBorder, cfg.flyoutBorder, "SetTexture", flyoutBorder)
  SetupTexture(flyoutBorderShadow, cfg.flyoutBorderShadow, "SetTexture", flyoutBorderShadow)
  SetupTexture(border, cfg.border, "SetTexture", border)
  SetupTexture(normalTexture, cfg.normalTexture, "SetNormalTexture", button)
  SetupTexture(pushedTexture, cfg.pushedTexture, "SetPushedTexture", button)
  SetupTexture(highlightTexture, cfg.highlightTexture, "SetHighlightTexture", button)
  SetupTexture(checkedTexture, cfg.checkedTexture, "SetCheckedTexture", button)

  -- cooldown
  SetupCooldown(cooldown, cfg.cooldown)

  -- no clue why but blizzard created count and duration on background layer, need to fix that
  local overlay = CreateFrame("Frame", nil, button)
  overlay:SetAllPoints()

  if count then
    count:SetParent(overlay)
    SetupFontString(count, cfg.count)
  end

  if hotkey then
    hotkey:SetParent(overlay)
    L:HookHotKey(button)
    SetupFontString(hotkey, cfg.hotkey)
  end

  if name then
    name:SetParent(overlay)
    SetupFontString(name, cfg.name)
  end

  button.__styled = true
end

function rButtonTemplate:StyleExtraActionButton(cfg)
  local button = ExtraActionButton1

  if button.__styled then
    return
  end

  local buttonName = button:GetName()

  local icon = _G[buttonName .. "Icon"]
  -- local flash = _G[buttonName.."Flash"] --wierd the template has two textures of the same name
  local hotkey = _G[buttonName .. "HotKey"]
  local count = _G[buttonName .. "Count"]
  local buttonstyle = button.style --artwork around the button
  local cooldown = _G[buttonName .. "Cooldown"]

  local normalTexture = button:GetNormalTexture()
  local pushedTexture = button:GetPushedTexture()
  local highlightTexture = button:GetHighlightTexture()
  local checkedTexture = button:GetCheckedTexture()

  -- backdrop
  SetupBackdrop(button, cfg.backdrop)

  -- textures
  SetupTexture(icon, cfg.icon, "SetTexture", icon)
  SetupTexture(buttonstyle, cfg.buttonstyle, "SetTexture", buttonstyle)
  SetupTexture(normalTexture, cfg.normalTexture, "SetNormalTexture", button)
  SetupTexture(pushedTexture, cfg.pushedTexture, "SetPushedTexture", button)
  SetupTexture(highlightTexture, cfg.highlightTexture, "SetHighlightTexture", button)
  SetupTexture(checkedTexture, cfg.checkedTexture, "SetCheckedTexture", button)

  -- cooldown
  SetupCooldown(cooldown, cfg.cooldown)

  -- hotkey, count
  SetupFontString(hotkey, cfg.hotkey)
  SetupFontString(count, cfg.count)

  button.__styled = true
end

function rButtonTemplate:StyleItemButton(button, cfg)
  if not button then
    return
  end
  if button.__styled then
    return
  end

  local buttonName = button:GetName()
  local icon = _G[buttonName .. "IconTexture"]
  local count = _G[buttonName .. "Count"]
  local stock = _G[buttonName .. "Stock"]
  local searchOverlay = _G[buttonName .. "SearchOverlay"]
  local border = button.IconBorder
  local normalTexture = button:GetNormalTexture()
  local pushedTexture = button:GetPushedTexture()
  local highlightTexture = button:GetHighlightTexture()
  -- local checkedTexture = button:GetCheckedTexture()

  -- backdrop
  SetupBackdrop(button, cfg.backdrop)

  -- textures
  SetupTexture(icon, cfg.icon, "SetTexture", icon)
  SetupTexture(searchOverlay, cfg.searchOverlay, "SetTexture", searchOverlay)
  SetupTexture(border, cfg.border, "SetTexture", border)
  SetupTexture(normalTexture, cfg.normalTexture, "SetNormalTexture", button)
  SetupTexture(pushedTexture, cfg.pushedTexture, "SetPushedTexture", button)
  SetupTexture(highlightTexture, cfg.highlightTexture, "SetHighlightTexture", button)
  SetupTexture(checkedTexture, cfg.checkedTexture, "SetCheckedTexture", button)

  -- count+stock
  SetupFontString(count, cfg.count)
  SetupFontString(stock, cfg.stock)

  button.__styled = true
end

function rButtonTemplate:StyleAllActionButtons(cfg)
  for i = 1, NUM_ACTIONBAR_BUTTONS do
    rButtonTemplate:StyleActionButton(_G["ActionButton" .. i], cfg)
    rButtonTemplate:StyleActionButton(_G["MultiBarBottomLeftButton" .. i], cfg)
    rButtonTemplate:StyleActionButton(_G["MultiBarBottomRightButton" .. i], cfg)
    rButtonTemplate:StyleActionButton(_G["MultiBarRightButton" .. i], cfg)
    rButtonTemplate:StyleActionButton(_G["MultiBarLeftButton" .. i], cfg)
  end
  for i = 1, 6 do
    rButtonTemplate:StyleActionButton(_G["OverrideActionBarButton" .. i], cfg)
  end
  -- petbar buttons
  for i = 1, NUM_PET_ACTION_SLOTS do
    rButtonTemplate:StyleActionButton(_G["PetActionButton" .. i], cfg)
  end
  -- stancebar buttons
  for i = 1, NUM_STANCE_SLOTS do
    rButtonTemplate:StyleActionButton(_G["StanceButton" .. i], cfg)
  end
  -- possess buttons
  for i = 1, NUM_POSSESS_SLOTS do
    rButtonTemplate:StyleActionButton(_G["PossessButton" .. i], cfg)
  end
end

function rButtonTemplate:StyleAuraButton(button, cfg)
  if not button then
    return
  end
  if button.__styled then
    return
  end

  local buttonName = button:GetName()
  local icon = _G[buttonName .. "Icon"]
  local count = _G[buttonName .. "Count"]
  local duration = _G[buttonName .. "Duration"]
  local border = _G[buttonName .. "Border"]
  local symbol = button.symbol

  -- backdrop
  SetupBackdrop(button, cfg.backdrop)

  -- textures
  SetupTexture(icon, cfg.icon, "SetTexture", icon)
  SetupTexture(border, cfg.border, "SetTexture", border)

  -- create a normal texture on the aura button
  if cfg.normalTexture and cfg.normalTexture.file then
    button:SetNormalTexture(cfg.normalTexture.file)
    local normalTexture = button:GetNormalTexture()
    SetupTexture(normalTexture, cfg.normalTexture, "SetNormalTexture", button)
  end

  -- no clue why but blizzard created count and duration on background layer, need to fix that
  local overlay = CreateFrame("Frame", nil, button)
  overlay:SetAllPoints()
  if count then
    count:SetParent(overlay)
  end
  if duration then
    duration:SetParent(overlay)
  end

  -- count, duration, symbol
  SetupFontString(count, cfg.count)
  SetupFontString(duration, cfg.duration)
  SetupFontString(symbol, cfg.symbol)

  button.__styled = true
end

-- style player BuffFrame buff buttons
local buffButtonIndex = 1
function rButtonTemplate:StyleBuffButtons(cfg)
  local function UpdateBuffButtons()
    if buffButtonIndex > BUFF_MAX_DISPLAY then
      return
    end
    for i = buffButtonIndex, BUFF_MAX_DISPLAY do
      local button = _G["BuffButton" .. i]
      if not button then
        break
      end
      rButtonTemplate:StyleAuraButton(button, cfg)
      if button.__styled then
        buffButtonIndex = i + 1
      end
    end
  end
  hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", UpdateBuffButtons)
end

-- style player BuffFrame debuff buttons
function rButtonTemplate:StyleDebuffButtons(cfg)
  local function UpdateDebuffButton(buttonName, i)
    local button = _G["DebuffButton" .. i]
    rButtonTemplate:StyleAuraButton(button, cfg)
  end
  hooksecurefunc("DebuffButton_UpdateAnchors", UpdateDebuffButton)
end

-- style player TempEnchant buttons
function rButtonTemplate:StyleTempEnchants(cfg)
  rButtonTemplate:StyleAuraButton(TempEnchant1, cfg)
  rButtonTemplate:StyleAuraButton(TempEnchant2, cfg)
  rButtonTemplate:StyleAuraButton(TempEnchant3, cfg)
end

-- style all aura buttons
function rButtonTemplate:StyleAllAuraButtons(cfg)
  rButtonTemplate:StyleBuffButtons(cfg)
  rButtonTemplate:StyleDebuffButtons(cfg)
  rButtonTemplate:StyleTempEnchants(cfg)
end

----------------------------------------
-- Create Bars (rActionBar_Lum: layout)
----------------------------------------

local abl = CreateFrame("Frame")

abl:SetScript(
  "OnEvent",
  function(self, event, ...)
    abl[event](self, ...)
  end
)

abl:RegisterEvent("ADDON_LOADED")
function abl:ADDON_LOADED(addon)
  if addon == "rActionBar" or addon == "LumUI" then
    abl:StyleBars()
  end
end

function abl:StyleBars()
  L:CreateActionBar1(A, settings.actionBars.bar1)
  L:CreateActionBar2(A, settings.actionBars.bar2)
  L:CreateActionBar3(A, settings.actionBars.bar3)
  L:CreateActionBar4(A, settings.actionBars.bar4)
  L:CreateActionBar5(A, settings.actionBars.bar5)
  L:CreateStanceBar(A, settings.actionBars.stancebar)
  L:CreatePetBar(A, settings.actionBars.petbar)
  L:CreateExtraBar(A, settings.actionBars.extrabar)
  L:CreateVehicleExitBar(A, settings.actionBars.vehicleexitbar)
  L:CreatePossessExitBar(A, settings.actionBars.possessexitbar)
  L:CreateBagBar(A, settings.actionBars.bagbar)
  L:CreateMicroMenuBar(A, settings.actionBars.micromenubar)
end
