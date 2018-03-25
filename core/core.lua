local _, ns = ...

local L, C, G = unpack(select(2, ...))

-- -----------------------------------
-- > FUNCTIONS
-- -----------------------------------

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