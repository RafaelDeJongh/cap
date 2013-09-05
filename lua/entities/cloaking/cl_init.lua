include("shared.lua");
if (StarGate==nil or StarGate.MaterialCopy==nil) then return end
ENT.Material = StarGate.MaterialCopy("CloakMuzzle","effects/strider_bulge_dudv");

--################### Init @aVoN
function ENT:Initialize()
	self.Created = CurTime();
end

--################### Init @aVoN
function ENT:Draw()
	if(render.GetDXLevel() >= 90) then
		local size = self.Entity:GetNetworkedInt("size") + 100;
		local parent =  self.Entity:GetNWEntity("parent",self.Entity);
		if (IsValid(parent)) then
			local multiply = math.Clamp(parent:GetVelocity():Length()/30000,0,1)*math.Clamp((CurTime() - self.Created)/2,0,1);
			self.Material:SetFloat("$refractamount",multiply);
		end
		render.UpdateScreenEffectTexture();
		render.SetMaterial(self.Material);
		render.DrawSprite(self.Entity:GetPos(),size,size,Color(255,255,255,255));
	end
end
