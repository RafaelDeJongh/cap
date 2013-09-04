include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
end

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("ring_ring",SGLanguage.GetMessage("ring_kill"))
end