--[[
	Doors
	Copyright (C) 2011 Madman07
]]--

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Cap Doors"
ENT.Author = "Madman07"
ENT.Category = "Stargate Carter Addon Pack"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true

ENT.Untouchable = true

-----------------------------------CLIENT----------------------------------
-- door clipping
if CLIENT then
	function ENT:Draw()
		self.clipDist1 = 0 -- clipping plane 1 distance
		self.clipDist2 = 0 -- clipping plane 2 distance
		self.dir = Vector(0,0,1) -- direction vector of the doors
		self.offset = 0 -- offset of clipping plane (for destiny bridge door)
		
		if (self:GetModel() == "models/madman07/doors/atl_door1.mdl" || self:GetModel() == "models/madman07/doors/atl_door2.mdl") then
			self.clipDist1 = 50
			self.clipDist2 = 50
			self.dir = self:GetRight()
		elseif (self:GetModel() == "models/madman07/doors/dest_door.mdl") then
			self.clipDist1 = 40
			self.clipDist2 = 40
			self.dir = self:GetRight()
		elseif (self:GetModel() == "models/madman07/doors/atl_door3.mdl") then
			self.clipDist1 = 78
			self.clipDist2 = 46
			self.dir = self:GetRight()
		elseif (self:GetModel() == "models/cryptalchemy_models/destiny/bridge_door/bridge_door.mdl") then
			self.clipDist1 = 0.1
			self.clipDist2 = 137
			self.dir = self:GetUp()
			self.offset = 0.2
		else
			self.clipDist1 = 50
			self.clipDist2 = 50
			self.dir = self:GetRight()
		end

		local normal = self.dir*self.clipDist1
		local distance = normal:Dot(self:GetPos()-normal) + self.offset
		local normal2 = self.dir*-self.clipDist2
		local distance2 = normal2:Dot(self:GetPos()-normal2)

		local oldclip = render.EnableClipping( true )
		render.PushCustomClipPlane( normal, distance );
		render.PushCustomClipPlane( normal2, distance2 );
			self:SetupBones()
			self:DrawModel()
		render.PopCustomClipPlane();
		render.PopCustomClipPlane();
		render.EnableClipping( oldclip )
	end
end

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end

AddCSLuaFile();

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:SetName("Doors");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.CanDoAnim = true;
	self.Delay = 2.5;
	self.Sound = false;
	self.OpenSound = "";
	self.CloseSound = "";
	self.PlaybackRate = 1;
	self.Shake = false;
end

function ENT:Think()
	if not self.CanDoAnim then --run often only if doors are busy
		self:NextThink(CurTime());
		return true
	end
end

function ENT:Toggle()
	if self.CanDoAnim then
		self.CanDoAnim = false;
		timer.Create("Close"..self:EntIndex(),self.Delay,1,function() --How long until we can do the anim again?
			self.CanDoAnim = true;
		end);
		if self.Shake then util.ScreenShake(self:GetPos(),2,6,4,400); end
		self:SetPlaybackRate(self.PlaybackRate);
		if self.Open then
			self.Open = false;
			self:SetNotSolid(false);
			self:ResetSequence(self:LookupSequence("close")); -- play the sequence
			if self.Sound then
				self:EmitSound(self.CloseSound,100,math.random(90,110));
			end
		else
			self.Open = true;
			self:SetNotSolid(true);
			self:ResetSequence(self:LookupSequence("open")); -- play the sequence
			if self.Sound then
				self:EmitSound(self.OpenSound,100,math.random(90,110));
			end
		end
	end
end

-----------------------------------DUPLICATOR----------------------------------

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end
	if IsValid(self.Frame) then
		dupeInfo.EntIDFrame = self.Frame:EntIndex()
		if WireAddon then
			dupeInfo.WireData = WireLib.BuildDupeInfo( self.Frame )
		end
	end

	dupeInfo.DoorModel = self.Frame.DoorModel;

	duplicator.StoreEntityModifier(self, "DupeInfo", dupeInfo)
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)

	local dupeInfo = Ent.EntityMods.DupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end
	if dupeInfo.EntID then
		self.Frame = CreatedEntities[ dupeInfo.EntIDFrame ]
	end

	if (IsValid(self.Frame)) then
		self.Frame.DoorModel = dupeInfo.DoorModel;
	end

	if(WireAddon and Ent.EntityMods and Ent.EntityMods.DupeInfo.WireData) then
		WireLib.ApplyDupeInfo( ply, Ent, Ent.EntityMods.DupeInfo.WireData, function(id) return CreatedEntities[id] end)
	end

end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "cap_doors", StarGate.CAP_GmodDuplicator, "Data" )
end

end