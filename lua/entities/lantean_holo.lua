--[[
	Holo
	Copyright (C) 2011 Madman07
]]--

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Lantean Holo"
ENT.Author			= "Madman07, MarkJaw, Iziraider, Boba Fett"
ENT.Category		= "Stargate Carter Addon Pack"

list.Set("CAP.Entity", ENT.PrintName, ENT);

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end
AddCSLuaFile()

ENT.Sounds = {
	Idle=Sound("tech/asgard_holo.wav"),
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:SetName("Lantean Holo Device");
	self.Entity:SetModel("models/MarkJaw/atlantis_holo/holo.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self:CreateWireOutputs("Activated");

	self.Touching = 0;
	self.SoundLoop = CreateSound(self,self.Sounds.Idle);
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr)
	if ( !tr.Hit ) then return end
	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local PropLimit = GetConVar("CAP_lantholo_max"):GetInt()
	if(ply:GetCount("CAP_lantholo")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"entity_limit_holo\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local ent = ents.Create("lantean_holo");
	ent:SetPos(tr.HitPos);
	ent:SetAngles(ang);
	ent:Spawn();
	ent:Activate();

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	ply:AddCount("CAP_lantholo", ent)
	return ent
end

-----------------------------------TOUCH----------------------------------

function ENT:StartTouch(ent)
	if ent:IsPlayer() then
		if (self.SoundLoop) then
			self.SoundLoop:Play();
			self.SoundLoop:SetSoundLevel(85);
		end
		self.Touching = self.Touching+1;
		if (self.Touching == 1) then self:SetNetworkedBool("Display", true); self:SetWire("Activated",true); end
		if timer.Exists(self:EntIndex().."NotTouch") then timer.Destroy(self:EntIndex().."NotTouch"); end
	end
end

function ENT:EndTouch(ent)
	if ent:IsPlayer() then
		self.Touching = self.Touching-1;
		timer.Create( self:EntIndex().."NotTouch", 1, 1, function()
			if IsValid(self) then
				if (self.Touching == 0) then self:SetNWBool("Display", false); self:SetWire("Activated",false); end
				if (self.SoundLoop) then
					self.SoundLoop:FadeOut(1);
				end
			end
		end);
	end
end

function ENT:OnRemove()
	if (self.SoundLoop) then
		self.SoundLoop:Stop();
	end
end

function ENT:PreEntityCopy()
	local dupeInfo = {}
	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end

	duplicator.StoreEntityModifier(self, "DestConDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "DestConDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	if (IsValid(ply)) then
		local PropLimit = GetConVar("CAP_lantholo_max"):GetInt();
		if(ply:GetCount("CAP_lantholo")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"entity_limit_holo\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			self.Entity:Remove();
			return;
		end
	end

	local dupeInfo = Ent.EntityMods.DestConDupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	if (IsValid(ply)) then
		self.Owner = ply;
		ply:AddCount("CAP_lantholo", self.Entity)
	end

end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "lantean_holo", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_main_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_lant_holo");
end

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

if (StarGate==nil or StarGate.MaterialFromVMT==nil) then return end
ENT.Stars = StarGate.MaterialFromVMT(
	"Stars",
	[["Sprite"
	{
		"$spriteorientation" "vp_parallel"
		"$spriteorigin" "[ 0.50 0.50 ]"
		"$basetexture" "sprites/glow04"
		"$spriterendermode" 5
	}]]
);

function ENT:Initialize()
	self.Speed = 5;
	self.Created = CurTime();
	self.Alpha = 0;

	self.RandRadius = {};
	self.RandAngle = {};
	self.RandZ = {};
	self.Col = {};
	self.Size = {};

	for i=1,200 do
		local randrad = math.Rand(20,150);
		local randangle = math.Rand(0,360);
		local randz = math.Rand(100,150);
		local size = math.Rand(5,20);
		local col = Vector(255,255,255,255);
		if (math.random(0,1) == 0) then col = Vector(math.random(150,200),math.random(0,30),math.random(0,30));
		else col = Vector(math.random(0,30),math.random(0,30),math.random(150,200)); end

		table.insert(self.RandRadius, randrad);
		table.insert(self.RandAngle, randangle);
		table.insert(self.RandZ, randz);
		table.insert(self.Size, size);
		table.insert(self.Col, col);
	end
end

function ENT:Draw()
	if self:GetNetworkedBool("Display", false) then
		self.Alpha = math.Approach(self.Alpha, 255, 5);
	else
		self.Alpha = math.Approach(self.Alpha, 0, -5);
	end

	self:DrawSprities();
	self.Entity:DrawModel();
end

function ENT:DrawSprities()
	local selfpos = self:GetPos();
	local time = (CurTime() - self.Created)*self.Speed;

	self:SetRenderBoundsWS(selfpos+1000*Vector(1,1,1), selfpos-1000*Vector(1,1,1));

	render.SetMaterial(self.Stars);

	for i=1,200 do
		local randrad = self.RandRadius[i];
		local randangle = self.RandAngle[i];
		local randz = self.RandZ[i];
		local size = self.Size[i];
		local col0 = self.Col[i];

		local pos =  selfpos + Vector(math.sin(math.rad(time+randangle))*randrad,math.cos(math.rad(time+randangle))*randrad,randz);

		local col = Color(col0.x, col0.y, col0.z, self.Alpha);
		render.DrawSprite(pos,size,size,col);

		col = Color(255, 255, 255, self.Alpha);
		render.DrawSprite(pos,size/4,size/4,col);
	end
end

function ENT:Think()
	if self:GetNWBool("Display", false) then
		if not self.Light then
			local dlight = DynamicLight(self:EntIndex().."light");
			if dlight then
				dlight.Pos = self.Entity:LocalToWorld(Vector(0,0,30));
				dlight.r = 255;
				dlight.g = 255;
				dlight.b = 255;
				dlight.Brightness = 7;
				dlight.Decay = 0;
				dlight.Size = 150;
				dlight.DieTime = CurTime()+0.25;
				self.Light = dlight;
				timer.Create( "Light"..self:EntIndex(), 0.1, 0, function()
					if IsValid(self.Entity) then
						self.Light.Pos = self.Entity:LocalToWorld(Vector(0,0,30));
						self.Light.DieTime = CurTime()+0.25;
					end
				end);
			end
		end
	else
		if timer.Exists("Light"..self:EntIndex()) then timer.Destroy("Light"..self:EntIndex()); end
		self.Light = nil;
	end
end

function ENT:OnRemove()
	if timer.Exists("Light"..self:EntIndex()) then timer.Destroy("Light"..self:EntIndex()); end
end

end