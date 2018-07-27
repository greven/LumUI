local _, ns = ...

local L, C, G = unpack(select(2, ...))

local f = CreateFrame("Frame")

f:SetScript('OnEvent', function(self, event, ...)
	f[event](self, ...)
end)

-- f:RegisterEvent("PLAYER_ENTERING_WORLD")
-- function f:PLAYER_ENTERING_WORLD()
  
-- end

f:RegisterEvent("ADDON_LOADED")
function f:ADDON_LOADED(addon)
  if addon == 'LumUI' then
    print(addon)
  end
end