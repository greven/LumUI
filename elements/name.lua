-- -----------------------------------------------------
-- Name (Unit Names)
-- -----------------------------------------------------

local L, C, G = unpack(select(2, ...))

local f = CreateFrame("Frame", "LumNames")
f:SetScript(
  "OnEvent",
  function(self, event, ...)
    self[event](self, ...)
  end
)

-- function f:UNIT_NAME_UPDATE(addon)
--   print(addon)
-- end
-- f:RegisterUnitEvent("UNIT_NAME_UPDATE")

-- function f:ADDON_LOADED(addon)
--   print("Addon Loaded")
-- end
-- f:RegisterEvent("ADDON_LOADED")
