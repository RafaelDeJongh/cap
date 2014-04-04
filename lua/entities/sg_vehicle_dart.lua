--[[
	Wraith Dart for GarrysMod 10
	Copyright (C) 2009 RononDex

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

ENT.Type = "vehicle"
ENT.Base = "sg_vehicle_base"

ENT.PrintName = "Wraith Dart"
ENT.Author	= "RononDex"
ENT.Contact	= ""
ENT.Purpose	= ""
ENT.Instructions= ""

list.Set("CAP.Entity", ENT.PrintName, ENT);

if SERVER then

--########Header########--
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("ship")) then return end
AddCSLuaFile()

ENT.Model = Model("models/Madman07/wraith_dart/wraith_dart.mdl")

ENT.Sounds = {
	Railgunsound = Sound("weapons/wraith_dart_shoot.mp3"),
}

function ENT:SpawnFunction(p, tr) --######## Pretty useless unless we can spawn it @RononDex
	if (!tr.HitWorld) then return end
	local PropLimit = GetConVar("CAP_ships_max"):GetInt()
	if(p:GetCount("CAP_ships")+1 > PropLimit) then
		p:SendLua("GAMEMODE:AddNotify(\"Ships limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local e = ents.Create("sg_vehicle_dart")
	e:SetPos(tr.HitPos+Vector(0,0,90))
	e:SetAngles(Angle(0,p:GetAimVector():Angle().Yaw,0))
	e:Spawn()
	e:Activate()
	e:SetWire("Health",e:GetNetworkedInt("health"));
	p:AddCount("CAP_ships", e)
	return e
end

function ENT:Initialize() --######## What happens when it first spawns(Set Model, Physics etc.) @RononDex

	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.EntHealth = 500
	self:SetNetworkedInt("health",self.EntHealth)
	self.Roll=0
	self.On=0
	self:SetUseType(SIMPLE_USE)
	self.Vehicle="Dart"
	self.ExitPos=self:GetPos()+Vector(0,0,80)
	self:StartMotionController()
	self:SpawnHarvester()
	self.Delay=10

	--######### Flight Vars
	self.Accel = {}
	self.Accel.FWD = 0
	self.Accel.RIGHT = 0
	self.Accel.UP = 0
	self.ForwardSpeed = 2000
	self.BackwardSpeed = 0
	self.UpSpeed=750
	self.MaxSpeed = 2500
	self.RightSpeed = 750
	self.Accel.SpeedForward = 20
	self.Accel.SpeedRight = 10
	self.Accel.SpeedUp = 10
	self.RollSpeed = 5
	self.Roll=0
	self.Hover=true
	self.GoesRight=true
	self.GoesUp=true
	self.CanRoll=true
	self.ShootingCann = 1
	self:CreateWireOutputs("Health");

	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(10000) --@Madman07 well i set model mass for 1500
	end

	timer.Create("SGDartHealth"..self:EntIndex(),1,0,function()
		if (not IsValid(self)) then return end
		local health = self:GetNetworkedInt("health");
		health = health + 2.5;
		if (health > 500) then health = 500; end
		self:SetNetworkedInt("health", health);
		self:SetWire("Health",health);
	end);
end

function ENT:OnTakeDamage(dmg) --########## Darts aren't invincible are they? @RononDex

	local health=self:GetNetworkedInt("health")
	self:SetNetworkedInt("health",health-dmg:GetDamage()) -- Sets heath(Takes away damage from health)
	self:SetWire("Health",health-dmg:GetDamage());

	if((health-dmg:GetDamage())<=0) then
		self:Bang() -- Go boom
	end
end

function ENT:OnRemove()
	timer.Remove("SGDartHealth"..self:EntIndex());
	self.BaseClass.OnRemove(self)
end --For some reason, it doesn't automatically use this function from the base so we have to tell it to

function ENT:Think() --####### Now let me think... @RononDex

	self.BaseClass.Think(self) --Retrieve stuff from the base
	self.ExitPos=self:GetPos()+self:GetRight()*120 --Where we get out

	if(self.StartDelay) then
		self.Delay = math.Approach(self.Delay,3,2)
	end

	if(self.Delay>=3) then
		self.StartDelay=false
	end

	if(IsValid(self.Pilot)) then
		if(not(self.Inflight)) then return end
		if(self.Delay>=3) then
			if(self.Pilot:KeyDown(self.Vehicle,"FIRE")) then
				self.Delay=0
				self.StartDelay=true
				self:FireTurrets()
			end
		end

		if(self.Pilot:KeyDown(self.Vehicle,"SUCK")) then
			self.Harvester:TurnOn(true)
		end

		if(self.Pilot:KeyDown(self.Vehicle,"DHD")) then
			self:OpenDHD(self.Pilot)
		end

		if(self.Pilot:KeyDown(self.Vehicle,"SPIT")) then
			self.Harvester:Spit()
		end
	end

	self.Entity:NextThink(CurTime()+0.25);
	return true
end

function ENT:SpawnHarvester()

	if(not(IsValid(self))) then return end

	local data = self:GetAttachment(self:LookupAttachment("Suck")) --@Madman07
	if(not (data and data.Pos)) then return end

	local e = ents.Create("dart_harvester")
	e:SetModel("models/miriam/minidrone/minidrone.mdl")
	e:SetPos(data.Pos)
	e:SetAngles(self:GetAngles()+Angle(0,0,180))
	e:SetOwner(self)
	e:SetParent(self)
	e:Spawn()
	e:Activate()
	e:GetPhysicsObject():EnableCollisions(false)
	e:SetColor(Color(255,255,255,1))
	e:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.Harvester=e
	self.Harvester.MaxEnts = 10
	self.Harvester.Disallowed={};
	table.insert(self.Harvester.Disallowed, "sg_vehicle_*");
end

function ENT:FireTurrets() --####### Fire!@ Madman07
	local data;

	if (self.ShootingCann == 1) then
		data = self:GetAttachment(self:LookupAttachment("FireL"))
	elseif (self.ShootingCann == 2) then
		data = self:GetAttachment(self:LookupAttachment("FireR"))
	end
	if(not (data and data.Pos)) then return end

	-- local fx = EffectData();
		-- fx:SetStart(data.Pos);
		-- fx:SetAngles(Angle(0,95,math.random(175,195)));
		-- fx:SetRadius(80);
	-- util.Effect("avon_energy_muzzle",fx,true)

	local e = ents.Create("energy_pulse");
	e:PrepareBullet(self:GetForward(), 10, 16000, 10, {self.Entity});
	e:SetPos(data.Pos-self:GetForward()*100);
	e:SetOwner(self);
	e.Owner = self;
	e:Spawn();
	e:Activate();
	e:SetRenderMode(RENDERMODE_TRANSALPHA)
	e:SetColor(Color(0,95,math.random(175,195),255));
	self:EmitSound(self.Sounds.Railgunsound,100,100)

	self.ShootingCann = self.ShootingCann + 1;
	if (self.ShootingCann == 3) then self.ShootingCann = 1; end
end

function ENT:StargateCheck()  --######### @ aVoN
	local gate = self:FindGate(5000)
	self.NearValidStargate = false
	if IsValid(gate) then
		if gate.IsStargate then
			if gate.Outbound then
				self.NearValidStargate = true
			end
		end
	end
end

function ENT:OpenDHD(p)   --######### @ aVoN
	if(not IsValid(p)) then return end;
	local e = self:FindGate(5000);
	if(not IsValid(e)) then return end;
	if(hook.Call("StarGate.Player.CanDialGate",GAMEMODE,p,e) == false) then return end;
	net.Start("StarGate.VGUI.Menu");
	net.WriteEntity(e);
	net.WriteInt(1,8);
	net.Send(p);
end

function ENT:FindGate(dist)  --######### @ aVoN
	local gate;
	local pos = self:GetPos();
	for _,v in pairs(ents.FindByClass("stargate_*")) do
		local sg_dist = (pos - v:GetPos()):Length();
		if(dist >= sg_dist) then
			dist = sg_dist;
			gate = v;
		end
	end
	return gate;
end


function ENT:Power(supply)
	/*if(StarGate.RDThree()) then
		RD.Link(self.Harvester,supply)
	else
		Dev_Link(self.Harvester,supply)
	end*/
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "sg_vehicle_dart", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_ships_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_dart");
end

if (StarGate==nil or StarGate.KeyBoard==nil) then return end

--########## Keybinder stuff
local KBD = StarGate.KeyBoard:New("Dart")
--Navigation
KBD:SetDefaultKey("FWD",StarGate.KeyBoard.BINDS["+forward"] or "W") -- Forward
KBD:SetDefaultKey("SPD",StarGate.KeyBoard.BINDS["+speed"] or "SHIFT") --  Boost
KBD:SetDefaultKey("UP",StarGate.KeyBoard.BINDS["+jump"] or "SPACE")
KBD:SetDefaultKey("DOWN",StarGate.KeyBoard.BINDS["+duck"] or "CTRL")
KBD:SetDefaultKey("LEFT",StarGate.KeyBoard.BINDS["+moveleft"] or "A")
KBD:SetDefaultKey("RIGHT",StarGate.KeyBoard.BINDS["+moveright"] or "D")
--Roll
KBD:SetDefaultKey("RL","MWHEELDOWN") -- Roll left
KBD:SetDefaultKey("RR","MWHEELUP") -- Roll right
KBD:SetDefaultKey("RROLL","MOUSE3") -- Reset Roll
--Attack
KBD:SetDefaultKey("FIRE",StarGate.KeyBoard.BINDS["+attack"] or "MOUSE1") -- Fire
--Special Actions
KBD:SetDefaultKey("SUCK","C") --  Cull
KBD:SetDefaultKey("SPIT","ALT") -- UnCull
KBD:SetDefaultKey("DHD","R") -- DHD
--View
KBD:SetDefaultKey("Z+","UPARROW")
KBD:SetDefaultKey("Z-","DOWNARROW")
KBD:SetDefaultKey("A+","LEFTARROW")
KBD:SetDefaultKey("A-","RIGHTARROW")

KBD:SetDefaultKey("BOOM","BACKSPACE")
KBD:SetDefaultKey("EXIT",StarGate.KeyBoard.BINDS["+use"] or "E")

ENT.Sounds={
	Engine=Sound("vehicles/DartEngine.wav"),
}

function ENT:Initialize( )
	self.BaseClass.Initialize(self)
	LocalPlayer().Missiles=0
	self.Dist=-850
	self.UDist=250
	self.KBD = self.KBD or KBD:CreateInstance(self)
	self.Vehicle="Dart"
end

function ENT:Effects()

	local pos = self:GetPos()+self:GetForward()*-100+self:GetUp()*25
	local data = self:GetAttachment(self:LookupAttachment("Engine")) --@Madman07
	if(not (data and data.Pos)) then return end

	local p = LocalPlayer()
	local dart = p:GetNetworkedEntity("ScriptedVehicle", NULL)
	local roll = math.Rand(-90,90)
	local normal = (self.Entity:GetForward() * -1):GetNormalized()

	if((dart)and(dart:IsValid()and(dart==self))) then

		if(StarGate.VisualsShips("cl_dart_heatwave")) then
			local heatwv = self.FXEmitter:Add("sprites/heatwave",data.Pos)
			heatwv:SetVelocity(normal*2)
			heatwv:SetDieTime(0.2)
			heatwv:SetStartAlpha(255)
			heatwv:SetEndAlpha(255)
			heatwv:SetStartSize(50)
			heatwv:SetEndSize(18)
			heatwv:SetColor(0,95,155)
			heatwv:SetRoll(roll)
		end
	end
	--self.FXEmitter:Finish()
end

function ENT:Draw()

	local p = LocalPlayer()
	local dart = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	self.BaseClass.Draw(self)

	if((dart)and(dart:IsValid())) then
		if(p:KeyDown("Dart","FWD")) then
			self:Effects(true)
		else
			self:Effects(false)
		end
	end
end

--######## Mainly Keyboard stuff @RononDex
function ENT:Think()

	self.BaseClass.Think(self)

	local p = LocalPlayer()
	local dart = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	if((dart)and((dart)==self)and(dart:IsValid())) then
		self.KBD:SetActive(true)
	else
		self.KBD:SetActive(false)
	end

	if((dart)and((dart)==self)and(dart:IsValid())) then

		if(p:KeyDown("Dart","Z+")) then
			self.Dist = self.Dist-5
		elseif(p:KeyDown("Dart","Z-")) then
			self.Dist = self.Dist+5
		end

		if(p:KeyDown("Dart","A+")) then
			self.UDist=self.UDist+5
		elseif(p:KeyDown("Dart","A-")) then
			self.UDist=self.UDist-5
		end
	end

end

end