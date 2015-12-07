ENT.RenderGroup = RENDERGROUP_OPAQUE;
ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.PrintName = "Atlantis Light"
ENT.Author = "RononDex"
ENT.Category = "Stargate Carter Addon Pack"

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

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
	
	self:CreateWireInputs("On","Disable Use","Brightness","Size","RGB [VECTOR]","R","G","B");
	self:CreateWireOutputs("Active");
	
	if(self.Phys:IsValid()) then
		self.Phys:Wake();
		self.Phys:SetMass(100);
	end
	
	self.MaxB = StarGate.CFG:Get("atlantis_light","max_brightness",5);
	self.MaxS = StarGate.CFG:Get("atlantis_light","max_size",400);

end

function ENT:SetBrightness(b)
	self.Brightness = math.Clamp(b,0,self.MaxB);
	self:SetNWInt("Light_Brightness",b);
end

function ENT:SetLightSize(size)
	self.LightSize = math.Clamp(size,0,self.MaxS);
	self:SetNWInt("Light_Size",size);
end

function ENT:SetLightColour(r,g,b)
	self.LightColour = Color(r,g,b,255);
	self:SetNWInt("Light_R",r);
	self:SetNWInt("Light_G",g);
	self:SetNWInt("Light_B",b);
end

function ENT:GetLightColour()

	local r = self.LightColour.r;
	local g = self.LightColour.g;
	local b = self.LightColour.b;
	return r,g,b;

end

function ENT:Use()
	if (self:GetWire("Disable Use")>0) then return end
	if self.NextUse < CurTime() then
		if(self.On) then
			self.On = false;
		else
			self.On = true;
		end
		self.NextUse = CurTime() + 1;
	end
	self:SetNWBool("On",self.On);
	self:SetWire("Active",self.On);
end

function ENT:TriggerInput(k,v)
	
	local r,g,b = self:GetLightColour();
	
	if(k=="On") then
		if(v >= 1) then
			self.On = true;
		else
			self.On = false;
		end
		self:SetNWBool("On",self.On);
		self:SetWire("Active",self.On);
	elseif(k=="Brightness") then
		self:SetBrightness(v);
	elseif(k=="Size") then
		self:SetLightSize(v);
	elseif(k=="R") then
		self:SetLightColour(v,g,b);
	elseif(k=="G") then
		self:SetLightColour(r,v,b);
	elseif(k=="B") then
		self:SetLightColour(r,g,v);
	elseif(k=="RGB") then
		self:SetLightColour(v.x,v.y,v.z);
	end

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