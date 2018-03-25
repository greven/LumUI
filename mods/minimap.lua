-- --------------------------------------------
-- Credits: Katae, p3lim, Zork.
-- --------------------------------------------

local _, ns = ...

local L, C, G = unpack(select(2, ...))

local lm = CreateFrame("Frame", "lumMinimap", UIParent)

-- ---------------------------------
-- > Variables
-- ---------------------------------

local zone

local font = G.font
local fontsize = 14
local fontOutline = "THINOUTLINE"

-- Config
local mParent = "UIParent" -- Minimap Parent
local mParentPoint = "TOPRIGHT" -- Minimap Anchor
local mPoint = "TOPRIGHT" -- Minimap Set Point

local mWidth = 200 -- Minimap Width 
local mHeight = 200 -- Minimap Height 
local mPosx = -20 -- Minimap Horizontal Position
local mPosy = -20 -- Minimap Vertical Position
local mScale = 1.0 -- Minimap Scale

local showZone = true -- Shows the Zone Location
local PvPcolor = true -- Colors the Location zone based on zone pvp info
local locationTextOnHover = false -- Location text is hidden, shows on mouse hover
local clockOnHover = true -- Clock is hidden, shows on mouse hover

-- ---------------------------------
-- > Functions
-- ---------------------------------

function lm:TextColor()
  if PvPcolor then
    local pvpType = GetZonePVPInfo()

    if ( pvpType == "sanctuary" ) then
      zone:SetTextColor(0.41, 0.8, 0.94)
    elseif ( pvpType == "arena" ) then
      zone:SetTextColor(1.0, 0.1, 0.1)
    elseif ( pvpType == "friendly" ) then
      zone:SetTextColor(0.1, 1.0, 0.1)
    elseif ( pvpType == "hostile" ) then
      zone:SetTextColor(1.0, 0.1, 0.1)
    elseif ( pvpType == "contested" ) then
      zone:SetTextColor(1.0, 0.7, 0.0)
    else
      zone:SetTextColor(1, 1, 1)
    end
  else
    zone:SetTextColor(1, 1, 1)
  end
end

-- Initialize Function
function lm:Init(event)
  if showZone then
    local zf = CreateFrame("Button", nil, Minimap)
    zf:SetHeight(20)
    zf:SetWidth(Minimap:GetWidth())
    zf:SetPoint("CENTER", Minimap, "TOP", 0, 2)
    zf:SetScript("OnClick", function() ToggleFrame(WorldMapFrame) end)

    zone = Minimap:CreateFontString(nil, "OVERLAY")
    zone:SetFont(font, fontsize, fontOutline)
    lm:TextColor()
    zone:SetShadowColor(0, 0, 0, 1)
    zone:SetAllPoints(zf)
    zone:SetText(GetMinimapZoneText())
    if locationTextOnHover then
      zone:Hide()
      zf:SetScript('OnEnter', function(self) zone:Show() end) -- Hover it Appears! Magic!!
      zf:SetScript('OnLeave', function(self) zone:Hide() end) -- Hover Disapears!
    end
  end

  lm:MouseScroll()

  lm:MoveQuestTracker()

  lm:MoveDurability()

  -- Position and Scale
  Minimap:ClearAllPoints()
  Minimap:SetScale(mScale)
  Minimap:SetSize(mWidth,mHeight)
  Minimap:SetFrameLevel(1)
  Minimap:SetMaskTexture('Interface/Buttons/WHITE8X8')   -- Make Minimap Square!
  lm:SetPos() -- Set Minimap Position

  -- Hide Some Crap

  for _,f in pairs {
    MinimapBackdrop, -- Backdrop
    MiniMapVoiceChatFrame, -- Voice Chat Icon
    MiniMapWorldMapButton, -- World Map toggle button
    MinimapZoneTextButton, -- Zone Information above Minimap
    MinimapNorthTag, -- The Little N
    MinimapZoomIn, -- Zoom Icon
    MinimapZoomOut, -- Zoom Icon
    GameTimeFrame, -- Calendar Icon
    MinimapBorder, -- Minimap Circular Border
    MinimapBorderTop, -- Location Frame of Minimap
    MiniMapMailFrame, -- The Mail Icon
    MiniMapMailBorder, -- The Mail Icon Border
    MiniMapTrackingBackground, -- Tracking button Background
    MiniMapTrackingButtonBorder, -- Tracking button border
    MiniMapBattlefieldBorder, -- PvP Battleground Border
    MiniMapLFGFrameBorder, -- LFG Border
  } do f.Show = f.Hide f:Hide() end

  -- Hide More Crap
  if not IsAddOnLoaded("Blizzard_TimeManager") then LoadAddOn("Blizzard_TimeManager") end
  TimeManagerClockButton:GetRegions():Hide() -- Clock Frame Border
  TimeManagerClockButton:SetAlpha(0) -- Sets Alpha to Zero so clock doesn't show initially
  if clockOnHover then
    TimeManagerClockButton:SetScript('OnEnter', function(self) self:SetAlpha(100) end) -- Hover it Appears! Magic!!
    TimeManagerClockButton:SetScript('OnLeave', function(self) self:SetAlpha(0) end) -- Hover Disapears!
  end
  TimeManagerClockButton:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -16)
  TimeManagerClockTicker:SetFont(font, fontsize, fontOutline) -- Clock Font
  TimeManagerClockTicker:SetPoint('CENTER', TimeManagerClockButton, 0, 0)
  TimeManagerClockTicker:SetShadowOffset(0, 0)

  -- Tracking Button
  MiniMapTracking:ClearAllPoints()
  MiniMapTracking:SetParent(Minimap)
  MiniMapTracking:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -1, -2)
  MiniMapTrackingButton:SetHighlightTexture''

  -- Queue Status Icon
  QueueStatusMinimapButton:ClearAllPoints()
  QueueStatusMinimapButton:SetParent(Minimap)
  QueueStatusMinimapButton:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 0, 0)
  QueueStatusMinimapButtonBorder:SetAlpha(0)

  -- Raid Difficulty
  MiniMapInstanceDifficulty:ClearAllPoints()
  MiniMapInstanceDifficulty:SetParent(Minimap)
  MiniMapInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
  GuildInstanceDifficulty:ClearAllPoints()
  GuildInstanceDifficulty:SetParent(Minimap)
  GuildInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)

  -- Garrison Report
  GarrisonLandingPageMinimapButton:ClearAllPoints()
  GarrisonLandingPageMinimapButton:SetParent(Minimap)
  GarrisonLandingPageMinimapButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 0, 0)
  GarrisonLandingPageMinimapButton:SetScale(0.7)
  GarrisonLandingPageMinimapButton:SetAlpha(0)
  GarrisonLandingPageMinimapButton:SetScript('OnEnter', function(self) self:SetAlpha(100) end) -- Hover it Appears! Magic!!
  GarrisonLandingPageMinimapButton:SetScript('OnLeave', function(self) self:SetAlpha(0) end) -- Hover Disapears!
end

-- Set Minimap Position
function lm:SetPos(margin)
  margin = margin or 0
  Minimap:SetPoint(mPoint, mParent, mParentPoint, mPosx, mPosy - margin)
end

-- Mousewheel Scrolling (p3lim)
function lm:MouseScroll()
  MinimapZoomIn:Hide()
  MinimapZoomOut:Hide()
  Minimap:EnableMouseWheel()
  Minimap:SetScript('OnMouseWheel', function(self, direction)
    if(direction > 0) then
      MinimapZoomIn:Click()
    else
      MinimapZoomOut:Click()
    end
  end)
end

-- Quest Tracker
function lm:MoveQuestTracker()
  ObjectiveTrackerBlocksFrame:SetParent(Minimap)
  ObjectiveTrackerBlocksFrame:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", -125, -155)
  ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", -116 ,-159)

  -- Hide Stuff
  ObjectiveTrackerBlocksFrame.QuestHeader.Background:Hide()
  ObjectiveTrackerBlocksFrame.QuestHeader.Background.Show = noop
  ObjectiveTrackerBlocksFrame.AchievementHeader.Background:Hide()
  ObjectiveTrackerBlocksFrame.AchievementHeader.Background.Show = noop
end

-- Durability Frame
function lm:MoveDurability()
  hooksecurefunc(DurabilityFrame,"SetPoint",function(self,_,parent)
    if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
        DurabilityFrame:ClearAllPoints()
    DurabilityFrame:SetPoint("RIGHT", Minimap, "RIGHT", -75, -250)
    DurabilityFrame:SetScale(0.8)
    end
  end)
end

-- For Other Addons to know the Shape of the Minimap
function GetMinimapShape()
  return 'SQUARE'
end

function lm:ZONE_CHANGED(event)
  lm:TextColor()
  zone:SetText(GetMinimapZoneText())
end

function lm:ZONE_CHANGED_INDOORS(event)
  lm:TextColor()
  zone:SetText(GetMinimapZoneText())
end

function lm:ZONE_CHANGED_NEW_AREA(event)
  if event == "ZONE_CHANGED_NEW_AREA" and not WorldMapFrame:IsShown() then
    SetMapToCurrentZone() -- Sets Map to Current Zone so Text Updates Correctly
  end
  lm:TextColor()
  zone:SetText(GetMinimapZoneText())
end


function lm:ADDON_LOADED(event, addon,...)
  if (addon == "lumUI") then
    lm:Init()
    lm:RegisterEvent("ZONE_CHANGED")
    lm:RegisterEvent("ZONE_CHANGED_INDOORS")
    lm:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  end

  if(addon == "Blizzard_OrderHallUI") then
    lm:SetPos(25)
  end
end

-- ---------------------------------
-- > Events
-- ---------------------------------

lm:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
lm:RegisterEvent("ADDON_LOADED")

-- ---------------------------------
-- > Border
-- ---------------------------------

L:CreatePanel(false, true, "MinimapPanel", "Minimap", mWidth+8, mHeight+8, {{"TOPLEFT", Minimap, "TOPLEFT", -4,4}}, 32, 12, 0, 0.6)