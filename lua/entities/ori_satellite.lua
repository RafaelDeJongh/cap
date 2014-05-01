--[[
	Ori Satellite
	Copyright (C) 2010 Madman07
]]--

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Ori Satellite"
ENT.WireDebugName = "Ori Satellite"
ENT.Author = "Madman07, Iziraider, Boba Fett"
ENT.Instructions= ""
ENT.Contact = "madman097@gmail.com"
ENT.Category = "Stargate Carter Addon Pack: Weapons"

list.Set("CAP.Entity", ENT.PrintName, ENT);

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile()

ENT.Sounds={
	Engage=Sound("shields/shield_engage.mp3"),
	Disengage=Sound("shields/shield_disengage.mp3"),
	Shoot=Sound("weapons/ori_beam.wav"),
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	if (WireAddon) then
		self.Inputs = WireLib.CreateInputs( self.Entity, {"Fire", "Active", "Shield", "Vector [VECTOR]","Entity [ENTITY]"});
		self.Outputs = WireLib.CreateOutputs( self.Entity, {"Shield Status", "Weapon Status", "Health"});
	end

	self.Entity:SetModel("models/Iziraider/ori_sat/ori_sat.mdl");

	self.Entity:SetName("Ori Satellite");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	local phys = self.Entity:GetPhysicsObject();
	if (phys:IsValid()) then
		phys:EnableGravity(false);
		phys:SetMass(200);
		phys:Wake();
	end
	self.Entity:SetGravity(0);
	self.Entity:StartMotionController();

	self.Time = CurTime()

	self.APC = nil;
	self.APCply = nil;

	self.HealthWep = StarGate.CFG:Get("ori_satellite","health",500);
	self.WepPower = 0;
	self.Shield = nil;
	self.Strength = 100;
	self.StrengthShield = 100;

	self.WireActive = nil;
	self.WireShoot = nil;
	self.WireShield = nil;
	self.WireEnt = nil;
	self.WireVec = nil;

	self.Beam = NULL;
	self.CantDamage = false;

	self.SatellitePhys = {}
	self.Angles = Angle(90,0,0);
	self.Position = self.Entity:GetPos();
	self.TouchPosition = self.Entity:GetPos();
	self.Touched = false;

	self.Timing = false;
	self.CallThink = false;
	self.Pressed = false
	self.LowThink = true;

	self.ShieldColor = Vector(1,0.6,0)
	self.Seq = self.Entity:LookupSequence("Spin");
	self.Entity:ResetSequence(self.Seq)

	timer.Create( self.Entity:EntIndex().."Anim", 33, 0, function() if IsValid(self.Entity) then self.Entity:ResetSequence(self.Seq) end end)

	Wire_TriggerOutput(self.Entity, "Shield Status", self.StrengthShield);
	Wire_TriggerOutput(self.Entity, "Weapon Status", self.WepPower);
	Wire_TriggerOutput(self.Entity, "Health", MaxHealth);

	local dynlight = ents.Create( "light_dynamic" );
	dynlight:SetPos(self.Entity:LocalToWorld(Vector(0,0,67.5)));
	dynlight:SetKeyValue( "_light", 255 .. " " .. 85 .. " " .. 0 .. " " .. 255 );
	dynlight:SetKeyValue( "style", 0 );
	dynlight:SetKeyValue( "distance", 100 );
	dynlight:SetKeyValue( "brightness", 10 );
	dynlight:SetParent(self.Entity);
	dynlight:Spawn();
	self.Light = dynlight;

	local dynlight2 = ents.Create( "light_dynamic" );
	dynlight2:SetPos(self.Entity:LocalToWorld(Vector(0,0,-120)));
	dynlight2:SetKeyValue( "_light", 255 .. " " .. 85 .. " " .. 0 .. " " .. 255 );
	dynlight2:SetKeyValue( "style", 0 );
	dynlight2:SetKeyValue( "distance", 50 );
	dynlight2:SetKeyValue( "brightness", 10 );
	dynlight2:SetParent(self.Entity);
	dynlight2:Spawn();
	self.Light2 = dynlight2;

end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local PropLimit = GetConVar("CAP_ori_max"):GetInt()
	if(ply:GetCount("CAP_ori")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Ori Satellites limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	ent = ents.Create("ori_satellite");
	ent:SetPos(tr.HitPos+Vector(0,0,800));
	ent:SetAngles(Angle(0,0,0));
	ent:Spawn();
	ent:Activate();
	local phys = ent:GetPhysicsObject()
	if phys and phys:IsValid() then
		phys:EnableMotion(false) -- Freezes the object in place.
	end

	ply:AddCount("CAP_ori", ent)
	return ent
end

function ENT:SpawnShield()
	local e = ents.Create("shield");
	e.Size = 240;
	e.DrawBubble = true;
	e:SetPos(self.Entity:GetPos()-self.Entity:GetUp()*50);
	e:SetAngles(self.Entity:GetAngles());
	e:SetParent(self.Entity);
	e:Spawn();
	e:SetNetworkedVector("shield_color",self.ShieldColor);
	e:SetNWBool("containment",false);
	timer.Simple(0.1,function()
		if (IsValid(e)) then
			e:DrawBubbleEffect();
		end
	end);
	e:SetTrigger(true);
	self.Entity:EmitSound(self.Sounds.Engage,90,math.random(90,110));
	return e
end

-----------------------------------REMOVE----------------------------------

function ENT:RemoveShield()
	self.Shield:Remove();
	self.Shield = nil;
	self:EmitSound(self.Sounds.Disengage,90,math.random(90,110));
end

function ENT:OnRemove()
	if timer.Exists(self.Entity:EntIndex().."Anim") then timer.Destroy(self.Entity:EntIndex().."Anim"); end
	if timer.Exists("CantDamage"..self.Entity:EntIndex()) then timer.Destroy("CantDamage"..self.Entity:EntIndex()); end
	if IsValid(self.Entity) then self.Entity:Remove(); end
	if IsValid(self.Shield) then self.Shield:Remove(); end
	if IsValid(self.Light) then
		self.Light:Fire("TurnOn","","0");
		self.Light:Remove();
		self.Light = nil;
	end
	if IsValid(self.Light2) then
		self.Light2:Fire("TurnOn","","0");
		self.Light2:Remove();
		self.Light2 = nil;
	end
	StarGate.WireRD.OnRemove(self)
end

-----------------------------------DAMAGE----------------------------------

function ENT:Hit(strength,normal,pos) end

function ENT:OnTakeDamage(dmg)
	if (not self.Shield and not self.CantDamage) then
		self.HealthWep = self.HealthWep - dmg:GetDamage();

		if (self.HealthWep <= 1) then
			local effectdata = EffectData();
				effectdata:SetOrigin( self.Entity:GetPos() );
				effectdata:SetStart(self.Entity:GetUp());
			util.Effect( "dirtyxplo", effectdata );
			self.Entity:Remove();
		end
	end
end

-----------------------------------TOUCH, WIRE----------------------------------

function ENT:TriggerInput(variable, value)
	if (variable == "Vector") then self.WireVec = value;
	elseif (variable == "Entity") then self.WireEnt = value;
	elseif (variable == "Fire") then self.WireShoot = value;
	elseif (variable == "Shield") then self.WireShield = value;
	elseif (variable == "Active") then self.WireActive = value;	end
end

function ENT:StartTouch( ent )
	if (ent and ent:IsValid() and ent:IsVehicle()) then
		if (self.APC != ent) then
			local ed = EffectData()
				ed:SetEntity( ent )
			util.Effect( "old_propspawn", ed, true, true )
		end
		self.APC = ent;
	end
end

-----------------------------------THINK----------------------------------

function ENT:LowProrityThink()
	self.LowThink = false;
	self.Strength = 100;

	if (self.Pressed == true) then timer.Simple( 1, function() self.Pressed = false end) end

	Wire_TriggerOutput(self.Entity, "Shield Status", self.StrengthShield);
	Wire_TriggerOutput(self.Entity, "Weapon Status", self.WepPower);
	Wire_TriggerOutput(self.Entity, "Health", self.HealthWep);

	if IsValid(self.APC) then

		self.APCply = self.APC:GetPassenger(0);
		if IsValid(self.APCply) then

			if (self.APCply:KeyDown( IN_ATTACK2 )) then
				if (!self.Shield and self.StrengthShield == 100 and self.Pressed == false ) then self.Shield = self.Entity:SpawnShield(); self.Pressed = true;
				elseif (IsValid(self.Shield) and self.Pressed == false) then self.Entity:RemoveShield(); self.Pressed = true; end
			end

			self.APCply:CrosshairEnable();
			if (self.APCply:KeyDown( IN_ATTACK ) and self.WepPower == 100) then
				self.Beam = self.Entity:Launch();
				self.WepPower = 0;
			end

		end

	elseif (self.WireActive == 1) then

		if ((self.WireShoot == 1) and self.WepPower == 100) then
			self.Beam = self.Entity:Launch();
			self.WepPower = 0;
		end

		if (self.WireShield == 1) then
			if (!self.Shield and self.StrengthShield == 100) then self.Shield = self.Entity:SpawnShield(); end
		else
			if IsValid(self.Shield) then self.Entity:RemoveShield(); end
		end

	end

	if (self.StrengthShield == 0 and self.Shield and self.Shield:IsValid()) then self.Entity:RemoveShield(); end

	if (CurTime() - self.Time > 1) then
		local ShieldTime = StarGate.CFG:Get("ori_satellite","shield_time",120);
		local WeaponTime = StarGate.CFG:Get("ori_satellite","recharge_time",60);

		self.Time = CurTime();
		self.WepPower = self.WepPower + 100/WeaponTime;
		if (self.Shield and self.Shield:IsValid()) then self.StrengthShield = self.StrengthShield - 100/ShieldTime;
		else self.StrengthShield = self.StrengthShield + 100/ShieldTime; end
		self.StrengthShield = math.Clamp(self.StrengthShield, 0, 100);
		self.WepPower = math.Clamp(self.WepPower, 0, 100);
	end


	timer.Simple( 0.1, function() self.LowThink = true end)
end

function ENT:Think(ply)
	if (not IsValid(self)) then return end
	if self.LowThink then self.Entity:LowProrityThink(); end
	self.Entity:NextThink(CurTime());
	return true
end

-----------------------------------PHYS----------------------------------

function ENT:PhysicsUpdate( phys, deltatime )
	if (not IsValid(self)) then return end
	local TargetPos = nil;

	if IsValid(self.APC) then
		self.APCply = self.APC:GetPassenger(0)
		if IsValid(self.APCply) then
			TargetPos = self.APCply:GetEyeTrace().HitPos;
		end
	elseif (self.WireActive == 1) then

		if IsValid(self.WireEnt) then
			TargetPos = self.WireEnt:LocalToWorld(self.WireEnt:OBBCenter())
		elseif (self.WireVec) then
			TargetPos = self.WireVec;
		end

	end

	local AimVec = Angle(0,0,0);

	if (TargetPos == nil) then AimVec = self.Angles;
	else AimVec = (TargetPos - self.Entity:GetPos()):Angle();
	end

	self.Angles.Pitch = AimVec.Pitch
	self.Angles.Yaw = AimVec.Yaw

	local Satellite = self.Entity:GetPhysicsObject();
	Satellite:Wake();

	self.SatellitePhys = {
			secondstoarrive	 = 1.6;
			maxangular		 = 100;
			maxangulardamp 	 = 1000;
			dampfactor 		 = 1;
			angle			 = self.Angles - Angle(90,0,0);
			deltatime		 = deltatime;
	}
	Satellite:ComputeShadowControl(self.SatellitePhys);

	Satellite:AddVelocity(-1*self.Entity:GetVelocity()/10)

end

function ENT:Launch()
	local pos = self.Entity:LocalToWorld(Vector(0,0,-240));

	local ent = ents.Create("energy_beam2");
	ent.Owner = self.Entity;
	ent:SetPos(pos);
	ent:Spawn();
	ent:Activate();
	ent:SetOwner(self.Entity);
	ent:Setup(pos, -1*self.Entity:GetUp(), 400, 1.5, "Ori");

	self.Entity:EmitSound(self.Sounds.Shoot,100,100);

	local glow = EffectData();
		glow:SetEntity(self.Entity);
		glow:SetStart(Vector(0,0,-240));
		glow:SetAngles(Angle(240,200,120));
		glow:SetScale(30);
		glow:SetMagnitude(1.5);
	util.Effect("energy_glow", glow);

	self.CantDamage = true;
	timer.Create("CantDamage"..self.Entity:EntIndex(), 5, 1, function() self.CantDamage = false; end);
end

function ENT:PreEntityCopy()
	local dupeInfo = {}
	if IsValid(self.Entity) then
		dupeInfo.EntityID = self.Entity:EntIndex()
	end
	if IsValid(self.APC) then
	    dupeInfo.APCID = self.APC
	end
	if WireAddon then
		dupeInfo.WireData = WireLib.BuildDupeInfo( self.Entity )
	end
	duplicator.StoreEntityModifier(self, "OriDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "OriDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local dupeInfo = Ent.EntityMods.OriDupeInfo

	if (IsValid(ply)) then
		local PropLimit = GetConVar("CAP_ori_max"):GetInt()
		if(ply:GetCount("CAP_ori")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(\"Ori Satellites limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			self.Entity:Remove();
			return
		end
	end

	if dupeInfo.EntityID then
		self.Entity = CreatedEntities[ dupeInfo.EntityID ]
	end
	if dupeInfo.APCID then
		self.APC = dupeInfo.APCID
	end

	if(Ent.EntityMods and Ent.EntityMods.OriDupeInfo.WireData) then
		WireLib.ApplyDupeInfo( ply, Ent, Ent.EntityMods.OriDupeInfo.WireData, function(id) return CreatedEntities[id] end)
	end

	self.Time = CurTime()

	self.WepPower = 0;
	self.Shield = nil;
	self.Strength = 100;
	self.StrengthShield = 100;

	self.Position = self.Entity:GetPos();
	self.TouchPosition = self.Entity:GetPos();
	self.Touched = false;

	self.Timing = false;
	self.CallThink = false;
	self.Pressed = false

	if (IsValid(ply)) then
		self.Owner = ply;
		ply:AddCount("CAP_ori", self.Entity)
	end

end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "ori_satellite", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_weapon_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_ori_satellite");
end

ENT.GlowSprite = Material("effects/multi_purpose_noz"); //MaterialFromVMT doesn't support changing render mode of sprities! @Mad
ENT.Col = Color(255,85,0,50);

function ENT:Draw()
	self.Entity:DrawModel();
	render.SetMaterial(self.GlowSprite);
	local endpos = self.Entity:LocalToWorld(Vector(0,0,67.5));
	if StarGate.LOSVector(EyePos(), endpos, {LocalPlayer(), self.Entity}, 50) then
		render.DrawSprite(endpos,250,250,self.Col);
	end
	local endpos = self.Entity:LocalToWorld(Vector(0,0,-120));
	if StarGate.LOSVector(EyePos(), endpos, {LocalPlayer(), self.Entity}, 50) then
		render.DrawSprite(endpos,250,250,self.Col);
	end
end

end