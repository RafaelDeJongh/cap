include("shared.lua")
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("energy_beam", SGLanguage.GetMessage("energy_beam_kill"))
end

function ENT:GetStartEntity()
   return self.Entity:GetNetworkedEntity("startEnt", nil)
end

function ENT:GetStartPos()
   return self.Entity:GetNetworkedVector("start", self.Entity:GetPos())
end

function ENT:GetEndPos()
   return self.Entity:GetNetworkedVector("end", self:GetStartPos())
end
