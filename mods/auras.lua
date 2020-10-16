-- ------------------------------------------------------------------------
-- Credits: Tuk, Luzzifus.
-- ------------------------------------------------------------------------

local _, ns = ...

local L, C, G = unpack(select(2, ...))

-- local lb = CreateFrame("Frame")

-- ---------------------------------
-- > Variables
-- ---------------------------------

local font = G.font
local shadow_tex = G.media.glow
local border_tex = G.media.buffsBorder

local outline = "THINOUTLINE" -- Font Outline
local bColor = C.color.border -- Default Border Color

local scale = 1
local buffSize = 30 -- Size of the Buff Icons
local debuffSize = 30 -- Size of the Debuff Icons
local iconsPerRow = 12 -- Number of Icons per Row
local iconSpacing = 8 -- Spacing between buffs
local iconborder = 3 -- Icon Texture Border Size
local shadowAlpha = 0.5 -- The Alpha of The buttons shadow

local posX = -20
local posY = -14
local buffAnchor = {"BOTTOMRIGHT", "Minimap", "BOTTOMLEFT", posX, posY}
local buffAnchor2ndRow = {"BOTTOMRIGHT", "Minimap", "BOTTOMLEFT", posX, posY + buffSize + 20}
local debuffAnchor = {"BOTTOMRIGHT", "Minimap", "TOPRIGHT", 4, 28}

-- ---------------------------------
-- > Variables
-- ---------------------------------

local hasMainHandEnchant, _, _, hasOffHandEnchant, _, _, hasThrownEnchant = GetWeaponEnchantInfo()
local _G = _G

-- ---------------------------------
-- > Functions
-- ---------------------------------

do
  TemporaryEnchantFrame:SetScale(scale)
  BuffFrame:SetScale(scale)
  buffSize = buffSize * scale
  debuffSize = debuffSize * scale

  TicketStatusFrame:ClearAllPoints() -- Move the Ticket from the default place
  TicketStatusFrame:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -15, -50)

  TemporaryEnchantFrame:ClearAllPoints()
  TemporaryEnchantFrame:SetPoint(unpack(buffAnchor))
  TemporaryEnchantFrame.SetPoint = function()
  end

  TempEnchant1:ClearAllPoints()
  TempEnchant2:ClearAllPoints()
  TempEnchant3:ClearAllPoints()
  TempEnchant1:SetPoint(unpack(buffAnchor))
  TempEnchant2:SetPoint("RIGHT", TempEnchant1, "LEFT", -iconSpacing, 0)
  TempEnchant3:SetPoint("RIGHT", TempEnchant2, "LEFT", -iconSpacing, 0)

  for i = 1, 3 do
    local f = CreateFrame("Frame", "TempEnchant" .. i .. "Container", _G["TempEnchant" .. i], "BackdropTemplate")
    f:SetSize(buffSize, buffSize)
    f:SetPoint("CENTER", _G["TempEnchant" .. i], "CENTER", 0, 0)
    f:SetBackdrop {
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = border_tex,
      tile = true,
      tileSize = 32,
      edgeSize = 16,
      insets = {left = 0, right = 0, top = 0, bottom = 0}
    }
    f:SetFrameStrata("BACKGROUND")

    local s = CreateFrame("Frame", nil, f, "BackdropTemplate")
    s:SetFrameLevel(0)
    s:SetPoint("TOPLEFT", f, "TOPLEFT", -4, 4)
    s:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 4, -4)
    s:SetBackdrop(
      {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = shadow_tex,
        tile = false,
        tileSize = 32,
        edgeSize = 5,
        insets = {left = -5, right = -5, top = -5, bottom = -5}
      }
    )
    s:SetBackdropColor(0, 0, 0, 0)
    s:SetBackdropBorderColor(0, 0, 0, shadowAlpha)

    _G["TempEnchant" .. i .. "Border"]:Hide()
    _G["TempEnchant" .. i]:SetHeight(buffSize)
    _G["TempEnchant" .. i]:SetWidth(buffSize)
    _G["TempEnchant" .. i .. "Icon"]:SetTexCoord(.08, .92, .08, .92)
    _G["TempEnchant" .. i .. "Icon"]:SetPoint("TOPLEFT", _G["TempEnchant" .. i], iconborder, -iconborder)
    _G["TempEnchant" .. i .. "Icon"]:SetPoint("BOTTOMRIGHT", _G["TempEnchant" .. i], -iconborder, iconborder)
    _G["TempEnchant" .. i .. "Duration"]:ClearAllPoints()
    _G["TempEnchant" .. i .. "Duration"]:SetPoint("BOTTOM", 1, -13)
    _G["TempEnchant" .. i .. "Duration"]:SetFont(font, 12, outline)
  end
end

local function StyleBuffs(buttonName, index)
  local buff = _G[buttonName .. index]
  local icon = _G[buttonName .. index .. "Icon"]
  local border = _G[buttonName .. index .. "Border"]
  local duration = _G[buttonName .. index .. "Duration"]
  local count = _G[buttonName .. index .. "Count"]

  if icon and not _G[buttonName .. index .. "Container"] then
    local container = CreateFrame("Frame", buttonName .. index .. "Container", buff, "BackdropTemplate")

    icon:SetTexCoord(.08, .92, .08, .92)
    icon:SetPoint("TOPLEFT", buff, iconborder, -iconborder)
    icon:SetPoint("BOTTOMRIGHT", buff, -iconborder, iconborder)

    duration:ClearAllPoints()
    duration:SetPoint("BOTTOM", 2, -16)
    duration:SetFont(font, 13, outline)
    duration:SetJustifyH("CENTER")

    count:ClearAllPoints()
    count:SetPoint("TOPRIGHT", 6, 1)
    count:SetFont(font, 12, "THICKOUTLINE")

    container:SetPoint("CENTER", buff, "CENTER", 0, 0)
    container:SetBackdrop {
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = border_tex,
      tile = true,
      tileSize = 32,
      edgeSize = 16,
      insets = {left = 0, right = 0, top = 0, bottom = 0}
    }
    container:SetBackdropBorderColor(bColor.r, bColor.g, bColor.b)
    container:SetFrameLevel(buff:GetFrameLevel() - 1)
    container:SetFrameStrata(buff:GetFrameStrata())

    if buttonName == "BuffButton" then
      buff:SetHeight(buffSize)
      buff:SetWidth(buffSize)
      container:SetSize(buffSize, buffSize)
    elseif buttonName == "DebuffButton" then
      buff:SetHeight(debuffSize)
      buff:SetWidth(debuffSize)
      container:SetSize(debuffSize, debuffSize)
    end

    local s = CreateFrame("Frame", buttonName .. index .. "Shadow", container, "BackdropTemplate")
    s:SetFrameLevel(0)
    s:SetPoint("TOPLEFT", container, "TOPLEFT", -4, 4)
    s:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 4, -4)
    s:SetBackdrop(
      {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = shadow_tex,
        tile = false,
        tileSize = 32,
        edgeSize = 5,
        insets = {left = -5, right = -5, top = -5, bottom = -5}
      }
    )
    s:SetBackdropColor(0, 0, 0, 0)
    s:SetBackdropBorderColor(0, 0, 0, shadowAlpha)
  end

  if border then
    border:Hide()
  end
end

local function UpdateBuffs()
  local buff, previousBuff, aboveBuff
  local numBuffs = 0

  for index = 1, BUFF_ACTUAL_DISPLAY do
    local buff = _G["BuffButton" .. index]
    StyleBuffs("BuffButton", index)

    if (buff.consolidated) then
      if (buff.parent == BuffFrame) then
        buff:SetParent(ConsolidatedBuffsContainer)
        buff.parent = ConsolidatedBuffsContainer
      end
    else
      numBuffs = numBuffs + 1
      index = numBuffs
      buff:ClearAllPoints()
      if ((index > 1) and (mod(index, iconsPerRow) == 1)) then
        if (index == iconsPerRow + 1) then
          buff:SetPoint(unpack(buffAnchor2ndRow))
        else
          buff:SetPoint(unpack(buffAnchor))
        end
        aboveBuff = buff
      elseif (index == 1) then
        if (hasMainHandEnchant and hasOffHandEnchant and hasThrownEnchant) and not UnitHasVehicleUI("player") then
          buff:SetPoint("RIGHT", TempEnchant3, "LEFT", -iconSpacing, 0)
        elseif
          ((hasMainHandEnchant and hasOffHandEnchant) or (hasMainHandEnchant and hasThrownEnchant) or
            (hasOffHandEnchant and hasThrownEnchant)) and
            not UnitHasVehicleUI("player")
         then
          buff:SetPoint("RIGHT", TempEnchant2, "LEFT", -iconSpacing, 0)
        elseif
          ((hasMainHandEnchant and not hasOffHandEnchant and not hasThrownEnchant) or
            (hasOffHandEnchant and not hasMainHandEnchant and not hasThrownEnchant) or
            (hasThrownEnchant and not hasMainHandEnchant and not hasOffHandEnchant)) and
            not UnitHasVehicleUI("player")
         then
          buff:SetPoint("RIGHT", TempEnchant1, "LEFT", -iconSpacing, 0)
        else
          buff:SetPoint(unpack(buffAnchor))
        end
      else
        buff:SetPoint("RIGHT", previousBuff, "LEFT", -iconSpacing, 0)
      end
      previousBuff = buff
    end
  end
end

local function UpdateDebuffs(buttonName, index)
  local debuff = _G[buttonName .. index]
  StyleBuffs(buttonName, index)
  local debuffType = select(4, UnitAura("player", index))
  local color

  -- Debuff Coloring
  if (debuffType ~= nil) then
    color = DebuffTypeColor[debuffType]
  else
    color = DebuffTypeColor["none"]
  end

  _G[buttonName .. index .. "Container"]:SetBackdropBorderColor(color.r, color.g, color.b)
  debuff:ClearAllPoints()

  if index == 1 then
    debuff:SetPoint(unpack(debuffAnchor))
  else
    debuff:SetPoint("RIGHT", _G[buttonName .. (index - 1)], "LEFT", -iconSpacing, 0)
  end
end

-- ---------------------------------
-- > Events
-- ---------------------------------

hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", UpdateBuffs)
hooksecurefunc("DebuffButton_UpdateAnchors", UpdateDebuffs)
