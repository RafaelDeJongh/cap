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

-- HACKY HACKY HACKY HACKY HACKY @aVoN
-- Stops making players "recognizeable" if they are cloaked (E.g. by looking at them - Before you e.g. saw "Catdaemon - Health 100" if you lookaed at a cloaked player. Now, you dont see anything if he is cloaked
if(util._Cloak_TraceLine) then return end;
util._Cloak_TraceLine = util.TraceLine;
function util.TraceLine(...)
	local t = util._Cloak_TraceLine(...);
	if(t and IsValid(t.Entity)) then
		if(t.Entity:IsPlayer()) then
			if(t.Entity:GetNWBool("CloakCloaked",false)) then t.Entity = NULL end;
		end
	end
	return t;
end