--[[
	Ships Hangar Doors
	Copyright (C) 2011 Madman07
]]--

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Ships Hangar Doors"
ENT.Author = "Madman07"
ENT.Category = "Stargate Carter Addon Pack"
ENT.WireDebugName = "Ships Hangar"

ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AutomaticFrameAdvance = true
ENT.Untouchable = true

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("ship")) then return end
AddCSLuaFile();

ENT.Sounds = {
	Door=Sound("tech/hangar_door.wav"),
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:SetName("Ships Hangar Door");
	self.Entity:SetModel("models/Iziraider/capbuild/hangardoor.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self.Open = false;
	self.Opened = false;
	self.Anim = false;
	self.Speed = 5;
	self.Weld = constraint.Weld(self,self.Parent,0,0,0,true)
	self.DoShake = false;
end

function ENT:Toggle()
	if not self.Anim then
		self.ArriveTime = CurTime();
		self.Anim = true;
		self:EmitSound(self.Sounds.Door,100,100);
		self.DoShake = true;
		self.Opened = not self.Opened;
		timer.Create(self.Entity:EntIndex().."DoorMove", self.Speed, 1, function()
			self.Anim = false
			self.Open = not self.Open;
			self.DoShake = false;
		end);
	end
end

function ENT:Remove()
	if timer.Exists(self.Entity:EntIndex().."DoorMove") then timer.Destroy(self.Entity:EntIndex().."DoorMove") end
end

function ENT:Think(ply)
	self:GetPhysicsObject():Wake();
	if self.DoShake then
		util.ScreenShake(self:GetPos(),1,10,0.5,300);
	end

	-- fix for physics
	if (IsValid(self:GetPhysicsObject()) and IsValid(self.Parent) and IsValid(self.Parent:GetPhysicsObject())) then
		self:GetPhysicsObject():EnableMotion(self.Parent:GetPhysicsObject():IsMotionEnabled())
	end

end

function ENT:PhysicsUpdate( phys, deltatime )
	if (not IsValid(self.Parent)) then return end
	local ang = self.Parent:GetAngles();
	ang.Yaw = -90-self.Factor*90+ang.Yaw;
	if (self.Factor>0) then
		ang.Pich = ang.Pith*(-1);
		ang.Roll = ang.Roll*(-1);
	end


	local center = self.Parent:GetPos();
	if (self.Factor > 0) then center = center + self.Parent:GetForward()*14.1; end

	local side = center + self.Parent:GetRight()*self.Factor*400;
	local newpos = Vector(0,0,0);

	if self.Anim then
		local relay = (math.abs(self.ArriveTime - CurTime()))/self.Speed;
		if self.Open then -- closing
			newpos = LerpVector(relay, side, center);
		else -- opening
			newpos = LerpVector(relay, center, side);
		end
	else
		if self.Open then
			newpos = side;
		else
			newpos = center;
		end
	end

	if self.Weld and self.Weld:IsValid() then
		self.Weld:Remove();
		self.Weld = nil;
	end
	self:SetPos(newpos);
	self:SetAngles(ang);
	self.Weld = constraint.Weld(self,self.Parent,0,0,0,true)
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "ship_hangar_door", StarGate.CAP_GmodDuplicator, "Data" )
end

end