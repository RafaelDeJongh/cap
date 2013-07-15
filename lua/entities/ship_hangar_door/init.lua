--[[
	Ships Hangar Doors
	Copyright (C) 2011 Madman07
]]--

if (not StarGate.CheckModule("ship")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

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
end

function ENT:PhysicsUpdate( phys, deltatime )
	local ang = self.Parent:GetAngles();
	ang.Yaw = -90-self.Factor*90+ang.Yaw;


	local center = self.Parent:GetPos();
	if (self.Factor > 0) then center = center + self.Parent:GetForward()*15; end

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