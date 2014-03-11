--[[############################################################################################################
	Anti Priori Device
	Copyright (C) 2010 assassin21
############################################################################################################]]

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Anti Priori Device"
ENT.WireDebugName = "Anti Priori Device"
ENT.Author = "assassin21, Boba Fett"
ENT.Instructions= ""
ENT.Contact = "zoellner21@gmail.com"
ENT.Category = "Stargate Carter Addon Pack"

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

list.Set("CAP.Entity", ENT.PrintName, ENT);

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
	ENT.Category = SGLanguage.GetMessage("entity_main_cat");
	ENT.PrintName = SGLanguage.GetMessage("entity_antiprior");
end

end

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end

AddCSLuaFile()

--##############################Init @ assassin21

function ENT:Initialize()

	self.Entity:SetModel("models/Madman07/anti_priest/anti_priest.mdl");

	self.Entity:SetName("Anti Priori Weapon");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Entity:SetUseType(SIMPLE_USE);

	self.IsOn = false;
	self.Radius = 800; --math.random(600, 800); sorry disable this, because added hook, lazy to make it with radius...
	if WireAddon then
		self:CreateWireInputs("Activate");
		self:CreateWireOutputs("Activated");
	end

end

--###############################Spawn @ assassin21

function ENT:SpawnFunction( ply, tr )
	if (!tr.Hit) then return end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("anti_prior");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply;

	local phys = ent:GetPhysicsObject();
	if IsValid(phys) then phys:EnableMotion(false); end

	return ent;
end

--##############################Use @ assassin21

function ENT:Use()
	if self.IsOn==false then
		self.IsOn=true;
		self:SetWire("Activated",1);
	else
		self.IsOn=false;
		self:SetWire("Activated",0);
	end
end


--################################Wire @ assassin21

function ENT:TriggerInput(variable, value)
	if (variable == "Activate") then
		self.IsOn = util.tobool(value)
		if (self.IsOn) then
			self:SetWire("Activated",1);
		else
			self:SetWire("Activated",0);
		end
	end
end

--################################Think @ assassin21

function ENT:Think()
	if self.IsOn==true then
		local e = ents.FindInSphere(self:GetPos(), self.Radius);
			for _,v in pairs(e) do
				if v:IsPlayer() and v:GetMoveType() == MOVETYPE_NOCLIP then
					if v != self.Owner and not v:HasGodMode() then
						local allow = hook.Call("StarGate.AntiPrior.Noclip",nil,v,self);
						if (allow==false) then continue end
						v:SetMoveType(MOVETYPE_WALK)
					end
				end
			end
	end

	if self.IsOn==true then
		self.Entity:Fire("skin",1);
	else
		self.Entity:Fire("skin",0);
	end

	self.Entity:NextThink(CurTime() + 0.5)
	return true
end

hook.Add("PlayerNoClip", "AntiPrior.DisableNoclip", function(ply,noclip)
	if (noclip) then
		if (IsValid(ply)) then
			if (ply.HasGodMode==nil) then
				error("ply.HasGodMode is nil! Ply: "..tostring(ply).." Class: "..ply:GetClass());
			elseif(type(ply.HasGodMode)!="function") then
				error("ply.HasGodMode is "..type(ply.HasGodMode)..", not function! Ply: "..tostring(ply).." Class: "..ply:GetClass());
			end
		end
		if (not IsValid(ply) or ply:HasGodMode()) then return end
		local allow = hook.Call("StarGate.AntiPrior.Noclip",nil,ply,self);
		if (allow==false) then return false end
		for k,v in pairs(ents.FindInSphere(ply:GetPos(),800)) do
			if (v:GetClass()=="anti_prior" and v.IsOn and ply!=v.Owner) then
				return false;
			end
		end
	end
end )

-----------------------------------DUPLICATOR----------------------------------

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end
	if WireAddon then
		dupeInfo.WireData = WireLib.BuildDupeInfo( self.Entity )
	end

	dupeInfo.IsOn = self.IsOn;
	dupeInfo.Radius = self.Radius;

	duplicator.StoreEntityModifier(self, "AntiProriDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "AntiProriDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local dupeInfo = Ent.EntityMods.AntiProriDupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	if(Ent.EntityMods and Ent.EntityMods.AntiProriDupeInfo.WireData) then
		WireLib.ApplyDupeInfo( ply, Ent, Ent.EntityMods.AntiProriDupeInfo.WireData, function(id) return CreatedEntities[id] end)
	end

	self.IsOn = dupeInfo.IsOn;
	self.Radius = dupeInfo.Radius;

	self.Owner = ply;
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "anti_prior", StarGate.CAP_GmodDuplicator, "Data" )
end

end