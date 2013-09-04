--[[
	Dakara Weapon
	Copyright (C) 2011 Madman07
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

ENT.Sounds = {
	Charge = Sound("dakara/dakara_charge.wav"),
	Release = Sound("dakara/dakara_release_energy.wav"),
	Loop = Sound("tech/background_loop.wav"),
}

ENT.NoDissolve = true; -- hope it will fix dissapearing dakara thingy

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	self.Entity:SetModel("models/Iziraider/dakara/dakara.mdl");

	self.Entity:SetName("Dakara Weapon");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Anim = false;
	self.OpenMain = false;
	self.OpenSecret = false;
	self.Busy = false;
	self.AlreadyOpened = false;
	self.CanDoAnim = true;

	self.MaxRadius = 15000;
	self.ProtectedByTouch = {};

	--self.Entity:SpawnStuff()

	self.Sounds.LoopSound = CreateSound(self.Entity, self.Sounds.Loop);
	self.Sounds.LoopSound:Play();
	self.Sounds.LoopSound:SetSoundLevel(140);

end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local PropLimit = GetConVar("CAP_dakara_max"):GetInt()
	if(ply:GetCount("CAP_dakara")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Dakara Building limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		self:Remove();
		return
	end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("dakara_building");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos-Vector(0,0,15));
	ent:Spawn();
	ent:Activate();

	ent:SetPos(ent:GetPos()-ent:GetForward()*2000);

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	ent.Owner = ply;
	ply:AddCount("CAP_dakara", ent)
	ent:SpawnStuff()
	return ent
end

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Control) then
		dupeInfo.Control = self.Control:EntIndex();
	end

	if IsValid(self.MainDoor) then
		dupeInfo.MainDoor = self.MainDoor:EntIndex();
	end

	if IsValid(self.SecretDoor) then
		dupeInfo.SecretDoor = self.SecretDoor:EntIndex();
	end

	if IsValid(self.MainButton1) then
		dupeInfo.MainButton1 = self.MainButton1:EntIndex();
	end

	if IsValid(self.MainButton2) then
		dupeInfo.MainButton2 = self.MainButton2:EntIndex();
	end

	if IsValid(self.SecretButton1) then
		dupeInfo.SecretButton1 = self.SecretButton1:EntIndex();
	end

	if IsValid(self.SecretButton2) then
		dupeInfo.SecretButton2 = self.SecretButton2:EntIndex();
	end

	duplicator.StoreEntityModifier(self, "DakaraDupe", dupeInfo)
	StarGate.WireRD.PreEntityCopy(self)
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)

	local dupeInfo = Ent.EntityMods["DakaraDupe"] or {}

	if dupeInfo.Control then
		self.Control = CreatedEntities[ dupeInfo.Control ]
		self.Control.Parent = self.Entity;
	end

	if dupeInfo.MainDoor then
		self.MainDoor = CreatedEntities[ dupeInfo.MainDoor ]
		self.MainDoor.Type = 1;
		self.MainDoor.Parent = self.Entity;
	end

	if dupeInfo.SecretDoor then
		self.SecretDoor = CreatedEntities[ dupeInfo.SecretDoor ]
		self.SecretDoor.Type = 2;
		self.SecretDoor.Parent = self.Entity;
	end

	if dupeInfo.MainButton1 then
		self.MainButton1 = CreatedEntities[ dupeInfo.MainButton1 ]
		self.MainButton1.Parent = self.Entity;
		self.MainButton1.Type = 1;
	end

	if dupeInfo.MainButton2 then
		self.MainButton2 = CreatedEntities[ dupeInfo.MainButton2 ]
		self.MainButton2.Parent = self.Entity;
		self.MainButton2.Type = 1;
	end

	if dupeInfo.SecretButton1 then
		self.SecretButton1 = CreatedEntities[ dupeInfo.SecretButton1 ]
		self.SecretButton1.Parent = self.Entity;
		self.SecretButton1.Type = 2;
	end

	if dupeInfo.SecretButton2 then
		self.SecretButton2 = CreatedEntities[ dupeInfo.SecretButton2 ]
		self.SecretButton2.Parent = self.Entity;
		self.SecretButton2.Type = 2;
	end

	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end

	local PropLimit = GetConVar("CAP_dakara_max"):GetInt()
	if(ply:GetCount("CAP_dakara")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Dakara Building limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		self.Entity:Remove();
		return
	end
	ply:AddCount("CAP_dakara", self.Entity)

	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

function ENT:SpawnStuff()

	local ang = self:GetAngles();

	local ent = ents.Create("ancient_control_panel");
	ent:SetAngles(ang);
	ent:SetPos(self:LocalToWorld(Vector(70, 0, 240)));
	ent.Parent = self;
	ent:Spawn();
	ent:Activate();
	constraint.Weld(self,ent,0,0,0,true)
	self.Control = ent;

	ent = ents.Create("dakara_door");
	ent:SetAngles(ang);
	ent:SetPos(self.Entity:GetPos());
	ent:SetModel("models/Iziraider/dakara/door_main.mdl");
	ent:Spawn();
	ent:Activate();
	ent.Parent = self;
	ent.Type = 1;
	constraint.Weld(self,ent,0,0,0,true)
	self.MainDoor = ent;

	ent = ents.Create("dakara_door");
	ent:SetAngles(ang);
	ent:SetPos(self.Entity:GetPos());
	ent:SetModel("models/Iziraider/dakara/door_secret.mdl");
	ent:Spawn();
	ent:Activate();
	ent.Parent = self;
	ent.Type = 2;
	constraint.Weld(self,ent,0,0,0,true)
	self.SecretDoor = ent;

	util.PrecacheModel("models/beer/wiremod/numpad.mdl")

	ent = ents.Create("dakara_button");
	ent:SetAngles(ang+Angle(90, -270, 180));
	ent:SetPos(self:LocalToWorld(Vector(608, 105, 277)));
	ent.Parent = self;
	ent.Type = 1;
	ent:Spawn();
	ent:Activate();
	constraint.Weld(self,ent,0,0,0,true)
	self.MainButton1 = ent;

	ent = ents.Create("dakara_button");
	ent:SetAngles(ang+Angle(90, -180, 180));
	ent:SetPos(self:LocalToWorld(Vector(550, 330, 277)));
	ent.Parent = self;
	ent.Type = 2;
	ent:Spawn();
	ent:Activate();
	constraint.Weld(self,ent,0,0,0,true)
	self.SecretButton2 = ent;

	ent = ents.Create("dakara_button");
	ent:SetAngles(ang+Angle(90, 50, 180));
	ent:SetPos(self:LocalToWorld(Vector(-75, 125, 231)));
	ent.Parent = self;
	ent.Type = 2;
	ent:Spawn();
	ent:Activate();
	constraint.Weld(self,ent,0,0,0,true)
	self.SecretButton1 = ent;

	ent = ents.Create("dakara_button");
	ent:SetAngles(ang+Angle(90, 0, 180));
	ent:SetPos(self:LocalToWorld(Vector(514, -158, 277)));
	ent.Parent = self;
	ent.Type = 1;
	ent:Spawn();
	ent:Activate();
	constraint.Weld(self,ent,0,0,0,true)
	self.MainButton2 = ent;

end

-----------------------------------OTHER CRAP----------------------------------

function ENT:OnRemove(ply)
	if self.Sounds.LoopSound then
		self.Sounds.LoopSound:Stop();
		self.Sounds.LoopSound = nil;
	end
	if IsValid(self.Control) then self.Control:Remove() end
	if IsValid(self.MainDoor) then self.MainDoor:Remove() end
	if IsValid(self.SecretDoor) then self.SecretDoor:Remove() end
	if IsValid(self.MainButton1) then self.MainButton1:Remove() end
	if IsValid(self.MainButton2) then self.MainButton2:Remove() end
	if IsValid(self.SecretButton1) then self.SecretButton1:Remove() end
	if IsValid(self.SecretButton2) then self.SecretButton2:Remove() end
end

function ENT:Think(ply)
	local e = ents.FindInSphere(self:GetPos()+Vector(0,0,1000), 1000);
	for _,v in pairs(e) do
		if (v:IsPlayer() and v:GetMoveType() == MOVETYPE_NOCLIP) then
			v:SetMoveType(MOVETYPE_WALK)
		end
	end
	self.Entity:NextThink(CurTime());
	return true;
end

--########## Run the anim that's set in the arguements @RononDex
function ENT:Anims(e,anim,delay,nosound,sound)
	if(e.CanDoAnim) then
		self:NextThink(CurTime());
		e.CanDoAnim = false;
		if(not(nosound)) then --Set false to allow sound
			e:EmitSound(Sound(sound),100,100); --create sound as a string in the arguements
		end
		e:SetPlaybackRate(1);
		e:ResetSequence(e:LookupSequence(anim)); -- play the sequence
		timer.Create(anim..e:EntIndex(),delay,1,function()--How long until we can do the anim again?
			e.CanDoAnim = true;
		end);
	end
end

function ENT:StartTouch(ent)
	if IsValid(ent) then
		if not table.HasValue(self.ProtectedByTouch, ent) then table.insert(self.ProtectedByTouch, ent) end
	end
end

function ENT:EndTouch(ent)
	if IsValid(ent) then
		local new_t = {};
		for _,v in pairs(self.ProtectedByTouch) do
			if(v ~= ent) then
				table.insert(new_t,v);
			end
		end
		self.ProtectedByTouch=new_t;
	end
end

function ENT:PrepareWeapon(power, d_ply, d_prp, d_veh, d_rep, d_npc)
	util.ScreenShake(self:GetPos(),4,4.5,20,1500);
	self:Anims(self, "open", 10, false, "dakara/dakara_charge.wav")

	timer.Create("DoWeaponClose"..self:EntIndex(),12,1,function()
		if IsValid(self) then
			util.ScreenShake(self:GetPos(),4,4.5,20,1500);
			self:Anims(self, "close", 10, true)
		end
	end);

	self.Targets = {}
	if (d_ply == 1) then table.insert(self.Targets, "player") end
	if (d_prp == 1) then table.insert(self.Targets, "prop") end
	if (d_veh == 1) then table.insert(self.Targets, "vehicle") end
	if (d_rep == 1) then table.insert(self.Targets, "replicator") end
	if (d_npc == 1) then table.insert(self.Targets, "npc") end

	self.MaxRadius = 15000+power*1000;

	timer.Create("CreateWave"..self:EntIndex(),8,1,function() if IsValid(self) then self.Entity:CreateWave() end end);
	timer.Create("CreateEffect"..self:EntIndex(),1,1,function() if IsValid(self) then self.Entity:SpawnChargingEffect() end end);
end

function ENT:SpawnChargingEffect()
    --Should stop this effect from not showing sometimes.
   timer.Simple(0.1, function()
      local effectInfo = EffectData()
	  effectInfo:SetEntity(self.Entity)
      effectInfo:SetMagnitude(10)
      effectInfo:SetScale(10)
      util.Effect("dakara_charging", effectInfo)
   end)
end

function ENT:CreateWave()
	local immuneEnts = {}
	immuneEnts = self.ProtectedByTouch;
	table.insert(immuneEnts, self.Entity)
	table.insert(immuneEnts, self.Control)
	table.insert(immuneEnts, self.MainDoor)
	table.insert(immuneEnts, self.SecretDoor)
	table.insert(immuneEnts, self.MainButton1)
	table.insert(immuneEnts, self.MainButton2)
	table.insert(immuneEnts, self.SecretButton1)
	table.insert(immuneEnts, self.SecretButton2)

	self.Wave = ents.Create("dakara_wave")
	self.Wave:Setup(self.Entity:GetPos()+Vector(0,0,2300), immuneEnts, self.Targets, true, self.MaxRadius)
	self.Wave:Spawn()
	self.Wave:Activate()
	self.Entity:EmitSound(self.Sounds.Release,100,math.random(98,102));
end

function ENT:FindGate()
	local gate;
	local dist = 10000;
	local pos = self.Entity:GetPos();
	for _,v in pairs(ents.FindByClass("stargate_*")) do
		if(v.IsStargate and v:GetClass() != "stargate_supergate" and v:GetClass() != "stargate_orlin" and v:GetClass() != "stargate_universe" and not v.GateGalaxy) then
			local sg_dist = (pos - v:GetPos()):Length();
			if(dist >= sg_dist) then
				dist = sg_dist;
				gate = v;
			end
		end
	end
	return gate;
end

function ENT:FindAllGate()
	local gate = {};
	for _,v in pairs(ents.FindByClass("stargate_*")) do
		if(v.IsStargate and v:GetClass() != "stargate_supergate" and v:GetClass() != "stargate_orlin" and v != self.DialGate and v:GetClass() != "stargate_universe" and not v.GateGalaxy) then
			table.insert(gate,v);
			v.Target = v;
		end
	end
	return gate;
end