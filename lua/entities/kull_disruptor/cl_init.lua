include("shared.lua")if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("kull_disruptor",SGLanguage.GetMessage("entity_kd"))end
function ENT:Initialize()

	self.BaseClass.Initialize(self)
	self.Sizes = {40,40,250}
	self.DrawShaft = false
	self.InstantEffect = false
end