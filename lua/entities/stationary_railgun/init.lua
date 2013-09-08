--[[
	Stargate Railgun
	Copyright (C) 2010 Madman07
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Sounds={
	Shoot=Sound("weapons/railgun_shoot.wav"),
	-- Move=Sound("railgun/move.wav"),
}

-----------------------------------INITIALISE----------------------------------

function ENT:Initialize()

	self.Entity:SetModel("models/Madman07/railgun/stand.mdl");

	self.Entity:SetName("Stationary Railgun");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Entity:SetUseType(SIMPLE_USE)
	self.Entity:StartMotionController();

	if (WireAddon) then
		self.Inputs = WireLib.CreateInputs( self.Entity, {"Fire [NORMAL]", "Active [NORMAL]", "Reload [NORMAL]", "Vector [VECTOR]", "Entity [ENTITY]"});
		self.Outputs = WireLib.CreateOutputs( self.Entity, {"Ammo"});
	end

	self.Driver = NULL;

	self.Pitch = 15;
	self.Yaw = 0;
	self.Control = 0;
	self.Active = false;
	self.Pressed = false;
	self.CanFire = true;

	self.CannPhys = {}

	self.Bullets = 1000;
	self.Reloadb = false;

	self.weps = {}

	self.WireActive = nil;
	self.WireShoot = nil;
	self.WireReload = nil;
	self.WireEnt = nil;

	self:SetNetworkedEntity("Cann",self.Cann);
	self:SetNWEntity("Turn",self.Turn);
	self:SetNWEntity("Stand",self.Stand);
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local PropLimit = GetConVar("CAP_statrail_max"):GetInt()
	if(ply:GetCount("CAP_statrail")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Stationary Railguns limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = ang.y % 360

	local ent = ents.Create("stationary_railgun");
	ent:SetPos(tr.HitPos);
	ent:SetAngles(ang);
	ent:Spawn();
	ent:Activate();
	ent.Stand = ent;

	local phys = ent.Stand:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	ent.Turn, ent.Cann = ent:SpawnRest();
	ent.Owner = ply;

	ply:AddCount("CAP_statrail", ent)
	return ent
end

function ENT:SpawnRest()

	local pos = self.Entity:GetPos();
	local ang = self.Entity:GetAngles();

	local ent1 = ents.Create("prop_physics");
	util.PrecacheModel("models/Madman07/railgun/turn.mdl")
	ent1:SetModel("models/Madman07/railgun/turn.mdl");
	ent1:SetPos(pos);
	ent1:SetAngles(ang);
	ent1:Spawn();
	ent1:Activate();

	local data = ent1:GetAttachment(ent1:LookupAttachment("Ball"))
	if(not (data and data.Pos)) then self:OnRemove() return end

	local ent2 = ents.Create("prop_physics");
	util.PrecacheModel("models/Madman07/railgun/cann.mdl")
	ent2:SetModel("models/Madman07/railgun/cann.mdl");
	ent2:SetPos(data.Pos+ent1:GetRight()*10.25);
	ent2:SetAngles(ang+Angle(25,0,0));
	ent2:Spawn();
	ent2:Activate();

	local ballpos = ent1:WorldToLocal(data.Pos);

	constraint.NoCollide( self.Entity, ent1, 0, 0 );
	constraint.NoCollide( ent1, ent2, 0, 0 );
	constraint.NoCollide( self.Entity, ent2, 0, 0 );

	constraint.Ballsocket( ent1, self.Entity, 0, 0, Vector(0, 0, 20), 0, 0, 1);
	constraint.Ballsocket( ent1, self.Entity, 0, 0, Vector(0, 0, 0), 0, 0, 1);
	constraint.Ballsocket( ent2, ent1, 0, 0, ballpos+Vector(0, 20, 0), 0, 0, 1);
	constraint.Ballsocket( ent2, ent1, 0, 0, ballpos+Vector(0, -20, 0), 0, 0, 1);

	return ent1, ent2;

end

-----------------------------------DIFFERENT CRAP----------------------------------

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS; end

function ENT:OnRemove()
	if (self.Active and IsValid(self.Driver)) then self.Entity:Exit(); end
	if IsValid(self.Stand) then self.Stand:Remove(); end
	if IsValid(self.Turn) then self.Turn:Remove(); end
	if IsValid(self.Cann) then self.Cann:Remove(); end
end

function ENT:TriggerInput(variable, value)
	if (variable == "Vector") then self.WireVec = value;
	elseif (variable == "Entity") then self.WireEnt = value;
	elseif (variable == "Fire")   then self.WireShoot = value;
	elseif (variable == "Reload") then self.WireReload = value;
	elseif (variable == "Active") then self.WireActive = value;	end
end

-----------------------------------THINK----------------------------------

function ENT:Think(ply)

	if (not IsValid(self.Turn) or not IsValid(self.Cann)) then
		self.Entity:OnRemove();
		return
	end

	self:SetNWEntity("Turn",self.Turn);

	if (self.Active and IsValid(self.Driver)) then

		if (self.Driver:KeyDown( IN_USE ) and not self.Pressed) then self.Entity:Exit(); return end

		if (self.Driver:KeyDown( IN_RELOAD ) and (self.Bullets == 0)) then
			self.Reloadb = true;
			self.CanFire = false;
		end

	else

		if (self.WireActive == 1) then
			if ((self.WireReload == 1) and (self.Bullets == 0)) then self.Reloadb = true; end
			self.WireReload = nil;
		end

	end

	if self.Reloadb then
		self.Bullets = self.Bullets + 25;
		if (self.Bullets > 1000) then
			self.Bullets = 1000;
			self.Reloadb = false;
			self.CanFire = true;
		end
	end

	if (self.Pressed) then timer.Simple(1, function() self.Pressed = false end) end

end

-----------------------------------PHYSIC----------------------------------

function ENT:PhysicsUpdate( phys, deltatime )

	local data = self.Cann:GetAttachment(self.Cann:LookupAttachment("FIRE"))
	if(not (data and data.Pos)) then return end

	self.ShootPos = data.Pos - self.Cann:GetForward()*5;

	if (self.Active and IsValid(self.Driver)) then

		if (self.Control == 1) then

			local ang = self.Driver:GetAimVector():Angle();
			local angstand = self.Stand:GetAngles();
			local a = math.NormalizeAngle(ang.Pitch);
			local b = math.NormalizeAngle(ang.Yaw);
			local c = -1 * (a - angstand.Pitch)
			local d = b - angstand.Yaw
			local e = math.ApproachAngle(self.Pitch, c, 0.5)
			local f = math.ApproachAngle(self.Yaw, d, 0.5)
			self.Pitch = math.Clamp(e, 15, 85);
			self.Yaw  = math.Clamp(f, -160, 160);

			if (self.Driver:KeyDown( IN_ATTACK ) and self.CanFire) then self.Entity:Shoot(); end

		else

			if self.Driver:KeyDown( IN_MOVELEFT )  then self.Yaw   = math.Approach(self.Yaw,90,0.5); end
			if self.Driver:KeyDown( IN_MOVERIGHT ) then self.Yaw   = math.Approach(self.Yaw,-90,0.5); end
			if self.Driver:KeyDown( IN_FORWARD )   then self.Pitch = math.Approach(self.Pitch,85,0.5); end
			if self.Driver:KeyDown( IN_BACK )      then self.Pitch = math.Approach(self.Pitch,15,0.5); end

			if (self.Driver:KeyDown( IN_JUMP ) and self.CanFire) then self.Entity:Shoot(); end

		end

	else

		if (self.WireActive == 1) then

			local TargetPos = nil;

			if ((self.WireShoot == 1) and self.CanFire) then self.Entity:Shoot(); end

			if (self.WireEnt and self.WireEnt:IsValid()) then
				TargetPos = self.WireEnt:LocalToWorld(self.WireEnt:OBBCenter())
			elseif (self.WireVec) then
				TargetPos = self.WireVec;
			end

			if (TargetPos) then

				local ShootAngle = (TargetPos - self.ShootPos):Angle() - self.Stand:GetAngles();
				local a = -1*math.NormalizeAngle(ShootAngle.Pitch)
				local b = math.NormalizeAngle(ShootAngle.Yaw+180)
				local c = math.ApproachAngle(self.Pitch, a, 0.5)
				local d = math.ApproachAngle(self.Yaw, b, 0.5)
				self.Pitch = math.Clamp(c, 15, 85);
				self.Yaw  = math.Clamp(d, 160, -160);

			end

		end

	end

	if (IsValid(self.Cann) and IsValid(self.Cann:GetPhysicsObject())) then
		local Cannon = self.Cann:GetPhysicsObject();
		Cannon:Wake();

		self.CannPhys = {
			secondstoarrive = 0.2;
			angle 			= self.Stand:GetAngles() + Angle(self.Pitch, self.Yaw, 0);
			maxangular 		= 1000000;
			maxangulardamp 	= 100000000;
			dampfactor 		= 0.8;
			deltatime 		= deltatime;
		}
		Cannon:ComputeShadowControl(self.CannPhys);
	end

end

-----------------------------------USE, ENTER, EXIT----------------------------------

function ENT:Use(ply,caller)
	if (not self.Active and not IsValid(self.Driver) and not self.Pressed) then self.Entity:Enter(ply); end
end

function ENT:Enter(ply)
	self:SetNWEntity("Cann",self.Cann);
	self:SetNWEntity("Turn",self.Turn);
	self:SetNWEntity("Stand",self.Stand);

	self.Active = true;
	--ply:SetScriptedVehicle(self);
	ply:SetNetworkedEntity( "ScriptedVehicle", self )
	ply:SetViewEntity( self )
	-- Garry broke this function
	/*if(not(game.SinglePlayer())) then
		ply:SetClientsideVehicle(self);
	end*/
	ply:SetMoveType(MOVETYPE_OBSERVER);
	ply:DrawViewModel(false);
	ply:DrawWorldModel(false);
	ply:Spectate( OBS_MODE_CHASE );
	for k,v in pairs(ply:GetWeapons()) do
		table.insert(self.weps, v:GetClass());
	end
	ply:StripWeapons();
	self.Control = 0;
	self.Driver = ply;
	ply:SetNWBool("InRailgun",true);
	self.Pressed = true;

	--self:SpawnRagdoll()
end

function ENT:Exit()
	self.Active = false;
	self.Driver:UnSpectate();
	self.Driver:DrawViewModel(true);
	self.Driver:DrawWorldModel(true);
	self.Driver:SetMoveType(MOVETYPE_VPHYSICS);
	self.Driver:Spawn();
	for k,v in pairs(self.weps) do
		self.Driver:Give(tostring(v));
	end
	self.Driver:SetPos(self.Stand:GetPos() - self.Stand:GetForward() * 100 - self.Stand:GetRight() * 100);
	self.Driver:SetParent();
	--self.Driver:SetScriptedVehicle(NULL);
	self.Driver:SetNetworkedEntity( "ScriptedVehicle", NULL )
	self.Driver:SetViewEntity( NULL )
	-- Garry broke this function
	/*if(not(game.SinglePlayer())) then
		self.Driver:SetClientsideVehicle(NULL);
	end*/
	self.Driver:SetNWBool("InRailgun",false);
	self.Driver = NULL;
	self.Pressed = true;
	--if IsValid(self.Ragdoll) then self.Ragdoll:Remove(); end

end


--####### Spawn the ragdoll @RononDex
function ENT:SpawnRagdoll()
	if(IsValid(self)) then
		local b = self.Turn:GetAttachment(self.Turn:LookupAttachment("pelvis"))
		if(not (b and b.Pos)) then return end

			local e = ents.Create("prop_ragdoll")
			e:SetModel(self.Driver:GetModel())
			e:SetPos(b.Pos)
			e:SetAngles(self.Turn:GetAngles()+Angle(0,180,0))
			e:Spawn()
			e:Activate()
			e:SetParent(self)
			e:GetPhysicsObject():EnableMotion(false)
			constraint.NoCollide( self.Turn, e, 0, 0 );
			constraint.NoCollide( self.Cann, e, 0, 0 );
			constraint.NoCollide( self.Stand, e, 0, 0 );
			constraint.Weld(e,self.Turn,0,0,0,true)
			self.Ragdoll=e
			self:RagdollPose()
	end
end

--############## This is what puts the ragdoll into the right pose @RononDex
function ENT:RagdollPose()

	local a = self.Turn:GetAttachment(self.Turn:LookupAttachment("head"))
	if(not (a and a.Pos)) then return end
	local head = self.Ragdoll:GetPhysicsObjectNum(10)
	--head:EnableMotion(false)
	head:SetPos(a.Pos)

	local b = self.Turn:GetAttachment(self.Turn:LookupAttachment("pelvis"))
	if(not (b and b.Pos)) then return end
	local pelvis = self.Ragdoll:GetPhysicsObjectNum(0)
	--pelvis:EnableMotion(false)
	pelvis:SetPos(b.Pos)

	local c = self.Turn:GetAttachment(self.Turn:LookupAttachment("chest"))
	if(not (c and c.Pos)) then return end
	local chest = self.Ragdoll:GetPhysicsObjectNum(1)
	--chest:EnableMotion(false)
	chest:SetPos(c.Pos)

	local d = self.Turn:GetAttachment(self.Turn:LookupAttachment("lefthand"))
	if(not (d and d.Pos)) then return end
	local lefthand = self.Ragdoll:GetPhysicsObjectNum(5)
	--lefthand:EnableMotion(false)
	lefthand:SetPos(d.Pos)

	local e = self.Turn:GetAttachment(self.Turn:LookupAttachment("righthand"))
	if(not (e and e.Pos)) then return end
	local righthand = self.Ragdoll:GetPhysicsObjectNum(7)
	--righthand:EnableMotion(false)
	righthand:SetPos(e.Pos)

	local f = self.Turn:GetAttachment(self.Turn:LookupAttachment("leftfoot"))
	if(not (f and f.Pos)) then return end
	local leftfoot = self.Ragdoll:GetPhysicsObjectNum(13)
	--leftfoot:EnableMotion(false)
	leftfoot:SetPos(f.Pos)

	local g = self.Turn:GetAttachment(self.Turn:LookupAttachment("rightfoot"))
	if(not (g and g.Pos)) then return end
	local rightfoot = self.Ragdoll:GetPhysicsObjectNum(14)
	--rightfoot:EnableMotion(false)
	rightfoot:SetPos(g.Pos)

end

-----------------------------------SHOOT----------------------------------

function ENT:Shoot()

	self.CanFire = false;

	self.StargateTrace = StarGate.Trace:New(self.ShootPos,self.ShootPos-self.Cann:GetForward() * 10^14);

	local mat = self.StargateTrace.MatType;
	local smoke = 1;
	if (self.StargateTrace.HitSky or (mat == MAT_FLESH) or (mat == MAT_METAL) or (mat == MAT_GLASS)) then smoke = 0 end

	local fx = EffectData();
		fx:SetStart(self.ShootPos);
		fx:SetOrigin(self.StargateTrace.HitPos);
		fx:SetMagnitude(smoke);
		fx:SetRadius(2);
	util.Effect("Bullet_tracer",fx);

	local effectdata = EffectData()
		effectdata:SetOrigin(self.ShootPos)
		effectdata:SetAngles(self.Cann:GetAngles())
		effectdata:SetScale( 2 )
	util.Effect( "MuzzleEffect", effectdata )

	local damage = GetConVar("CAP_statrail_damage"):GetInt();

	bullet = {}
	bullet.Src		= self.ShootPos;
	bullet.Attacker = self.Entity;
	bullet.Dir		= -1*self.Cann:GetForward();
	bullet.Spread	= Vector(0.01,0.01,0);
	bullet.Num		= 1;
	bullet.Damage	= damage;
	bullet.Force	= damage;
	bullet.Tracer	= 0	;

	self.Cann:FireBullets(bullet);

	self.Bullets = self.Bullets - 1;
	self:EmitSound(self.Sounds.Shoot,100,math.random(98,102));
	util.ScreenShake(self.ShootPos,2,2.5,0.5,800);

	local rand = math.random(4,10)/100;
	timer.Simple(rand, function() self.CanFire = true; end);

	Wire_TriggerOutput(self.Entity, "Ammo", self.Bullets);
	self.Entity:SetNWInt("ammo",self.Bullets)

end

-----------------------------------DUPE INFO----------------------------------

function ENT:PreEntityCopy()
	local dupeInfo = {}
	if IsValid(self.Stand) then
		dupeInfo.StandID = self.Stand:EntIndex()
	end
	if IsValid(self.Turn) then
		dupeInfo.TurnID = self.Turn:EntIndex()
	end
	if IsValid(self.Cann) then
		dupeInfo.CannID = self.Cann:EntIndex()
	end
	if WireAddon then
		dupeInfo.WireData = WireLib.BuildDupeInfo( self.Entity )
	end
	duplicator.StoreEntityModifier(self, "StatRailDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "StatRailDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local dupeInfo = Ent.EntityMods.StatRailDupeInfo

	if (IsValid(ply)) then
		local PropLimit = GetConVar("CAP_statrail_max"):GetInt()
		if(ply:GetCount("CAP_statrail")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(\"Stationary Railguns limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			self.Entity:Remove();
			return
		end
	end

	if dupeInfo.StandID then
		self.Stand = CreatedEntities[ dupeInfo.StandID ]
	end
	if dupeInfo.TurnID then
		self.Turn = CreatedEntities[ dupeInfo.TurnID ]
	end
	if dupeInfo.CannID then
		self.Cann = CreatedEntities[ dupeInfo.CannID ]
	end

	if(Ent.EntityMods and Ent.EntityMods.StatRailDupeInfo.WireData) then
		WireLib.ApplyDupeInfo( ply, Ent, Ent.EntityMods.StatRailDupeInfo.WireData, function(id) return CreatedEntities[id] end)
	end

	self.Driver = NULL;
	self.Pitch = 15;
	self.Yaw = 0;
	self.Control = 0;
	self.Active = false;
	self.Pressed = false;
	self.CanFire = true;

	self.CannPhys = {}

	self.Bullets = 1000;
	self.Reloadb = false;

	self.weps = {}

	if (IsValid(ply)) then
		ply:AddCount("CAP_statrail", self.Entity)
	end

end
		--PrintMessage( HUD_PRINTTALK, ""..tostring() )