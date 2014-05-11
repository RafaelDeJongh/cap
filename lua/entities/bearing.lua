if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Gate bearing"
ENT.Author = "Llapp"
ENT.Category = "Stargate Carter Addon Pack"
ENT.WireDebugName = "Gate bearing"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if CLIENT then

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
   if(not StarGate.VisualsMisc("cl_stargate_un_dynlights")) then return end;
   if(self.BearingColor and (self.NextLight or 0) < CurTime()) then
	    self.NextLight = CurTime()+0.001;
		if(self.Entity:GetNWBool("bearing",false)) then
			local dlight = DynamicLight(self:EntIndex());
			if(dlight) then
				dlight.Pos = self.Entity:LocalToWorld(self.LightPositions);
				dlight.r = self.BearingColor.r;
				dlight.g = self.BearingColor.g;
				dlight.b = self.BearingColor.b;
				dlight.Brightness = 0.5;
				dlight.Decay = 150;
				dlight.Size = 250;
				dlight.DieTime = CurTime()+0.5;
			end
		end
	end
end

end

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end

AddCSLuaFile()

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	--################# Set physic and entity properties
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:EnableMotion(false);
		phys:SetMass(400);
	end

	self:CreateWireOutputs("Activated");
end

function ENT:Bearing(skin)
    if(skin)then
        self.Entity:Fire("skin",1);
        self.Entity:SetNetworkedBool("bearing",true);
        self:SetWire("Activated",true);
	else
	    self.Entity:Fire("skin",2);
		self.Entity:SetNetworkedBool("bearing",false); -- Dynamic light of the bearing
		self:SetWire("Activated",false);
    end
end

end