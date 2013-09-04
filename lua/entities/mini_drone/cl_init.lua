include("shared.lua");
ENT.Glow = StarGate.MaterialFromVMT(
	"DroneSprite",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/light_glow01"
		"$nocull" 1
		"$additive" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
);
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("mini_drone",SGLanguage.GetMessage("mdrone_kill"));
end

function ENT:Initialize()
	self.Created = CurTime();
end

// Draws model

--################# Draw @aVoN
function ENT:Draw()
	local pos = self.Entity:GetPos();
	self.Size = self.Size or 8;
	self.Alpha = self.Alpha or 255;
	local time = self.Entity:GetNetworkedInt("turn_off",false);
	if(time) then
		-- Drone turns off (But only, when the Trail has been removed before)
		if(time+1 < CurTime()) then
			self.Size = math.Clamp((2-CurTime()+(time+1))*8,0,8);
		end
	end
	if(StarGate.VisualsWeapons("cl_drone_glow")) then
		-- The sprite on the drone
		render.SetMaterial(self.Glow);
		render.DrawSprite(
			self.Entity:GetPos(),
			self.Size,self.Size,
			Color(255,210,100,255)
		);
	end
	-- Drone has to fade out
	if(self.Entity:GetNWBool("fade_out")) then
		self.Alpha = math.Clamp(self.Alpha-FrameTime()*80,0,255);
		self.Entity:SetColor(Color(255,255,255,self.Alpha));
	end
	self.Entity:DrawModel();
end
