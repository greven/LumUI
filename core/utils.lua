local _, ns = ...

local L, C, G = unpack(select(2, ...))

-- -----------------------------------
-- > FUNCTIONS
-- -----------------------------------

function L:ShortNumber(v)
  if v > 1E10 then
    return (floor(v/1E9)).."|cffbbbbbbb|r"
  elseif v > 1E9 then
    return (floor((v/1E9)*10)/10).."|cffbbbbbbb|r"
  elseif v > 1E7 then
    return (floor(v/1E6)).."|cffbbbbbbm|r"
  elseif v > 1E6 then
    return (floor((v/1E6)*10)/10).."|cffbbbbbbm|r"
  elseif v > 1E4 then
    return (floor(v/1E3)).."|cffbbbbbbk|r"
  elseif v > 1E3 then
    return (floor((v/1E3)*10)/10).."|cffbbbbbbk|r"
  else
    return v
  end
end

function L:FormatInt(number)
  local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
  int = int:reverse():gsub("(%d%d%d)", "%1,")
  return minus .. int:reverse():gsub("^,", "") .. fraction
end


-- Format Money
function L:FormatMoney(money)
  local gold = math.floor(money / 1e4)
  local silver = math.floor((money / 1e2) % 1e2)
  local copper = math.floor(money % 1e2)

  local output = string.format('|cffffff66%d|r', gold)
  output = string.format('%s.|cffc0c0c0%d|r', output, silver)
  output = string.format('%s.|cffcc9900%d|r', output, copper)

  return output
end

-- Create Panel
function L:CreatePanel(classColored, hasShadow, fname, fparent, fwidth, fheight, fpoints, ftilesize, fedgesize, finsect, shadowalpha)
  local f = CreateFrame("Frame", fname .. "Border", UIParent)
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

  return f
end