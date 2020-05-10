-- --------------------------------------
-- Light Chat mods
-- Credits: rChat, BasicChatMods, TukUI
-- --------------------------------------

local _, ns = ...

-- local L, C, G = unpack(select(2, ...))

local lc = CreateFrame("Frame")

local _G = _G
local format = format
local Toast = BNToastFrame
local Noop = function() end
local dummy = function(self) self:Hide() end

lc:SetScript('OnEvent', function(self, event, ...)
	lc[event](self, ...)
end)

-- -------------------------

function lc:StyleChatFrame(self)
  if not self then return end
  local FrameName = self:GetName()
  local ButtonFrame = _G[FrameName.."ButtonFrame"]
  local TabText = _G[FrameName.."TabText"]
  local EditBox = _G[FrameName.."EditBox"]

  -- Resizing
  self:SetClampRectInsets(0, 0, 0, 0)
	self:SetClampedToScreen(false)
	self:SetFading(false)

  -- Font
  self:SetFont(STANDARD_TEXT_FONT, 13, "THINOUTLINE")
  self:SetShadowOffset(1, -2)
  self:SetShadowColor(0, 0, 0, 0.20)

  -- Fading
  self:SetFading(true)

  -- Hide textures
	-- for i = 1, #CHAT_FRAME_TEXTURES do
	-- 	_G[FrameName..CHAT_FRAME_TEXTURES[i]]:SetTexture(nil)
	-- end

  -- Hide button frame
  ButtonFrame:HookScript("OnShow", ButtonFrame.Hide)
  ButtonFrame:Hide()

  TabText:SetFont(STANDARD_TEXT_FONT, 11, "THINOUTLINE")
	TabText.SetFont = Noop

  EditBox:ClearAllPoints()
  EditBox:SetAltArrowKeyMode(false)

  if FrameName == "ChatFrame2" then
    EditBox:SetPoint("BOTTOM", self, "TOP", 0, 24+24)
  else
    EditBox:SetPoint("BOTTOM", self, "TOP", 0, 24)
  end
  EditBox:SetPoint("LEFT", self, -2, 0)
  EditBox:SetPoint("RIGHT", self, 24, 0)
  lc:SetBorder(EditBox)

  -- Textures
  _G[FrameName.."TabLeft"]:SetAlpha(0)
	_G[FrameName.."TabMiddle"]:SetAlpha(0)
	_G[FrameName.."TabRight"]:SetAlpha(0)

	_G[FrameName.."TabSelectedLeft"]:SetAlpha(0)
	_G[FrameName.."TabSelectedMiddle"]:SetAlpha(0)
  _G[FrameName.."TabSelectedRight"]:SetAlpha(0)

	_G[FrameName.."TabHighlightLeft"]:SetAlpha(0)
	_G[FrameName.."TabHighlightMiddle"]:SetAlpha(0)
  _G[FrameName.."TabHighlightRight"]:SetAlpha(0)

  _G[FrameName.."TabSelectedLeft"]:SetAlpha(0)
	_G[FrameName.."TabSelectedMiddle"]:SetAlpha(0)
	_G[FrameName.."TabSelectedRight"]:SetAlpha(0)

	_G[FrameName.."ButtonFrameMinimizeButton"]:SetAlpha(0)
	_G[FrameName.."ButtonFrame"]:SetAlpha(0)

	_G[FrameName.."EditBoxFocusLeft"]:SetAlpha(0)
	_G[FrameName.."EditBoxFocusMid"]:SetAlpha(0)
	_G[FrameName.."EditBoxFocusRight"]:SetAlpha(0)

	_G[FrameName.."EditBoxLeft"]:SetAlpha(0)
	_G[FrameName.."EditBoxMid"]:SetAlpha(0)
  _G[FrameName.."EditBoxRight"]:SetAlpha(0)
end

function lc:HideMoreStuff()
  -- Other Buttons
  ChatFrameMenuButton:Hide()
  ChatFrameMenuButton:SetScript("OnShow", dummy)
  QuickJoinToastButton:Hide()
  QuickJoinToastButton:SetScript("OnShow", dummy)
  ChatFrameChannelButton:Hide()
  ChatFrameChannelButton:SetScript("OnShow", dummy)
end

-- OnMOuseScroll
local function OnMOuseScroll(self, direction)
  if(direction > 0) then
    if(IsShiftKeyDown()) then self:ScrollToTop() else self:ScrollUp() end
  else
    if(IsShiftKeyDown()) then self:ScrollToBottom() else self:ScrollDown() end
  end
end

function lc:AltInviteUrlCopy()
  -- Replace the default setitemref and use it to parse links
  -- for alt invite and url copy
  local DefaultSetItemRef = SetItemRef
  local function NewSetItemRef(link, ...)
    local type, value = link:match("(%a+):(.+)")
    if IsAltKeyDown() and type == "player" then
      InviteUnit(value:match("([^:]+)"))
    elseif (type == "url") then
      local eb = LAST_ACTIVE_CHAT_EDIT_BOX or ChatFrame1EditBox
      if not eb then return end
      eb:SetText(value)
      eb:SetFocus()
      eb:HighlightText()
      if not eb:IsShown() then eb:Show() end
    else
      return DefaultSetItemRef(link, ...)
    end
  end
  SetItemRef = NewSetItemRef
end

function lc:SmartChat()
	SlashCmdList["SMARTGROUP"] = function(msg)
		if msg and msg:len() > 0 then
			SendChatMessage(msg, (IsInGroup(2) and "INSTANCE_CHAT") or (IsInRaid() and "RAID") or (IsInGroup() and "PARTY") or "SAY")
		end
	end
	SLASH_SMARTGROUP1 = "/gr"
	SLASH_SMARTGROUP2 = "/group"
end

function lc:TellTarget()
  SlashCmdList["TELLTARGET"] = function(msg)
    if UnitIsPlayer("target") and UnitIsFriend("player", "target") and msg and msg:len() > 0 then
      local name, realm = UnitName("target")
      if realm then
        name = name.."-"..realm
      end
      SendChatMessage(msg, "WHISPER", nil, name)
    end
  end
  SLASH_TELLTARGET1 = "/tt"
  SLASH_TELLTARGET2 = "/wt"
end

function lc:AdditionalFeatures()
  -- Scrolling
  FloatingChatFrame_OnMouseScroll = OnMOuseScroll

  -- Editbox font
  ChatFontNormal:SetFont(STANDARD_TEXT_FONT, 13, "THINOUTLINE")
  ChatFontNormal:SetShadowOffset(1, -2)
  ChatFontNormal:SetShadowColor(0, 0, 0, 0.20)

  -- Don't cut the toastframe
  Toast:SetClampedToScreen(true)
  Toast:SetClampRectInsets(-15,15,15,-15)

  -- Font size
  CHAT_FONT_HEIGHTS = {10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}

  -- Tabs
  CHAT_TAB_HIDE_DELAY = 1
  CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1
  CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0
  CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
  CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
  CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
  CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1

  -- Channels
  CHAT_WHISPER_GET              = "From %s "
  CHAT_WHISPER_INFORM_GET       = "To %s "
  CHAT_BN_WHISPER_GET           = "From %s "
  CHAT_BN_WHISPER_INFORM_GET    = "To %s "
  CHAT_YELL_GET                 = "%s "
  CHAT_SAY_GET                  = "%s "
  CHAT_BATTLEGROUND_GET         = "|Hchannel:Battleground|hBG.|h %s: "
  CHAT_BATTLEGROUND_LEADER_GET  = "|Hchannel:Battleground|hBGL.|h %s: "
  CHAT_GUILD_GET                = "|Hchannel:Guild|hG.|h %s: "
  CHAT_OFFICER_GET              = "|Hchannel:Officer|hGO.|h %s: "
  CHAT_PARTY_GET                = "|Hchannel:Party|hP.|h %s: "
  CHAT_PARTY_LEADER_GET         = "|Hchannel:Party|hPL.|h %s: "
  CHAT_PARTY_GUIDE_GET          = "|Hchannel:Party|hPG.|h %s: "
  CHAT_RAID_GET                 = "|Hchannel:Raid|hR.|h %s: "
  CHAT_RAID_LEADER_GET          = "|Hchannel:Raid|hRL.|h %s: "
  CHAT_RAID_WARNING_GET         = "|Hchannel:RaidWarning|hRW.|h %s: "
  CHAT_INSTANCE_CHAT_GET        = "|Hchannel:Battleground|hI.|h %s: "
  CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:Battleground|hIL.|h %s: "
  CHAT_FLAG_AFK = "<AFK> "
  CHAT_FLAG_DND = "<DND> "
  CHAT_FLAG_GM = "<[GM]> "

  -- Remove the annoying guild loot messages by replacing them
  -- with the original ones
  YOU_LOOT_MONEY_GUILD = YOU_LOOT_MONEY
  LOOT_MONEY_SPLIT_GUILD = LOOT_MONEY_SPLIT

  lc:AltInviteUrlCopy()
  lc:SmartChat()
  lc:TellTarget()
end

function lc:CreateAdditionalChatFrames()
  -- Note: See https://github.com/p3lim-wow/Inomena_Settings/blob/master/chat.lua
  CreateChatFrame('Whisper', 'BN_WHISPER', 'WHISPER', 'IGNORED')
  CreateChatFrame('Loot', 'LOOT', 'COMBAT_FACTION_CHANGE', 'CURRENCY', 'MONEY')
end

local function init()
  for i = 1, NUM_CHAT_WINDOWS do
    local chatframe = _G["ChatFrame"..i]
    local Tab = _G["ChatFrame"..i.."Tab"]

    -- Tabs
    Tab.noMouseAlpha = 0
    Tab:SetAlpha(0)

    lc:StyleChatFrame(chatframe)
  end

  lc:HideMoreStuff()
  lc:AdditionalFeatures()
  -- lc:CreateAdditionalChatFrames()
end

-- -------------------------

function lc:SetBorder(frame)
	frame:SetBackdrop{
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    tile = true,
    tileSize = 24,
    edgeSize = 10,
    edgeFile = [[Interface\AddOns\LumUI\media\Textures\border_squared]],
    insets = {left = 0, right = 0, top = 0, bottom = 0},
  }
  frame:SetBackdropColor(0, 0, 0, 0.7)
  frame:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)
end

lc:RegisterEvent("PLAYER_LOGIN")
function lc:PLAYER_LOGIN(addon)
  init()
end

