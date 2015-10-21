--[[
	Doors
	Copyright (C) 2011 Madman07
]]--

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Doors"
ENT.Author = "Madman07"
ENT.Instructions= ""
ENT.Contact = "madman097@gmail.com"
ENT.Category = "Stargate Carter Addon Pack"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end

AddCSLuaFile()

ENT.Sounds={
	DestOpen=Sound("door/dest_door_open.wav"),
	DestClose=Sound("door/dest_door_close.wav"),
	Lock=Sound("door/dest_door_lock.wav"),
	AtlOpen=Sound("door/atlantis_door_open.wav"),
	AtlClose=Sound("door/atlantis_door_close.wav"),
	DestBridgeOpen=Sound("cryptalchemy_sounds/destiny/bridge_door/bridge_door_open.wav"),
	DestBridgeClose=Sound("cryptalchemy_sounds/destiny/bridge_door/bridge_door_close.wav"),
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:SetName("Doors");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.NoButtons = 0;

	self.Lockdown = false;
	self:CreateWireInputs( "Toggle", "Lockdown", "Disable Buttons Mode");
	self:CreateWireOutputs( "Opened");

	if (self.DoorModel) then
		local ent = ents.Create("cap_doors");
		--ent:SetAngles(self:GetAngles());
		ent:SetPos(self:GetPos());
		ent:SetModel(self.DoorModel);
		ent:Spawn();
		ent:Activate();
		constraint.NoCollide(self, ent, 0, 0 ); -- be sure it wont flip out!
		--ent:SetAngles(self:GetAngles());
		--ent:SetPos(self:GetPos());
		constraint.Weld(self,ent,0,0,0,true)
		ent.Delay = 2.5;
		ent.Sound = false;
		self.Door = ent;
		ent.Frame = self;
		self.DoorPhys = ent:GetPhysicsObject();
		if CPPI and IsValid(self.Owner) and ent.CPPISetOwner then ent:CPPISetOwner(self.Owner) end
	end

	self.Phys = self.Entity:GetPhysicsObject();
end

function ENT:SoundType(t)
	self.Door.Sound = true;
	if (t == 1) then
		self.Door.OpenSound = self.Sounds.DestOpen;
		self.Door.CloseSound = self.Sounds.DestClose;
	elseif (t == 9000) then
		self.Door.OpenSound = self.Sounds.DestBridgeOpen;
		self.Door.CloseSound = self.Sounds.DestBridgeClose;
	else
		self.Door.OpenSound = self.Sounds.AtlOpen;
		self.Door.CloseSound = self.Sounds.AtlClose;
	end
end

function ENT:Think()
	-- fix for physics
	if (IsValid(self.Phys) and IsValid(self.DoorPhys)) then
        local mot,dmot = self.Phys:IsMotionEnabled(),self.DoorPhys:IsMotionEnabled();

		if (not mot and dmot) then
			self.DoorPhys:EnableMotion(false);
		elseif (mot and not dmot) then
			self.DoorPhys:EnableMotion(true);
		end
	end

	self:NextThink(CurTime()+0.1);
	return true;
end

function ENT:OnRemove()
	if IsValid(self.Door) then self.Door:Remove() end
end

function ENT:TriggerInput(variable, value)
	if (variable == "Toggle" and value > 0) then
		self:Toggle();
	elseif (variable == "Lockdown") then
		if (value == 1) then
			if self.Door.Open then self:Toggle() end
			self.Lockdown = true;
		else
			self.Lockdown = false;
		end
	elseif (variable == "Disable Buttons Mode") then
		if (value >= 2) then
			self.NoButtons = 2;
		elseif (value == 1) then
			self.NoButtons = 1;
		else
			self.NoButtons = 0;
		end
	end
end

function ENT:Toggle()
	if not IsValid(self.Door) then return end
	if (not self.Lockdown) then
		self.Door:Toggle();
		self:SetWire("Opened",self.Door.Open);
	elseif (self.Door:GetModel()=="models/madman07/doors/dest_door.mdl") then
		self.Entity:EmitSound(self.Sounds.Lock,100,math.random(90,110));
	end
end

-----------------------------------DUPLICATOR----------------------------------

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end
	if IsValid(self.Door) then
		dupeInfo.EntIDDoor = self.Door:EntIndex()
	end
	if WireAddon then
		dupeInfo.WireData = WireLib.BuildDupeInfo( self.Entity )
	end

	if (self.Entity:GetMaterial() == "Madman07/doors/atlwall_red") then
		dupeInfo.Mat = true;
	end

	dupeInfo.DoorModel = self.DoorModel;

	duplicator.StoreEntityModifier(self, "DupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "DupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)

	local dupeInfo = Ent.EntityMods.DupeInfo

	self.DoorModel = dupeInfo.DoorModel;
	self.Owner = ply;

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
		self.DoorModel = dupeInfo.DoorModel;
	end
	if dupeInfo.EntIDDoor then
		if (IsValid(self.Door)) then self.Door:Remove() end
		self.Door = CreatedEntities[ dupeInfo.EntIDDoor ]
		if (IsValid(self.Door)) then
			self.Door.Frame = self.Entity;
			if (self.DoorModel == "models/madman07/doors/dest_door.mdl" || self.DoorModel == "models/madman07/doors/dest_frame.mdl") then self.Entity:SoundType(1);
			else self.Entity:SoundType(2); end
			self.DoorPhys = self.Door:GetPhysicsObject();
		end
	end

	if(Ent.EntityMods and Ent.EntityMods.DupeInfo.WireData and WireLib) then
		WireLib.ApplyDupeInfo( ply, Ent, Ent.EntityMods.DupeInfo.WireData, function(id) return CreatedEntities[id] end)
	end

	if (dupeInfo.Mat) then
		self.Entity:SetMaterial("Madman07/doors/atlwall_red");
	end

	self.Owner = ply;
end

end
