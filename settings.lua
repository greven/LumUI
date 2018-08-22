local addon, ns = ...

local L, C, G = unpack(select(2, ...))

-- Settings GUI

local function Basic(self)
  local Title = self:CreateTitle()
	Title:SetPoint('TOPLEFT', 16, -16)
	Title:SetText(addon)

  local Description = self:CreateDescription()
	Description:SetPoint('TOPLEFT', Title, 'BOTTOMLEFT', 0, -8)
	Description:SetPoint('RIGHT', -32, 0)
	Description:SetText('Settings for LumUI')

  local ModsTitle = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
  ModsTitle:SetPoint('TOPLEFT', Description, 'BOTTOMLEFT', 0, -32)
  ModsTitle:SetTextColor(1,1,1)
	ModsTitle:SetText('Mods')

  local ModsDescription = self:CreateDescription()
  ModsDescription:SetPoint('TOPLEFT', ModsTitle, 'BOTTOMLEFT', 0, -8)
  ModsDescription:SetPoint('RIGHT', -32, 0)
  ModsDescription:SetTextColor(0.6,0.6,0.6)
  ModsDescription:SetText('Enable or disable specific modifications')

  local ActionBars = self:CreateCheckButton('actionbar')
	ActionBars:SetPoint('TOPLEFT', ModsDescription, 'BOTTOMLEFT', -2, -10)
	ActionBars:SetText('ActionBars')
  ActionBars.tooltipText = 'ActionBars'
  ActionBars.tooltipRequirement = 'Customizes the default Blizzard ActionBars.'

  local Auras = self:CreateCheckButton('auras')
  Auras:SetPoint('TOPLEFT', ActionBars, 'BOTTOMLEFT', 0, -10)
  Auras:SetText('Auras')
  Auras.tooltipText = 'Auras'
  Auras.tooltipRequirement = 'Customizes the default Blizzard Buffs / Debuffs.'

  local Buttons = self:CreateCheckButton('buttons')
  Buttons:SetPoint('TOPLEFT', Auras, 'BOTTOMLEFT', 0, -10)
  Buttons:SetText('Buttons')
  Buttons.tooltipText = 'Buttons'
  Buttons.tooltipRequirement = 'Skins the ActionBars buttons.'

  local CombatText = self:CreateCheckButton('combatText')
  CombatText:SetPoint('TOPLEFT', Buttons, 'BOTTOMLEFT', 0, -10)
  CombatText:SetText('Combat Text')
  CombatText.tooltipText = 'CombatText'
  CombatText.tooltipRequirement = 'Small tweaks to the default Blizzard Combat Text.'

  local Minimap = self:CreateCheckButton('minimap')
  Minimap:SetPoint('TOPLEFT', CombatText, 'BOTTOMLEFT', 0, -10)
  Minimap:SetText('Minimap')
  Minimap.tooltipText = 'Minimap'
  Minimap.tooltipRequirement = 'Modernizes the Minimap.'
  -- Minimap:On('Click', function(self, event)
	-- end)
end

local Settings = LibStub('Wasabi'):New(addon, 'LumuiConfig', C.settings)
Settings:AddSlash('/lumui')
Settings:Initialize(Basic)
