--[[
	Doors
	Copyright (C) 2011 Madman07
]]--

if (not StarGate.CheckModule("devices")) then return end

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:SetName("Atlantis Doors");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	--self.Entity:SetModel("models/Madman07/doors/atl_door2.mdl");
	self.CanDoAnim = true;
	self.Delay = 2.0;
	self.Sound = true;
	self.OpenSound = "door/atlantis_door_open.wav";
	self.CloseSound = "door/atlantis_door_close.wav";
	self.PlaybackRate = 1;
	self.Shake = false;
	self.BaseTP = self.BaseTP or NULL;
end

function ENT:Think()
	if not self.CanDoAnim then --run often only if doors are busy
		self:NextThink(CurTime());
		return true
	end
end

function ENT:GetSelf()
	return self.Entity
end

function ENT:Toggle()
	if self.CanDoAnim then
		self.CanDoAnim = false;
		timer.Create("Close"..self:EntIndex(),self.Delay,1,function() --How long until we can do the anim again?
			self.CanDoAnim = true;
		end);
		--if self.Shake then util.ScreenShake(self:GetPos(),2,6,4,400); end
		self:SetPlaybackRate(self.PlaybackRate);
		if self.Open then
			timer.Create("Close2"..self:EntIndex(),self.Delay,1,function()
				self.Open = false;
			end);
			if (IsValid(self.BaseTP)) then
				self.BaseTP:SetWire("Doors Opened",0);
				self.BaseTP.ShouldClose = false;
			end
			self:SetNotSolid(false);
			self:ResetSequence(self:LookupSequence("close")); -- play the sequence
			if self.Sound then
				self:EmitSound(self.CloseSound,100,math.random(90,110));
			end
		else
			if (IsValid(self.BaseTP) and self.BaseTP.DoorsLocked) then return end
			self.Open = true;
			if (IsValid(self.BaseTP)) then
				self.BaseTP:SetWire("Doors Opened",1);
			end
			self:SetNotSolid(true);
			self:ResetSequence(self:LookupSequence("open")); -- play the sequence
			if self.Sound then
				self:EmitSound(self.OpenSound,100,math.random(90,110));
			end
		end
	end
end
