local _, ns = ...

local L, C, G = unpack(select(2, ...))

-- -----------------------------------
-- > FUNCTIONS
-- -----------------------------------

function L:RegisterCallback(event, callback, ...)
  if not self.eventFrame then
    self.eventFrame = CreateFrame("Frame")
    function self.eventFrame:OnEvent(event, ...)
      for callback, args in next, self.callbacks[event] do
        callback(args, ...)
      end
    end
    self.eventFrame:SetScript("OnEvent", self.eventFrame.OnEvent)
  end
  if not self.eventFrame.callbacks then self.eventFrame.callbacks = {} end
  if not self.eventFrame.callbacks[event] then self.eventFrame.callbacks[event] = {} end
  self.eventFrame.callbacks[event][callback] = {...}
  self.eventFrame:RegisterEvent(event)
end

function L:createText(f, layer, fontsize, flag, justifyh)
	local text = f:CreateFontString(nil, layer)
	text:SetFont(G.font, fontsize, flag)
	text:SetJustifyH(justifyh)
	return text
end

function L:createNumber(f, layer, fontsize, flag, justifyh)
	local text = f:CreateFontString(nil, layer)
	text:SetFont(G.numFont, fontsize, flag)
	text:SetJustifyH(justifyh)
	return text
end