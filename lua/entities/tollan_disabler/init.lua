--[[
	Tollan Weapon Disabler
	Copyright (C) 2010 Madman07
]]--

if (not StarGate.CheckModule("devices")) then return end

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

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
		"weapon_jumperv4_remote",
		"kinoremote",
		"remotecontroller",
		"weapon_crowbar",
		"weapon_physcannon",
		"tool_npc_eof",
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

	self.Inputs = WireLib.CreateInputs( self.Entity, {"Active"});

end

-----------------------------------SETUP----------------------------------

function ENT:Setup(size, immunity)
	self.Size = size;
	self.Immunity = immunity;
end

-----------------------------------WIRE----------------------------------

function ENT:TriggerInput(variable, value)
	if (variable == "Active") then self.IsEnabled = util.tobool(value) end
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

				if not table.HasValue(self.Tools, active) then v:SelectWeapon("weapon_physgun"); end

			end
		end

	end

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
		self.IsEnabled = false;
	else
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