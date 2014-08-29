--[[
	Tokra Shield Controller
	Copyright (C) 2011 Madman07
]]--

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Tokra Shield Controller"
ENT.WireDebugName = "Tokra Shield"
ENT.Author = "Madman07"
ENT.Instructions= ""
ENT.Contact = "madman097@gmail.com"
ENT.Category = "Stargate Carter Addon Pack"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end

AddCSLuaFile()

ENT.Sounds = {
	Click = Sound("tech/tokra_button.wav")
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);
	self.Entity:CreateWireInputs("Press Button");
	self.Entity:CreateWireOutputs("Pressed");
	self.Entity:SetUseType(SIMPLE_USE);

	self.Enabled = false;
	self.Link = NULL;
end

function ENT:TriggerInput(k,v)
	if (k=="Press Button") then
		if (v>=0) then
			self:PressButton();
		end
	end
end

function ENT:Use(ply)
	self:PressButton();
end

function ENT:PressButton()
	self.Enabled = not self.Enabled;
	self:EmitSound(self.Sounds.Click,100,math.random(95,105));

	if self.Enabled then
		local Gen1 = self:FindGen(self);
		local Gen2 = self:FindGen(Gen1);
		if (not IsValid(Gen1) or not IsValid(Gen2)) then self.Enabled = false; return end
		self:SetSkin(1);
		self:SetWire("Pressed",1);
		if (IsValid(Gen1)) then
			Gen1:SetSkin(1);
			Gen1.Enabled = true;
		end
		if (IsValid(Gen2)) then
			Gen2:SetSkin(1);
			Gen2.Enabled = true;
		end

		self.Weld1 = constraint.Weld(Gen1,Gen2,0,0,0,true);
		self.Weld2 = constraint.Weld(Gen1,self.Entity,0,0,0,true);
		self.Weld3 = constraint.Weld(Gen2,self.Entity,0,0,0,true);

		self:SpawnShield(Gen1, Gen2);
		self.Weld4 = constraint.Weld(self.Shield,self.Entity,0,0,0,true);
		self.Shield:CreateCollision(Gen1, Gen2);
		--self.Weld4 = constraint.Weld(self.Shield,self.Entity,0,0,0,true);
	else
		local Gen1 = self:FindGen(self,true);
		local Gen2 = self:FindGen(Gen1,true);
		self:SetSkin(0);
		self:SetWire("Pressed",0);
		if (IsValid(Gen1)) then
			Gen1:SetSkin(0);
			Gen1.Enabled = false;
		end
		if (IsValid(Gen2)) then
			Gen2:SetSkin(0);
			Gen2.Enabled = false;
		end

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

function ENT:FindGen(ent,disable)
	if (not IsValid(ent)) then return end
	if (ent==self and IsValid(self.Link)) then return self.Link;
	elseif (ent!=self and IsValid(ent.Link)) then return ent.Link end
	local gen;
	local dist = 1000;
	local pos = self:GetPos();
	for _,v in pairs(ents.FindByClass("tokra_emmiter")) do
		if (v != ent and (not v.Enabled and not disable or v.Enabled and disable) and not IsValid(v.KeyLink) and not IsValid(v.Link)) then
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

function ENT:OnRemove()
	if (IsValid(self.Link)) then
		if (IsValid(self.Link.Link)) then
			self.Link.Link.KeyLink = NULL;
		end
		self.Link.KeyLink = NULL;
	end
	StarGate.WireRD.OnRemove(self);
end

function ENT:Touch(ent)
	if (IsValid(ent)) then
		if (IsValid(ent.KeyLink) or IsValid(self.Link)) then return end
		if (ent:GetClass()=="tokra_emmiter") then
			self.Link = ent;
			ent.KeyLink = ent;
			if (IsValid(ent.Link)) then ent.Link.KeyLink = ent; end
			local ed = EffectData()
			ed:SetEntity( self )
			util.Effect( "propspawn", ed, true, true )
		end
	end
end

function ENT:PreEntityCopy()
	local dupeInfo = {};

	if (IsValid(self.Link)) then
		dupeInfo.Link = self.Link:EntIndex();
	end

    duplicator.StoreEntityModifier(self, "TokraKey", dupeInfo)
	StarGate.WireRD.PreEntityCopy(self);
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end

	local dupeInfo = Ent.EntityMods.TokraKey
	if (dupeInfo and dupeInfo.Link and CreatedEntities[dupeInfo.Link]) then
		self.Link = CreatedEntities[dupeInfo.Link];
	end

	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

end