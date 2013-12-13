--[[
	SG Turret Base Part
	Copyright (C) 2011 Madman07
]]--

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Stargate Turret Part"
ENT.Author = "Madman07"
ENT.Instructions= ""
ENT.Contact = "madman097@gmail.com"
ENT.Category = "Stargate Carter Addon Pack: Weapons"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.AutomaticFrameAdvance = true

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile()

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	if (WireAddon) then
		self.Inputs = WireLib.CreateInputs( self.Entity, {"Fire [NORMAL]", "Active [NORMAL]", "Vector [VECTOR]", "Entity [ENTITY]"});
	end

	local phys = self.Entity:GetPhysicsObject();
	if IsValid(phys) then
		phys:Wake();
		phys:EnableGravity(false);
		construct.SetPhysProp( nil, self.Entity, 0, nil, {GravityToggle = false});
	end

	self.Anim = false;
end

function ENT:TriggerInput(variable, value)
	if IsValid(self.Parent) then
		if (variable == "Vector") then self.Parent.WireVec = value;
		elseif (variable == "Entity") then self.Parent.WireEnt = value;
		elseif (variable == "Fire") then self.Parent.WireShoot = value;
		elseif (variable == "Active") then self.Parent.WireActive = value;	end
	end
end

function ENT:Think(ply)
	if self.Anim then
		self:NextThink(CurTime());
		return true
	end
end

function ENT:StartTouch( ent )
	if IsValid(self.Parent) then self.Parent:StartTouch(ent); end
end

function ENT:OnRemove()
	if timer.Exists(self.Entity:EntIndex().."Anim") then timer.Destroy(self.Entity:EntIndex().."Anim") end
end

function ENT:DoAnim(time, name)
	self.Anim = true;
	timer.Create(self.Entity:EntIndex().."Anim", time, 1, function()
		self.Anim = false;
	end);

	local seq = self.Entity:LookupSequence(name);
	self.Entity:ResetSequence(seq);
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "sg_turret_part", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

end