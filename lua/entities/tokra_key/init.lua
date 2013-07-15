--[[
	Tokra Shield Controller
	Copyright (C) 2011 Madman07
]]--

if (not StarGate.CheckModule("devices")) then return end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Sounds = {
	Click = Sound("tech/tokra_button.wav")
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self.Enabled = false;
end

function ENT:Use(ply)
	self.Enabled = not self.Enabled;
	self:EmitSound(self.Sounds.Click,100,math.random(95,105));

	if self.Enabled then
		local Gen1 = self:FindGen(self);
		local Gen2 = self:FindGen(Gen1);
		if (not IsValid(Gen1) or not IsValid(Gen2)) then self.Enabled = false; return end
		self:SetSkin(1);
		Gen1:SetSkin(1);
		Gen2:SetSkin(1);

		self.Weld1 = constraint.Weld(Gen1,Gen2,0,0,0,true);
		self.Weld2 = constraint.Weld(Gen1,self.Entity,0,0,0,true);
		self.Weld3 = constraint.Weld(Gen2,self.Entity,0,0,0,true);

		self:SpawnShield(Gen1, Gen2);
		self.Weld4 = constraint.Weld(self.Shield,self.Entity,0,0,0,true);
		self.Shield:CreateCollision(Gen1, Gen2);
		self.Weld4 = constraint.Weld(self.Shield,self.Entity,0,0,0,true);
	else
		local Gen1 = self:FindGen(self);
		local Gen2 = self:FindGen(Gen1);
		self:SetSkin(0);
		Gen1:SetSkin(0);
		Gen2:SetSkin(0);

		if IsValid(self.Weld1) then self.Weld1:Remove(); end
		if IsValid(self.Weld2) then self.Weld2:Remove(); end
		if IsValid(self.Weld3) then self.Weld3:Remove(); end
		if IsValid(self.Weld4) then self.Weld4:Remove(); end
		if IsValid(self.Shield) then self.Shield:Remove(); end
	end
end

function ENT:OnRemove()
	if IsValid(self.Shield) then self.Shield:Remove(); end
end

function ENT:FindGen(ent)
	local gen;
	local dist = 1000;
	local pos = self:GetPos();
	for _,v in pairs(ents.FindByModel("models/Madman07/tokra_shield/generator.mdl")) do
		if (v != ent) then
			local sg_dist = (pos - v:GetPos()):Length();
			if(dist >= sg_dist) then
				dist = sg_dist;
				gen = v;
			end
		end
	end
	return gen;
end

function ENT:SpawnShield(Gen1, Gen2)
	local ang = (Gen1:GetPos()-Gen2:GetPos()):Angle()
	local pos = -1*(Gen1:GetPos()-Gen2:GetPos())/2 + Gen1:GetPos()

	local ent = ents.Create("tokra_shield");
	ent:SetAngles(ang);
	ent:SetPos(pos);
	ent:Immunity(Gen1, Gen2);
	ent:Spawn();
	ent:Activate();
	self.Shield = ent;
end