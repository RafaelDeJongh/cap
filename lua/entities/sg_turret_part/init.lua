--[[
	SG Turret Base Part
	Copyright (C) 2011 Madman07
]]--

if (not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Inputs = WireLib.CreateInputs( self.Entity, {"Fire [NORMAL]", "Active [NORMAL]", "Vector [VECTOR]", "Entity [ENTITY]"});

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