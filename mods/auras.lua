-- ------------------------------------------------------------------------
-- Credits: Tuk, Luzzifus.
-- ------------------------------------------------------------------------

local _, ns = ...

local L, C, G = unpack(select(2, ...))

local cfg = C.settings.auras

-- ---------------------------------
-- > Variables
-- ---------------------------------

local hasMainHandEnchant, _, _, hasOffHandEnchant, _, _, hasThrownEnchant = GetWeaponEnchantInfo()
local _G = _G

-- ---------------------------------
-- > Functions
-- ---------------------------------

do
  TemporaryEnchantFrame:SetScale(cfg.scale)
  BuffFrame:SetScale(cfg.scale)
  cfg.buffSize = cfg.buffSize * cfg.scale
  cfg.debuffSize = cfg.debuffSize * cfg.scale

  TicketStatusFrame:ClearAllPoints() -- Move the Ticket from the default place
  TicketStatusFrame:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -15, -50)

  TemporaryEnchantFrame:ClearAllPoints()
  TemporaryEnchantFrame:SetPoint(unpack(cfg.buffAnchor))
  TemporaryEnchantFrame.SetPoint = function()
  end

  TempEnchant1:ClearAllPoints()
  TempEnchant2:ClearAllPoints()
  TempEnchant3:ClearAllPoints()
  TempEnchant1:SetPoint(unpack(cfg.buffAnchor))
  TempEnchant2:SetPoint("RIGHT", TempEnchant1, "LEFT", -cfg.iconSpacing, 0)
  TempEnchant3:SetPoint("RIGHT", TempEnchant2, "LEFT", -cfg.iconSpacing, 0)

  for i = 1, 3 do
    local f = CreateFrame("Frame", "TempEnchant" .. i .. "Container", _G["TempEnchant" .. i], "BackdropTemplate")
    f:SetSize(cfg.buffSize, cfg.buffSize)
    f:SetPoint("CENTER", _G["TempEnchant" .. i], "CENTER", 0, 0)
    f:SetBackdrop {
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = cfg.border_tex,
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
        edgeFile = cfg.shadow_tex,
        tile = false,
        tileSize = 32,
        edgeSize = 5,
        insets = {left = -5, right = -5, top = -5, bottom = -5}
      }
    )
    s:SetBackdropColor(0, 0, 0, 0)
    s:SetBackdropBorderColor(0, 0, 0, cfg.shadowAlpha)

    _G["TempEnchant" .. i .. "Border"]:Hide()
    _G["TempEnchant" .. i]:SetHeight(cfg.buffSize)
    _G["TempEnchant" .. i]:SetWidth(cfg.buffSize)
    _G["TempEnchant" .. i .. "Icon"]:SetTexCoord(.08, .92, .08, .92)
    _G["TempEnchant" .. i .. "Icon"]:SetPoint("TOPLEFT", _G["TempEnchant" .. i], cfg.iconborder, -cfg.iconborder)
    _G["TempEnchant" .. i .. "Icon"]:SetPoint("BOTTOMRIGHT", _G["TempEnchant" .. i], -cfg.iconborder, cfg.iconborder)
    _G["TempEnchant" .. i .. "Duration"]:ClearAllPoints()
    _G["TempEnchant" .. i .. "Duration"]:SetPoint("BOTTOM", 1, -13)
    _G["TempEnchant" .. i .. "Duration"]:SetFont(cfg.font, 12, cfg.outline)
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
    icon:SetPoint("TOPLEFT", buff, cfg.iconborder, -cfg.iconborder)
    icon:SetPoint("BOTTOMRIGHT", buff, -cfg.iconborder, cfg.iconborder)

    duration:ClearAllPoints()
    duration:SetPoint("BOTTOM", 2, -16)
    duration:SetFont(cfg.font, 13, cfg.outline)
    duration:SetJustifyH("CENTER")

    count:ClearAllPoints()
    count:SetPoint("TOPRIGHT", 6, 1)
    count:SetFont(cfg.font, 12, "THICKOUTLINE")

    container:SetPoint("CENTER", buff, "CENTER", 0, 0)
    container:SetBackdrop {
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = cfg.border_tex,
      tile = true,
      tileSize = 32,
      edgeSize = 16,
      insets = {left = 0, right = 0, top = 0, bottom = 0}
    }
    container:SetBackdropBorderColor(cfg.borderColor.r, cfg.borderColor.g, cfg.borderColor.b)
    container:SetFrameLevel(buff:GetFrameLevel() - 1)
    container:SetFrameStrata(buff:GetFrameStrata())

    if buttonName == "BuffButton" then
      buff:SetHeight(cfg.buffSize)
      buff:SetWidth(cfg.buffSize)
      container:SetSize(cfg.buffSize, cfg.buffSize)
    elseif buttonName == "DebuffButton" then
      buff:SetHeight(cfg.debuffSize)
      buff:SetWidth(cfg.debuffSize)
      container:SetSize(cfg.debuffSize, cfg.debuffSize)
    end

    local s = CreateFrame("Frame", buttonName .. index .. "Shadow", container, "BackdropTemplate")
    s:SetFrameLevel(0)
    s:SetPoint("TOPLEFT", container, "TOPLEFT", -4, 4)
    s:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 4, -4)
    s:SetBackdrop(
      {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = cfg.shadow_tex,
        tile = false,
        tileSize = 32,
        edgeSize = 5,
        insets = {left = -5, right = -5, top = -5, bottom = -5}
      }
    )
    s:SetBackdropColor(0, 0, 0, 0)
    s:SetBackdropBorderColor(0, 0, 0, cfg.shadowAlpha)
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
      if ((index > 1) and (mod(index, cfg.iconsPerRow) == 1)) then
        if (index == cfg.iconsPerRow + 1) then
          buff:SetPoint(unpack(cfg.buffAnchor2ndRow))
        else
          buff:SetPoint(unpack(cfg.buffAnchor))
        end
        aboveBuff = buff
      elseif (index == 1) then
        if (hasMainHandEnchant and hasOffHandEnchant and hasThrownEnchant) and not UnitHasVehicleUI("player") then
          buff:SetPoint("RIGHT", TempEnchant3, "LEFT", -cfg.iconSpacing, 0)
        elseif
          ((hasMainHandEnchant and hasOffHandEnchant) or (hasMainHandEnchant and hasThrownEnchant) or
            (hasOffHandEnchant and hasThrownEnchant)) and
            not UnitHasVehicleUI("player")
         then
          buff:SetPoint("RIGHT", TempEnchant2, "LEFT", -cfg.iconSpacing, 0)
        elseif
          ((hasMainHandEnchant and not hasOffHandEnchant and not hasThrownEnchant) or
            (hasOffHandEnchant and not hasMainHandEnchant and not hasThrownEnchant) or
            (hasThrownEnchant and not hasMainHandEnchant and not hasOffHandEnchant)) and
            not UnitHasVehicleUI("player")
         then
          buff:SetPoint("RIGHT", TempEnchant1, "LEFT", -cfg.iconSpacing, 0)
        else
          buff:SetPoint(unpack(cfg.buffAnchor))
        end
      else
        buff:SetPoint("RIGHT", previousBuff, "LEFT", -cfg.iconSpacing, 0)
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
    debuff:SetPoint(unpack(cfg.debuffAnchor))
  else
    debuff:SetPoint("RIGHT", _G[buttonName .. (index - 1)], "LEFT", -cfg.iconSpacing, 0)
  end
end

-- ---------------------------------
-- > Events
-- ---------------------------------

hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", UpdateBuffs)
hooksecurefunc("DebuffButton_UpdateAnchors", UpdateDebuffs)
