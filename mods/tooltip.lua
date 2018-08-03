-- -------------------------
-- Credits: zork (rTooltip)
-- -------------------------

-----------------------------
-- Variables
-----------------------------

local _, ns = ...

local L, C, G = unpack(select(2, ...))

if C.options.tooltip.show then

  -----------------------------
  -- Config
  -----------------------------

  local cfg = {}
  cfg.showSpellID = true
  cfg.talents = {
    show = true,
    onlyParty = false
  }
  cfg.textColor = {0.4,0.4,0.4}
  cfg.bossColor = {1,0,0}
  cfg.eliteColor = {1,0,0.5}
  cfg.rareeliteColor = {1,0.5,0}
  cfg.rareColor = {1,0.5,0}
  cfg.levelColor = {0.8,0.8,0.5}
  cfg.deadColor = {0.5,0.5,0.5}
  cfg.targetColor = {1,0.5,0.5}
  cfg.guildColor = {1,0,1}
  cfg.afkColor = {0,1,1}
  cfg.scale = 1
  cfg.fontFamily = STANDARD_TEXT_FONT
  cfg.backdrop = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = [[Interface\AddOns\lumUI\media\Textures\border_squared]],
    tiled = true,
    edgeSize = 10,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
  }
  cfg.backdrop.bgColor = {0.05,0.05,0.05,0.9}
  cfg.backdrop.borderColor = {0.1,0.1,0.1,1}

  -- Position
  -- cfg.pos = "ANCHOR_CURSOR"
  cfg.pos = { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -20, 20 }


  -----------------------------
  -- Variables
  -----------------------------

  local unpack, type = unpack, type
  local RAID_CLASS_COLORS, FACTION_BAR_COLORS, ICON_LIST = RAID_CLASS_COLORS, FACTION_BAR_COLORS, ICON_LIST
  local GameTooltip, GameTooltipStatusBar = GameTooltip, GameTooltipStatusBar
  local GameTooltipTextRight1, GameTooltipTextRight2, GameTooltipTextRight3, GameTooltipTextRight4, GameTooltipTextRight5,
    GameTooltipTextRight6, GameTooltipTextRight7, GameTooltipTextRight8 = GameTooltipTextRight1, GameTooltipTextRight2,
    GameTooltipTextRight3, GameTooltipTextRight4, GameTooltipTextRight5, GameTooltipTextRight6, GameTooltipTextRight7, GameTooltipTextRight8
  local GameTooltipTextLeft1, GameTooltipTextLeft2, GameTooltipTextLeft3, GameTooltipTextLeft4,
    GameTooltipTextLeft5, GameTooltipTextLeft6, GameTooltipTextLeft7, GameTooltipTextLeft8 = GameTooltipTextLeft1, GameTooltipTextLeft2,
    GameTooltipTextLeft3, GameTooltipTextLeft4, GameTooltipTextLeft5, GameTooltipTextLeft6, GameTooltipTextLeft7, GameTooltipTextLeft8
  local classColorHex, factionColorHex = {}, {}

  -- Talents (Credit: TipTac)
  local tt = CreateFrame("Frame","TooltipTalents")
  local gtt = GameTooltip
  local cache = {}
  local current = {}

  -- String Constants
  local TALENTS_PREFIX = TALENTS..":|cffffffff "	-- MoP: Could be changed from TALENTS to SPECIALIZATION
  local TALENTS_NA = NOT_APPLICABLE:lower()
  local TALENTS_NONE = NO.." "..TALENTS

  -- Option Constants
  local CACHE_SIZE = 25	-- Change cache size here (Default 25)
  local INSPECT_DELAY = 0.2	-- The time delay for the scheduled inspection
  local INSPECT_FREQ = 2		-- How often after an inspection are we allowed to inspect again?

  local lastInspectRequest = 0

  tt:Hide()

  -----------------------------
  -- Functions
  -----------------------------

  local function GetHexColor(color)
    if color.r then
      return ("%.2x%.2x%.2x"):format(color.r*255, color.g*255, color.b*255)
    else
      local r,g,b,a = unpack(color)
      return ("%.2x%.2x%.2x"):format(r*255, g*255, b*255)
    end
  end

  local function GetTarget(unit)
    if UnitIsUnit(unit, "player") then
      return ("|cffff0000%s|r"):format("<YOU>")
    elseif UnitIsPlayer(unit, "player") then
      local _, class = UnitClass(unit)
      return ("|cff%s%s|r"):format(classColorHex[class], UnitName(unit))
    elseif UnitReaction(unit, "player") then
      return ("|cff%s%s|r"):format(factionColorHex[UnitReaction(unit, "player")], UnitName(unit))
    else
      return ("|cffffffff%s|r"):format(UnitName(unit))
    end
  end

  -- Talents
  local function IsInspectFrameOpen() return (InspectFrame and InspectFrame:IsShown()) or (Examiner and Examiner:IsShown()) end

  local function GatherTalents(isInspect)
    local spec = isInspect and GetInspectSpecialization(current.unit) or GetSpecialization()
    if (not spec or spec == 0) then
      current.format = TALENTS_NONE
    elseif (isInspect) then
      local _, specName = GetSpecializationInfoByID(spec)
      current.format = specName or TALENTS_NA
    else
      local _, specName = GetSpecializationInfo(spec)
      current.format = specName or TALENTS_NA
    end

    if (not isInspect) then
      gtt:AddLine(TALENTS_PREFIX..current.format)
    elseif (gtt:GetUnit()) then
      for i = 2, gtt:NumLines() do
        if ((_G["GameTooltipTextLeft"..i]:GetText() or ""):match("^"..TALENTS_PREFIX)) then
          _G["GameTooltipTextLeft"..i]:SetFormattedText("%s%s",TALENTS_PREFIX,current.format)
          -- Do not call Show() if the tip is fading out, this only works with TipTac, if TipTacTalents are used alone, it might still bug the fadeout
          if (not gtt.fadeOut) then
            gtt:Show()
          end
          break
        end
      end
    end

    -- Organise Cache
    local cacheSize = CACHE_SIZE
    for i = #cache, 1, -1 do
      if (current.name == cache[i].name) then
        tremove(cache,i)
        break
      end
    end
    if (#cache > cacheSize) then
      tremove(cache,1)
    end
    -- Cache the new entry
    if (cacheSize > 0) then
      cache[#cache + 1] = CopyTable(current)
    end
  end

  local function OnTooltipSetUnit(self)
    local unitName, unit = self:GetUnit()
    if not unit then return end
    GameTooltipTextLeft2:SetTextColor(unpack(cfg.textColor))
    GameTooltipTextLeft3:SetTextColor(unpack(cfg.textColor))
    GameTooltipTextLeft4:SetTextColor(unpack(cfg.textColor))
    GameTooltipTextLeft5:SetTextColor(unpack(cfg.textColor))
    GameTooltipTextLeft6:SetTextColor(unpack(cfg.textColor))
    GameTooltipTextLeft7:SetTextColor(unpack(cfg.textColor))
    GameTooltipTextLeft8:SetTextColor(unpack(cfg.textColor))
    if not UnitIsPlayer(unit) then
      --unit is not a player
      --color textleft1 and statusbar by faction color
      local reaction = UnitReaction(unit, "player")
      if reaction then
        local color = FACTION_BAR_COLORS[reaction]
        if color then
          cfg.barColor = color
          GameTooltipStatusBar:SetStatusBarColor(color.r,color.g,color.b)
          GameTooltipTextLeft1:SetTextColor(color.r,color.g,color.b)
        end
      end
      --color textleft2 by classificationcolor
      local unitClassification = UnitClassification(unit)

      local levelLine
      if string.find(GameTooltipTextLeft2:GetText() or "empty", "%a%s%d") then
        levelLine = GameTooltipTextLeft2
      elseif string.find(GameTooltipTextLeft3:GetText() or "empty", "%a%s%d") then
        GameTooltipTextLeft2:SetTextColor(unpack(cfg.guildColor)) --seems like the npc has a description, use the guild color for this
        levelLine = GameTooltipTextLeft3
      end
      if levelLine then
        local l = UnitLevel(unit)
        local color = GetCreatureDifficultyColor((l > 0) and l or 999)
        levelLine:SetTextColor(color.r,color.g,color.b)
      end
      if unitClassification == "worldboss" or UnitLevel(unit) == -1 then
        self:AppendText(" |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:14:14|t")
        --GameTooltipTextLeft1:SetText(("%s%s"):format("|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:14:14|t", unitName))
        GameTooltipTextLeft2:SetTextColor(unpack(cfg.bossColor))
      elseif unitClassification == "rare" then
        self:AppendText(" |TInterface\\AddOns\\rTooltip\\media\\diablo:14:14:0:0:16:16:0:14:0:14|t")
      elseif unitClassification == "rareelite" then
        self:AppendText(" |TInterface\\AddOns\\rTooltip\\media\\diablo:14:14:0:0:16:16:0:14:0:14|t")
      elseif unitClassification == "elite" then
        self:AppendText(" |TInterface\\HelpFrame\\HotIssueIcon:14:14|t")
      end
    else
      --unit is any player
      local _, unitClass = UnitClass(unit)
      --color textleft1 and statusbar by class color
      local color = RAID_CLASS_COLORS[unitClass]
      cfg.barColor = color
      GameTooltipStatusBar:SetStatusBarColor(color.r,color.g,color.b)
      GameTooltipTextLeft1:SetTextColor(color.r,color.g,color.b)
      --color textleft2 by guildcolor
      local unitGuild = GetGuildInfo(unit)
      if unitGuild then
        GameTooltipTextLeft2:SetText("<"..unitGuild..">")
        GameTooltipTextLeft2:SetTextColor(unpack(cfg.guildColor))
      end
      local levelLine = unitGuild and GameTooltipTextLeft3 or GameTooltipTextLeft2
      local l = UnitLevel(unit)
      local color = GetCreatureDifficultyColor((l > 0) and l or 999)
      levelLine:SetTextColor(color.r,color.g,color.b)
      -- afk?
      if UnitIsAFK(unit) then
        self:AppendText((" |cff%s<AFK>|r"):format(cfg.afkColorHex))
      end
    end
    -- dead?
    if UnitIsDeadOrGhost(unit) then
      GameTooltipTextLeft1:SetTextColor(unpack(cfg.deadColor))
    end
    -- target line
    if (UnitExists(unit.."target")) then
      GameTooltip:AddDoubleLine(("|cff%s%s|r"):format(cfg.targetColorHex, "Target"),GetTarget(unit.."target") or "Unknown")
    end

    -- Talents
    if cfg.talents.show == false then
      return
    end
    -- Abort any delayed inspect in progress
    tt:Hide()
    -- Get the unit -- Check the UnitFrame unit if this tip is from a concated unit, such as "targettarget".
    if (not unit) then
      local mFocus = GetMouseFocus()
      if (mFocus) and (mFocus.unit) then
        unit = mFocus.unit
      end
    end
    -- No Unit or not a Player
    if (not unit) or (not UnitIsPlayer(unit)) then
      return
    end
    -- Show only talents for people in your party/raid
    if (cfg.talents.onlyParty and not UnitInParty(unit) and not UnitInRaid(unit)) then
      return
    end
    -- Only bother for players over level 9
    local level = UnitLevel(unit)
    if (level > 9 or level == -1) then
      -- Wipe Current Record
      wipe(current)
      current.unit = unit
      current.name = UnitName(unit)
      current.guid = UnitGUID(unit)
      -- No need for inspection on the player
      if (UnitIsUnit(unit,"player")) then
        GatherTalents()
        return
      end
      -- Show Cached Talents, If Available
      local cacheLoaded = false
      for _, entry in ipairs(cache) do
        if (current.name == entry.name) then
          self:AddLine(TALENTS_PREFIX..entry.format)
          current.format = entry.format
          cacheLoaded = true
          break
        end
      end
      -- Queue an inspect request
      if (CanInspect(unit)) and (not IsInspectFrameOpen()) then
        local lastInspectTime = (GetTime() - lastInspectRequest)
        tt.nextUpdate = (lastInspectTime > INSPECT_FREQ) and INSPECT_DELAY or (INSPECT_FREQ - lastInspectTime + INSPECT_DELAY)
        tt:Show()
        if (not cacheLoaded) then
          self:AddLine(TALENTS_PREFIX.."Loading...")
        end
      end
    end
  end

  local function ResetBackdropColor()
    backdrop.backdropColor:SetRGBA(unpack(backdrop.bgColor))
    backdrop.backdropBorderColor:SetRGBA(unpack(backdrop.borderColor))
  end

  local function SetBackdropColor(self)
    self:SetBackdropColor(backdrop.backdropColor:GetRGBA())
    self:SetBackdropBorderColor(backdrop.backdropBorderColor:GetRGBA())
  end

  --OnShow
  local function OnShow(self)
    ResetBackdropColor()
    local itemName, itemLink = self:GetItem()
    if itemLink then
      local _, _, itemRarity = GetItemInfo(itemLink)
      if itemRarity then
        local r,g,b = GetItemQualityColor(itemRarity)
        backdrop.backdropBorderColor:SetRGBA(r,g,b,1)
      end
    end
    SetBackdropColor(self)
  end

  --OnHide
  local function OnHide(self)
    ResetBackdropColor()
  end

  --OnTooltipCleared
  local function OnTooltipCleared(self)
    SetBackdropColor(self)
  end

  --OnUpdate
  local function OnUpdate(self)
    SetBackdropColor(self)
  end

  local function FixBarColor(self,r,g,b)
    if not cfg.barColor then return end
    if r == cfg.barColor.r and g == cfg.barColor.g and b == cfg.barColor.b then return end
    self:SetStatusBarColor(cfg.barColor.r,cfg.barColor.g,cfg.barColor.b)
  end

  local function ResetTooltipPosition(self,parent)
    if not cfg.pos then return end
    if type(cfg.pos) == "string" then
      self:SetOwner(parent, cfg.pos)
    else
      self:SetOwner(parent, "ANCHOR_NONE")
      self:ClearAllPoints()
      self:SetPoint(unpack(cfg.pos))
    end
  end

  -----------------------------
  -- Init
  -----------------------------

  backdrop  = GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT
  backdrop.bgFile = cfg.backdrop.bgFile
  backdrop.edgeFile = cfg.backdrop.edgeFile
  backdrop.tile = cfg.backdrop.tile
  backdrop.tileEdge = cfg.backdrop.tileEdge
  backdrop.tileSize = cfg.backdrop.tileSize
  backdrop.edgeSize = cfg.backdrop.edgeSize
  backdrop.insets = cfg.backdrop.insets
  backdrop.backdropColor = CreateColor(1,1,1)
  backdrop.backdropBorderColor = CreateColor(1,1,1)
  backdrop.backdropColor.GetRGB = ColorMixin.GetRGBA
  backdrop.backdropBorderColor.GetRGB = ColorMixin.GetRGBA
  backdrop.bgColor = cfg.backdrop.bgColor
  backdrop.borderColor = cfg.backdrop.borderColor

  --hex class colors
  for class, color in next, RAID_CLASS_COLORS do
    classColorHex[class] = GetHexColor(color)
  end
  --hex reaction colors
  --for idx, color in next, FACTION_BAR_COLORS do
  for i = 1, #FACTION_BAR_COLORS do
    factionColorHex[i] = GetHexColor(FACTION_BAR_COLORS[i])
  end

  cfg.targetColorHex = GetHexColor(cfg.targetColor)
  cfg.afkColorHex = GetHexColor(cfg.afkColor)

  GameTooltipHeaderText:SetFont(cfg.fontFamily, 14, "NONE")
  GameTooltipHeaderText:SetShadowOffset(1,-1)
  GameTooltipHeaderText:SetShadowColor(0,0,0,0.9)
  GameTooltipText:SetFont(cfg.fontFamily, 12, "NONE")
  GameTooltipText:SetShadowOffset(1,-1)
  GameTooltipText:SetShadowColor(0,0,0,0.9)
  Tooltip_Small:SetFont(cfg.fontFamily, 11, "NONE")
  Tooltip_Small:SetShadowOffset(1,-1)
  Tooltip_Small:SetShadowColor(0,0,0,0.9)

  --gametooltip statusbar
  GameTooltipStatusBar:ClearAllPoints()
  GameTooltipStatusBar:SetPoint("LEFT",5,0)
  GameTooltipStatusBar:SetPoint("RIGHT",-5,0)
  GameTooltipStatusBar:SetPoint("TOP",0,-2.5)
  GameTooltipStatusBar:SetHeight(4)
  --gametooltip statusbar bg
  GameTooltipStatusBar.bg = GameTooltipStatusBar:CreateTexture(nil,"BACKGROUND",nil,-8)
  GameTooltipStatusBar.bg:SetAllPoints()
  GameTooltipStatusBar.bg:SetColorTexture(1,1,1)
  GameTooltipStatusBar.bg:SetVertexColor(0,0,0,0.7)

  --GameTooltipStatusBar:SetStatusBarColor()
  hooksecurefunc(GameTooltipStatusBar,"SetStatusBarColor", FixBarColor)
  --GameTooltip_SetDefaultAnchor()
  hooksecurefunc("GameTooltip_SetDefaultAnchor", ResetTooltipPosition)
  --OnTooltipSetUnit
  GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)

  --loop over tooltips
  local tooltips = { GameTooltip,ShoppingTooltip1,ShoppingTooltip2,ItemRefTooltip,ItemRefShoppingTooltip1,ItemRefShoppingTooltip2,WorldMapTooltip,
  WorldMapCompareTooltip1,WorldMapCompareTooltip2,SmallTextTooltip }
  for i, tooltip in next, tooltips do
    tooltip:SetBackdrop(backdrop)
    tooltip:SetScale(cfg.scale)
    tooltip:HookScript("OnShow", OnShow)
    --tooltip:HookScript("OnHide", OnHide)
    if tooltip:HasScript("OnTooltipCleared") then
      tooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
    end
  end

  --loop over menues
  local menues = {
    DropDownList1MenuBackdrop,
    DropDownList2MenuBackdrop,
  }
  for idx, menu in ipairs(menues) do
    menu:SetScale(cfg.scale)
  end

  --spellid line
  if cfg.showSpellID then
    --func TooltipAddSpellID
    local function TooltipAddSpellID(self,spellid)
      if not spellid then return end
      self:AddDoubleLine("|cff0099ffSpell ID|r",spellid)
      self:Show()
    end

    --hooksecurefunc GameTooltip SetUnitBuff
    hooksecurefunc(GameTooltip, "SetUnitBuff", function(self,...)
      TooltipAddSpellID(self,select(10,UnitBuff(...)))
    end)

    --hooksecurefunc GameTooltip SetUnitDebuff
    hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self,...)
      TooltipAddSpellID(self,select(10,UnitDebuff(...)))
    end)

    --hooksecurefunc GameTooltip SetUnitAura
    hooksecurefunc(GameTooltip, "SetUnitAura", function(self,...)
      TooltipAddSpellID(self,select(10,UnitAura(...)))
    end)

    --hooksecurefunc SetItemRef
    hooksecurefunc("SetItemRef", function(link)
      local type, value = link:match("(%a+):(.+)")
      if type == "spell" then
        TooltipAddSpellID(ItemRefTooltip,value:match("([^:]+)"))
      end
    end)

    --HookScript GameTooltip OnTooltipSetSpell
    GameTooltip:HookScript("OnTooltipSetSpell", function(self)
      TooltipAddSpellID(self,select(3,self:GetSpell()))
    end)
  end

  -- Talents Events
  tt:SetScript("OnEvent", function(self,event,guid)
    self:UnregisterEvent(event)
    if (guid == current.guid) then
      GatherTalents(1)
    end
  end)

  -- OnUpdate
  tt:SetScript("OnUpdate", function(self,elapsed)
    self.nextUpdate = (self.nextUpdate - elapsed)
    if (self.nextUpdate <= 0) then
      self:Hide()
      -- Make sure the mouseover unit is still our unit
      if (UnitGUID("mouseover") == current.guid) and (not IsInspectFrameOpen()) then
        lastInspectRequest = GetTime()
        self:RegisterEvent("INSPECT_READY")
        NotifyInspect(current.unit)
      end
    end
  end)
end
