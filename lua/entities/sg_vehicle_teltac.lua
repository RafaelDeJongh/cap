--[[
	Tel'Tak for GarrysMod 10
	Copyright (C) 2011 Madman07, RononDex

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]--

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Type = "vehicle"
ENT.Base = "sg_vehicle_base"

ENT.PrintName = "TelTac"
ENT.Author	= "RononDex, Madman07, James, Boba Fett"
ENT.Contact	= ""
ENT.Purpose	= ""
ENT.Instructions= ""
list.Set("CAP.Entity", ENT.PrintName, ENT);
ENT.AutomaticFrameAdvance = true

ENT.IsSGVehicleCustomView = true

if SERVER then

--########Header########--
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("ship")) then return end
AddCSLuaFile()

ENT.Model = Model("models/James/teltac/teltac.mdl")

ENT.Sounds={
	Cloak=Sound("jumper/puddlejumpercloak2.wav"),
	Uncloak=Sound("jumper/JumperUnCloak.mp3"),
	Open=Sound("teltak/teltak_outterdoor_open.wav"),
	Close=Sound("teltak/teltak_outterdoor_close.wav"),
	OpenC=Sound("teltak/teltak_centerdoor_open.wav"),
	CloseC=Sound("teltak/teltak_centerdoor_close.wav"),
}

ENT.Gibs = true;
ENT.GibTable = {
	Chair = Model("models/James/teltac/gib_chair.mdl");
	Engine = Model("models/James/teltac/gib_engine.mdl");
	Panel1 = Model("models/James/teltac/gib_panel1.mdl");
	Panel2 = Model("models/James/teltac/gib_panel2.mdl");
	Wing1 = Model("models/James/teltac/gib_wing1.mdl");
	Wing2 = Model("models/James/teltac/gib_wing2.mdl");
}

local COCKPIT_POS = Vector(365.02545166016,1.2539007663727,74.670593261719)
local DOOR_POS = Vector(158.8932, 5.9064, 47.4537)
local DOORE_POS = Vector(-162.5597, 5.3606, 47.9206)


function ENT:SpawnFunction(pl, tr) --######## Pretty useless unless we can spawn it @RononDex
	if (!tr.HitWorld) then return end;

	local PropLimit = GetConVar("CAP_ships_max"):GetInt()
	if(pl:GetCount("CAP_ships")+1 > PropLimit) then
		pl:SendLua("GAMEMODE:AddNotify(\"Ships limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local e = ents.Create("sg_vehicle_teltac");
	e:SetPos(tr.HitPos + Vector(0,0,180));
	e:Spawn();
	e:Activate();
	e:SetVar("Owner",pl)
	e:SpawnRings();
	e:SpawnRingPanel();
	e:SpawnDoor()
	e:SpawnDoor2()
	e:ToggleDoors("out")
	e:SetWire("Health",e:GetNetworkedInt("health"));
	pl:Give("weapon_ringcaller");
	pl:AddCount("CAP_ships", e)
	return e;
end

function ENT:Initialize() --######## What happens when it first spawns(Set Model, Physics etc.) @RononDex

	self.BaseClass.Initialize(self)

	self.Vehicle = "Teltac";
	self.EntHealth = 6000;
	self.BlastMaxVel = 10000000;
	self.Blasts = {};
	self.BlastCount = 0;
	self.MaxBlasts = (4);
	self.BlastsFired = 0;
	self:SetNetworkedInt("health",self.EntHealth);
	self.ExitPos = self:GetPos()+Vector(0,0,120);
	self.ShouldRotorwash = true;

	self:CreateWireInputs("Hyperspace X","Hyperspace Y","Hyperspace Z","Cloak")

	self.CanUse = false;

	--######### Flight Vars
	self.Accel = {};
	self.Accel.FWD = 0;
	self.Accel.RIGHT = 0;
	self.Accel.UP = 0;
	self.ForwardSpeed = 1000;
	self.BackwardSpeed = -1000;
	self.UpSpeed = 750;
	self.MaxSpeed = 1750;
	self.RightSpeed = 750;
	self.Accel.SpeedForward = 20;
	self.Accel.SpeedRight = 10;
	self.Accel.SpeedUp = 10;
	self.RollSpeed = 0;
	self.num = 0;
	self.num2 = 0;
	self.num3 = 0
	self.Roll = 0;
	self.Hover = true;
	self.GoesRight = true;
	self.GoesUp = true;
	self.CanDoAnim = true;

	self.CanCloak = true;
	self.CanDoCloak = true;
	self.ImmuneOwner = true;

	self.HoverPos = self:GetPos();
	self.HoverAlways = true;	 -- let me hover always :)
	self:CreateWireOutputs("Health");

	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(20000)
	end

	self.Open = false;

end

function ENT:Bang()

	self.BaseClass.Bang(self)

	local velocity = self:GetVelocity()
	for _,v in pairs(self.GibTable) do
		local k = ents.Create("prop_physics");
		k:SetPos(self:GetPos())
		k:SetAngles(self:GetAngles());
		k:SetModel(v);
		k:PhysicsInit(SOLID_VPHYSICS);
		k:SetMoveType(MOVETYPE_VPHYSICS);
		k:SetSolid(SOLID_VPHYSICS);
		k:Activate();
		k:Spawn();
		k:Ignite(10,10)
		k:GetPhysicsObject():SetVelocity(velocity*1000 + VectorRand()*40000);
		k:GetPhysicsObject():ApplyForceCenter(velocity*1000 +VectorRand()*40000);
		k:Fire("Kill", "", 10);
	end
end

function ENT:OnTakeDamage(dmg) --########## Gliders aren't invincible are they? @RononDex

	local health=self:GetNetworkedInt("health")
	self:SetNetworkedInt("health",health-dmg:GetDamage()) -- Sets heath(Takes away damage from health)
	self:SetWire("Health",health-dmg:GetDamage());

	if(health-dmg:GetDamage()<=1500) then
		self.CanCloak = false;
	end

	if((health-dmg:GetDamage())<=0) then
		self:Bang(); -- Go boom
	end
end

function ENT:OnRemove()
	if IsValid(self.RingPanel) then self.RingPanel:Remove(); end
	if IsValid(self.InRing) then self.InRing:Remove(); end
	if IsValid(self.OutRing) then self.OutRing:Remove(); end
	if(IsValid(self.Door)) then self.Door:Remove(); end
	if(IsValid(self.Door2)) then self.Door2:Remove(); end
	if(IsValid(self.Door3)) then self.Door3:Remove(); end
	self.BaseClass.OnRemove(self)
end

function ENT:Think()

	self.BaseClass.Think(self)


	if self.HasRD then
		self:LSSupport()
	end

	if(IsValid(self.InRing and self.OutRing)) then
		if(self.Inflight and not self.LandingMode) then
			self.InRing.Busy = true;
			self.OutRing.Busy = true;
		elseif((self.LandingMode and self.Inflight) or not self.Inflight) then
			self.InRing.Busy = false;
			self.OutRing.Busy = false;
		end
	end

	if(self.Inflight and self.LandingMode) then
		self.Accel.FWD = 0;
		self.Accel.RIGHT = 0;
	end

	if(self.Inflight) then
		if(IsValid(self.Pilot)) then
			if(self.Pilot:KeyDown(self.Vehicle,"CLOAK")) then
				self:ToggleCloak()
			elseif(self.Pilot:KeyDown(self.Vehicle,"DOOR")) then
				self:ToggleDoors("out")
			elseif(self.Pilot:KeyDown(self.Vehicle,"HYPERSPACE")) then
				if(self.Accel.FWD == self.MaxSpeed) then
					if(not self.Pressed) then
						self.Pressed = true;
						timer.Simple(1, function() self:HyperSpace(); self.Pressed = false; end);
					end
				end
			end
		end
	end
end

function ENT:Enter(p)
	self.BaseClass.Enter(self,p);
	self:ToggleDoors("out",true);
end

function ENT:Exit(kill)
	self.ExitPos = self:GetPos()+Vector(0,0,120);
	self.CanUse = false;
	self.BaseClass.Exit(self,kill);
end

function ENT:ToggleDoors(d,set)

	if(d=="out" and IsValid(self.Door)) then
		if(self.Open) then
			self:SetPlaybackRate(0.4)
			self:ResetSequence("unhide");
			self.Open = false;
			self.Door:SetSolid(SOLID_VPHYSICS);
			self.Door:EmitSound(self.Sounds.Open,80,98);
		elseif(not set) then
			self:SetPlaybackRate(0.4)
			self:ResetSequence("hide");
			self.Open = true;
			self.Door:SetSolid(SOLID_NONE);
			self.Door:EmitSound(self.Sounds.Close,80,100);
		end
	elseif(d=="inc" and IsValid(self.Door2)) then
		if(self.Door2.Open) then
			timer.Simple(0.2,function()
				if (IsValid(self)) then
					self.Door2:SetPlaybackRate(0.5)
					self.Door2:ResetSequence("open");
					self.Door2.Open = false;
					self.Door2:SetSolid(SOLID_VPHYSICS);
				end
			end);
			self.Door2:EmitSound(self.Sounds.CloseC,80,98);
		else
			self.Door2:SetPlaybackRate(0.5)
			self.Door2:ResetSequence("close");
			self.Door2.Open = true;
			self.Door2:SetSolid(SOLID_NONE)
			self.Door2:EmitSound(self.Sounds.OpenC,80,100);
		end
	elseif(d=="ine" and IsValid(self.Door3)) then
		if(self.Door3.Open) then
			timer.Simple(0.2,function()
				if (IsValid(self)) then
					self.Door3:SetPlaybackRate(0.5)
					self.Door3:ResetSequence("open");
					self.Door3.Open = false;
					self.Door3:SetSolid(SOLID_VPHYSICS);
				end
			end);
			self.Door3:EmitSound(self.Sounds.CloseC,80,98);
		else
			self.Door3:SetPlaybackRate(0.5)
			self.Door3:ResetSequence("close");
			self.Door3.Open = true;
			self.Door3:SetSolid(SOLID_NONE)
			self.Door3:EmitSound(self.Sounds.OpenC,80,100);
		end
	end
end


function ENT:SpawnDoor()


	local e = ents.Create("prop_physics");
	e:SetModel("models/props_c17/door01_left.mdl");
	e:SetPos(self:GetPos()+self:GetRight()*160+self:GetForward()*270+self:GetUp()*103);
	e:SetAngles(self:GetAngles()+Angle(0,90,0));
	e:Spawn();
	e:Activate();
	e:SetColor(Color(255,255,255,0))
	e:SetRenderMode(RENDERMODE_TRANSALPHA)
	constraint.Weld(self,e,0,0,0,true)
	constraint.NoCollide(self,e,0,0)
	self.Door = e;

end

function ENT:Use(p)

	if (self.LastUse and self.LastUse>CurTime()) then return end
	self.LastUse = CurTime()+1;

	self.BaseClass.Use(self,p)

	local pos = self:WorldToLocal(p:GetPos()) - COCKPIT_POS;
	local d_pos = self:WorldToLocal(p:GetPos()) - DOOR_POS;
	local de_pos = self:WorldToLocal(p:GetPos()) - DOORE_POS;

	if(not(self.Inflight)) then
		if(	(pos.x > -100 and pos.x < 100) and --Allow player if he is 30 units away from COCKPIT_POS in left/right direction
			(pos.y > -100 and pos.y < 100) and --Allow, if 30 units away from COCKPIT_POS in froward/backward dir
			(pos.z > -30 and pos.z < 70) -- Allow, if in range of -2 or + 30 in z-direction
		) then
			self.CanUse = true;
			self:Enter(p);
			if(self.Open) then
				self:ToggleDoors("out");
			end
		elseif(	(d_pos.x > -50 and d_pos.x < 50) and
			(d_pos.y > -125 and d_pos.y < 125) and
			(d_pos.z > -30 and d_pos.z < 70)
		) then
			self.CanUse = false;
			self:ToggleDoors("inc")
		elseif(	(de_pos.x > -50 and de_pos.x < 50) and
			(de_pos.y > -185 and de_pos.y < 155) and
			(de_pos.z > -30 and de_pos.z < 70)
		) then
			self.CanUse = false;
			self:ToggleDoors("ine")
		else
			self.CanUse = false;
			self:ToggleDoors("out");
		end
	end
end

function ENT:SpawnRings()
	local e = ents.Create("ring_base_ancient");
	e:SetModel(e.BaseModel);
	e:SetPos(self:LocalToWorld(Vector(0,0,7)));
	e:Spawn();
	e:Activate();
	e:SetAngles(self:GetAngles()+Angle(180,0,0));
	constraint.Weld(self,e,0,0,0,true)
	e:SetParent(self);
	e.DirOverride = true
	e.Dir = -1;
	self.OutRing = e;

	local e = ents.Create("ring_base_ancient");
	e:SetModel(e.BaseModel);
	e:SetPos(self:LocalToWorld(Vector(0,-5,45)));
	e:Spawn();
	e:Activate();
	e:SetAngles(self:GetAngles());
	constraint.Weld(self,e,0,0,0,true)
	e:SetParent(self);
	e.DirOverride = true
	e.Dir = 1;
	self.InRing = e;
end

function ENT:SpawnRingPanel()
	local e = ents.Create("ring_panel_goauld");
	e:SetPos(self:GetPos()+self:GetForward()*135+self:GetRight()*-50+self:GetUp()*100);
	e:SetAngles(self:GetAngles()+Angle(0,180,0));
	e:Spawn();
	e:Activate();
	constraint.Weld(self,e,0,0,0,true)
	e:SetParent(self);
	self.RingPanel = e;
end

--############# Cloak @ aVoN
function ENT:Status(b,nosound)
	if(b) then
		if(not(self:Enabled())) then
			local e = ents.Create("cloaking")
			e.Size = 300
			e:SetPos(self:GetPos()+Vector(0,0,70))
			e:SetAngles(self:GetAngles())
			e:SetParent(self.Entity)
			e:Spawn()
			self:EmitSound(self.Sounds.Cloak,100,math.random(80,100))
			if(e and e:IsValid() and not e.Disable) then -- When our new cloak mentioned, that there is already a cloak
				self.Cloak = e
				self.Cloaked = e
				return
			end
		end
	else
		if(self:Enabled()) then
			self.Cloak:Remove()
			self.Cloak = nil
			self:EmitSound(self.Sounds.Uncloak,80,math.random(90,110))
		end
	end
	return
end

function ENT:Enabled()
	return (self.Cloak and self.Cloak:IsValid())
end

function ENT:ToggleCloak() --############# Toggle Cloak @ RononDex

	if(self.CanCloak)then
		if(self.CanDoCloak)then
			if(self.Cloaked)then
				self:Status(false);
				if(self.Inflight)then
					self:Rotorwash(true);
				end
				self.Cloaked = false;
				self.CanDoCloak = false;
				timer.Simple( 2, function() self.CanDoCloak=true end);
			else
				self:Status(true);
				self.Cloaked = true;
				if(self.Inflight) then
					self:Rotorwash(false);
				end
				self.CanDoCloak = false;
				timer.Simple( 2, function() self.CanDoCloak=true end);
			end
		end
	end
end

function ENT:HyperSpace()

	local Ofs = Vector(self.HyperspacePos.X,self.HyperspacePos.Y,self.HyperspacePos.Z) - self:GetPos()

	local fx = EffectData()
		fx:SetOrigin(self:GetPos())
		fx:SetEntity(self)
	util.Effect("propspawn",fx)

	local ed = EffectData()
		ed:SetEntity( self )
		ed:SetOrigin(self:GetPos() + (Ofs:GetNormalized() * math.Clamp( self:BoundingRadius() * 5, 180, 4092 )))
	util.Effect( "jump_in", ed, true, true );

	local ed = EffectData()
		ed:SetEntity( self )
		ed:SetOrigin( self:GetPos() + (Ofs:GetNormalized() * math.Clamp( self:BoundingRadius() * 5, 180, 4092 ) ) )
	util.Effect( "jump_out", ed, true, true );
	self:EmitSound("ambient/levels/citadel/weapon_disintegrate2.wav", 500)
	self:EmitSound("npc/turret_floor/die.wav", 450, 70)
	if(not(self.DestSet)) then
		self:SetPos(self:GetPos()+self:GetForward()*7500)
	else
		self:SetPos(Vector(self.HyperspacePos.X,self.HyperspacePos.Y,self.HyperspacePos.Z))
	end
end

ENT.HyperspacePos = {}
function ENT:TriggerInput(k,v)

	if(k=="Hyperspace X") then
		self.HyperspacePos.X = v
		self.DestSet = true;
	elseif(k=="Hyperspace Y") then
		self.HyperspacePos.Y = v
		self.DestSet = true;
	elseif(k=="Hyperspace Z") then
		self.HyperspacePos.Z = v
		self.DestSet = true;
	elseif(k=="Cloak") then
		self:ToggleCloak()
	end
end

function ENT:SpawnDoor2()

	local e = ents.Create("prop_physics");
	e:SetModel("models/James/teltac/inner_door.mdl");
	e:SetPos(self:GetPos()+self:GetForward()*300);
	e:SetAngles(self:GetAngles());
	e:Spawn();
	e:Activate();
	constraint.Weld(self,e,0,0,0,true)
	self.Door2 = e;

	local d = ents.Create("prop_physics");
	d:SetModel("models/James/teltac/inner_door.mdl");
	d:SetPos(self:GetPos()+self:GetForward()*-40);
	d:SetAngles(self:GetAngles());
	d:Spawn();
	d:Activate();
	constraint.Weld(self,d,0,0,0,true)
	self.Door3 = d;
end

--####### Give us air @RononDex
function ENT:LSSupport()

	local ent_pos = self:GetPos();

	if(IsValid(self)) then
		for _,p in pairs(player.GetAll()) do -- Find all players
			local pos = (p:GetPos()-ent_pos):Length(); -- Where they are in relation to the jumper
			if(pos<800 and p.suit) then -- If they're close enough
				if(not(StarGate.RDThree())) then
					p.suit.air = 100; -- They get air
					p.suit.energy = 100; -- and energy
					p.suit.coolant = 100; -- and coolant
				else
					p.suit.air = 200; -- We need double the amount of LS3(No idea why)
					p.suit.coolant = 200;
					p.suit.energy = 200;
				end
			end
		end
	end
end

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.RingPanel) then dupeInfo.RingPanel = self.RingPanel:EntIndex(); end
	if IsValid(self.InRing) then dupeInfo.InRing = self.InRing:EntIndex(); end
	if IsValid(self.OutRing) then dupeInfo.OutRing = self.OutRing:EntIndex(); end
	if IsValid(self.Door) then dupeInfo.Door = self.Door:EntIndex(); end
	if IsValid(self.Door2) then dupeInfo.Door2 = self.Door2:EntIndex(); end
	if IsValid(self.Door3) then dupeInfo.Door3 = self.Door3:EntIndex(); end

	duplicator.StoreEntityModifier(self, "TelTakDupeInfo", dupeInfo)
	StarGate.WireRD.PreEntityCopy(self)
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)

	local dupeInfo = Ent.EntityMods.TelTakDupeInfo

	if dupeInfo.RingPanel then self.RingPanel = CreatedEntities[dupeInfo.RingPanel]; end
	if dupeInfo.InRing then self.InRing = CreatedEntities[dupeInfo.InRing]; end
	if dupeInfo.OutRing then self.OutRing = CreatedEntities[dupeInfo.OutRing]; end
	if dupeInfo.Door then self.Door = CreatedEntities[dupeInfo.Door]; end
	if dupeInfo.Door2 then self.Door2 = CreatedEntities[dupeInfo.Door2]; end
	if dupeInfo.Door3 then self.Door3 = CreatedEntities[dupeInfo.Door3]; end

	self:ToggleDoors("out")

	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end

	if (IsValid(ply)) then
		local PropLimit = GetConVar("CAP_ships_max"):GetInt()
		if(ply:GetCount("CAP_ships")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(\"Ships limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			self.Entity:Remove();
			return
		end
		ply:AddCount("CAP_ships", Ent);
	end

	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "sg_vehicle_teltac", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_ships_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_teltak");
end
ENT.ViewOverride = true;
ENT.Sounds = {
	Engine=Sound("vehicles/AlkeshEngine.wav"),
}

if (StarGate==nil or StarGate.KeyBoard==nil) then return end

--########## Keybinder stuff
local KBD = StarGate.KeyBoard:New("Teltac")
--Navigation
KBD:SetDefaultKey("FWD",StarGate.KeyBoard.BINDS["+forward"] or "W"); -- Forward
KBD:SetDefaultKey("LEFT",StarGate.KeyBoard.BINDS["+moveleft"] or "A"); -- Forward
KBD:SetDefaultKey("RIGHT",StarGate.KeyBoard.BINDS["+moveright"] or "D"); -- Forward
KBD:SetDefaultKey("BACK",StarGate.KeyBoard.BINDS["+back"] or "S"); -- Forward
KBD:SetDefaultKey("UP",StarGate.KeyBoard.BINDS["+jump"] or "SPACE"); -- Forward
KBD:SetDefaultKey("DOWN",StarGate.KeyBoard.BINDS["+duck"] or "CTRL"); -- Forward
KBD:SetDefaultKey("SPD",StarGate.KeyBoard.BINDS["+speed"] or "SHIFT");
KBD:SetDefaultKey("LAND","ENTER");
--Roll
KBD:SetDefaultKey("RL","MWHEELDOWN"); -- Roll left
KBD:SetDefaultKey("RR","MWHEELUP"); -- Roll right
KBD:SetDefaultKey("RROLL","MOUSE3"); -- Reset Roll
--Attack
KBD:SetDefaultKey("FIRE",StarGate.KeyBoard.BINDS["+attack"] or "MOUSE1"); -- Fire blasts
--Special Actions
KBD:SetDefaultKey("RROLL","MOUSE3"); -- Reset roll
KBD:SetDefaultKey("BOOM","BACKSPACE");
KBD:SetDefaultKey("CLOAK","ALT");
KBD:SetDefaultKey("DOOR","2");
KBD:SetDefaultKey("HYPERSPACE","R");

--View
KBD:SetDefaultKey("Z+","UPARROW");
KBD:SetDefaultKey("Z-","DOWNARROW");
KBD:SetDefaultKey("A+","LEFTARROW");
KBD:SetDefaultKey("A-","RIGHTARROW");
KBD:SetDefaultKey("FPV","1");

KBD:SetDefaultKey("EXIT",StarGate.KeyBoard.BINDS["+use"] or "E");


function ENT:Initialize()
	self.Dist=-1160
	self.UDist=450
	self.KBD = self.KBD or KBD:CreateInstance(self)
	self.BaseClass.Initialize(self)
	self.Vehicle = "Teltac";
	self.NextPress = CurTime();
	self.FPV = 0;
end


function SGTeltacCalcView(Player,Origin, Angles, FieldOfView)
	local view = {};

	local p = LocalPlayer();
	local self = p:GetNetworkedEntity("ScriptedVehicle", NULL);

	if(IsValid(self) and self:GetClass()=="sg_vehicle_teltac") then
		if(self.FPV==0) then
			local pos = self:GetPos()+self:GetUp()*self.UDist+LocalPlayer():GetAimVector():GetNormal()*self.Dist;
			local face = ( ( self:GetPos() + Vector( 0, 0, 100 ) ) - pos ):Angle();
			view.origin = pos;
			view.angles = face;
		elseif(self.FPV==1) then
			local pos = self.Entity:GetPos()+self.Entity:GetForward()*500+self.Entity:GetUp()*130+self:GetRight()*30;
			local angle = self.Entity:GetAngles();
			view.origin = pos;
			view.angles = angle;
		elseif(self.FPV==2) then
			local pos = self:LocalToWorld(Vector(0,0,10));
			local angle = self.Entity:GetAngles()+Angle(90,0,0);
			view.origin = pos;
			view.angles = angle;
		end
		return view;
	end
end
hook.Add("CalcView", "SGTeltacCalcView", SGTeltacCalcView)

--######## Mainly Keyboard stuff @RononDex
function ENT:Think()

	self.BaseClass.Think(self)

	local p = LocalPlayer()
	local vehicle = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	if((vehicle)and((vehicle)==self)and(vehicle:IsValid())) then
		self.KBD:SetActive(true)
		self:StartClientsideSound("Normal")
	else
		self.KBD:SetActive(false)
		self:StopClientsideSound("Normal")
	end

	if((vehicle)and((vehicle)==self)and(vehicle:IsValid())) then
		if(p:KeyDown(self.Vehicle,"Z+")) then
			self.Dist = self.Dist-5
		elseif(p:KeyDown(self.Vehicle,"Z-")) then
			self.Dist = self.Dist+5
		end

		if(p:KeyDown(self.Vehicle,"A+")) then
			self.UDist=self.UDist+5
		elseif(p:KeyDown(self.Vehicle,"A-")) then
			self.UDist=self.UDist-5
		end

		if(p:KeyDown(self.Vehicle,"FPV") and self.NextPress < CurTime()) then
			if(self.FPV == 2) then self.FPV = 0
		else
			self.FPV = self.FPV + 1
		end
		self.NextPress = CurTime() + 1;
		end
	end
end

end
