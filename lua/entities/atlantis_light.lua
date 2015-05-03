ENT.RenderGroup = RENDERGROUP_OPAQUE;
ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.PrintName = "Atlantis Light"
ENT.Author = "RononDex"
ENT.Category = "Stargate Carter Addon Pack"

if SERVER then

AddCSLuaFile()

function ENT:Initialize()

	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self.NextUse = CurTime();
	self:SetUseType(SIMPLE_USE);
	self.Phys = self.Entity:GetPhysicsObject();
	self.On = false;
	
	self:SetNWBool("On",false);
	
	print(self.Brightness)
	print(self.Lightsize)
	print(self.LightColour)
	
	if(self.Phys:IsValid()) then
		self.Phys:Wake();
		self.Phys:SetMass(100);
	end

end

function ENT:SetBrightness(b)
	self.Brightness = b;
	self:SetNWInt("Light_Brightness",b);
end

function ENT:SetLightSize(size)
	self.LightSize = size;
	self:SetNWInt("Light_Size",size);
end

function ENT:SetLightColour(r,g,b)
	self.LightColour = Color(r,g,b,255);
	self:SetNWInt("Light_R",r);
	self:SetNWInt("Light_G",g);
	self:SetNWInt("Light_B",b);
end

function ENT:Use()

	if self.NextUse < CurTime() then
		if(self.On) then
			self.On = false;
		else
			self.On = true;
		end
		self.NextUse = CurTime() + 1;
	end
	self:SetNWBool("On",self.On);
	print(self.On);
	print(self.LightColour);
	print(self.LightSize);
	print(self.Brightness);
end



end



if CLIENT then


function ENT:Draw() self:DrawModel() end

function ENT:Think()
	local On = self:GetNWBool("On");
	if(On) then
		self:Light();
	end
end

function ENT:Light()

	local r = self:GetNWInt("Light_R");
	local g = self:GetNWInt("Light_G");
	local b = self:GetNWInt("Light_B");
	local pos = self:GetPos()+self:GetUp()*35;
	local Brightness = self:GetNWInt("Light_Brightness");
	local size = self:GetNWInt("Light_Size");

	local dynlight = DynamicLight(self:EntIndex());
	dynlight.Pos = pos;
	dynlight.Brightness = Brightness;
	dynlight.Size = size;
	dynlight.Decay = size*5;
	dynlight.r = r;
	dynlight.g = g;
	dynlight.b = b;
	dynlight.DieTime = CurTime()+1;
end

end