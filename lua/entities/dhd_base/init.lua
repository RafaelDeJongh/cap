/*
	DHD SENT for GarrysMod10
	Copyright (C) 2007  aVoN

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
*/

--[[
	DHD Base
	Copyright (C) 2011 Madman07
]]--

--################# HEADER #################
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end

--################# Include
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");
-- Defines
ENT.CDSIgnore = true; -- Make it undestroyable by Combad Damage System
function ENT:gcbt_breakactions() end; ENT.hasdamagecase = true; -- GCombat invulnarability!

--################# SENT CODE #################
ENT.Model = "models/MarkJaw/dhd_new/dhd_base.mdl"
ENT.ModelBroken = "models/MarkJaw/dhd_new/dhd_open.mdl"
ENT.PlorkSound = "stargate/dhd_sg1.mp3"; -- The old sound
ENT.LockSound = "stargate/stargate/dhd/dhd_usual_dial.wav";
ENT.SkinNumber = 0;
ENT.Healthh = 500;

ENT.ChevronModel = { -- Oh Mark, why u didnt named buttons in same order, like for concept DHD?

	"models/MarkJaw/dhd_new/buttons/b33.mdl",
	"models/MarkJaw/dhd_new/buttons/b34.mdl",
	"models/MarkJaw/dhd_new/buttons/b35.mdl",
	"models/MarkJaw/dhd_new/buttons/b36.mdl",
	"models/MarkJaw/dhd_new/buttons/b37.mdl",
	"models/MarkJaw/dhd_new/buttons/b38.mdl",

	"models/MarkJaw/dhd_new/buttons/b20.mdl",
	"models/MarkJaw/dhd_new/buttons/b21.mdl",
	"models/MarkJaw/dhd_new/buttons/b22.mdl",
	"models/MarkJaw/dhd_new/buttons/b23.mdl",
	"models/MarkJaw/dhd_new/buttons/b24.mdl",
	"models/MarkJaw/dhd_new/buttons/b25.mdl",
	"models/MarkJaw/dhd_new/buttons/b26.mdl",
	"models/MarkJaw/dhd_new/buttons/b27.mdl",
	"models/MarkJaw/dhd_new/buttons/b28.mdl",
	"models/MarkJaw/dhd_new/buttons/b29.mdl",
	"models/MarkJaw/dhd_new/buttons/b30.mdl",
	"models/MarkJaw/dhd_new/buttons/b31.mdl",
	"models/MarkJaw/dhd_new/buttons/b32.mdl",

	"models/MarkJaw/dhd_new/buttons/b14.mdl",
	"models/MarkJaw/dhd_new/buttons/b15.mdl",
	"models/MarkJaw/dhd_new/buttons/b16.mdl",
	"models/MarkJaw/dhd_new/buttons/b17.mdl",
	"models/MarkJaw/dhd_new/buttons/b18.mdl",
	"models/MarkJaw/dhd_new/buttons/b19.mdl",

	"models/MarkJaw/dhd_new/buttons/b1.mdl",
	"models/MarkJaw/dhd_new/buttons/b2.mdl",
	"models/MarkJaw/dhd_new/buttons/b3.mdl",
	"models/MarkJaw/dhd_new/buttons/b4.mdl",
	"models/MarkJaw/dhd_new/buttons/b5.mdl",
	"models/MarkJaw/dhd_new/buttons/b6.mdl",
	"models/MarkJaw/dhd_new/buttons/b7.mdl",
	"models/MarkJaw/dhd_new/buttons/b8.mdl",
	"models/MarkJaw/dhd_new/buttons/b9.mdl",
	"models/MarkJaw/dhd_new/buttons/b10.mdl",
	"models/MarkJaw/dhd_new/buttons/b11.mdl",
	"models/MarkJaw/dhd_new/buttons/b12.mdl",
	"models/MarkJaw/dhd_new/buttons/b13.mdl",

	"models/MarkJaw/dhd_new/buttons/dialorb.mdl",
}

ENT.ChevronNumber = {
	["!"] = 1,
	[0] = 1,
	["0"] = 1,
	[1] = 2,
	["1"] = 2,
	[2] = 3,
	["2"] = 3,
	[3] = 4,
	["3"] = 4,
	[4] = 5,
	["4"] = 5,
	[5] = 6,
	["5"] = 6,
	[6] = 7,
	["6"] = 7,
	[7] = 8,
	["7"] = 8,
	[8] = 9,
	["8"] = 9,
	[9] = 10,
	["9"] = 10,
	A = 11,
	B = 12,
	C = 13,
	D = 14,
	E = 15,
	F = 16,
	G = 17,
	H = 18,
	I = 19,

	J = 20,
	K = 21,
	L = 22,
	M = 23,
	N = 24,
	O = 25,
	["#"] = 26,
	P = 27,
	Q = 28,
	R = 29,
	S = 30,
	T = 31,
	U = 32,
	V = 33,
	W = 34,
	X = 35,
	Y = 36,
	Z = 37,
	["@"] = 38,

	["DIAL"] = 39,
}

--################# Initialize @aVoN
function ENT:Initialize()
	self.DialledAddress = {}; -- The address, the DHD shall dial
	self.busy = false;
	util.PrecacheModel(self.Model);
	util.PrecacheSound(self.PlorkSound);
	if (self.ChevSounds) then
		for i=1,table.getn(self.ChevSounds) do
			util.PrecacheSound(self.ChevSounds[i]);
		end
	end
	self.Entity:SetModel(self.Model)
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);
	self.WireNoSound = false;
	if (self.IsDHDSg1) then
		self:CreateWireInputs("Press Button","Disable Menu","Disable Glyphs","Disable Ring Rotation","Wire Disable DHD Sound");
	elseif (self.IsDHDAtl) then
		self:CreateWireInputs("Press Button","Disable Menu","Disable Glyphs","Slow Mode","Wire Disable DHD Sound");
	else
		self:CreateWireInputs("Press Button","Disable Menu","Disable Glyphs","Wire Disable DHD Sound");
	end
	local dhd = {"dhd_atlantis","dhd_universe","dhd_infinity"}
	for i=1,3 do
	    if(self.Entity:GetClass()==dhd[i])then
	        self.Entity:Fire("skin",i);
	    end
	end
	self.Range = StarGate.CFG:Get("dhd","range",1000);
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:EnableMotion(false);
	end
	self.Destroyed = false;
	self:SetNetworkedBool("SG_GROUP_SYSTEM",GetConVar("stargate_group_system"):GetBool());
	self.Entity:SpawnChevron()
	-- Now, check for near active gates and light up this DHD with the recently called address on this gate
	local e = self:FindGate();
	if(IsValid(e) and (e.IsOpen or e.Dialling or e.WireManualDial) and (e.DialledAddress or e.WireDialledAddress)) then
		for i=1,11 do
			local chev = "";
			if (e.WireManualDial) then
				chev = e.WireDialledAddress[i];
			else
				chev = e.DialledAddress[i];
			end
			if(not e:GetNetworkedBool("chevron"..i) and not e.WireManualDial and chev ~= "DIAL") then break end;
			self:AddChevron(chev,true,true);
		end
	end
	util.PrecacheModel(self.ModelBroken); -- fix for delay on first broke
	self.DisRingRotate = false;
	self.LockedGate = NULL;
	if (pewpew and pewpew.NeverEverList and not table.HasValue(pewpew.NeverEverList,self.Entity:GetClass())) then table.insert(pewpew.NeverEverList,self.Entity:GetClass()); end -- pewpew support
end

function ENT:SpawnChevron()
	self.Chevron={};
	local pos = self.Entity:GetPos();
	local ang = self.Entity:GetAngles();
	for i=1,table.getn(self.ChevronModel) do
		if (self.ChevronModel[i] == "") then return e; end
		local e = ents.Create("prop_dynamic");
		util.PrecacheModel(self.ChevronModel[i]);
		e:SetModel(self.ChevronModel[i]);
		e:SetSolid(SOLID_VPHYSICS); -- fix zat chevron destroy
		e:SetParent(self.Entity);
		e:SetDerive(self.Entity); -- Derive Material/Color from "Parent"
		e:DrawShadow(false);
		e:SetPos(pos);
		e:SetAngles(ang);
		e:Spawn();
		e:Activate();
		e.CAP_EH_NoTouch = true;
		self.Chevron[i] = e;
		--e.Symbol = table.KeyFromValue( self.ChevronNumber, i )
		e:SetDerive(self.Entity); -- Derive Material/Color from "Parent"
		e:Fire("skin",self.SkinNumber);
	end
	return e;
end

--################# Stop lights @aVoN
function ENT:Shutdown(delay)
	local e = self.Entity;
	timer.Simple(delay,
		function()
			if(IsValid(e)) then
				e.Entity:SetNetworkedString("ADDRESS","");
				e.DialledAddress = {};
				e.Target = nil;
				timer.Remove("_StarGate.DeactivateDHDTimer"..e:EntIndex());
				if(IsValid(e) and e.Chevron) then
					for i=1,table.getn(e.Chevron) do
						local f = e.Chevron[i];
						if IsValid(f) then f:Fire("skin",e.SkinNumber); end
					end
				end
			end
		end
	);
end

function ENT:OnRemove()
	if timer.Exists("Flicker1"..self:EntIndex()) then timer.Destroy("Flicker1"..self:EntIndex()); end
	if timer.Exists("Flicker2"..self:EntIndex()) then timer.Destroy("Flicker2"..self:EntIndex()); end
	if timer.Exists("RandomClose"..self:EntIndex()) then timer.Destroy("RandomClose"..self:EntIndex()); end
	if timer.Exists("LightThink"..self:EntIndex()) then timer.Remove("LightThink"..self:EntIndex()) end
	if timer.Exists("EnergyThink"..self:EntIndex()) then timer.Remove("EnergyThink"..self:EntIndex()) end
	if not self.Destroyed and self.Chevron then for _,v in pairs(self.Chevron) do v:Remove() end end
	if (IsValid(self.LockedGate)) then
		self.LockedGate.LockedDHD = nil;
		self.LockedGate:SetNWEntity("LockedDHD",NULL);
	end
	self.Entity:Remove()
end

--################# Wire input by AlexALX
function ENT:TriggerInput(k,v)
	if(k == "Press Button") then
		if (v >= 1) then
			local symbols = "A-Z1-9@#!*";
			if (GetConVar("stargate_group_system"):GetBool()) then
				symbols = "A-Z0-9@#*";
			end
			local char = string.char(v):upper();
			if (v>=128 and v<=137) then char = string.char(v-80):upper(); -- numpad 0-9
			elseif (v==139) then char = string.char(42):upper(); end -- numpad *
			if(v == 13) then -- Enter Key
				self:PressButton("DIAL",_,true);
			elseif(v == 127) then -- Backspace key
				local e = self:FindGate();
				if not IsValid(e) then return end
				if (GetConVar("stargate_dhd_close_incoming"):GetInt()==0 and e.IsOpen and not e.Outbound) then return end -- if incoming, then we can do nothign
				if (e.IsOpen) then
					e:AbortDialling();
				elseif (e.NewActive and #self.DialledAddress>0) then
					self:PressButton(self.DialledAddress[table.getn(self.DialledAddress)],_,true);
				end
			elseif(char:find("["..symbols.."]")) then -- Only alphanumerical and the @, #
				self:PressButton(char,_,true);
			end
		end
	elseif (k == "Disable Ring Rotation" or k == "Slow Mode") then
		if (v >= 1) then
			self.DisRingRotate = true;
			self.Entity:SetNWBool("DisRingRotate",true);
		else
			self.DisRingRotate = false;
			self.Entity:SetNWBool("DisRingRotate",false);
		end
	elseif (k == "Disable Glyphs") then
		if (v >= 1) then
			self.Entity:SetNWBool("DisGlyphs",true);
		else
			self.Entity:SetNWBool("DisGlyphs",false);
		end
	elseif (k == "Wire Disable DHD Sound") then
		if (v>0) then
			self.WireNoSound = true
		else
			self.WireNoSound = false;
		end
	end
end

--################# Busy? Don't allow manuall input now @aVoN
function ENT:SetBusy(d,no_nw)
	local d = d or 0;
	local e = self.Entity;
	local id = "DHD.UnsetBusy."..e:EntIndex();
	self.busy = true;
	if(d > 1 and not no_nw) then -- Delay > 1 means, only set this "Client-Side-Busy" if the gate (which already has been dialled) is telling this DHD to activate a chevron (no user shall be able to press this now for about 10 secs mostly)
		-- Tells clientside, that we do not want the overlay do be drawn now
		e:SetNetworkedBool("Busy",true);
	end
	e:SetNWBool("BusyGUI",true);
	timer.Remove(id);
	timer.Create(id,d,1,
		function()
			if(IsValid(e)) then
				e.busy = false
				e:SetNWBool("Busy",false);
				e:SetNWBool("BusyGUI",false);
			end
		end
	);
end

function ENT:DestroyEffect(noeffect)
	if self.Destroyed then return end
	if (not noeffect) then
		local effectdata = EffectData()
		effectdata:SetStart(self.Entity:GetPos()) // not sure if we need a start and origin (endpoint) for this effect, but whatever
		effectdata:SetOrigin(self.Entity:GetPos())
		effectdata:SetScale(2)
		util.Effect( "HelicopterMegaBomb", effectdata )
	end

	for _,v in pairs(self.Chevron) do if (IsValid(v)) then v:Remove(); end end
	self.SpawnedChevs = {}
	self.busy = true;
	self.Destroyed = true;
	self:SetNWBool("Busy",true);
	self:SetNWBool("Destroyed",true);

	util.PrecacheModel(self.ModelBroken);
	self.Entity:SetModel(self.ModelBroken)
	self.Entity:Fire("skin",self.SkinNumber/2);

	local gate = self:FindGate();
	if IsValid(gate) then
		gate:Flicker(3);
		gate:Flicker(3);
	end

	timer.Create( "Flicker1"..self:EntIndex(), 1, 0, function()
		if IsValid(self) then
			local gate = self:FindGate();
			if IsValid(gate) then
				local workingdhd = false;
				for _,v in pairs(gate:FindDHD(true)) do
					if (v != self and not v.Destroyed) then workingdhd = true end
				end
				if (gate:CheckEnergyDHD()) then workingdhd = true end
				if not workingdhd then gate:Flicker(1); end
			end
		end
	end)
	timer.Create( "Flicker2"..self:EntIndex(), 2.2, 0, function()
		if IsValid(self) then
			local gate = self:FindGate();
			if IsValid(gate) then
				local workingdhd = false;
				for _,v in pairs(gate:FindDHD(true)) do
					if (v != self and not v.Destroyed) then workingdhd = true end
				end
				if (gate:CheckEnergyDHD()) then workingdhd = true end
				if not workingdhd then gate:Flicker(1); end
			end
		end
	end)
	timer.Create( "RandomClose"..self:EntIndex(), 40, 0, function()
		if IsValid(self) then
			local gate = self:FindGate();
			if IsValid(gate) then
				local workingdhd = false;
				for _,v in pairs(gate:FindDHD(true)) do
					if (v != self and not v.Destroyed) then workingdhd = true end
				end
				if (gate:CheckEnergyDHD()) then workingdhd = true end
				if not workingdhd then gate:AbortDialling(); end
			end
		end
	end)
end

--################# When it get's hurt, make it flicker etc
function ENT:OnTakeDamage(dmg)
	local gate = self:FindGate();
	local damage = dmg:GetDamage();
	local class = self:GetClass();

	if (dmg:GetDamageType() != DMG_BLAST) then return end

	if(not self.GateSpawnerSpawned and not util.tobool(GetConVar("stargate_dhd_protect"):GetInt()) or self.GateSpawnerSpawned and not util.tobool(GetConVar("stargate_dhd_protect_spawner"):GetInt()))then
		self.Healthh = self.Healthh - damage/4;
		if (self.Healthh < 1 and class != "dhd_concept" and class != "dhd_city") then self.Entity:DestroyEffect() end
	end

	if not IsValid(gate) then return end

	if self.Destroyed then
		if (damage<=30) then
			gate:Flicker(1);
		elseif (damage>30 and damage<=60) then
			gate:Flicker(2);
		elseif (damage>60) then
			gate:Flicker(3);
		end
		if (damage>100) then
			gate:AbortDialling();
		end
		return
	else
		if (damage<=30) then
			gate:Flicker(1);
		elseif (damage>30 and damage<=60) then
			gate:Flicker(2);
		elseif (damage>60) then
			gate:Flicker(3);
		end
	end

end

function ENT:Touch(ent)
	if not IsValid(self.LockedGate) then
		if (string.find(ent:GetClass(), "stargate")) then
			local gate = self:FindGate()
			if IsValid(gate) and gate==ent and not IsValid(gate.LockedDHD) then
				self.LockedGate = gate;
				self:SetNWEntity("LockedGate",gate);
				gate.LockedDHD = self.Entity;
				gate:SetNWEntity("LockedDHD",self.Entity);
				local ed = EffectData()
 					ed:SetEntity( self.Entity )
 				util.Effect( "propspawn", ed, true, true )
			end
		end
	end
end

--################# Finds a gate @aVoN
function ENT:FindGate()
	if (IsValid(self.LockedGate)) then return self.LockedGate end
	local gate;
	local dist = self.Range;
	if (dist==nil) then return NULL end
	local pos = self.Entity:GetPos();
	for _,v in pairs(ents.FindByClass("stargate_*")) do
		if(v.IsStargate and not v.IsSupergate and (not IsValid(v.LockedDHD) or v.LockedDHD==self.Entity)) then
			local sg_dist = (pos - v:GetPos()):Length();
			if(dist >= sg_dist) then
				dist = sg_dist;
				gate = v;
			end
		end
	end
	return gate;
end

--################# Call address @aVoN
function ENT:Use(p)
	--Player is calling the gate and it is not busy
	if(IsValid(p) and p:IsPlayer() and not self.busy and not self.Destroyed) then
		local e = self:FindGate();
		if(not IsValid(e) or e.jammed) then return end; -- Just necessary to make the hook below not being called if no gate is here to get dialled
		if (GetConVar("stargate_group_system"):GetBool() and e:GetGateGroup()=="") then return end;
		if(hook.Call("StarGate.Player.CanDialGate",GAMEMODE,p,e) == false) then return end;
		self.LastPlayer = p;
		local btn = self:GetCurrentButton(p);
		if (btn) then self:PressButton(btn); end
	end
	return false;
end

--################# Calling to client server convar by AlexALX
function ENT:Think()
	if (not IsValid(self)) then return false end;
	local candialg = GetConVar("stargate_candial_groups_dhd"):GetInt()
	if (self:GetClass()=="dhd_city") then candialg = 1; end
	if (candialg != self.Entity:GetNetworkedInt("CANDIAL_GROUP_DHD")) then
		self.Entity:SetNetworkedInt("CANDIAL_GROUP_DHD",candialg);
	end
	candialg = GetConVar("stargate_candial_groups_menu"):GetInt()
	if (candialg != self.Entity:GetNetworkedInt("CANDIAL_GROUP_MENU")) then
		self.Entity:SetNetworkedInt("CANDIAL_GROUP_MENU",candialg);
	end
	candialg = GetConVar("stargate_sgu_find_range"):GetInt()
	if (candialg != self.Entity:GetNetworkedInt("SGU_FIND_RANDE")) then
		self.Entity:SetNetworkedInt("SGU_FIND_RANDE",candialg);
	end
	local groupsystem = GetConVar("stargate_group_system"):GetBool()
	if (groupsystem != self.Entity:GetNetworkedBool("SG_GROUP_SYSTEM")) then
		self.Entity:SetNetworkedBool("SG_GROUP_SYSTEM",groupsystem);
	end
	local gate = self:FindGate();
	if IsValid(gate) then
		candialg = gate:GetLocale();
		if (candialg != self.Entity:GetNetworkedBool("Locale")) then
			self.Entity:SetNetworkedBool("Locale",candialg);
		end
	end
	candialg = GetConVar("stargate_dhd_letters"):GetInt()
	if (candialg != self.Entity:GetNetworkedInt("DHD_LETTERS")) then
		self.Entity:SetNetworkedInt("DHD_LETTERS",candialg);
	end

	self.Entity:NextThink(CurTime()+5.0)
	return true
end

--################# Adding address @aVoN
function ENT:AddChevron(btn, nosound, lightup, gate, city, fail)
	--if(table.getn(self.DialledAddress) < 10) then
		if(not table.HasValue(self.DialledAddress,btn)) then
			timer.Remove("_StarGate.DeactivateDHDTimer"..self.Entity:EntIndex());
			timer.Create("_StarGate.DeactivateDHDTimer"..self.Entity:EntIndex(),20,1,
				function()
					if(IsValid(gate) and not gate.IsOpen and not self.Outbound and not self.Dialling) then
						gate:AbortDialling();
					end
				end
			);
			if (not city) then table.insert(self.DialledAddress,btn); end
			if (self.Entity:GetClass()=="dhd_city" and btn == "#") then
				self.Chevron[self.ChevronNumber["DIAL"]]:Fire("skin",1);
				self.Entity:SetNetworkedBool("CITYBUSY",true);
			end
			self.Entity:SetNetworkedString("ADDRESS",string.Implode(",",self.DialledAddress));
			if self.Chevron and IsValid(self.Chevron[self.ChevronNumber[btn]]) and lightup then
				self.Chevron[self.ChevronNumber[btn]]:Fire("skin",self.SkinNumber+1);
			end
			if IsValid(gate) and btn != "DIAL" and lightup then
				local n = table.getn(self.DialledAddress);
				local action = gate.Sequence:New();
				action = gate.Sequence:OnButtonChevron(true, n, self.DialledAddress, btn, fail,false,self.DisRingRotate);
				gate:RunActions(action);
			end
			if((not fail or btn == "#" or table.getn(self.DialledAddress)==9 and not table.HasValue(self.DialledAddress,"DIAL")) and not nosound) then
				if (btn == "DIAL") then
					if (self.LockSound and not fail) then self.Entity:EmitSound(Sound(self.LockSound),90,math.random(97,103)); end
				elseif(self.Entity:GetClass()=="dhd_atlantis" or self.Entity:GetClass()=="dhd_city") then
					if (not self.DisRingRotate) then
						self.Entity:EmitSound(Sound(self.PlorkSound),130,math.random(97,103));
					end
				else
					if (self.ChevSounds) then
						self.Entity:EmitSound(self.ChevSounds[math.random(1,table.getn(self.ChevSounds))],70,math.random(97,103));
					else
						self.Entity:EmitSound(Sound(self.PlorkSound),70,math.random(97,103));
					end
				end
			end
		end
	--end
end

--################# Removing one button from address @aVoN
function ENT:RemoveChevron(btn, lightup, gate)
	--if(table.getn(self.DialledAddress) < 10) then
		local new_t = {};
		for _,v in pairs(self.DialledAddress) do
			if(v ~= btn) then -- If remove any button, the Chevron 7 will be unlocked automatically!
				table.insert(new_t,v);
			end
		end
		timer.Remove("_StarGate.DeactivateDHDTimer"..self.Entity:EntIndex());
		if (#new_t>0) then
			timer.Create("_StarGate.DeactivateDHDTimer"..self.Entity:EntIndex(),20,1,
				function()
					if(IsValid(self) and IsValid(gate) and not gate.Active and not gate.IsOpen) then
						gate:AbortDialling();
					end
				end
			);
		end
		if (IsValid(gate) and IsValid(gate.Target) and gate.Target.OnButtLock) then
			local t = gate.Target;
			local action = t.Sequence:New();
			action = action + t.Sequence:DialFail(nil,true);
			action:Add({f=t.ResetVars,v={t},d=0})
			t:RunActions(action);
		end
		if IsValid(self.Chevron[self.ChevronNumber[btn]]) then
			self.Chevron[self.ChevronNumber[btn]]:Fire("skin",self.SkinNumber);
		end
		if (self.Entity:GetClass()=="dhd_city" and btn == "#") then
			self.Chevron[self.ChevronNumber["DIAL"]]:Fire("skin",0);
			self.Entity:SetNetworkedBool("CITYBUSY",false);
		end
		self.DialledAddress=new_t;
		self.Entity:SetNetworkedString("ADDRESS",string.Implode(",",self.DialledAddress));
		if IsValid(gate) and lightup and btn != "DIAL" then
			local n = table.getn(self.DialledAddress);
			local action = gate.Sequence:New();
			action = gate.Sequence:OnButtonChevron(false, n, self.DialledAddress, btn, false, false, self.DisRingRotate);
			gate:RunActions(action);
		end
		--self.Entity:EmitSound(Sound(self.PlorkSound),70,math.random(97,103));
	--end
end

--################# Press Button @aVoN
-- This function is also used by the USE function and the ConCommand which is getting triggered by the GUI click
function ENT:PressButton(btn, nolightup, no_menu)
	if (self.busy or self.Destroyed) then return end
	if self:GetClass()=="dhd_city" and not self:GetNetworkedBool("HasEnergy",false) then return end
	local e = self:FindGate();
	if not IsValid(e) then return end
	if (GetConVar("stargate_dhd_close_incoming"):GetInt()==0 and e.IsOpen and not e.Outbound) then return end -- if incoming, then we can do nothign
	if (e.Dialling and e.Active and not e.IsOpen or e.Jamming!=nil and e.Jamming==true or e:IsShutdown()) then return end
	if (IsValid(e.EventHorizon) and not e.EventHorizon:IsOpen()) then return end
	if (e.Dialling and (e.Stop!=nil and e.Stop==true or e.Gate!=nil and e.Gate.Moving!=nil and e.Gate.Moving == true) or e.WireManualDial!=nil and e.WireManualDial==true) then return end
	local num = table.getn(self.DialledAddress);
	if ((num==0 or btn!="DIAL") and e.IsOpen) then return end
	local nosound = (self.WireNoSound and no_menu)
	-- #################  Random gate dialing for concept
	if (btn and btn == "*" and num == 0) then
		if (e:GetClass() == "stargate_universe") then return end
		self:AddChevron(btn, nosound, lightup, e);
		-- Prepare gate
		local gates = {}
		for _,v in pairs(ents.FindByClass("stargate_*")) do
			if(v.IsStargate and self.Entity != v.Entity and v:GetClass() != "stargate_supegate" and v:GetClass() != "stargate_orlin") then
				if (v:GetGateGroup() == e:GetGateGroup() or v:GetLocale() == false and e:GetLocale() == false) then
					table.insert(gates,v);
				end
			end
		end
		-- Select and dial gate
		local RandGate = table.Random(gates)
		local dialaddress
		RandGate:AbortDialling();
		timer.Create("DialRand"..self.EntIndex(), 1, 1, function()
			if RandGate.GateAddress == "" then
				RandGate.GateAddress = "5GW7M2"; -- hope nobody will make such adress
			else
				dialaddress = RandGate.GateAddress
				if (RandGate.GateGroup != e.GateGroup) then
					dialaddress = dialaddress..RandGate.GateGroup
					if (string.len(e.GateGroup)==3 and string.len(RandGate.GateGroup)!=3) then
						dialaddress = dialaddress.."@#"
					end
				end
			end
			self:RemoveChevron(btn, false, lightup, e);
			e:DialGate(dialaddress,true);
		end);
		self:SetBusy(7);
		return;
	elseif (btn and btn == "*") then return end
	-- #################  DIAL button features
	if (btn and btn == "DIAL") then
		if(e:GetClass()=="stargate_orlin" and e.IsOpen or IsValid(e.Target) and e.Target:GetClass()=="stargate_orlin" and e.Target.IsOpen) then return end
		-- Old gate still opened. Close it
		if(IsValid(self.Target) and self.Target.IsOpen) then
			self.Target:AbortDialling();
			self.Target = nil;
			self:SetBusy(3.0);
			self:Shutdown(3.0);
			return;
		end
		if(e.IsOpen) then
			e:AbortDialling();
			self.Target = nil;
			self:SetBusy(3.0);
			self:Shutdown(3.0);
			return;
		end
		if (num == 0) then
			-- Open the dialling menu!
			if (not no_menu and not self.DisMenu and GetConVar("stargate_dhd_menu"):GetInt()>=1) then
				local candialg = GetConVar("stargate_candial_groups_dhd"):GetBool();
				if (self.Entity:GetClass()=="dhd_city") then candialg = true; end
				net.Start("StarGate.VGUI.Menu");
				net.WriteEntity(e);
				net.WriteInt(2,8);
				net.WriteBit(candialg);
				net.Send(self.LastPlayer);
				self:SetBusy(0.2);
			end
			return;
		end
	end
	-- #################  Usual button features
	local class = self:GetClass();
	local candialg = GetConVar("stargate_candial_groups_dhd"):GetInt()
	if (self:GetClass()=="dhd_city") then candialg = 1; end
	local allowed_symbols = 9
	if (candialg==0 or e:GetLocale()==true) then
		allowed_symbols = 6
	end
	local lightup = true;
	local fail = false;
	local remove = false;
	if (nolightup) then lightup = false end
	if (btn and num==0) then e.Outbound = true; end
	if (btn and ((num < allowed_symbols or allowed_symbols==6 and num==6 and btn == "#") and (not table.HasValue(self.DialledAddress,"#") or btn == "#") and (btn != "#" or btn == "#" and (num >= 6 and num <= 8)) or btn == "DIAL") or table.HasValue(self.DialledAddress,btn) and (not table.HasValue(self.DialledAddress,"#") or btn == "#")) then
		local atlantis = false
		if (IsValid(e) and e:GetClass()=="stargate_atlantis" and self.DisRingRotate) then atlantis = true end
		if (not table.HasValue(self.DialledAddress,"DIAL")) then
		    local city = false
			if (btn == "DIAL" and class == "dhd_city") then city = true end
			if table.HasValue(self.DialledAddress,btn) then
				self:RemoveChevron(btn, lightup, e);
				remove = true
			else
				local busy = false
				if(btn == "#" or num==8 or btn == "DIAL") then
					table.insert(self.DialledAddress,btn)
					if (btn!="DIAL") then
						table.insert(self.DialledAddress,"DIAL");
					end
					e.DialledAddress = self.DialledAddress;
					local oldtarget = e.Target;
					if (not e:OnButtCheckStargate()) then
						fail = true
						if (btn=="DIAL") then lightup = false end
						if (IsValid(e) and e:CheckEnergy(false,true) and IsValid(e.Target) and e.Target.IsStargate and (e.Target.IsOpen or e.Target.Dialling == true or e.Target:IsBlocked(nil,nil,true)) or IsValid(e) and e:IsSelfDial()) then
							if (IsValid(e) and e:CheckEnergy(false,true)) then
								lightup = true;
								fail = false;
							else
								lightup = false;
								fail = true;
							end
						end
					end
					local dly = 0.8;
					if (atlantis) then
						dly = 2.0;
					end
					if (e:GetClass()=="stargate_atlantis") then
						timer.Create(self.Entity:EntIndex().."DelayDialLock2", dly, 1, function()
							if not IsValid(self) or not IsValid(e) then return end
							if (lightup==true and fail==false and IsValid(e.Target) and not (e.Target.IsOpen or e.Target.Dialling == true or e.Target:IsBlocked(nil,nil,true))) then
								e:OnButtLockStargate(oldtarget)
							end
						end);
					else
						if (lightup==true and fail==false and IsValid(e.Target) and not (e.Target.IsOpen or e.Target.Dialling == true or e.Target:IsBlocked(nil,nil,true))) then
							e:OnButtLockStargate(oldtarget)
						end
					end
					e.DialledAddress = {};
					table.remove(self.DialledAddress,#self.DialledAddress);
					if (btn!="DIAL") then
						table.remove(self.DialledAddress,#self.DialledAddress);
					end
				end
				self:AddChevron(btn, nosound, lightup, e, city, fail);
			end
		end
		if (not remove and IsValid(e) and (e:GetClass()=="stargate_sg1" or e:GetClass()=="stargate_infinity" or e:GetClass()=="stargate_movie" or atlantis) and (btn=="#" or num==8 or atlantis) and (not self.DisRingRotate and GetConVar("stargate_dhd_ring"):GetBool() or atlantis and self.DisRingRotate or e.Ring.WireMoving)) then
			if (atlantis) then
				self:SetBusy(2.0,true);
			else
				self:SetBusy(1.5);
			end
		else
			if (btn=="#" or num==9) then
				self:SetBusy(1.5);
			else
				self:SetBusy(0.55);
			end
		end
		-- Dial? Ok, lets dial!
		if(IsValid(e)) then
			if(btn == "DIAL") then
				timer.Remove("_StarGate.DeactivateDHDTimer"..self.Entity:EntIndex());
				if(e.Dialling and e.Outbound and not e.IsOpen) then -- Only allow outbound gates to get disabled by DHD during a call
					e:AbortDialling();
					self.Target = nil;
					self:SetBusy(1.5);
					self:Shutdown(1.5);
				else
					--##### We got exact 7 chevrons, C7 as chevron7 and dialbutton activated - Lets dial out, holy crap
					if(table.getn(self.DialledAddress) >= 8 and table.getn(self.DialledAddress) <= 10 and class != "dhd_city") then
						e.DialledAddress = self.DialledAddress;
						-- Set address, dialling type and start dialling
						e:OnButtDialGate();
						-- Send Close UMSG for the dial menu
						if (not no_menu) then
							umsg.Start("StarGate.DialMenuDHDClose",self.LastPlayer);
							umsg.End();
						end
						self.Target = e; -- Needs to be set, so the gate does not "relightupt" this DHD on dial
						self:SetBusy(2.5);
					elseif(table.getn(self.DialledAddress) >= 6 and table.getn(self.DialledAddress) <= 9 and class == "dhd_city") then
						if (table.getn(self.DialledAddress)<9 and not table.HasValue(self.DialledAddress,"#")) then

							table.insert(self.DialledAddress,"#")
							table.insert(self.DialledAddress,"DIAL");
							e.DialledAddress = self.DialledAddress;
							local lightup = true;
							local fail = false;
							local snd = true;
							if (not e:OnButtCheckStargate()) then
								fail = true
								snd = false;
								if (IsValid(e) and e:CheckEnergy(false,true) and IsValid(e.Target) and e.Target.IsStargate and (e.Target.IsOpen or e.Target.Dialling == true or e.Target:IsBlocked(nil,nil,true)) or IsValid(e) and e:IsSelfDial()) then
									if (IsValid(e) and e:CheckEnergy(false,true)) then
										lightup = true;
										fail = false;
										snd = true;
									else
										lightup = false;
										fail = true;
									end
								end
							end
							e.DialledAddress = {};
							table.remove(self.DialledAddress,#self.DialledAddress);
							table.remove(self.DialledAddress,#self.DialledAddress);
							self:AddChevron("#", nosound, lightup, e, false, fail);
							local dly,dly2 = 1.2,1.0;
							if (atlantis) then
								dly,dly2 = 2.5,2.0
								self:SetBusy(2.7);
							else
								self:SetBusy(1.5);
							end
							if (not no_menu) then
								umsg.Start("StarGate.DialMenuDHDClose",self.LastPlayer);
								umsg.End();
							end
							timer.Create(self.Entity:EntIndex().."DelayDialLock", dly2, 1, function()
								if not IsValid(self) or not IsValid(e) then return end
								if (lightup==true and fail==false and IsValid(e.Target) and not (e.Target.IsOpen or e.Target.Dialling == true or e.Target:IsBlocked(nil,nil,true))) then
									e:OnButtLockStargate()
								end
							end);
							timer.Create(self.Entity:EntIndex().."DelayDialSnd", dly, 1, function()
								if not IsValid(self) then return end
								if (snd and self.LockSound and not nosound) then self.Entity:EmitSound(Sound(self.LockSound),90,math.random(97,103)); end
							end);
							timer.Create(self.Entity:EntIndex().."DelayDial", dly+0.4, 1, function()
								if not IsValid(self) then return end
								table.insert(self.DialledAddress,"DIAL");
								self.Entity:SetNetworkedString("ADDRESS",string.Implode(",",self.DialledAddress));
								self.Entity:SetNetworkedBool("CITYBUSY",true);
								e.DialledAddress = self.DialledAddress;
								e:OnButtDialGate();
								self.Target = e; -- Needs to be set, so the gate does not "relightupt" this DHD on dial
								--self:SetBusy(3.0);
							end);
						elseif (table.getn(self.DialledAddress)==9 or table.HasValue(self.DialledAddress,"#")) then
							table.insert(self.DialledAddress,"DIAL");
							self.Entity:SetNetworkedString("ADDRESS",string.Implode(",",self.DialledAddress));
							self.Entity:SetNetworkedBool("CITYBUSY",true);
							e.DialledAddress = self.DialledAddress;
							-- Set address, dialling type and start dialling
							e:OnButtDialGate();
							-- Send Close UMSG for the dial menu
							if (not no_menu) then
								umsg.Start("StarGate.DialMenuDHDClose",self.LastPlayer);
								umsg.End();
							end
							self.Target = e; -- Needs to be set, so the gate does not "relightupt" this DHD on dial
						end
					else
						local action = e.Sequence:New();
						action = e.Sequence:OnButtonDialFail(#self.DialledAddress-1,true)
						action = action + e.Sequence:DialFail(nil,true);
						e:RunActions(action);
						self:SetBusy(1.5);
						self:Shutdown(1.5);
					end
				end
			end
		else
			local action = e.Sequence:New();
			action = e.Sequence:OnButtonDialFail(#self.DialledAddress-1,true)
			action = action + e.Sequence:DialFail(nil,true);
			e:RunActions(action);
			self:SetBusy(1.5);
			self:Shutdown(1.5);
		end
	end
end

--################# Called by the OnScreen click function @aVoN
concommand.Remove("_StarGate.DHD.AddSymbol_Group"); -- In case of a lua_reloadents
concommand.Add("_StarGate.DHD.AddSymbol_Group",
	function(_,_,arg)
		local e = ents.GetByIndex(tonumber(arg[1])); -- Entity
		if(IsValid(e) and arg[2] and arg[2] ~= "") then
			local num = tonumber(arg[2]);
			if(num) then arg[2] = num end; -- If it is a number, we make this string to a number again
			if not e.busy then e:PressButton(arg[2],false); end
		end
	end
);

--######################## @Alex, aVoN -- snap gates to cap ramps
function ENT:CartersRampsDHD(t)
	local e = t.Entity;
	if(not IsValid(e)) then return end;
	local RampOffset = StarGate.RampOffset.DHD;
	if (self.Entity:GetClass()=="dhd_concept") then
		RampOffset = StarGate.RampOffset.DHDC;
	end
	local mdl = e:GetModel();
	if(RampOffset[mdl]) then
		-- Check, if there is already a gate snapped to it...
		for _,v in pairs(StarGate.GetConstrainedEnts(e,2) or {}) do
			if(IsValid(v) and v:GetClass():find("dhd_")) then return end;
		end
		-- Freeze ramp
		local phys = e:GetPhysicsObject();
		if(phys:IsValid()) then
			phys:EnableMotion(false);
		end
		self.Entity:SetPos(e:LocalToWorld(RampOffset[mdl][1]));
		if (RampOffset[mdl][2]) then
			self.Entity:SetAngles(e:GetAngles() + RampOffset[mdl][2]);
		else
			self.Entity:SetAngles(e:GetAngles());
		end
		constraint.Weld(self.Entity,e,0,0,0,true);
		e.CDSIgnore = true; -- Fixes Combat Damage System destroying Ramps - http://mantis.39051.vs.webtropia.com/view.php?id=45
		return e;
	end
end

function ENT:PreEntityCopy()
	local dupeInfo = {};

	if (IsValid(self.LockedGate)) then
		dupeInfo.LockedGate = self.LockedGate:EntIndex();
	end

    duplicator.StoreEntityModifier(self, "StarGateDHDInfo", dupeInfo)
	StarGate.WireRD.PreEntityCopy(self);
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end

	local dupeInfo = Ent.EntityMods.StarGateDHDInfo
	if (dupeInfo and dupeInfo.LockedGate and CreatedEntities[dupeInfo.LockedGate]) then
		self.LockedGate = CreatedEntities[dupeInfo.LockedGate];
		self:SetNWEntity("LockedGate",self.LockedGate);
		CreatedEntities[dupeInfo.LockedGate].LockedDHD = self.Entity;
		CreatedEntities[dupeInfo.LockedGate]:SetNWEntity("LockedDHD",self.Entity);
	end

	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end