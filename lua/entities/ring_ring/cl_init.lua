include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
end

language.Add("ring_ring",Language.GetMessage("ring_kill"))