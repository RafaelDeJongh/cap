--[[
	Door Controller
	Copyright (C) 2011 Madman07
]]--

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Door Controller"
ENT.Author = "Madman07"
ENT.Instructions= ""
ENT.Contact = "madman097@gmail.com"
ENT.Category = "Stargate Carter Addon Pack"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end

AddCSLuaFile()

ENT.Sounds={
	PressDest=Sound("door/dest_door_button.wav"),
	LockedDest=Sound("gmod4phun/dest_door_lock_new.wav"),
	PressAtl=Sound("door/atlantis_door_chime.wav"),
	PressGoa=Sound("button/ring_button1.mp3"),
	PressGoa2=Sound("button/ring_button2.mp3"),
	PressOri=Sound("button/ancient_button1.wav"),
	PressOri2=Sound("button/ancient_button2.wav"),
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
	elseif (self.Entity:GetModel() == "models/boba_fett/props/buttons/atlantis_button.mdl") then self.Entity.TypeS = 2;
	elseif (self.Entity:GetModel() == "models/madman07/ring_panel/goauld_panel.mdl") then self.Entity.TypeS = 3;
	elseif (self.Entity:GetModel() == "models/madman07/ring_panel/ancient/panel.mdl") then self.Entity.TypeS = 4;
	else self.Entity.TypeS = 5; end
end

function ENT:TriggerInput(variable, value)
	if (variable == "Press" and value > 0) then
		self:PressButton();
	end
end

function ENT:Use()
	self:PressButton()
end

function ENT:PressButton()
	if (self.Pressed) then return end;
	if (self.TypeS == 1) then -- if its Destiny door
		local frame = self:FindDoor() -- apparently it returns the frame, so thats good
		if IsValid(frame) then
			if not frame.Lockdown then
				if not frame.Door.Open then
					self.Entity:SetSkin(1);
				else
					self.Entity:SetSkin(2);
				end
			elseif frame.Lockdown then
				self.Entity:SetSkin(3);
			end
		end
	else
		self.Entity:SetSkin(1);
	end
	self:SetWire("Pressed",1);
	self.Pressed = true;
	timer.Create( "Skin"..self:EntIndex(), 1, 1, function()
		if IsValid(self.Entity) then
			self.Entity:SetSkin(0);
			self:SetWire("Pressed",0);
			self.Pressed = false;
		end
	end);

	local no_sound = false
	if (self.TypeS == 1) then
		local frame = self:FindDoor() -- apparently it returns the frame, so thats good
		if IsValid(frame) then
			if not frame.Lockdown then
				self.Entity:EmitSound(self.Sounds.PressDest,100,math.random(90,110));
			elseif frame.Lockdown then
				no_sound = true
				self.Entity:EmitSound(self.Sounds.LockedDest,100,100); -- dont put random pitch, it sounds weird then
			end
		end
	elseif (self.TypeS == 3) then
		local SoundToPlay = math.random(0,1)
		if(SoundToPlay==1) then
			self.Entity:EmitSound(self.Sounds.PressGoa,100,math.random(90,110));
		else
			self.Entity:EmitSound(self.Sounds.PressGoa2,100,math.random(90,110));
		end
	elseif(self.TypeS == 4 or self.TypeS == 5) then
		local SoundToPlay = math.random(0,1)
		if(SoundToPlay==1) then
			self.Entity:EmitSound(self.Sounds.PressOri,100,math.random(90,110));
		else
			self.Entity:EmitSound(self.Sounds.PressOri2,100,math.random(90,110));
		end
	else self.Entity:EmitSound(self.Sounds.PressAtl,100,math.random(90,110)); end

	if (self.Atlantis and IsValid(self.AtlTP) and self.AtlTP.Busy) then return end

	if (self.Atlantis and self.AtlDoor) then
		if (IsValid(self.AtlDoor[1])) then
			self.AtlDoor[1]:Toggle();
		end
		if (IsValid(self.AtlDoor[2])) then
			self.AtlDoor[2]:Toggle();
		end
	else
		local door = self:FindDoor();
		if IsValid(door) and (door.NoButtons==0 or door.Owner==self.Owner) then door:Toggle(no_sound); end
	end
end

function ENT:FindDoor()
	local door;
	local dist = 1000;
	local pos = self.Entity:GetPos();
	for _,v in pairs(ents.FindByClass("cap_doors_frame")) do
		if (v.NoButtons==2) then continue end
		local door_dist = (pos - v:GetPos()):Length();
		if(dist >= door_dist) then
			dist = door_dist;
			door = v;
		end
	end
	return door;
end

-----------------------------------DUPLICATOR----------------------------------

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	self.Owner = ply;
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "cap_doors_contr", StarGate.CAP_GmodDuplicator, "Data" )
end

end