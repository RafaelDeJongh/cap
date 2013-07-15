include("shared.lua")

language.Add("energy_beam", Language.GetMessage("energy_beam_kill"))

function ENT:GetStartEntity()
   return self.Entity:GetNetworkedEntity("startEnt", nil)
end

function ENT:GetStartPos()
   return self.Entity:GetNetworkedVector("start", self.Entity:GetPos())
end

function ENT:GetEndPos()
   return self.Entity:GetNetworkedVector("end", self:GetStartPos())
end
