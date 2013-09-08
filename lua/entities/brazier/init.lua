--[[
	Braziers
	Copyright (C) 2010 Madman07
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

function ENT:Initialize()

	self.Entity:SetName("Brazier");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Act = "5";
	if string.find(self.Entity:GetModel(), "ori") then self.Pos = Vector(0,0,self.Entity:OBBMaxs().z-25);
	else self.Pos = Vector(0,0,self.Entity:OBBMaxs().z); end

	self.Entity:MakeFire()
	self.Entity:Light();

end

function ENT:MakeFire()
    local fire = ents.Create("env_fire");

	fire:SetKeyValue("health","5");
    fire:SetKeyValue("firesize",self.Act);
    fire:SetKeyValue("fireattack","1");
    fire:SetKeyValue("damagescale","5");
    fire:SetKeyValue("spawnflags","159");

	fire:SetPos(self.Entity:LocalToWorld(self.Pos));
    fire:Spawn();
    fire:Activate();
	fire:Fire("StartFire","",0);
	fire:SetParent(self.Entity);
	self.FireEnt = fire;
end

function ENT:Light()
	local lamp = ents.Create( "gmod_light" )
	if (not IsValid(lamp)) then self:Remove(); return end

	lamp:SetColor(Color(255, 128, 0))
	if (lamp.SetBrightness) then
		lamp:SetBrightness(2)
		lamp:SetLightSize(200)
	end

	lamp:SetPos(self.Entity:LocalToWorld(self.Pos));
	lamp:Spawn()
	lamp:Toggle()
	lamp:SetRenderMode(RENDERMODE_NONE);
	lamp:SetParent(self.Entity);
	lamp:SetSolid(SOLID_NONE);

	self.LampEnt = lamp;
end

function ENT:OnRemove()
    if IsValid(self.FireEnt) then
	    self.FireEnt:Remove()
	end
	if IsValid(self.LampEnt) then
	    self.LampEnt:Remove()
	end
end
