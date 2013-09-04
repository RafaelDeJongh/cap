include("shared.lua")
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
	ENT.Category = SGLanguage.GetMessage("entity_main_cat");
	ENT.PrintName = SGLanguage.GetMessage("entity_apple_core");
end
ENT.RenderGroup = RENDERGROUP_BOTH;
ENT.HoloText = surface.GetTextureID("VGUI/resources_hud/sgu_screen");
local font = {
	font = "coolvetica",
	size = 50,
	weight = 400,
	antialias = true,
	additive = false,
}
surface.CreateFont("AppleCore", font);

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self.Entity:GetPos());
	self.Wire = 0;

	self.NameA = "";
	self.NameB = "";
	self.NameC = "";
	self.NameD = "";
	self.NameE = "";
	self.NameF = "";
	self.NameG = "";
	self.NameH = "";

	self.ValueA = 0;
	self.ValueB = 0;
	self.ValueC = 0;
	self.ValueD = 0;
	self.ValueE = 0;
	self.ValueF = 0;
	self.ValueG = 0;
	self.ValueH = 0;

	self.SmokeTime = CurTime();
end

function ENT:Think()
	if IsValid(self.Console) then
		self.Wire = self.Console:GetNetworkedInt("Wire",0);

		self.NameA = self.Console:GetNWString("NameA","");
		self.NameB = self.Console:GetNWString("NameB","");
		self.NameC = self.Console:GetNWString("NameC","");
		self.NameD = self.Console:GetNWString("NameD","");
		self.NameE = self.Console:GetNWString("NameE","");
		self.NameF = self.Console:GetNWString("NameF","");
		self.NameG = self.Console:GetNWString("NameG","");
		self.NameH = self.Console:GetNWString("NameH","");

		self.ValueA = self.Console:GetNWInt("ValueA",0)
		self.ValueB = self.Console:GetNWInt("ValueB",0)
		self.ValueC = self.Console:GetNWInt("ValueC",0)
		self.ValueD = self.Console:GetNWInt("ValueD",0)
		self.ValueE = self.Console:GetNWInt("ValueE",0)
		self.ValueF = self.Console:GetNWInt("ValueF",0)
		self.ValueG = self.Console:GetNWInt("ValueG",0)
		self.ValueH = self.Console:GetNWInt("ValueH",0)
	else
		self.Console = self:GetNWEntity("Console");
	end
	if (StarGate.VisualsMisc("cl_applecore_smoke") and self.Wire > 0 and CurTime() > self.SmokeTime) then
		self.SmokeTime = CurTime()+0.2;
		self:Smoke();
	end
	if (StarGate.VisualsMisc("cl_applecore_light") and self.Wire > 0) then
		if not self.Light then
			local dlight = DynamicLight(self:EntIndex().."light");
			if dlight then
				dlight.Pos = self.Entity:LocalToWorld(Vector(0,0,100));
				dlight.r = 255;
				dlight.g = 255;
				dlight.b = 255;
				dlight.Brightness = 7;
				dlight.Decay = 0;
				dlight.Size = 150;
				dlight.DieTime = CurTime()+0.25;
				self.Light = dlight;
				timer.Create( "Light"..self:EntIndex(), 0.1, 0, function()
					if IsValid(self.Entity) then
						self.Light.Pos = self.Entity:LocalToWorld(Vector(0,0,100));
						self.Light.DieTime = CurTime()+0.25;
					end
				end);
			end
		end
	else
		if timer.Exists("Light"..self:EntIndex()) then timer.Destroy("Light"..self:EntIndex()); end

		self.Light = nil;
	end
end

function ENT:OnRemove()
	if timer.Exists("Light"..self:EntIndex()) then timer.Destroy("Light"..self:EntIndex()); end
end

function ENT:Draw()
	self.Entity:DrawModel();

	if IsValid(self.Console) then
		if (self.Wire > 0) then
			local col = Color(255,255,255);
			local factor = 5;

			local data = self:GetAttachment(self:LookupAttachment("Screen2"))
			if not (data and data.Pos and data.Ang) then return end
			local ang = data.Ang;
			ang:RotateAroundAxis(data.Ang:Forward(),90);

			for i=1,2 do
				cam.Start3D2D(data.Pos,ang,0.1);
					surface.SetTexture(self.HoloText);
					surface.SetDrawColor(Color(255,255,255, 255));
					surface.DrawTexturedRect(-50*factor, -30*factor, 100*factor, 60*factor);

					draw.SimpleText(self.NameA,"AppleCore", -10*factor,-19*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
					draw.SimpleText(self.ValueA,"AppleCore",25*factor,-19*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
					draw.SimpleText(self.NameB,"AppleCore", -10*factor,-8*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
					draw.SimpleText(self.ValueB,"AppleCore",25*factor,-8*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);

					draw.SimpleText(self.NameC,"AppleCore", -10*factor,6*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
					draw.SimpleText(self.ValueC,"AppleCore",25*factor,6*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
					draw.SimpleText(self.NameD,"AppleCore", -10*factor,18*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
					draw.SimpleText(self.ValueD,"AppleCore",25*factor,18*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
				cam.End3D2D();

				ang:RotateAroundAxis(self:GetAngles():Up(),180);
			end

			local data2 = self:GetAttachment(self:LookupAttachment("Screen1"))
			if not (data2 and data2.Pos and data2.Ang) then return end
			local ang2 = data2.Ang;
			ang2:RotateAroundAxis(data2.Ang:Forward(),90);

			for i=1,2 do
				cam.Start3D2D(data2.Pos,ang2,0.1);
					surface.SetTexture(self.HoloText);
					surface.SetDrawColor(Color(255,255,255, 255));
					surface.DrawTexturedRect(-50*factor, -30*factor, 100*factor, 60*factor);

					draw.SimpleText(self.NameE,"AppleCore", -10*factor,-19*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
					draw.SimpleText(self.ValueE,"AppleCore",25*factor,-19*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
					draw.SimpleText(self.NameF,"AppleCore", -10*factor,-8*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
					draw.SimpleText(self.ValueF,"AppleCore",25*factor,-8*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);

					draw.SimpleText(self.NameG,"AppleCore", -10*factor,6*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
					draw.SimpleText(self.ValueG,"AppleCore",25*factor,6*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
					draw.SimpleText(self.NameH,"AppleCore", -10*factor,18*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
					draw.SimpleText(self.ValueH,"AppleCore",25*factor,18*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
				cam.End3D2D();

				ang2:RotateAroundAxis(self:GetAngles():Up(),180);
			end

		end
	end
end

function ENT:Smoke()
	local roll = math.Rand(-90,90);
	local ran = math.Rand(160,200);

	local selfpos = self.Entity:GetPos();
	local up = self.Entity:GetUp()*110;

	local particle = self.Emitter:Add("Llapp/particles/Smoke01_Main",selfpos+up);
	particle:SetDieTime(3);
	particle:SetStartAlpha(50);
	particle:SetEndAlpha(10);
	particle:SetStartSize(40);
	particle:SetEndSize(40);
	particle:SetColor(ran,ran,ran);
	particle:SetRoll(roll);
	particle:SetRollDelta(1);
	particle:SetAirResistance(20);
	particle:SetGravity(Vector(0,0,-25));

	self.Emitter:Finish();
end