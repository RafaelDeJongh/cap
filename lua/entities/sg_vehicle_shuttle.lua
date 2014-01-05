--[[
	Destiny Shuttle for GarrysMod 10
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

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Type = "vehicle"
ENT.Base = "sg_vehicle_base"

ENT.PrintName = "Destiny Shuttle"
ENT.Author	= "RononDex, Iziraider, Madman, Boba Fett"
ENT.Contact	= ""
ENT.Purpose	= ""
ENT.Instructions= ""
list.Set("CAP.Entity", ENT.PrintName, ENT);

ENT.EntHealth = 2000

if SERVER then

--########Header########--
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("ship")) then return end
AddCSLuaFile()

ENT.Model = Model("models/Iziraider/shuttle/shuttle.mdl")
ENT.Shuttle=true

function ENT:SpawnFunction(ply, tr) --######## Pretty useless unless we can spawn it @RononDex
	if (!tr.HitWorld) then return end

	local PropLimit = GetConVar("CAP_ships_max"):GetInt()
	if(ply:GetCount("CAP_ships")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Ships limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local e = ents.Create("sg_vehicle_shuttle")
	e:SetPos(tr.HitPos + Vector(0,0,90))
	e:Spawn()
	e:Activate()
	e:SetWire("Health",e:GetNetworkedInt("health"));
	ply:AddCount("CAP_ships", e)
	e.Owner = ply;
	return e
end
ENT.Sounds={
	Engage=Sound("shields/shield_engage.mp3"),
	Disengage=Sound("shields/shield_disengage.mp3"),
	Fail={Sound("buttons/button19.wav"),Sound("buttons/combine_button2.wav")},
	Railgunsound = Sound("pulse_weapon/dexgun_flyby1.mp3"),
	Explosion=Sound("jumper/JumperExplosion.mp3"),
};

function ENT:Initialize() --######## What happens when it first spawns(Set Model, Physics etc.) @RononDex

	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetNetworkedInt("health",self.EntHealth)
	self:SetUseType(SIMPLE_USE)
	self:StartMotionController()
	self:SpawnChairs()
	self:SpawnShieldGen()
	self:CreateWireInputs("Shield")
	self:CreateWireOutputs("Health","Shield Strength","Shield Enabled")
	self.IsShuttle=true
	self.Vehicle = "Shuttle"

	self.BlastCount = 0;
	self.CanFire = true;

	--######### Flight Vars
	self.Accel = {}
	self.Accel.FWD = 0
	self.Accel.RIGHT = 0
	self.Accel.UP = 0
	self.ForwardSpeed = 1250
	self.BackwardSpeed = -600
	self.UpSpeed=500
	self.MaxSpeed = 1750
	self.RightSpeed = 750
	self.Accel.SpeedForward = 20
	self.Accel.SpeedRight = 8
	self.Accel.SpeedUp = 8
	self.num = 0
	self.num2 = 0
	self.num3 =0
	self.Roll=0
	self.Hover=true
	self.GoesRight=true
	self.GoesUp=true
	self.CanRoll=true

	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(10000)
	end
end

function ENT:OnRemove()	self.BaseClass.OnRemove(self) end

function ENT:OnTakeDamage(dmg) --########## Shuttle's aren't invincible are they? @RononDex

	local health=self:GetNetworkedInt("health")-(dmg:GetDamage()/10)
	if(not self.Shields:Enabled() or self.Shields.Depleted) then
		self:SetNetworkedInt("health",health)
		self:SetWire("Health",health);
	end
	if((health)<=250) then
		self.TurretDisabled=true
	end

	if((health)<=150) then
		self.ShieldOffline=true
	end

	if((health)<=0) then
		self:DoKill() -- Go boom
	end
end

function ENT:DoKill(ply)   --######### @ RononDex

	self.Done=true
	local velocity = self:GetForward()

	local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetStart(self:GetUp())
	util.Effect( "dirtyxplo", effectdata )

	self:EmitSound(self.Sounds.Explosion, 100, 100)

	local e = ents.Create("info_particle_system")
	e:SetPos(self:GetPos())
	e:SetAngles(self:GetAngles())
	e:SetKeyValue("effect_name","citadel_shockwave_06") -- http://developer.valvesoftware.com/wiki/Half-Life_2:_Episode_Two_Particle_Effect_List
	e:SetKeyValue("start_active",1)
	e:Spawn()
	e:Activate()
	e:Fire("Stop","",0.9)
	e:Fire("kill","",3)

	if(IsValid(self)) then
		self:ExitShut()
		if(IsValid(self.Pilot)) then
			self.Pilot:Kill()
		end
	end
	self:Remove()
end


function ENT:ExitShut() --################# Get out the jumper@RononDex
	if (not IsValid(self.Pilot)) then return end
	self.Pilot:UnSpectate()
	self.Pilot:DrawViewModel(true)
	self.Pilot:DrawWorldModel(true)
	self.Pilot:Spawn()
	self.Pilot:SetPos(self:GetPos()+self:GetForward()*15+self:GetUp()*-40)
	self.Pilot:SetMoveType(MOVETYPE_WALK)
	--self.Pilot:SetScriptedVehicle(NULL)
	self.Pilot:SetNetworkedEntity( "ScriptedVehicle", NULL )
	self.Pilot:SetViewEntity( NULL )
end


function ENT:Think()

	self.BaseClass.Think(self)

	if (IsValid(self.Pilot)) then
		self:SetNWInt("shield",math.Round(self.Shields.Strength))
  	end

	if(self.Inflight) then
		if((self.Pilot)and(self.Pilot:IsValid())) then
			if(self.Pilot:KeyDown("Shuttle","SHIELD")) then
				if(self.ShieldOffline) then
					self.Pilot:ChatPrint("Shuttle is to badly Damaged!/nShield's are offline")
				end
				if(self.Shields.Depleted) then
					self.Pilot:ChatPrint("Shield's Depleted wait for them to recharge")
				else
					if(not(self.ShieldOffline)) then
						self:ToggleShield()
					end
				end
			end
		end
	end

	self.ExitPos=self:GetPos()+self:GetForward()*100

	if(self.Shields.Depleted) then
		self:SetWire("Shield Enabled",-1);
		self:SetWire("Shield Strength",self.Shields.Strength);
	else
		self:SetWire("Shield Enabled",self.Shields:Enabled());
		self:SetWire("Shield Strength",self.Shields.Strength);
	end

	if(self.Inflight) then
		if((self.TurretDisabled)and(self.Pilot:KeyDown(self.Vehicle,"FIRE"))) then
			self.Pilot:ChatPrint("Taken to much damage! Turrets are offline")
		end
		if((self.Pilot:KeyDown(self.Vehicle,"FIRE"))and(not(self.TurretDisabled))) then
			self:FireBlast(self:GetRight()*-525)
			self:FireBlast(self:GetRight()*525)
		end
	end
end

function ENT:FireBlast(diff) --####### Fire! @Mad

	if self.BlastCount < 10 and self.CanFire then
		local e = ents.Create("energy_pulse");
		e:PrepareBullet(self:GetForward(), 10, 16000, 6, {self.Entity});
		e:SetPos(self:GetPos()+diff);
		e:SetOwner(self);
		e.Owner = self;
		e:Spawn();
		e:Activate();
		e:SetColor(Color(255,255,math.random(75,125),255));
		self:EmitSound(self.Sounds.Railgunsound,100,100)
		self.BlastCount = self.BlastCount + 1;
	else
		self.BlastCount = math.Approach(self.BlastCount,0,0.5)
		self.CanFire = false;
	end
	if self.BlastCount == 0 then
		self.CanFire = true;
	end
end

function ENT:SpawnChairs()

	--[[local seat = {}

	if(IsValid(self)) then

		seat[1] = ents.Create("prop_vehicle_prisoner_pod")
		seat[1]:SetModel("models/props_phx/carseat2.mdl")
		seat[1]:SetPos(self:GetPos()+self:GetForward()*30+self:GetRight()*40)
		seat[1]:SetAngles(self:GetAngles())
		seat[1]:Spawn()
		seat[1]:Activate()
		seat[1]:SetParent(self)

		seat[2] = ents.Create("prop_vehicle_prisoner_pod")
		seat[2]:SetModel("models/props_phx/carseat2.mdl")
		seat[2]:SetPos(self:GetPos()+self:GetForward()*30+self:GetRight()*-40)
		seat[2]:SetAngles(self:GetAngles()+Angle(0,180,0))
		seat[2]:Spawn()
		seat[2]:Activate()
		seat[2]:SetParent(self)

		seat[3] = ents.Create("prop_vehicle_prisoner_pod")
		seat[3]:SetModel("models/props_phx/carseat2.mdl")
		seat[3]:SetPos(self:GetPos()+self:GetForward()*65+self:GetRight()*40)
		seat[3]:SetAngles(self:GetAngles())
		seat[3]:Spawn()
		seat[3]:Activate()
		seat[3]:SetParent(self)

		seat[4] = ents.Create("prop_vehicle_prisoner_pod")
		seat[4]:SetModel("models/props_phx/carseat2.mdl")
		seat[4]:SetPos(self:GetPos()+self:GetForward()*65+self:GetRight()*-40)
		seat[4]:SetAngles(self:GetAngles()+Angle(0,180,0))
		seat[4]:Spawn()
		seat[4]:Activate()
		seat[4]:SetParent(self)

		seat[5] = ents.Create("prop_vehicle_prisoner_pod")
		seat[5]:SetModel("models/props_phx/carseat2.mdl")
		seat[5]:SetPos(self:GetPos()+self:GetRight()*40+self:GetForward()*-5)
		seat[5]:SetAngles(self:GetAngles())
		seat[5]:Spawn()
		seat[5]:Activate()
		seat[5]:SetParent(self)

		seat[6] = ents.Create("prop_vehicle_prisoner_pod")
		seat[6]:SetModel("models/props_phx/carseat2.mdl")
		seat[6]:SetPos(self:GetPos()+self:GetRight()*-40+self:GetForward()*-5)
		seat[6]:SetAngles(self:GetAngles()+Angle(0,180,0))
		seat[6]:Spawn()
		seat[6]:Activate()
		seat[6]:SetParent(self)

		seat[7] = ents.Create("prop_vehicle_prisoner_pod")
		seat[7]:SetModel("models/props_phx/carseat2.mdl")
		seat[7]:SetPos(self:GetPos()+self:GetForward()*-35+self:GetRight()*40)
		seat[7]:SetAngles(self:GetAngles())
		seat[7]:Spawn()
		seat[7]:Activate()
		seat[7]:SetParent(self)

		seat[8] = ents.Create("prop_vehicle_prisoner_pod")
		seat[8]:SetModel("models/props_phx/carseat2.mdl")
		seat[8]:SetPos(self:GetPos()+self:GetForward()*-35+self:GetRight()*-40)
		seat[8]:SetAngles(self:GetAngles()+Angle(0,180,0))
		seat[8]:Spawn()
		seat[8]:Activate()
		seat[8]:SetParent(self)

		seat[9] = ents.Create("prop_vehicle_prisoner_pod")
		seat[9]:SetModel("models/props_phx/carseat2.mdl")
		seat[9]:SetPos(self:GetPos()+self:GetRight()*40+self:GetForward()*-75)
		seat[9]:SetAngles(self:GetAngles())
		seat[9]:Spawn()
		seat[9]:Activate()
		seat[9]:SetParent(self)

		seat[10] = ents.Create("prop_vehicle_prisoner_pod")
		seat[10]:SetModel("models/props_phx/carseat2.mdl")
		seat[10]:SetPos(self:GetPos()+self:GetRight()*-40+self:GetForward()*-75)
		seat[10]:SetAngles(self:GetAngles()+Angle(0,180,0))
		seat[10]:Spawn()
		seat[10]:Activate()
		seat[10]:SetParent(self)
	end]]
end

function ENT:SpawnShieldGen()

	if(IsValid(self)) then
		local e = ents.Create("ship_shield_generator")
		e:SetPos(self:GetPos())
		e:SetAngles(self:GetAngles()-Angle(0,90,0))
		e:SetParent(self)
		e:Spawn()
		e:Activate()
		self.Shields=e
		e.StrengthMultiplier={0.1,0.5,-5}
		e:SetShieldColor(1,0.6,0)
	end
end

function ENT:ToggleShield()

	if(IsValid(self)) then
		if(not(self.Shielded)) then
			self.Shields:Status(true)
			self.Shielded=true
		else
			self.Shields:Status(false)
			self.Shielded=false
		end
	end
end

function ENT:ShowOutput()
end

function ENT:TriggerInput(k,v) --######### Wire Inputs @ RononDex

	if(k=="Shield") then
		if((v or 0) >= 1) then
			if(not(self.Shielded)) then
				self.Shields:Status(true)
			else
				self.Shields:Status(false)
			end
		end
	end
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "sg_vehicle_shuttle", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_ships_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_dest_shuttle");
end
ENT.RenderGroup = RENDERGROUP_BOTH

if (StarGate==nil or StarGate.KeyBoard==nil) then return end

--########## Keybinder stuff
local KBD = StarGate.KeyBoard:New("Shuttle")
--Navigation
KBD:SetDefaultKey("FWD",StarGate.KeyBoard.BINDS["+forward"] or "W") -- Forward
KBD:SetDefaultKey("SPD",StarGate.KeyBoard.BINDS["+speed"] or "SHIFT") --  Boost
KBD:SetDefaultKey("UP",StarGate.KeyBoard.BINDS["+jump"] or "SPACE")
KBD:SetDefaultKey("DOWN",StarGate.KeyBoard.BINDS["+duck"] or "CTRL")
KBD:SetDefaultKey("LEFT",StarGate.KeyBoard.BINDS["+moveleft"] or "A")
KBD:SetDefaultKey("RIGHT",StarGate.KeyBoard.BINDS["+moveright"] or "D")
--Attack
KBD:SetDefaultKey("FIRE",StarGate.KeyBoard.BINDS["+attack"] or "MOUSE1")
--View
KBD:SetDefaultKey("Z+","UPARROW")
KBD:SetDefaultKey("Z-","DOWNARROW")
KBD:SetDefaultKey("A+","LEFTARROW")
KBD:SetDefaultKey("A-","RIGHTARROW")
--Special Actions
KBD:SetDefaultKey("SHIELD","ALT")

KBD:SetDefaultKey("BOOM","BACKSPACE")
KBD:SetDefaultKey("EXIT",StarGate.KeyBoard.BINDS["+use"] or "E")

ENT.Sounds={
	Engine=Sound("f302/f302_Engine.wav"),
}

function ENT:Initialize( )
	self.BaseClass.Initialize(self)
	self.Dist=-1150
	self.UDist=400
	self.KBD = self.KBD or KBD:CreateInstance(self)
	self.Vehicle = "Shuttle"
end

function ENT:Effects()

	local pos = {}
	pos[1] = self:GetPos() + self:GetForward() * -390 + self:GetUp()*40 + self:GetRight()*270
	pos[2] = self:GetPos() + self:GetForward() * -390 + self:GetUp()*67.5 + self:GetRight()*190
	pos[3] = self:GetPos() + self:GetForward() * -390 + self:GetUp()*40 + self:GetRight()*-270
	pos[4] = self:GetPos() + self:GetForward() * -390 + self:GetUp()*67.5 + self:GetRight()*-190

	local p = LocalPlayer()
	local Shuttle = p:GetNetworkedEntity("ScriptedVehicle", NULL)
	local roll = math.Rand(-90,90)
	local normal = (self.Entity:GetForward() * -1):GetNormalized()

	if((Shuttle)and(Shuttle:IsValid()and(Shuttle==self))) then
		for i=1,4 do
			if((p:KeyDown("Shuttle","FWD"))) then
				if(StarGate.VisualsShips("cl_shuttle_heatwave")) then
					local fx = self.FXEmitter:Add("sprites/heatwave",pos[i])
					fx:SetVelocity(normal*2)
					fx:SetDieTime(0.2)
					fx:SetStartAlpha(255)
					fx:SetEndAlpha(255)
					fx:SetStartSize(90)
					fx:SetEndSize(50)
					fx:SetColor(255,255,255)
					fx:SetRoll(roll)
				end

				if(StarGate.VisualsShips("cl_shuttle_sprites")) then
					local fx2 = self.FXEmitter:Add("sprites/orangecore1",pos[i])
					fx2:SetVelocity(normal*2)
					fx2:SetDieTime(0.02)
					fx2:SetStartAlpha(255)
					fx2:SetEndAlpha(255)
					fx2:SetStartSize(60)
					fx2:SetEndSize(35)
					fx2:SetColor(math.Rand(200,255),math.Rand(200,255),165)
					fx2:SetRoll(roll)
				end
			end
		end
	end
	self.FXEmitter:Finish()
end

function ENT:BoostFX()

	local pos = {}
	pos[1] = self:GetPos() + self:GetRight() * 365 + self:GetForward() * -390 + self:GetUp() * 20
	pos[2] = self:GetPos() + self:GetRight() * -365 + self:GetForward() * -390 + self:GetUp() * 20
	pos[3] = self:GetPos() + self:GetRight() * 430 + self:GetForward() * -390
	pos[4] = self:GetPos() + self:GetRight() * -430 + self:GetForward() * -390

	local normal = (self.Entity:GetForward() * -1):GetNormalized()
	local roll = math.Rand(-90,90)
	local p = LocalPlayer()
	local Shuttle = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	if((p:KeyDown("Shuttle","SPD"))and(p:KeyDown("Shuttle","FWD"))and((Shuttle)and(Shuttle:IsValid())and(Shuttle==self))) then

		local vel = Shuttle:GetVelocity()
		for i=1,4 do

			if(StarGate.VisualsShips("cl_shuttle_sprites")) then
				local aftbrn = self.FXEmitter:Add("sprites/orangecore1",pos[i])
				aftbrn:SetVelocity(normal*2)
				aftbrn:SetDieTime(0.05)
				aftbrn:SetStartAlpha(255)
				aftbrn:SetEndAlpha(100)
				aftbrn:SetStartSize(40)
				aftbrn:SetEndSize(13.5)
				aftbrn:SetColor(math.Rand(220,255),math.Rand(220,255),155)
				aftbrn:SetRoll(roll)
			end

			if(StarGate.VisualsShips("cl_shuttle_heatwave")) then
				local heatwv = self.FXEmitter:Add("sprites/heatwave",pos[i])
				heatwv:SetVelocity(normal*2)
				heatwv:SetDieTime(0.2)
				heatwv:SetStartAlpha(255)
				heatwv:SetEndAlpha(255)
				heatwv:SetStartSize(50)
				heatwv:SetEndSize(18)
				heatwv:SetColor(255,255,255)
				heatwv:SetRoll(roll)
			end
		end
	end
end


function ENT:Draw()

	local p = LocalPlayer()

	self.BaseClass.Draw(self)

	if(p:KeyDown("Shuttle","FWD")) then
		self:Effects()
	end

	if(p:KeyDown("Shuttle","SPD")) then
		self:BoostFX()
	end
end

--######## Mainly Keyboard stuff @RononDex
function ENT:Think()

	self.BaseClass.Think(self)

	local p = LocalPlayer()
	local Shuttle = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	if((Shuttle)and((Shuttle)==self)and(Shuttle:IsValid())) then
		self.KBD:SetActive(true)
	else
		self.KBD:SetActive(false)
	end

	if((Shuttle)and((Shuttle)==self)and(Shuttle:IsValid())) then
		if(p:KeyDown("Shuttle","Z+")) then
			self.Dist = self.Dist-5
		elseif(p:KeyDown("Shuttle","Z-")) then
			self.Dist = self.Dist+5
		end

		if(p:KeyDown("Shuttle","A+")) then
			self.UDist=self.UDist+5
		elseif(p:KeyDown("Shuttle","A-")) then
			self.UDist=self.UDist-5
		end
	end
end

local function SetData(um) --############# Recieve data from init@RononDex
	LocalPlayer().Shield = um:ReadShort();
end
usermessage.Hook("ShuttleData", SetData)

--########### All HUD Related stuff is below @ RononDex
local hudpos = {
	healthw = (ScrW()/10*1.5),
	healthh = (ScrH()/10*2),
	shieldw = (ScrW()/10*1.5),
	shieldh = (ScrH()/10*3),
}
function PrintHUD()

	local p = LocalPlayer()
	local self = p:GetNetworkedEntity("ScriptedVehicle", NULL)
	local shuttle = p:GetNetworkedEntity("Shuttle")
	if (not IsValid(shuttle)) then return end
	local health = math.Round(shuttle:GetNWInt("health")/shuttle.EntHealth*100)

	if(IsValid(self)) then
		if((IsValid(shuttle))and(shuttle==self)) then
			draw.WordBox(8,hudpos.healthw,hudpos.healthh, "Hull: "..health.."%","ScoreboardText",Color(50,50,75,100), Color(255,255,255,255))
			draw.WordBox( 8, hudpos.shieldw, hudpos.shieldh, "Shield: "..self:GetNWInt("shield",100).."%", "ScoreboardText", Color(50,50,75,100), Color(255,255,255,255))
		end
	end
end
hook.Add("HUDPaint","ShuttleHUD",PrintHUD)

end