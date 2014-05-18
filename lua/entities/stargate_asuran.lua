/*   Copyright (C) 2010 by Llapp   */

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Asuran Satellite"
ENT.Author = "Llapp "
ENT.Category = "Stargate Carter Addon Pack: Weapons"

list.Set("CAP.Entity", ENT.PrintName, ENT);

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end
AddCSLuaFile()

AsuranGibs={}
AsuranGibs[1] = "models/Iziraider/asuransat/gibs/gib1.mdl"
AsuranGibs[2] = "models/Iziraider/asuransat/gibs/gib2.mdl"
AsuranGibs[3] = "models/Iziraider/asuransat/gibs/gib3.mdl"
AsuranGibs[4] = "models/Iziraider/asuransat/gibs/gib4.mdl"
AsuranGibs[5] = "models/Iziraider/asuransat/gibs/gib5.mdl"
AsuranGibs[6] = "models/Iziraider/asuransat/gibs/gib6.mdl"
--AsuranGibs[7] = "models/Zup/Stargate/sga_test_gate.mdl"

ENT.Sounds = {
	HyperspaceWindow=Sound("stargate/asuran/hyperwindow.wav"),
}

local HEALTH=1000
local DESTROYABLE=true

function ENT:Initialize()   --############ @  Llapp
    self:SetNetworkedInt("health",HEALTH);
    if (WireAddon) then
    	self.Inputs = WireLib.CreateInputs( self.Entity, {"Active", "AsuranShield","HyperDrive","Vector [VECTOR]","X","Y","Z","Entity [ENTITY]"}); -- "Iris",
    end
	self.Entity:SetModel("models/Iziraider/asuransat/asuran_sat.mdl") ;
	--self.Entity:SetColor(Color(95, 155, 209, 255));
	self.Entity:PhysicsInit( SOLID_VPHYSICS ) ;
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS );
	--self.Entity:SetSolid( SOLID_VPHYSICS ); -- bug with world collision in chair remote
	self:AddGate();
	--self:GateIris();  --bug with gate overloader
	self.Phys = self.Entity:GetPhysicsObject();
	if (self.Phys:IsValid()) then
	    self.Phys:EnableMotion(false)
		self.Phys:EnableGravity(false);
		self.Phys:SetMass(35000);
		self.Phys:Wake();
	end
	self.Entity:SetGravity(0);
	self.Entity:StartMotionController();
	self.WireActive = nil;
	self.WireShoot = nil;
	self.WireEnt = nil;
	self.WireVec = Vector(0,0,0);
	self.WireIris = nil;
	self.WireHoverdrive = nil;
    self.Shield = nil;
	self.Strength = 100;
	self.StrengthShield = 100;
	self.ShieldColor = Vector(0,255,0)
	self.Time = CurTime()
	self.SatellitePhys = {}
	self.Angles = Angle(90,0,0);
	self.Position = self.Entity:GetPos();
	self.TouchPosition = self.Entity:GetPos();
	self.Touched = false;
	self.Time = CurTime()
	self.APC = nil;
	self.APCply = nil;
	self.Pressed = false
	self.GoUp = 0;
	self.Forw = 0
	self.Accel=0;
	self.Accel={FWD=0, RIGHT=0, UP=0};
	--self.Rider=false;
	--self.OutBeam = false;
	--self.viewmode = false
end

function ENT:SpawnShield()  --############ @ Madman07
	local e = ents.Create("shield");
	e.Size = 310;
	e.DrawBubble = true;
	e:SetPos(self.Entity:GetPos());
	e:SetAngles(self.Entity:GetAngles());
	e:SetColor(Color(230, 230, 230, 255));
	e:SetParent(self.Entity);
	e:Spawn();
	e:SetNetworkedBool("containment",false);
	e:DrawBubbleEffect();
	e:SetTrigger(true);
	self.Entity:EmitSound("tech/shield_goauld_engage.mp3",90,math.random(90,110));
	return e;
end

function ENT:SpawnFunction(p,t)   --############ @  Llapp
	if (!t.HitWorld) then return end;
	local e = ents.Create("stargate_asuran") ;
	e:SetPos(t.HitPos + Vector(0,0,1000));
	ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;
	e:SetAngles(ang);
	e:DrawShadow(false);
	self.Sat = e;
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:AddGate()  --############ @  Llapp
    local pos = self:GetPos()+self:GetForward()*(51.5)
	local l = ents.Create("stargate_atlantis");
	l:DrawShadow(false);
	l:SetParent(self.Entity);
	l:SetPos(pos);
	l:SetAngles(self.Entity:GetAngles());
	l:Spawn();
	l:Activate();
	l:SetGateName("ASURAN");
	--l:SetGateAddress("ASUR4N");
	l:SetLocale(true);
	l:SetGateGroup("P@");
	self.Gate = l;
	local physic = self.Gate:GetPhysicsObject()
	if physic and physic:IsValid() then
	    if(physic:GetMass())then
		    physic:SetMass(0.000000001);
		end
		physic:EnableMotion(true)
		physic:EnableGravity( false )
		physic:Wake()
	end
    constraint.Weld(self.Gate,self,0,0,0,true);
	return l;
end

--[[function ENT:GateIris()  --############ @  Llapp
    local ir = ents.Create("stargate_iris");
	ir:SetModel("models/zup/Stargate/sga_shield.mdl");
	local posiris = self.Gate:GetPos()+self.Gate:GetForward()*0.4;
	ir:SetParent(self.Gate);
	ir:SetPos(posiris);
	ir:Spawn();
	ir:Activate();
	self.Iris = ir;
	self.Iris:Toggle();
	timer.Simple(1,function()
	    if(self.Iris:IsValid())then self.Iris:Toggle(); end
	end);
	return ir;
end]]--

function ENT:HyperspaceOut(jumpCoords)  --############ @  Llapp
	local effect = {}
	if(IsValid(self)) then
	    self.Entity:EmitSound(self.Sounds.HyperspaceWindow,90,math.random(97,103));
	    effect[1] = EffectData()
	    effect[1]:SetOrigin(self:GetPos()+self:GetForward()*900)
	    effect[1]:SetScale(10000)
	    effect[1]:SetEntity(self.Entity)
	    util.Effect("propspawn",effect[1])
	    effect[2] = EffectData()
	    effect[2]:SetOrigin(jumpCoords)
	    effect[2]:SetScale(10000)
	    effect[2]:SetEntity(self.Entity)
        util.Effect("propspawn",effect[2])
	    self.Entity:SetPos(jumpCoords)
	end
end

--[[function ENT:Setup(start, dir)
self.InitStartPos = start;
self.Dir = dir;
self.StartPos = start;

self.EndPos = start
end]]--

--[[function ENT:Beam()  --############ @  Llapp
        local effect = EffectData()
	    effect:SetOrigin(self.Gate:GetPos()+self.Gate:GetForward()*0.4)
	    effect:SetEntity(self.Gate)
	    util.Effect("AsuranBeam",effect)

		local startPos = self.Laser:GetPos()
		local beamVector = self.forward * newLength
		self.trace = StargateExtras:ShieldTrace(startPos,
                                           beamVector,
                                           ignorableEntities,
                                           true)

		local owner = self.Entity:GetVar("Owner", self.Entity)
		local hitPos = self.trace.HitPos
		self.Damage.radius = 50;
		self.Damage.amount = 5;
		local time = CurTime()
        self.Ftime = time-self.LastThink
		util.BlastDamage(self.Gate,
                       owner,
                       hitPos,
                       self.Damage.radius,
                       self.Damage.amount * self.Ftime)
end]]--

function ENT:TriggerInput(variable, value)  --############ @ Madman07 and Llapp

    if (variable == "Vector") then self.WireVec = value;
	elseif variable == "X" then self.WireVec.X = value;
	elseif variable == "Y" then self.WireVec.Y = value;
	elseif variable == "Z" then self.WireVec.Z = value;
    elseif (variable == "Entity") then self.WireEnt = value;
	elseif (variable == "AsuranShield") then self.WireShield = value;
	--elseif (variable == "Iris") then self.WireIris = value;
	elseif (variable == "HyperDrive") then self.WireHoverdrive = value;
    elseif (variable == "Active") then self.WireActive = value;	end
end

function ENT:RemoveShield()  --############ @ Madman07
    if(self.Shield:IsValid())then
	    self.Shield:Remove();
	    self.Shield = nil;
	    self:EmitSound("tech/shield_goauld_disengage.mp3",90,math.random(90,110));
	end
end

function ENT:OnRemove()   --############ @ Madman07 and Llapp
	if (self.Entity and self.Entity:IsValid()) then self.Entity:Remove(); end
	if (self.Shield and self.Shield:IsValid()) then self.Shield:Remove(); end
	if (self.Gate and self.Gate:IsValid()) then self.Gate:Remove(); end
	if (self.e and self.e:IsValid()) then self.e:Remove(); end
end

function ENT:Hit(strength,normal,pos) end

function ENT:DoKill(ply)   --######### @ RononDex,aVoN
	local velocity = self:GetForward();
	local effectdata = EffectData();
	effectdata:SetOrigin(self:GetPos());
	effectdata:SetStart(self:GetUp());
	util.Effect("dirtyxplo", effectdata);
	self:OnRemove();
	local e = ents.Create("info_particle_system");
	e:SetPos(self:GetPos());
	e:SetAngles(self:GetAngles());
	e:SetKeyValue("effect_name","citadel_shockwave_06"); -- http://developer.valvesoftware.com/wiki/Half-Life_2:_Episode_Two_Particle_Effect_List
	e:SetKeyValue("start_active",1);
	e:Spawn();
	e:Activate();
	e:Fire("Stop","",0.9);
	e:Fire("kill","",1);
	for k,v in pairs(AsuranGibs) do
		local model = v;
		local k = ents.Create("prop_physics");
		k:SetPos(self:GetPos())
		k:SetAngles(self:GetAngles());
		k:SetModel( model );
		if(model != "models/Zup/Stargate/sga_test_gate.mdl")then
		    k:SetMaterial("Iziraider\asuransat\asuransat");
		    --k:SetColor(Color(95, 155, 209, 255));
		end
		k:PhysicsInit( SOLID_VPHYSICS );
		k:SetMoveType( MOVETYPE_VPHYSICS );
		k:SetSolid( SOLID_VPHYSICS );
		k:SetCollisionGroup( COLLISION_GROUP_WORLD );
		k:Activate();
		k:Spawn();
		k:GetPhysicsObject():SetVelocity(velocity*1000 + VectorRand()*40000);
		k:GetPhysicsObject():ApplyForceCenter(velocity*1000 +VectorRand()*40000);
		k:Fire("Kill", "", 10);
	end
end

function ENT:OnTakeDamage(dmg)
	if(DESTROYABLE)then
		local health=self:GetNetworkedInt("health");
		self:SetNetworkedInt("health",health-dmg:GetDamage());
		if(health<=1)then
			self:DoKill();
		end
	end
end

function ENT:StartTouch( ent )  --############ @ Madman07
	if (ent and ent:IsValid() and ent:IsVehicle()) then
		if (self.APC != ent) then
			local ed = EffectData()
				ed:SetEntity( ent )
			util.Effect( "propspawn", ed, true, true )
		end
		self.APC = ent;
	end
end

function ENT:PhysicsUpdate( phys, deltatime )  --############ @ Madman07 and Llapp
	local TargetPos = nil;
	local jumpCoords = nil;
	local FWD = self.Entity:GetForward();
	local UP = Vector(0,0,1);
	local RIGHT = FWD:Cross(UP):GetNormalized();
	local strafe = 0;
	local move = 0;
	local up = 0;
	local acc = 10;
	local coords = 0;

	if (self.Pressed == true) then timer.Simple( 1, function() self.Pressed = false end) end
	if self.APC && self.APC:IsValid() then
		self.APCply = self.APC:GetPassenger(0)
		if (self.APCply && self.APCply:IsValid()) then
			TargetPos = self.APCply:GetEyeTrace().HitPos;
			if (self.APCply:KeyDown(IN_FORWARD)) then
			    move = 400;
				acc = 20;
		    elseif (self.APCply:KeyDown(IN_BACK)) then
			    move = -400;
				acc = 20;
		    end
			self.Accel.FWD=math.Approach(self.Accel.FWD,move,acc);
			if(self.APCply:KeyDown(IN_SPEED)) then
	            up = -400;
				acc = 20;
	        elseif(self.APCply:KeyDown(IN_JUMP)) then
			    up = 400;
				acc = 20;
			end
			self.Accel.UP=math.Approach(self.Accel.UP,up,acc);
			if(self.APCply:KeyDown(IN_MOVERIGHT)) then
				strafe = 400;
				acc = 20;
			elseif(self.APCply:KeyDown(IN_MOVELEFT)) then
				strafe = -400;
				acc = 20;
			end
	        self.Accel.RIGHT=math.Approach(self.Accel.RIGHT,strafe,acc);
			if (self.APCply:KeyDown(IN_RELOAD) and TargetPos!=nil and IsValid(self.Entity) and self.Pressed == false) then
                if(TargetPos!=nil and self.Entity:IsValid())then
				    if ((TargetPos-self.Entity:GetPos()):Length() > 0) then
				        coords = -800;
			        else
				        coords = 800;
			        end
		            jumpCoords = Vector(TargetPos.x+coords, TargetPos.y, self.Entity:GetPos().z);
		        end
        	    timer.Simple(2,function()
				    if(IsValid(self.Entity))then
				        if ((jumpCoords-self.Entity:GetPos()):Length() > 2000) then
							self:HyperspaceOut(jumpCoords)
							self.Pressed = true;
					    end
					end
			    end);
			end
		end
	elseif (self.WireActive == 1) then
		if (self.WireEnt and self.WireEnt:IsValid()) then
			TargetPos = self.WireEnt:LocalToWorld(self.WireEnt:OBBCenter())
		elseif (self.WireVec) then
			TargetPos = self.WireVec;
		end
		if(TargetPos!=nil and IsValid(self.Entity))then
			if ((TargetPos-self.Entity:GetPos()):Length() > 0) then
				coords = -1000;
			else
				coords = 1000;
			end
			jumpCoords = Vector(TargetPos.x+coords, TargetPos.y, self.Entity:GetPos().z);
		end
		if(self.WireHoverdrive==1 and TargetPos!=nil and IsValid(self.Entity) and self.Pressed == false)then
		    timer.Simple(5,function()
			    if(IsValid(self.Entity) and (jumpCoords-self.Entity:GetPos()):Length() > 3000)then
						self:HyperspaceOut(jumpCoords)
						self.Pressed = true;
				end
			end);
		end
	end
	local AimVec = Angle(0,0,0);
    local ang = Angle(90, 00, 0);
	local pos = self.Entity:GetPos();
	if (TargetPos == nil) then
	    AimVec = self.Angles or Angle(90,0,0);
	else
	    AimVec = (TargetPos - pos):Angle() + ang;
	end
	if (self.Angles) then
		self.Angles.Pitch = AimVec.Pitch
		self.Angles.Yaw = AimVec.Yaw
	else
		self.Angles = Angle(90,0,0);
	end
	ShootAngle = AimVec
	pit = -1 * math.NormalizeAngle(ShootAngle.Pitch);
    ya  = math.NormalizeAngle(ShootAngle.Yaw);
    self.Pitch = -1*math.NormalizeAngle(self.Entity:GetAngles().Pitch+90);
	self.Yaw = math.NormalizeAngle(self.Entity:GetAngles().Yaw);
	if ((math.abs(self.Pitch - pit) < 15) and (math.abs(self.Yaw - ya) < 15)) then
	    self.InRange = 1;
    else
	    self.InRange = 0;
	end
	local Satellite = self.Entity:GetPhysicsObject();
	if (self.APCply && self.APCply:IsValid()) then
	    Satellite:Wake();
	    self.SatellitePhys = {
			secondstoarrive	 = 4;
			pos 			 = self.Entity:GetPos()+(FWD*self.Accel.FWD)+(UP*self.Accel.UP)+(RIGHT*self.Accel.RIGHT);
			maxangular		 = 8000;
			maxangulardamp 	 = 900;
			maxspeed 		 = 10000000;
			maxspeeddamp 	 = 400000;
			dampfactor 		 = 0.6;
			angle			 = self.Angles - Angle(90,0,0);
			deltatime		 = deltatime;
	    }
	    Satellite:ComputeShadowControl(self.SatellitePhys);
	else
    	Satellite:Wake();
	    self.SatellitePhys = {
			secondstoarrive	 = 3;
			maxangular		 = 100;
			maxangulardamp 	 = 1000;
			dampfactor 		 = 0.5;
			angle			 = self.Angles - Angle(90,0,0);
			deltatime		 = deltatime;
	    }
	    Satellite:ComputeShadowControl(self.SatellitePhys);
	    Satellite:AddVelocity(-1*self.Entity:GetVelocity()/8)
	end
end

function ENT:LowPriorityThink()  --############ @ Madman07 and Llapp
	self.Strength = 100;
	--[[if(self.APC:GetPassenger(0) == nil and self.Rider==true)then
	    self:ExitViewMode(self.APC:GetPassenger(0));
		self.viewmode = false
		self.Rider=false;
	end]]--

	if (self.Pressed == true) then timer.Simple( 1, function() self.Pressed = false end) end
	if (self.APC and self.APC:IsValid()) then
		self.APCply = self.APC:GetPassenger(0);
		if (self.APCply and self.APCply:IsValid()) then
		    self.APCply:CrosshairEnable();
			self.Rider=true;
			if (self.APCply:KeyDown( IN_ATTACK2 )) then
				if (!self.Shield and self.StrengthShield == 100 and self.Pressed == false ) then self.Shield = self.Entity:SpawnShield(); self.Pressed = true;
				elseif (self.Shield and self.Shield:IsValid() and self.Pressed == false) then self.Entity:RemoveShield(); self.Pressed = true; end
			end
			if (self.APCply:KeyDown( IN_ATTACK )) then
				--[[if (not self.Iris.IsActivated and self.Pressed == false ) then
				    self.Entity:SetNetworkedEntity("beamsound",false)
				    self.Iris:Toggle();
					self.Pressed = true;
				elseif (self.Iris.IsActivated  and self.Pressed == false) then
				    self.Entity:SetNetworkedEntity("beamsound",true)
    				self.Iris:Toggle();
					self.Pressed = true;
				end ]]--
			end
			--[[if (self.APCply:KeyDown( IN_ZOOM )) then
			    if(self.viewmode==false and self.Pressed == false)then
					self:ViewMode(self.APCply);
					self.viewmode = true;
					self.Pressed = true;
				elseif(self.viewmode==true and self.Pressed == false)then
				    self:ExitViewMode(self.APCply);
					self.viewmode = false
					self.Pressed = true;
				end
			end]]--
		end
	elseif (self.WireActive == 1) then
		if (self.WireShield == 1) then
			if (!self.Shield and self.StrengthShield == 100) then self.Shield = self.Entity:SpawnShield(); end
		else
			if (self.Shield and self.Shield:IsValid()) then self.Entity:RemoveShield(); end
		end
	else
	    if (self.Shield and self.Shield:IsValid()) then self.Entity:RemoveShield(); end
	end
--[[	if(self.WireIris==1)then
	    if((not self.Iris.IsActivated and self.Gate.Active) and self.InRange==0)then
		    self.Entity:SetNetworkedEntity("beamsound",false)
		    self.Iris:Toggle();
	    end
		if((self.Iris.IsActivated and self.Gate.Active) and self.InRange==1)then
		    self.Entity:SetNetworkedEntity("beamsound",true)
			self.Iris:Toggle();
		end
	end
	if(self.Gate.IsOpen and self.OutBeam == false and not self.Gate.Outbound)then
	    self.Entity:SetNetworkedEntity("beamsound",true)
	    timer.Simple(3.2,function()
	        if(IsValid(self.Entity))then
	            self:Beam();
		    end
	    end);
	    self.OutBeam=true;
	end
	if(not self.Gate.IsOpen)then
	    self.Entity:SetNetworkedEntity("beamsound",false)
	    self.OutBeam=false;
	end]]--
	--if(self.Gate.Active and not self.Iris.IsActivated)then self.Iris:Toggle(); end
end

function ENT:Think(ply)  --############ @  Llapp

	if IsValid(self.Phys) then
		self.Phys:EnableGravity(false);
	end
	if(IsValid(self.Gate)) then
		if IsValid(self.Gate:GetPhysicsObject()) then
			self.Gate:GetPhysicsObject():EnableGravity(false);
		end
	end

	self.Entity:LowPriorityThink();
	self:NextThink(CurTime()+0.1);
	return true;
end

--[[function ENT:ViewMode(ply)  --############ @  Llapp
	self.Entity:SetUseType(SIMPLE_USE);
	if (not self.Active) then
		self.Active = true;
		self.APCply = ply;
		self.APCply:SetPos(self.Entity:GetPos());
		--self.APCply:SetScriptedVehicle(self);
		self.APCply:SetNetworkedEntity( "ScriptedVehicle", self )
		self.APCply:SetViewEntity( self )
		-- Garry broke this function
		/*if(not(game.SinglePlayer())) then
			self.APCply:SetClientsideVehicle(self);
		end*/
		self.APCply:SetMoveType(MOVETYPE_OBSERVER);
		self.APCply:DrawViewModel(false);
		self.APCply:DrawWorldModel(false);
		self.APCply:CrosshairEnable();
		self.APCply:Spectate( OBS_MODE_CHASE );
		self.APCply:SetNetworkedEntity("Asuran",self);
	end
	self.Entity:NextThink( CurTime() + 0.5 );
end

function ENT:ExitViewMode(ply)  --############ @  Llapp
	self.Active = false;
	self.APCply = ply;
	self.APCply:UnSpectate();
	self.APCply:DrawViewModel(true);
	self.APCply:DrawWorldModel(true);
	self.APCply:SetMoveType(MOVETYPE_VPHYSICS);
	self.APCply:Spawn();
	self.APCply:SetPos(self.APCply:GetPos());
	--self.APCply:SetScriptedVehicle(NULL);
	self.APCply:SetNetworkedEntity( "ScriptedVehicle", NULL )
	self.APCply:SetViewEntity( NULL )
	-- Garry broke this function
	/*if(not(game.SinglePlayer())) then
		self.APCply:SetClientsideVehicle(NULL);
	end*/
	self.APCply:SetNetworkedEntity("Asuran",NULL);
	self.APCply = NULL;
end]]--

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "stargate_asuran", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_weapon_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_asuran_satellite");
end

--[[ENT.RenderGroup = RENDERGROUP_BOTH;

function ENT:Initialize()
    --self:SetShouldDrawInViewMode( true );
end

function ENT:CalcView(Player, Origin, Angles, FieldOfView)
	local view={};
	local pos = Vector(0,0,0);
	local face = Angle(0,0,0);

    pos = self.Entity:GetPos()+self.Entity:GetForward()*52+Player:GetAimVector():GetNormal();--self.Entity:GetPos()+self.Entity:GetForward()*23
    face = (self.Entity:GetPos()+Vector(0,180,0)):Angle(); --Player:GetAimVector()     + Vector( 0, 0, 0 )
	view.origin = pos;
    --view.angles = face;
	--view.fov = FieldOfView;
    return view;
end

function ENT:Draw()
	self:DrawModel();
end]]--

--[[ENT.RenderGroup 	= RENDERGROUP_BOTH

ENT.Sounds={
	Beam=Sound("stargate/asuran/asurane_beam.wav"),
}

function ENT:Initialize()
	self.BeamSound = self.BeamSound or CreateSound(self.Entity,self.Sounds.Beam);
	self.BeamSoundOn = false;
	self:StartClientsideSound()
	self.Entity:GetNetworkedEntity("beamsound",false)
end

function ENT:OnRemove()
	self.BeamSound:Stop();
end

function ENT:StartClientsideSound()
	self.BeamSound:SetSoundLevel(100);
	self.BeamSound:PlayEx(1,60);
	--self.BeamSoundOn = false;
end

function ENT:Think()
	local velo = self.Entity:GetVelocity()*10;
	local pitch = self.Entity:GetVelocity():Length();
	local doppler = 0;

	local dir = (LocalPlayer():GetPos() - self.Entity:GetPos());
	doppler = velo:Dot(dir)/(160*dir:Length());


	if(self.Entity:GetNetworkedEntity("beamsound",true)) then
		self.BeamSound:ChangePitch(math.Clamp(150 + pitch,150,150) + doppler,0);
	end
end]]--

end