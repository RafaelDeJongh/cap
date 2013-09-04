include('shared.lua') ;
ENT.BearingColor = Color(255,255,255);
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("bearing",SGLanguage.GetMessage("stool_bearing"));
end

ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.SpritePositions = Vector(0,0,5);
ENT.LightPositions = Vector(0,0,5);
ENT.BearingSprite = Material("effects/multi_purpose_noz");

function ENT:Draw()
	self.Entity:DrawModel();
	render.SetMaterial(self.BearingSprite);
	local col = Color(255,255,255,50);
	if(self.Entity:GetNetworkedBool("bearing",false)) then
		local endpos = self.Entity:LocalToWorld(self.SpritePositions);
		if StarGate.LOSVector(EyePos(), endpos, LocalPlayer(), 10) then
			render.DrawSprite(endpos,46,46,col);
		end
	end
end

local stargates = {};
function ENT:Initialize()
	table.insert(stargates,self.Entity);
end

function ENT:Think()
   if(not StarGate.VisualsMisc("cl_stargate_dynlights")) then return end;
   if(self.BearingColor and (self.NextLight or 0) < CurTime()) then
	    self.NextLight = CurTime()+0.001;
		if(self.Entity:GetNWBool("bearing",false)) then
			local dlight = DynamicLight(self:EntIndex()..i);
			if(dlight) then
				dlight.Pos = self.Entity:LocalToWorld(self.LightPositions);
				dlight.r = self.BearingColor.r;
				dlight.g = self.BearingColor.g;
				dlight.b = self.BearingColor.b;
				dlight.Brightness = 0.5;
				dlight.Decay = 150;
				dlight.Size = 250;
				dlight.DieTime = CurTime()+1;
			end
		end
	end
end