-- ------------------------------------------------------------------------
-- Hide or customize Blizzard default frames / addons
-- ------------------------------------------------------------------------

local A, ns = ...

local L, C, G = unpack(select(2, ...))

local eventframe = CreateFrame("Frame")

eventframe:SetScript(
  "OnEvent",
  function(self, event, ...)
    eventframe[event](self, ...)
  end
)

-- Binding UI
local function SetupBindingUI()
  -- QuickKeybind Mode

  local QuickFrame = _G.QuickKeybindFrame
  QuickFrame.phantomExtraActionButton:ClearAllPoints()
  QuickFrame.phantomExtraActionButton:SetPoint("RIGHT", "LumUIBar1", "LEFT", -8, 0)

  -- QuickFrame.MultiBarBottomLeft.QuickKeybindGlow:SetAlpha(0)
end

function eventframe:ADDON_LOADED(addon)
  if addon == "Blizzard_BindingUI" then
    SetupBindingUI()
  end
end

eventframe:RegisterEvent("ADDON_LOADED", OnAddonLoaded)
