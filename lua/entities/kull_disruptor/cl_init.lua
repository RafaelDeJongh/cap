include("shared.lua")
language.Add("kull_disruptor",Language.GetMessage("entity_kd"))


function ENT:Initialize()

	self.BaseClass.Initialize(self)
	self.Sizes = {40,40,250}
	self.DrawShaft = false
	self.InstantEffect = false
end