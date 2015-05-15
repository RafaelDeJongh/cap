--[[
	Gate Glider for GarrysMod 10
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

ENT.Base = "sg_vehicle_base"
ENT.Type = "vehicle"

ENT.PrintName = "Gate Glider"
ENT.Author = "RononDex, Iziraider, Boba Fett"
list.Set("CAP.Entity", ENT.PrintName, ENT);

--ENT.IsSGVehicleCustomView = true

if SERVER then

--########Header########--
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("ship")) then return end
AddCSLuaFile()

ENT.Model = Model("models/Iziraider/gateglider/gateglider.mdl")

ENT.Sounds = {
	Staff=Sound("pulse_weapon/staff_weapon.mp3")
}

function ENT:SpawnFunction(ply, tr) --######## Pretty useless unless we can spawn it @RononDex
	if (!tr.HitWorld) then return end

	local PropLimit = GetConVar("CAP_ships_max"):GetInt()
	if(ply:GetCount("CAP_ships")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"entity_limit_ships\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local e = ents.Create("sg_vehicle_gate_glider")
	e:SetPos(tr.HitPos + Vector(0,0,80))
	e:Spawn()
	e:Activate()
	e:SetWire("Health",e:GetNetworkedInt("health"));
	ply:AddCount("CAP_ships", e)
	return e
end

function ENT:Initialize() --######## What happens when it first spawns(Set Model, Physics etc.) @RononDex

	self.Vehicle = "GateGlider"
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.EntHealth = 300
	self:SetNetworkedInt("health",self.EntHealth)
	self:SetUseType(SIMPLE_USE)
	self:StartMotionController()

	--####### Attack vars
	self.LastBlast=0
	self.Delay=10

	--######### Flight Vars
	self.Accel = {}
	self.Accel.FWD = 0
	self.Accel.RIGHT = 0
	self.Accel.UP = 0
	self.ForwardSpeed = 1500
	self.BackwardSpeed = -750
	self.UpSpeed=600
	self.MaxSpeed = 2000
	self.RightSpeed = 750
	self.Accel.SpeedForward = 10
	self.Accel.SpeedRight = 7
	self.Accel.SpeedUp = 7
	self.RollSpeed = 5
	self.num = 0
	self.num2 = 0
	self.num3 =0
	self.Roll=0
	self.Hover=true
	self.GoesRight=true
	self.GoesUp=true
	self.CanRoll=true
	self:CreateWireOutputs("Health","Driver [ENTITY]");
	self:SetWire("Driver",NULL);

	local phys = self:GetPhysicsObject()

	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(10000)
	end
end

function ENT:Enter(p)
	self.BaseClass.Enter(self,p);
	if IsValid(self.Pilot) and self.Pilot:IsPlayer() then
		self:SetWire("Driver",self.Pilot);
	end
end

function ENT:Exit(kill)
	self.BaseClass.Exit(self,kill);
	self:SetWire("Driver",NULL);
end

function ENT:Think()

	self.BaseClass.Think(self);
	self.ExitPos = self:GetPos()+self:GetForward()*75;

	if(self.StartDelay) then
		self.Delay = math.Approach(self.Delay,10,3);
	end

	if(self.Delay>=10) then
		self.StartDelay = false;
	end

	if(IsValid(self.Pilot)) then
		if(self.Pilot:KeyDown(self.Vehicle,"DHD")) then
			self:OpenDHD(self.Pilot);
		end

		if(self.Pilot:KeyDown(self.Vehicle,"FIRE")) then
			if(self.Delay>=10) then
				self:FireBlast(self:GetRight()*80);
				self:FireBlast(self:GetRight()*-80);
				self.Delay = 0;
			end
			self.StartDelay = true;
		end
	else
		self.StartDelay = false;
	end
end

function ENT:OnRemove()	self.BaseClass.OnRemove(self) end

function ENT:OnTakeDamage(dmg) --########## Gliders aren't invincible are they? @RononDex

	local health=self:GetNetworkedInt("health")
	self:SetNetworkedInt("health",health-dmg:GetDamage()) -- Sets heath(Takes away damage from health)
	self:SetWire("Health",health-dmg:GetDamage());

	if((health-dmg:GetDamage())<=0) then
		self:Bang() -- Go boom
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
		if (not v.IsStargate or v.IsSupergate) then continue end
		local sg_dist = (pos - v:GetPos()):Length();
		if(dist >= sg_dist) then
			dist = sg_dist;
			gate = v;
		end
	end
	return gate;
end

function ENT:FireBlast(diff)
	if(self.Delay>=10) then
		-- local fx = EffectData();
			-- fx:SetStart(self:GetPos()+diff);
			-- fx:SetAngles(Angle(255,200,120));
			-- fx:SetRadius(80);
		-- util.Effect("avon_energy_muzzle",fx,true);
		local e = ents.Create("energy_pulse");
		e:PrepareBullet(self:GetForward(), 10, 16000, 6, {self.Entity});
		e:SetPos(self:GetPos()+diff);
		e:SetOwner(self);
		e.Owner = self;
		e:Spawn();
		e:Activate();
		self:EmitSound(self.Sounds.Staff,90,math.random(90,110))

	end
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "sg_vehicle_gate_glider", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_ships_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_gate_glider");
end
ENT.RenderGroup = RENDERGROUP_BOTH

if (StarGate==nil or StarGate.KeyBoard==nil or StarGate.KeyBoard.New==nil) then return end

--########## Keybinder stuff
local KBD = StarGate.KeyBoard:New("GateGlider")
--Navigation
KBD:SetDefaultKey("FWD",StarGate.KeyBoard.BINDS["+forward"] or "W") -- Forward
KBD:SetDefaultKey("LEFT",StarGate.KeyBoard.BINDS["+moveleft"] or "A")
KBD:SetDefaultKey("RIGHT",StarGate.KeyBoard.BINDS["+moveright"] or "D")
KBD:SetDefaultKey("BACK",StarGate.KeyBoard.BINDS["+back"] or "S")
KBD:SetDefaultKey("UP",StarGate.KeyBoard.BINDS["+jump"] or "SPACE")
KBD:SetDefaultKey("DOWN",StarGate.KeyBoard.BINDS["+duck"] or "CTRL")
KBD:SetDefaultKey("SPD",StarGate.KeyBoard.BINDS["+speed"] or "SHIFT")
--Roll
KBD:SetDefaultKey("RL","MWHEELDOWN") -- Roll left
KBD:SetDefaultKey("RR","MWHEELUP") -- Roll right
KBD:SetDefaultKey("RROLL","MOUSE3") -- Reset Roll
--Attack
KBD:SetDefaultKey("FIRE",StarGate.KeyBoard.BINDS["+attack"] or "MOUSE1")
KBD:SetDefaultKey("TRACK",StarGate.KeyBoard.BINDS["+attack2"] or "MOUSE2")
--Special Actions
KBD:SetDefaultKey("DHD","R")
KBD:SetDefaultKey("BOOM","BACKSPACE")
--View
KBD:SetDefaultKey("VIEW","1")
KBD:SetDefaultKey("Z+","UPARROW")
KBD:SetDefaultKey("Z-","DOWNARROW")
KBD:SetDefaultKey("A+","LEFTARROW")
KBD:SetDefaultKey("A-","RIGHTARROW")

KBD:SetDefaultKey("EXIT",StarGate.KeyBoard.BINDS["+use"] or "E")

ENT.Sounds={
	Engine=Sound("glider/deathglideridleoutside.wav"),
}

function ENT:Initialize( )
	self.BaseClass.Initialize(self)
	self.Dist=-750
	self.UDist=120
	self.KBD = self.KBD or KBD:CreateInstance(self)
	self.FirstPerson=false
	self.Vehicle = "GateGlider"
end

--[[

function SGGGCalcView(Player, Origin, Angles, FieldOfView)
	local view = {}
	--self.BaseClass.CalcView(self,Player, Origin, Angles, FieldOfView)
	local p = LocalPlayer()
	local self = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	if(IsValid(self) and self:GetClass()=="sg_vehicle_gate_glider") then
		if(self.FirstPerson) then
			local pos = self:GetPos()+self:GetUp()*20+self:GetForward()*70;
			local angle = self:GetAngles( );
				view.origin = pos		;
				view.angles = angle;
				view.fov = FieldOfView + 20;
			return view;
		else
			local pos = self:GetPos()+self:GetUp()*self.Udist+Player:GetAimVector():GetNormal()*-self.Dist;
			local face = ( ( self.Entity:GetPos() + Vector( 0, 0, 100 ) ) - pos ):Angle() + Angle(0,180,0);
				view.origin = pos;
				view.angles = face;
			return view;
		end
	end
end
hook.Add("CalcView", "SGGGCalcView", SGGGCalcView)
]]--

--######## Mainly Keyboard stuff @RononDex
function ENT:Think()

	self.BaseClass.Think(self)

	local p = LocalPlayer()
	local GateGlider = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	if((GateGlider)and((GateGlider)==self)and(GateGlider:IsValid())) then
		self.KBD:SetActive(true)
	else
		self.KBD:SetActive(false)
	end

	if((GateGlider)and((GateGlider)==self)and(GateGlider:IsValid())) then
		if(p:KeyDown("GateGlider","Z+")) then
			self.Dist = self.Dist-5
		elseif(p:KeyDown("GateGlider","Z-")) then
			self.Dist = self.Dist+5
		end

		if(p:KeyDown("GateGlider","VIEW")) then
			if(self.FirstPerson) then
				self.FirstPerson=false
			else
				self.FirstPerson=true
			end
		end

		if(p:KeyDown("GateGlider","A+")) then
			self.UDist=self.UDist+5
		elseif(p:KeyDown("GateGlider","A-")) then
			self.UDist=self.UDist-5
		end
	end
end

end