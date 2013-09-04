--[[
	Comunication Device
	Copyright (C) 2011 Madman07
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

ENT.Sounds = {
	Place = Sound("tech/comstone_placestone.wav"),
	Transfer = Sound("tech/comstone_transferminds.wav"),
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:SetModel("models/Madman07/com_device/device.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self.Stones = {};
	self.Channel = 1;
	self.ActiveStones = 0;
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("comstones_tablet");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	return ent
end

-----------------------------------USE----------------------------------

function ENT:Use(ply)
	umsg.Start("ComDeviceSet",ply)
	umsg.Entity(self.Entity);
	umsg.End()
end

-----------------------------------REMOVE----------------------------------

function ENT:OnRemove()
	for _,v in pairs(self.Stones) do
		self:Disconnect(v);
	end
end

-----------------------------------THINK----------------------------------

function ENT:Think(ply)
	concommand.Add("Chan"..self:EntIndex(),function(ply,cmd,args)
		self.Channel = tonumber(args[1]);
		self.Entity:SetNetworkedInt("Chann", self.Channel);
    end);
end

-----------------------------------TOUCH----------------------------------

function ENT:StartTouch(ent)
	if (ent:GetClass()=="comstones_stone") then
		self:EmitSound(self.Sounds.Place,100,math.random(98,102));
		ent.Tablet = self.Entity;
		local effectdata = EffectData()
			effectdata:SetEntity(ent)
		util.Effect( "entity_remove", effectdata )
		if (IsValid(ent.Ply) and ent.Ply:IsPlayer()) then self:Connect(ent); end
	end
end

function ENT:EndTouch(ent)
	if (ent:GetClass() == "comstones_stone" and table.HasValue(self.Stones, ent)) then
		self:EmitSound(self.Sounds.Place,100,math.random(98,102));
		ent.Tablet = NULL;
		local effectdata = EffectData()
			effectdata:SetEntity(ent)
		util.Effect( "entity_remove", effectdata )
		if (IsValid(ent.Ply) and ent.Ply:IsPlayer()) then self:Disconnect(ent); end
	end
end

-----------------------------------CONNECT----------------------------------

function ENT:Connect(ent)
	if table.HasValue(self.Stones, ent) then return end
	table.insert(self.Stones, ent);

	local device, pair = self:FindDevice();
	if not IsValid(device) then return end
	if not IsValid(pair) then return end

	local ply1 = ent.Ply;
	local ply2 = pair.Ply;

	self:EmitSound(self.Sounds.Transfer,100,math.random(98,102));
	device:EmitSound(device.Sounds.Place,100,math.random(98,102));

	if IsValid(ply1) and IsValid(ply2) then -- swap players
		self:SwapPlayers(ply1, ply2);
	else return end

	ply1.Stone = ent; -- for both side death purposes;
	ply2.Stone = pair;
	ply1.Ply = ply2;
	ply2.Ply = ply1;
	ply1.UsingStone = true;
	ply2.UsingStone = true;

	ent.Connected = true;
	ent.PairedStone = pair;
	pair.Connected = true;
	pair.PairedStone = ent;

	self.ActiveStones = self.ActiveStones+1;
	self.Entity:SetNWInt("Active", self.ActiveStones);

	device.ActiveStones = device.ActiveStones+1;
	device:SetNWInt("Active", device.ActiveStones);
end

function ENT:Disconnect(ent)
	local new_t = {};
	for _,v in pairs(self.Stones) do
		if(v ~= ent) then table.insert(new_t,v);
		end
	end
	self.Stones = new_t;

	self:EmitSound(self.Sounds.Transfer,100,math.random(98,102));

	if ent.Connected then
		ent.Connected = false;
		local pair = ent.PairedStone;
		if IsValid(pair) then
			local ply1 = ent.Ply;
			local ply2 = pair.Ply;

			if IsValid(ply1) and IsValid(ply2) then-- swap players back
				self:SwapPlayers(ply1, ply2);
			end

			ply1.Stone = nil;
			ply1.Ply = nil;
			ply1.UsingStone = true;
			ply1 = NULL;

			if IsValid(pair.Tablet) then --- disconnect second stone
				pair.Tablet:Disconnect(pair);
			end
			pair = NULL;

			self.ActiveStones = self.ActiveStones-1;
			self.Entity:SetNWInt("Active", self.ActiveStones);
		end
	end
end

-----------------------------------DEATH----------------------------------

function PlayerDeath_Stone(ply,a,b) -- What happen if one of connected player will die?
	if ply.UsingStone then
		local stone = ply.Stone
		if IsValid(ply2) then
			local tablet = stone.Tablet;
			if IsValid(tablet) then tablet:Disconnect(stone); end
		end

		local ply2 = ply.Ply;
		if IsValid(ply2) then ply2:Kill() end
	end
end
hook.Add( "PlayerDeath", "PlayerDeath_Stone", PlayerDeath_Stone )

-----------------------------------FIND----------------------------------

function ENT:FindDevice()
	local ston;
	local pos = self.Entity:GetPos();
	for _,v in pairs(ents.FindByClass("comstones_tablet")) do
		if(v != self.Entity and v.Channel == self.Channel) then
			ston = v:FindStone();
			if IsValid(ston) then
				return v, ston;
			end
		end
	end
	return nil, nil;
end

function ENT:FindStone()
	local stone;
	for _,v in pairs(self.Stones) do
		if not v.Connected then
			stone = v;
		end
	end
	return stone;
end

-----------------------------------SWAP----------------------------------

function ENT:SwapPlayers(pl1,pl2)

	local fx1 = EffectData();
		fx1:SetEntity(pl1);
	util.Effect("com_device_light",fx1,true);
	local fx2 = EffectData();
		fx2:SetEntity(pl2);
	util.Effect("com_device_light",fx2,true);

	local v1 = pl1:GetPos();
	local v2 = pl2:GetPos();
	local a1 = pl1:EyeAngles();
	local a2 = pl2:EyeAngles();
	local m1 = pl1:GetModel();
	local m2 = pl2:GetModel();
	local n1 = pl1:GetName();
	local n2 = pl1:GetName();
	local vh1 = pl1:GetVehicle();
	local vh2 = pl2:GetVehicle();
	local h1 = pl1:Health();
	local h2 = pl2:Health();
	local m1 = pl1:GetMoveType();
	local m2 = pl2:GetMoveType();

	local w1 = {};
	for k,v in pairs(pl1:GetWeapons()) do table.insert(w1, v:GetClass()) end
	local w2 = {};
	for k,v in pairs(pl2:GetWeapons()) do table.insert(w2, v:GetClass()) end

	local aw1 = pl1:GetActiveWeapon():GetClass();
	local aw2 = pl2:GetActiveWeapon():GetClass();

	-- pl1.__PreviousMoveType = pl1:GetMoveType();
	-- pl1:SetMoveType(MOVETYPE_NOCLIP)
	-- pl2.__PreviousMoveType = pl2:GetMoveType();
	-- pl2:SetMoveType(MOVETYPE_NOCLIP)

	pl1:SetPos(v2);
	pl2:SetPos(v1);
	pl1:SetEyeAngles(a2);
	pl2:SetEyeAngles(a1);

	pl1:SetMoveType(m2);
	pl2:SetMoveType(m1);

	pl1:SetModel(m2);
	pl2:SetModel(m1);
	pl1:SetName(n2);
	pl2:SetName(n1);

	pl1:SetHealth(h2);
	pl2:SetHealth(h1);

	if IsValid(vh1) then pl1:ExitVehicle() end
	if IsValid(vh2) then pl2:ExitVehicle() end

	pl1:StripWeapons();
	pl2:StripWeapons();
	for k,v in pairs(w2) do pl1:Give(tostring(v)); end
	for k,v in pairs(w1) do pl2:Give(tostring(v)); end
	pl1:SelectWeapon(aw2);
	pl2:SelectWeapon(aw1);

	if (IsValid(vh1)) then pl2:EnterVehicle(vh1) end
	if (IsValid(vh2)) then pl1:EnterVehicle(vh2) end
end

-----------------------------------DUPLICATOR----------------------------------

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end

	dupeInfo.Channel = self.Channel;

	duplicator.StoreEntityModifier(self, "StoneTabletDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "StoneTabletDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local dupeInfo = Ent.EntityMods.StoneTabletDupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	self.Channel = dupeInfo.Channel;
	self.Entity:SetNWInt("Chann", self.Channel);

end