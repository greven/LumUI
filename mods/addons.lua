-- ------------------------------------------------------------------------
-- Customize other addons...
-- ------------------------------------------------------------------------

local A, ns = ...

local L, C, G = unpack(select(2, ...))

local f = CreateFrame("Frame")

f:SetScript(
	"OnEvent",
	function(self, event, ...)
		f[event](self, ...)
	end
)

-- Bagnon
-- function f:styleBagnon()
--   print("Hello, WoW!")
-- end

-- if not IsAddOnLoaded("Bagnon") then
--   LoadAddOn("Bagnon")
-- else
--   f:styleBagnon()
-- end
