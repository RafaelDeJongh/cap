--[[
	Tollan Weapon Disabler
	Copyright (C) 2010 Madman07
]]--

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Tollan Disabler Device"
ENT.Author			= "Madman07"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Category		= "Stargate Carter Addon Pack"

ENT.Spawnable	= false
ENT.AdminSpawnable = false

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end

AddCSLuaFile()

ENT.Tools = {
		"weapon_physgun",
		"laserpointer",
		"gmod_tool",
		"gmod_camera",
		"manhack_welder",
		"weapon_oriringcaller",
		"personal_shield",
		"weapon_ringcaller",
		"sodan_cloak",
		"dagger",
		"weapon_jumper_remote",
		"kinoremote",
		"remotecontroller",
		"weapon_crowbar",
		"weapon_physcannon",
		"tool_npc_eof",
		"nox_hands",
	}

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	self.Entity:SetName("Tollan Weapon Disabler");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self.Size = 100;
	self.Immunity = false;
	self.IsEnabled = false;

	if (WireAddon) then
		self:CreateWireInputs("Activate");
		self:CreateWireOutputs("Activated");
	end

end

-----------------------------------SETUP----------------------------------

function ENT:Setup(size, immunity, owner)
	self.Size = math.Clamp(size,1,1024);
	self.Immunity = immunity;
	self.Owner = owner;
end

-----------------------------------WIRE----------------------------------

function ENT:TriggerInput(variable, value)
	if (variable == "Activate") then
		self.IsEnabled = util.tobool(value)
		if (self.IsEnabled) then
			self:SetWire("Activated",1);
		else
			self:SetWire("Activated",0);
		end
	end
end

-----------------------------------THINK----------------------------------

function ENT:Think()

	self.Entity:ShowOutput(self.IsEnabled);

	if self.IsEnabled then

		for _,v in pairs(ents.FindInSphere(self.Entity:GetPos(),  self.Size)) do
			if IsValid(v) and v:IsPlayer() then

				if self.Immunity and v == self.Owner then return end
				if (not IsValid(v:GetActiveWeapon())) then return end
				local active = v:GetActiveWeapon():GetClass();

				if not table.HasValue(self.Tools, active) then
					local allow = hook.Call("StarGate.TollanDisabler.CanBlockWeapon",nil,v,active,self);
					if (allow==false) then continue end
					local weps = v:GetWeapons() or {};
					if (not table.HasValue(weps,"weapon_physgun")) then
						v:Give("weapon_physgun");
					end
					v:SelectWeapon("weapon_physgun");
				end

			end
		end

	end

	self.Entity:NextThink(CurTime()+0.25);
	return true
end

function ENT:ShowOutput(active)
	local add = "Off";
	local enabled = 0;
	if(active) then
		add = "On";
		enabled = 1;
	end
	self:SetOverlayText("Tollan Weapon Disabler ("..add..")\nSize: "..self.Size);
end

-----------------------------------USE---------------------------------

function ENT:Use(ply)
	if(self.IsEnabled) then
		self:SetWire("Activated",0);
		self.IsEnabled = false;
	else
		self:SetWire("Activated",1);
		self.IsEnabled = true;
	end
end

-----------------------------------DUPLICATOR----------------------------------

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end
	if WireAddon then
		dupeInfo.WireData = WireLib.BuildDupeInfo( self.Entity )
	end

	dupeInfo.Size = self.Size;
	dupeInfo.Immunity = self.Immunity;
	dupeInfo.IsEnabled = self.IsEnabled;

	duplicator.StoreEntityModifier(self, "TollDisDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "TollDisDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)

	local dupeInfo = Ent.EntityMods.TollDisDupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	if(Ent.EntityMods and Ent.EntityMods.TollDisDupeInfo.WireData) then
		WireLib.ApplyDupeInfo( ply, Ent, Ent.EntityMods.TollDisDupeInfo.WireData, function(id) return CreatedEntities[id] end)
	end

	self.Size = dupeInfo.Size;
	self.Immunity = dupeInfo.Immunity;
	self.IsEnabled = dupeInfo.IsEnabled;

	self.Owner = ply;
end

end