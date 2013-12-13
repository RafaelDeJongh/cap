--[[
	Doors
	Copyright (C) 2011 Madman07
]]--

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Atlantis Transporter Doors"
ENT.Author = "Madman07, Cartman300, AlexALX"
ENT.Category = "Stargate Carter Addon Pack"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.AutomaticFrameAdvance = true
ENT.Untouchable = true

if CLIENT then

function ENT:Initialize()
	--self:SetRenderClipPlaneEnabled(true)
end

function ENT:Draw()
	/* old code
	local ent=self.Entity
	local normal = ent:GetRight()*50
	local distance = normal:Dot(ent:GetPos()-normal)

	local normal2 = ent:GetRight()*50*(-1)
	local distance2 = normal2:Dot(ent:GetPos()-normal2)

	--render.EnableClipping( true )
	render.PushCustomClipPlane( normal, distance );
	render.PushCustomClipPlane( normal2, distance2 );
	self:DrawModel()
	render.PopCustomClipPlane();
	--render.EnableClipping( false )  */

	if (self.ClipEnabled) then
		local norm = self:GetForward()*(-50);
		self:SetRenderClipPlane(norm, norm:Dot(self:GetPos()-norm));
	end
	self:DrawModel()
end

usermessage.Hook("StarGate.AtlantisTP.ClipStart", function(um)
	local e = um:ReadEntity();
	if (not IsValid(e)) then return end
	local norm = e:GetForward()*(-50);
	e.ClipEnabled = true;
	e:SetRenderClipPlaneEnabled(true);
	e:SetRenderClipPlane(norm, norm:Dot(e:GetPos()-norm));
end)

usermessage.Hook( "StarGate.AtlantisTP.ClipStop", function(um)
	local e = um:ReadEntity();
	if (not IsValid(e)) then return end
	e.ClipEnabled = nil;
	e:SetRenderClipPlaneEnabled(false);
end)

end

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end

AddCSLuaFile();

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:SetName("Atlantis Doors");
	self.Entity:SetModel("models/Madman07/doors/atl_door2_part.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
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
				if (IsValid(self)) then
					self.Open = false;
					umsg.Start("StarGate.AtlantisTP.ClipStop");
						umsg.Entity(self);
					umsg.End()
				end
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
			umsg.Start("StarGate.AtlantisTP.ClipStart");
				umsg.Entity(self);
			umsg.End()
			self:SetNotSolid(true);
			self:ResetSequence(self:LookupSequence("open")); -- play the sequence
			if self.Sound then
				self:EmitSound(self.OpenSound,100,math.random(90,110));
			end
		end
	end
end

end