-- --------------------------------------------
-- Credits: Katae, p3lim, Zork.
-- --------------------------------------------
local A, ns = ...

local L, C, G = unpack(select(2, ...))

local lm = CreateFrame("Frame", A .. "Minimap", UIParent)

local cfg = C.settings.minimap

-- ---------------------------------
-- > Variables
-- ---------------------------------

local zone

-- Config
local mParent = cfg.parent
local mParentPoint = cfg.parentPoint
local mPoint = cfg.point
local mWidth = cfg.width
local mHeight = cfg.height
local mPosx = cfg.posX
local mPosy = cfg.posY
local mScale = cfg.scale
local showZone = cfg.showZone
local PvPcolor = cfg.pvpColor
local locationTextOnHover = cfg.locationTextOnHover
local clockOnHover = cfg.clockOnHover
local customizeQuestTracker = cfg.customizeQuestTracker

LumuiConfig = LumuiConfig or {}
LumuiConfig.minimap = C.settings.minimap

-- ---------------------------------
-- > Functions
-- ---------------------------------

function lm:TextColor()
    if PvPcolor then
        local pvpType = GetZonePVPInfo()

        if (pvpType == "sanctuary") then
            zone:SetTextColor(0.41, 0.8, 0.94)
        elseif (pvpType == "arena") then
            zone:SetTextColor(1.0, 0.1, 0.1)
        elseif (pvpType == "friendly") then
            zone:SetTextColor(0.1, 1.0, 0.1)
        elseif (pvpType == "hostile") then
            zone:SetTextColor(1.0, 0.1, 0.1)
        elseif (pvpType == "combat") then
            zone:SetTextColor(1.0, 0.1, 0.1)
        elseif (pvpType == "contested") then
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
        zone:SetFont(cfg.font, cfg.fontSize, cfg.fontOutline)
        lm:TextColor()
        zone:SetShadowColor(0, 0, 0, 1)
        zone:SetAllPoints(zf)
        zone:SetText(GetMinimapZoneText())
        if locationTextOnHover then
            zone:Hide()
            zf:SetScript("OnEnter", function(self) zone:Show() end) -- Hover it Appears! Magic!!
            zf:SetScript("OnLeave", function(self) zone:Hide() end) -- Hover Disapears!
        end
    end

    lm:MouseScroll()

    if customizeQuestTracker then lm:TweakQuestTracker() end

    lm:MoveDurability()

    -- MinimapCluster
    MinimapCluster:SetFrameStrata("BACKGROUND")

    -- Position and Scale
    Minimap:ClearAllPoints()
    Minimap:SetScale(mScale)
    Minimap:SetSize(mWidth, mHeight)
    lm:SetPos() -- Set Minimap Position

    -- Hide Some Crap

    for _, f in pairs {
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
        MiniMapLFGFrameBorder -- LFG Border
    } do
        f.Show = f.Hide
        f:Hide()
    end

    -- Hide More Crap
    if not IsAddOnLoaded("Blizzard_TimeManager") then
        LoadAddOn("Blizzard_TimeManager")
    end
    TimeManagerClockButton:GetRegions():Hide() -- Clock Frame Border
    TimeManagerClockButton:SetAlpha(0) -- Sets Alpha to Zero so clock doesn't show initially
    if clockOnHover then
        TimeManagerClockButton:SetScript("OnEnter",
                                         function(self)
            self:SetAlpha(100)
        end) -- Hover it Appears! Magic!!
        TimeManagerClockButton:SetScript("OnLeave",
                                         function(self) self:SetAlpha(0) end) -- Hover Disapears!
    end
    TimeManagerClockButton:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -16)
    TimeManagerClockTicker:SetFont(cfg.font, cfg.fontSize, cfg.fontOutline) -- Clock Font
    TimeManagerClockTicker:SetPoint("CENTER", TimeManagerClockButton, 0, 0)
    TimeManagerClockTicker:SetShadowOffset(0, 0)

    -- Vehicle Position Indicator
    VehicleSeatIndicator:SetAlpha(0)

    -- Tracking Button
    MiniMapTracking:ClearAllPoints()
    MiniMapTracking:SetParent(Minimap)
    MiniMapTracking:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -1, -2)
    MiniMapTrackingButton:SetHighlightTexture ""

    -- Queue Status Icon
    QueueStatusMinimapButton:ClearAllPoints()
    QueueStatusMinimapButton:SetParent(Minimap)
    QueueStatusMinimapButton:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 0, 0)
    QueueStatusMinimapButton:SetFrameLevel(15)
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
    GarrisonLandingPageMinimapButton:SetPoint("BOTTOMRIGHT", Minimap,
                                              "BOTTOMRIGHT", 0, 0)
    GarrisonLandingPageMinimapButton:SetScale(0.7)
    GarrisonLandingPageMinimapButton:SetAlpha(0)
    GarrisonLandingPageMinimapButton:SetScript("OnEnter", function(self)
        self:SetAlpha(100)
    end) -- Hover it Appears! Magic!!
    GarrisonLandingPageMinimapButton:SetScript("OnLeave", function(self)
        self:SetAlpha(0)
    end) -- Hover Disapears!
end

-- Set Minimap Position
function lm:SetPos(margin)
    margin = margin or 0
    Minimap:SetPoint(mPoint, mParent, mParentPoint, mPosx, mPosy - margin)
end

-- Set Minimap Position based on top Margin elements
function lm:SetMinimapPosition()
    local margin = 0

    -- Order Hall
    if OrderHallCommandBar then
        if OrderHallCommandBar:IsShown() then
            margin = margin + OrderHallCommandBar.Background:GetHeight()
        end
    end
    lm:SetPos(margin)
end

-- Mousewheel Scrolling (p3lim)
function lm:MouseScroll()
    MinimapZoomIn:Hide()
    MinimapZoomOut:Hide()
    Minimap:EnableMouseWheel()
    Minimap:SetScript("OnMouseWheel", function(self, direction)
        if (direction > 0) then
            MinimapZoomIn:Click()
        else
            MinimapZoomOut:Click()
        end
    end)
end

-- Quest Tracker (Credit: Nibelheim)
function lm:TweakQuestTracker()
    local tracker = ObjectiveTrackerFrame
    local tint = 1.25

    if IsAddOnLoaded("Blizzard_ObjectiveTracker") then
        hooksecurefunc("ObjectiveTracker_Update", function(_, id)
            if tracker.MODULES then
                for i = 1, #tracker.MODULES do
                    tracker.MODULES[i].Header.Background:SetAtlas(nil)
                    tracker.MODULES[i].Header.Text:SetTextColor(0.8, 0.8, 0.8)
                end
            end
        end)

        hooksecurefunc(QUEST_TRACKER_MODULE, "SetBlockHeader",
                       function(_, block)
            block.HeaderText:SetFont(cfg.font, 14, "OUTLINE")
            block.HeaderText:SetShadowColor(0, 0, 0, 0.4)
            block.HeaderText:SetTextColor(G.classColor.r * tint,
                                          G.classColor.g * tint,
                                          G.classColor.b * tint)
            block.HeaderText:SetJustifyH("LEFT")
        end)

        local function hoverquest(_, block)
            block.HeaderText:SetTextColor(G.classColor.r * tint,
                                          G.classColor.g * tint,
                                          G.classColor.b * tint)
        end
        hooksecurefunc(QUEST_TRACKER_MODULE, "OnBlockHeaderEnter", hoverquest)
        hooksecurefunc(QUEST_TRACKER_MODULE, "OnBlockHeaderLeave", hoverquest)

        hooksecurefunc(ACHIEVEMENT_TRACKER_MODULE, "SetBlockHeader",
                       function(_, block)
            local trackedAchievements = {GetTrackedAchievements()}
            for i = 1, #trackedAchievements do
                local achieveID = trackedAchievements[i]
                local _, achievementName, _, completed, _, _, _, description, _,
                      icon, _, _, wasEarnedByMe = GetAchievementInfo(achieveID)
                if not wasEarnedByMe then
                    block.HeaderText:SetFont(cfg.font, 14, "OUTLINE")
                    block.HeaderText:SetShadowColor(0, 0, 0, 1)
                    block.HeaderText:SetTextColor(0, 0.5, 0.9)
                    block.HeaderText:SetJustifyH("LEFT")
                    block.HeaderText:SetWidth(200)
                end
            end
        end)

        local function hoverachieve(_, block)
            block.HeaderText:SetTextColor(0, 0.5, 0.9)
        end
        hooksecurefunc(ACHIEVEMENT_TRACKER_MODULE, "OnBlockHeaderEnter",
                       hoverachieve)
        hooksecurefunc(ACHIEVEMENT_TRACKER_MODULE, "OnBlockHeaderLeave",
                       hoverachieve)

        -- Resize and Reposition
        local anchor = CreateFrame("Frame", "A..WatchFrame", UIParent)
        anchor:SetSize(250, 20)
        anchor:SetPoint(cfg.questTrackerAnchor, "UIParent",
                        cfg.questTrackerAnchorParent, cfg.questTrackerPosX,
                        cfg.questTrackerPosY)

        tracker:ClearAllPoints()
        tracker:SetPoint("TOPLEFT", anchor, "TOPLEFT")
        tracker:SetHeight(G.ScreenHeight - 600)
        tracker.ClearAllPoints = function() end
        tracker.SetPoint = function() end
    end

    -- local anchor = CreateFrame("Frame", "A..WatchFrame", UIParent)
    -- local tracker = ObjectiveTrackerFrame
    -- local tint = 1.6
    -- anchor:SetSize(250, 20)
    -- anchor:SetPoint(
    --   cfg.questTrackerAnchor,
    --   "UIParent",
    --   cfg.questTrackerAnchorParent,
    --   cfg.questTrackerPosX,
    --   cfg.questTrackerPosY
    -- )
    -- tracker:ClearAllPoints()
    -- tracker:SetPoint("TOPLEFT", anchor, "TOPLEFT")
    -- -- tracker:SetHeight(G.screenheight - 600)
    -- -- tracker:SetFrameStrata("MEDIUM")
    -- tracker:SetFrameLevel(15)
    -- tracker.ClearAllPoints = function()
    -- end
    -- tracker.SetPoint = function()
    -- end
    -- if IsAddOnLoaded("Blizzard_ObjectiveTracker") then
    --   hooksecurefunc(
    --     "ObjectiveTracker_Update",
    --     function(reason, id)
    --       if tracker.MODULES then
    --         for i = 1, #tracker.MODULES do
    --           tracker.MODULES[i].Header.Background:SetAtlas(nil)
    --           -- tracker.MODULES[i].Header.Text:SetFont(cfg.font, 14, "OUTLINE")
    --           -- tracker.MODULES[i].Header.Text:SetShadowColor(0, 0, 0, 0.1)
    --           tracker.MODULES[i].Header.Text:SetTextColor(0.9, 0.9, 0.9)
    --           -- tracker.MODULES[i].Header.Text:ClearAllPoints()
    --           -- tracker.MODULES[i].Header.Text:SetPoint("LEFT", tracker.MODULES[i].Header, 10, 0)
    --           -- tracker.MODULES[i].Header.Text:SetJustifyH("LEFT")
    --         end
    --       end
    --       -- tracker.HeaderMenu.Title:SetFont(cfg.font, 16, "OUTLINE")
    --     end
    --   )
    -- end
    -- hooksecurefunc(
    --   QUEST_TRACKER_MODULE,
    --   "SetBlockHeader",
    --   function(_, block)
    --     block.HeaderText:SetFont(cfg.font, 14, "OUTLINE")
    --     block.HeaderText:SetShadowColor(0, 0, 0, 1)
    --     block.HeaderText:SetTextColor(G.classColor.r * tint, G.classColor.g * tint, G.classColor.b * tint)
    --     block.HeaderText:SetJustifyH("LEFT")
    --   end
    -- )
    -- local function hoverquest(_, block)
    --   block.HeaderText:SetTextColor(G.classColor.r * tint, G.classColor.g * tint, G.classColor.b * tint)
    -- end
    -- hooksecurefunc(QUEST_TRACKER_MODULE, "OnBlockHeaderEnter", hoverquest)
    -- hooksecurefunc(QUEST_TRACKER_MODULE, "OnBlockHeaderLeave", hoverquest)
    -- hooksecurefunc(
    --   ACHIEVEMENT_TRACKER_MODULE,
    --   "SetBlockHeader",
    --   function(_, block)
    --     local trackedAchievements = {GetTrackedAchievements()}
    --     for i = 1, #trackedAchievements do
    --       local achieveID = trackedAchievements[i]
    --       local _, achievementName, _, completed, _, _, _, description, _, icon, _, _, wasEarnedByMe =
    --         GetAchievementInfo(achieveID)
    --       if not wasEarnedByMe then
    --         block.HeaderText:SetFont(cfg.font, 14, "OUTLINE")
    --         block.HeaderText:SetShadowColor(0, 0, 0, 1)
    --         block.HeaderText:SetTextColor(0, 0.5, 0.9)
    --         block.HeaderText:SetJustifyH("LEFT")
    --         block.HeaderText:SetWidth(200)
    --       end
    --     end
    --   end
    -- )
    -- local function hoverachieve(_, block)
    --   block.HeaderText:SetTextColor(0, 0.5, 0.9)
    -- end
    -- hooksecurefunc(ACHIEVEMENT_TRACKER_MODULE, "OnBlockHeaderEnter", hoverachieve)
    -- hooksecurefunc(ACHIEVEMENT_TRACKER_MODULE, "OnBlockHeaderLeave", hoverachieve)
    -- Collapse Quest Tracker in instance
    -- Callback PLAYER_ENTERING_WORLD
    -- L:RegisterCallback("PLAYER_ENTERING_WORLD", function()
    --   if IsInInstance() then
    --     ObjectiveTracker_Collapse()
    --   else
    --     ObjectiveTracker_Expand()
    --   end
    -- end)
end

-- Durability Frame
function lm:MoveDurability()
    hooksecurefunc(DurabilityFrame, "SetPoint", function(self, _, parent)
        if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
            DurabilityFrame:ClearAllPoints()
            DurabilityFrame:SetPoint("BOTTOM", Minimap, "TOP", 0, 250)
            DurabilityFrame:SetScale(0.8)
        end
    end)
end

function lm:PLAYER_LOGIN(event)
    lm:TextColor()
    zone:SetText(GetMinimapZoneText())
    -- lm:SetMinimapPosition()
end

function lm:PLAYER_ENTERING_WORLD()
    lm:TextColor()
    zone:SetText(GetMinimapZoneText())
    -- lm:SetMinimapPosition()
end

function lm:ZONE_CHANGED(event)
    lm:TextColor()
    zone:SetText(GetMinimapZoneText())
    -- lm:SetMinimapPosition()
end

function lm:ZONE_CHANGED_INDOORS(event)
    lm:TextColor()
    zone:SetText(GetMinimapZoneText())
    -- lm:SetMinimapPosition()
end

function lm:ZONE_CHANGED_NEW_AREA(event)
    -- if event == "ZONE_CHANGED_NEW_AREA" and not WorldMapFrame:IsShown() then
    --   SetMapToCurrentZone() -- Sets Map to Current Zone so Text Updates Correctly
    -- end
    lm:TextColor()
    zone:SetText(GetMinimapZoneText())
    -- lm:SetMinimapPosition()
end

function lm:ADDON_LOADED(event, addon, ...)
    -- Make Minimap Square
    Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8X8")

    -- if LumuiConfig and not LumuiConfig.minimap then
    -- Revert the Minimap back to round!
    -- Minimap:SetMaskTexture("Interface\\Addons\\LumUI\\media\\Textures\\circle")
    -- end

    if (addon == A and LumuiConfig.minimap) then
        lm:Init()
        lm:RegisterEvent("PLAYER_LOGIN")
        lm:RegisterEvent("PLAYER_ENTERING_WORLD")
        lm:RegisterEvent("ZONE_CHANGED")
        lm:RegisterEvent("ZONE_CHANGED_INDOORS")
        lm:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        -- lm:SetMinimapPosition()
        -- Border
        L:CreatePanel(false, true, "MinimapPanel", "Minimap", mWidth + 8,
                      mHeight + 8, {{"TOPLEFT", Minimap, "TOPLEFT", -4, 4}}, 32,
                      12, 0, 0.6)
    end
end

-- ---------------------------------
-- > Events
-- ---------------------------------

lm:SetScript("OnEvent", function(self, event, ...)
    if self[event] then return self[event](self, event, ...) end
end)
lm:RegisterEvent("ADDON_LOADED")
