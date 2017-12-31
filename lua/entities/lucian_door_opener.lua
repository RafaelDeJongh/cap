/*
	Lucian Door Opener
	Copyright (C) 2017 Gmod4phun
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Lucian Door Opener"
ENT.Author = "Gmod4phun"
ENT.Category = "Stargate Carter Addon Pack"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.WireDebugName = "Lucian Door Opener"

ENT.AutomaticFrameAdvance = true

ENT.Untouchable = true

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_main_cat");
end

ENT.SpritePositions = {
    Vector(1.5,1.5,0.545),
	Vector(1.6,1.4,0.545),
	Vector(1.4,1.6,0.545),
	Vector(-1.5,1.5,0.545),
	Vector(-1.6,1.4,0.545),
	Vector(-1.4,1.6,0.545),
	Vector(1.5,-1.5,0.545),
	Vector(1.6,-1.4,0.545),
	Vector(1.4,-1.6,0.545),
	Vector(-1.5,-1.5,0.545),
	Vector(-1.6,-1.4,0.545),
	Vector(-1.4,-1.6,0.545),
}

ENT.SpriteColor = Color(255,0,0,255)

function ENT:Draw()
	self:SetupBones()
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
    self:DrawModel();
	
	render.SetMaterial( Material("sprites/bluecore") )
	for i=1, #self.SpritePositions do
		render.DrawSprite( self:LocalToWorld(self.SpritePositions[i]), 0.2, 0.2, self.SpriteColor )
	end
	
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:OnRemove()
end

end

function ENT:GetPair() -- returns the 2 LDO entities
	if IsValid(self) and IsValid(self.SecondLucianDevice) then
		return {self, self.SecondLucianDevice}
	elseif IsValid(self) and IsValid(self.MainLDO) then
		return {self, self.MainLDO}
	else
		return NULL, NULL -- in case one of them wasnt found
	end
end

if SERVER then
	util.AddNetworkString("CAP_LDO_SpriteColorUpdate")
end

function ENT:UpdateSpriteColor(color) -- convenient function to change the color (server and client) if needed
	local e = self
	local tab = e:GetPair()
	if CLIENT then
		for _,device in pairs(tab) do
			device.SpriteColor = color
		end
	else
		net.Start("CAP_LDO_SpriteColorUpdate")
		net.WriteTable(tab)
		net.WriteColor(color)
		net.Broadcast()
	end
end

if CLIENT then
	net.Receive( "CAP_LDO_SpriteColorUpdate", function()
		local tab = net.ReadTable()
		local color = net.ReadColor()
		for _,device in pairs(tab) do
			if device != NULL then
				device.SpriteColor = color
			end
		end
	end)
end

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end

AddCSLuaFile();

function ENT:Initialize()
	self:SetModel("models/gmod4phun/lucian_door_opener.mdl");
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE)
	self.Attached = false
	self.SecondAttached = false
	self.TargetDoor = nil
	self.IsMain = nil
	self.CanUse = true
	self.Activator = NULL
end

function ENT:RemoveBothLDO()
	if IsValid(self) then
		self:Remove()
	end
	if IsValid(self) and IsValid(self.SecondLucianDevice) then
		self.SecondLucianDevice:Remove()
	end
	if IsValid(self) and IsValid(self.MainLDO) then
		self.MainLDO:Remove()
	end
end

function ENT:Use(activator)

	if !self.CanUse then return end
	
	if not IsValid(self.TargetDoor) then return end

	if IsValid(self) and IsValid(self.TargetDoor) and activator:KeyDown(IN_WALK) then -- Let us pick up when holding ALT and press E
		activator:Give("lucian_door_opener_wep")
		self:RemoveBothLDO()
		return
	end

	if IsValid(self) and IsValid(self.TargetDoor) and !activator:KeyDown(IN_WALK) then
	
		if self.TargetDoor.Open != true and self.TargetDoor.CanDoAnim then
			self.CanUse = false
			self:EmitSound("npc/scanner/cbot_servoscared.wav",70,100)
			timer.Simple(0.7, function() if IsValid(self) and IsValid(self.TargetDoor) then self:EmitSound("npc/scanner/combat_scan4.wav",70,100) self:UpdateSpriteColor(Color(0,255,0)) end end)
			timer.Simple(1.2, function() if IsValid(self) and IsValid(self.TargetDoor) then self.TargetDoor:Toggle() end end)
			timer.Simple(2.0, function() if IsValid(self) and IsValid(self.TargetDoor) then self:UpdateSpriteColor(Color(255,0,0)) end end)
			timer.Simple(3.0, function() if IsValid(self) and IsValid(self.TargetDoor) then self.CanUse = true end end)
		end
		
		if self.TargetDoor.Open == true and self.TargetDoor.CanDoAnim then
			self.CanUse = false
			self.TargetDoor:Toggle()
			timer.Simple(2.0, function() if IsValid(self) and IsValid(self.TargetDoor) then self.CanUse = true end end)
		end
	
	end

end

function ENT:Touch(ent)
	
	if ent:GetClass() == "cap_doors" and ent:GetModel() == "models/madman07/doors/dest_door.mdl" and ent.Attached != true then
		ent.Attached = true
		self.IsMain = true
		self.TargetDoor = ent
		self:SetPos(self.TargetDoor:LocalToWorld(Vector(0,0,0)))
		self:SetAngles(self.TargetDoor:LocalToWorldAngles(Angle(90,0,0)))
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:FollowBone(self.TargetDoor, self.TargetDoor:LookupBone("RightLock"))
		constraint.NoCollide(self,self.TargetDoor,0,0)
	end
	
	if ent:GetClass() == "cap_doors_frame" and ent:GetModel() == "models/madman07/doors/dest_frame.mdl" and ent.Door.Attached != true then
		ent.Door.Attached = true
		self.IsMain = true
		self.TargetDoor = ent.Door
		self:SetPos(self.TargetDoor:LocalToWorld(Vector(0,0,0)))
		self:SetAngles(self.TargetDoor:LocalToWorldAngles(Angle(90,0,0)))
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:FollowBone(self.TargetDoor, self.TargetDoor:LookupBone("RightLock"))
		constraint.NoCollide(self,self.TargetDoor,0,0)
	end
	
end

function ENT:Think()

	if not IsValid(self.TargetDoor) then
		self:RemoveBothLDO()
		return
	end
	
	if self.TargetDoor.Attached and not self.SecondAttached and not self.TargetDoor.LucianProcessDone then
		local second = ents.Create("lucian_door_opener");
		second:Spawn();
		second:Activate();
		self.SecondAttached = true
		second.MainLDO = self
		second.IsMain = false
		second.TargetDoor = self.TargetDoor
		second:SetPos(self.TargetDoor:LocalToWorld(Vector(0,0,0)))
		second:SetAngles(self.TargetDoor:LocalToWorldAngles(Angle(90,0,0)))
		second:SetCollisionGroup(COLLISION_GROUP_WORLD)
		second:FollowBone(self.TargetDoor, self.TargetDoor:LookupBone("LeftLock"))
		second.Owner = second.MainLDO.Owner
		constraint.NoCollide(second,self.TargetDoor,0,0)
		self.SecondLucianDevice = second
		self.SecondLucianDevice.Untouchable = true
		self.TargetDoor.LucianProcessDone = true
	end
	
	self:NextThink(CurTime()+0.1);
	
	return true
end

function ENT:OnRemove()
	self.Attached = false
	self.SecondAttached = false
	
	if IsValid(self.TargetDoor) then
		self.TargetDoor.Attached = false
		self.TargetDoor.LucianProcessDone = false
	end
	
	if IsValid(self.SecondLucianDevice) then
		self.SecondLucianDevice:Remove()
		self:Remove()
	end
	
	if IsValid(self) and IsValid(self.SecondLucianDevice) then
		self.SecondLucianDevice:Remove()
	end
	
	if IsValid(self) and IsValid(self.TargetDoor) and self.TargetDoor.Open == true then
		self.TargetDoor:Toggle()
	end
	
end

function ENT:PostEntityPaste() 
	self:Remove()
end

end