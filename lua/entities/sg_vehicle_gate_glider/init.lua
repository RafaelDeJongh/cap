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

--########Header########--
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("ship")) then return end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
ENT.Model = Model("models/Iziraider/gateglider/gateglider.mdl")

ENT.Sounds = {
	Staff=Sound("pulse_weapon/staff_weapon.mp3")
}

function ENT:SpawnFunction(ply, tr) --######## Pretty useless unless we can spawn it @RononDex
	if (!tr.HitWorld) then return end

	local PropLimit = GetConVar("CAP_ships_max"):GetInt()
	if(ply:GetCount("CAP_ships")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Ships limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
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
	self:SetNetworkedInt("health",300)
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
	self:CreateWireOutputs("Health");

	local phys = self:GetPhysicsObject()

	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(10000)
	end
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
	umsg.Start("StarGate.OpenDialMenuDHD",p);
	umsg.Entity(e);
	umsg.End();
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