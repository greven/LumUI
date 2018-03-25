local _, ns = ...

local L, C, G = unpack(select(2, ...))

-- -----------------------------------
-- > FUNCTIONS
-- -----------------------------------

-- Create Panel
function L:CreatePanel(classColored, hasShadow, fname, fparent, fwidth, fheight, fpoints, ftilesize, fedgesize, finsect, shadowalpha)
  local f = CreateFrame("Frame","Drop_"..fname,UIParent)
  if classColored then bColor = G.classColor else bColor = C.color.border end
  f:SetParent(fparent)
  f:SetFrameStrata("BACKGROUND")
  f:SetFrameLevel(1)
  f:SetWidth(fwidth)
  f:SetHeight(fheight)
  f:SetBackdrop({
    bgFile = G.media.bg, 
    edgeFile = G.media.border, 
    tile = false, 
    tileSize = ftilesize, 
    edgeSize = fedgesize, 
    insets = {left = finsect, right = finsect, top = finsect, bottom = finsect}
  })
  f:SetBackdropColor(C.color.bg.r, C.color.bg.g, C.color.bg.b, C.color.bg.a)
  f:SetBackdropBorderColor(bColor.r, bColor.g, bColor.b, bColor.a)
  for i,v in pairs(fpoints) do
    f:SetPoint(unpack(v))
  end
  
  if hasShadow then
    local s = CreateFrame("Frame",nil, f)
    s:SetFrameStrata("BACKGROUND")
    s:SetFrameLevel(0)
    s:SetPoint("TOPLEFT",f,"TOPLEFT", -4, 4)
    s:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT", 4, -4)
    s:SetBackdrop({
      bgFile = G.media.b, 
      edgeFile = G.media.glow, 
      tile = false, 
      tileSize = 32, 
      edgeSize = 5, 
      insets = {left = -5, right = -5, top = -5, bottom = -5}
    })
    s:SetBackdropColor(C.color.bg.r, C.color.bg.g, C.color.bg.b, C.color.bg.a)
    s:SetBackdropBorderColor(0, 0, 0, shadowalpha)
  end
end