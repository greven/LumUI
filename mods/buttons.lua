
-- rButtonTemplate_Lumen: theme
-- zork, 2016

-- Lumen Button Theme for rButtonTemplate

-----------------------------
-- Variables
-----------------------------

local A, L = ...

local f = CreateFrame("Frame")

f:SetScript('OnEvent', function(self, event, ...)
	f[event](self, ...)
end)

f:RegisterEvent("ADDON_LOADED")
function f:ADDON_LOADED(addon)
  if addon == 'rButtonTemplate' or addon == 'LumUI' then
    f:styleButtons()
  end
end

-----------------------------
-- mediapath
-----------------------------

local mediapath = "interface\\addons\\"..A.."\\media\\textures\\"
---

function f:styleButtons()
  -----------------------------
  -- copyTable
  -----------------------------

  local function copyTable(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
      copy = {}
      for orig_key, orig_value in next, orig, nil do
        copy[copyTable(orig_key)] = copyTable(orig_value)
      end
      setmetatable(copy, copyTable(getmetatable(orig)))
    else -- number, string, boolean, etc
      copy = orig
    end
    return copy
  end

  -----------------------------
  -- actionButtonConfig
  -----------------------------

  local actionButtonConfig = {}

  --backdrop
  actionButtonConfig.backdrop = {
    bgFile = mediapath.."backdrop",
    edgeFile = mediapath.."backdropBorder",
    tile = false,
    tileSize = 32,
    edgeSize = 5,
    insets = {
      left = 5,
      right = 5,
      top = 5,
      bottom = 5,
    },
    backgroundColor = {0.2,0.2,0.2,0.9},
    borderColor = {0.05,0.05,0.05,0.8},
    points = {
      {"TOPLEFT", -3, 3 },
      {"BOTTOMRIGHT", 3, -3 },
    },
  }

  --icon
  actionButtonConfig.icon = {
    texCoord = {0.1,0.9,0.1,0.9},
    points = {
      {"TOPLEFT", 1, -1 },
      {"BOTTOMRIGHT", -1, 1 },
    },
  }

  --flyoutBorder
  actionButtonConfig.flyoutBorder = {
    file = "",
  }

  --flyoutBorderShadow
  actionButtonConfig.flyoutBorderShadow = {
    file = ""
  }

  --border
  actionButtonConfig.border = {
    file = mediapath.."border",
    blendMode = "ADD",
    texCoord = {0,1,0,1},
    points = {
      {"TOPLEFT", 0, 0 },
      {"BOTTOMRIGHT", 0, 0 },
    },
  }

  --normalTexture
  actionButtonConfig.normalTexture = {
    file = mediapath.."normal",
    color = {0.05,0.05,0.05,1},
    points = {
      {"TOPLEFT", 0, 0 },
      {"BOTTOMRIGHT", 0, 0 },
    },
  }

  --pushedTexture
  actionButtonConfig.pushedTexture = {
    file = mediapath.."pushed",
    points = {
      {"TOPLEFT", 0, 0 },
      {"BOTTOMRIGHT", 0, 0 },
    },
  }
  --highlightTexture
  actionButtonConfig.highlightTexture = {
    file = mediapath.."highlight",
    color = {0.3,0.3,0.3,0.8},
    points = {
      {"TOPLEFT", 0, 0 },
      {"BOTTOMRIGHT", 0, 0 },
    },
  }
  --checkedTexture
  actionButtonConfig.checkedTexture = {
    file = mediapath.."checked",
    points = {
      {"TOPLEFT", 0, 0 },
      {"BOTTOMRIGHT", 0, 0 },
    },
  }

  --cooldown
  actionButtonConfig.cooldown = {
    points = {
      {"TOPLEFT", 0, 0 },
      {"BOTTOMRIGHT", 0, 0 },
    },
  }

  --name (macro name fontstring)
  actionButtonConfig.name = {
    font = { STANDARD_TEXT_FONT, 10, "OUTLINE"},
    points = {
      {"BOTTOMLEFT", 0, 0 },
      {"BOTTOMRIGHT", 0, 0 },
    },
    alpha = 0,
  }

  --hotkey
  actionButtonConfig.hotkey = {
    font = { STANDARD_TEXT_FONT, 11, "OUTLINE"},
    points = {
      {"TOPRIGHT", 0, 0 },
      {"TOPLEFT", 0, 0 },
    },
    alpha = 0,
  }

  --count
  actionButtonConfig.count = {
    font = { STANDARD_TEXT_FONT, 11, "THICKOUTLINE"},
    points = {
      {"BOTTOMRIGHT", -1, 4 },
    },
  }

  rButtonTemplate:StyleAllActionButtons(actionButtonConfig)
  --style rActionBar vehicle exit button
  rButtonTemplate:StyleActionButton(_G["rActionBarVehicleExitButton"],actionButtonConfig)

  -----------------------------
  -- itemButtonConfig
  -----------------------------

  local itemButtonConfig = {}

  itemButtonConfig.backdrop = copyTable(actionButtonConfig.backdrop)
  itemButtonConfig.icon = copyTable(actionButtonConfig.icon)
  itemButtonConfig.count = copyTable(actionButtonConfig.count)
  itemButtonConfig.stock = copyTable(actionButtonConfig.name)
  itemButtonConfig.stock.alpha = 1
  itemButtonConfig.border = copyTable(actionButtonConfig.border)
  itemButtonConfig.normalTexture = copyTable(actionButtonConfig.normalTexture)

  --rButtonTemplate:StyleItemButton
  local itemButtons = { MainMenuBarBackpackButton, CharacterBag0Slot, CharacterBag1Slot, CharacterBag2Slot, CharacterBag3Slot }
  for i, button in next, itemButtons do
    rButtonTemplate:StyleItemButton(button, itemButtonConfig)
  end

  -----------------------------
  -- extraButtonConfig
  -----------------------------

  local extraButtonConfig = copyTable(actionButtonConfig)
  extraButtonConfig.buttonstyle = { file = "" }

  --rButtonTemplate:StyleExtraActionButton
  rButtonTemplate:StyleExtraActionButton(extraButtonConfig)
end
