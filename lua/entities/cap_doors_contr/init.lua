--[[
	Door Controller
	Copyright (C) 2011 Madman07
]]--

if (not StarGate.CheckModule("extra")) then return end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Sounds={
	PressDest=Sound("door/dest_door_button.wav"),
	PressAtl=Sound("door/atlantis_door_chime.wav"),
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:SetName("Door Controller");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self:CreateWireInputs( "Press" );
	self:CreateWireOutputs( "Pressed" );
	self.Pressed = false;
	self.Atlantis = false;

	if (self.Entity:GetModel() == "models/iziraider/destinybutton/destinybutton.mdl") then self.Entity.TypeS = 1;
	else self.Entity.TypeS = 2; end
end

function ENT:TriggerInput(variable, value)
	if (variable == "Press" and value > 0) then
		self:BressButton();
	end
end

function ENT:Use()
	self:BressButton()
end

function ENT:BressButton()
	if (self.Pressed) then return end;
	self.Entity:SetSkin(1);
	self:SetWire("Pressed",1);
	self.Pressed = true;
	timer.Create( "Skin"..self:EntIndex(), 1, 1, function()
		if IsValid(self.Entity) then
			self.Entity:SetSkin(0);
			self:SetWire("Pressed",0);
			self.Pressed = false;
		end
	end);

	if (self.TypeS == 1) then self.Entity:EmitSound(self.Sounds.PressDest,100,math.random(90,110));
	else self.Entity:EmitSound(self.Sounds.PressAtl,100,math.random(90,110)); end

	if (self.Atlantis and IsValid(self.AtlTP) and self.AtlTP.Busy) then return end

	local door = self:FindDoor();
	if IsValid(door) then door:Toggle(); end
end

function ENT:FindDoor()
	local door;
	local dist = 1000;
	local pos = self.Entity:GetPos();
	if (self.Atlantis) then
		door = self.AtlDoor;
	else
		for _,v in pairs(ents.FindByClass("cap_doors_frame")) do
			local door_dist = (pos - v:GetPos()):Length();
			if(dist >= door_dist) then
				dist = door_dist;
				door = v;
			end
		end
	end
	return door;
end

-----------------------------------DUPLICATOR----------------------------------

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end

	duplicator.StoreEntityModifier(self, "DoorContrDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "DoorContrDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)

	local dupeInfo = Ent.EntityMods.DoorContrDupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	self.Owner = ply;
end