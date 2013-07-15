ENT.Type = "anim";
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:GetEntRadius()
   return self.Entity:GetNetworkedInt("blast_radius", 5);
end

function ENT:GetEntPos()
   return self:GetPos();
end
