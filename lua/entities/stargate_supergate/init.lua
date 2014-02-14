/*
	Stargate SENT for GarrysMod10
	Copyright (C) 2007  aVoN,Assassin21, Madman07s

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

--################# HEADER #################
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
--################# Include
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");
include("modules/dialling.lua");
-- Sounds
ENT.Sounds = {
	Dial=Sound("stargate/supergate/supergate.wav"),
	Ring=Sound("stargate/gate_roll.mp3"),
	Open=Sound("stargate/sg1/open.mp3"),
	Travel=Sound("stargate/gate_travel.mp3"),
	Close=Sound("stargate/gate_close.mp3"),
	ChevronDHD=Sound("stargate/chevron_dhd.mp3"),
	Inbound=Sound("stargate/chevron_incoming.mp3");
	Lock=Sound("stargate/chevron_lock.mp3"),
	LockDHD=Sound("stargate/chevron_lock_dhd.mp3"),
	Fail=Sound("stargate/dial_fail.mp3"),
}

--################# SENT CODE ###############

--################# Init @aVoN,Assassin21
function ENT:Initialize()

	self.BaseClass.Initialize(self); -- BaseClass Initialize call

	util.PrecacheModel("models/Iziraider/supergate/segment.mdl");
	util.PrecacheModel("models/Iziraider/supergate/electric.mdl");
	self.Entity:SetModel("models/Iziraider/supergate/circle.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetColor(Color(0,0,0,0));
	self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA);
	self.Segments = {};
	self.EffectSegments = {};

	local block;
	local radius = 2375;
	local x;
	local y;
	local i = 0;
	local effblock;

	timer.Create( "Spawning"..self:EntIndex(), 0.1, 72, function()

		local ent = self.Entity;
		local ang = self.Entity:GetAngles();
		local forw = self.Entity:GetForward();
		local rig = self.Entity:GetRight();
		local up = self.Entity:GetUp();
		local pos = self.Entity:GetPos()

		x = math.sin(math.rad(i*5))*radius;
		y = math.cos(math.rad(i*5))*radius;

		block = ents.Create("prop_dynamic");
		block:SetAngles(ang  + Angle(0,0,5*i));
		block:SetPos(pos + forw*10 + up*y + rig*x);
		block:SetModel("models/Iziraider/supergate/segment.mdl");
		block:Spawn();
		block:Activate();
		block:SetParent(ent);
		--block.CAP_NotSave = true;

		local ed = EffectData()
			ed:SetEntity(block)
		util.Effect( "old_propspawn", ed, true, true )
		table.insert(ent.Segments, block)

		effblock = ents.Create("prop_dynamic");
		effblock:SetAngles(ang + Angle(0,0,i*5-2.5));
		effblock:SetPos(pos + forw*10);
		effblock:SetModel("models/Iziraider/supergate/electric.mdl");
		effblock:SetColor(Color(255,255,255,0))
		effblock:SetRenderMode( RENDERMODE_TRANSALPHA )
		effblock:Spawn();
		effblock:Activate();
		effblock:SetParent(ent);
		--effblock.CAP_NotSave = true;

		table.insert(self.EffectSegments, effblock)
		i = i + 1;

	end);

end

--#################  Called when stargate_group_system changed
function ENT:ChangeSystemType(groupsystem,reload)
	self:GateWireInputs(groupsystem);
	self:GateWireOutputs(groupsystem);
	self:SetWire("Dialing Mode",-1);
	self.WireCharters = "A-Z0-9@#!";
	if (reload) then
		StarGate.ReloadSystem(groupsystem);
	end
end

function ENT:GateWireInputs(groupsystem)
	self:CreateWireInputs("Dial Address","Dial String [STRING]","Dial Mode","Start String Dial","Close","Disable Autoclose","Transmit [STRING]","Disable Menu");
end

function ENT:GateWireOutputs(groupsystem)
	self:CreateWireOutputs("Active","Open","Inbound","Dialing Address [STRING]","Dialing Mode","Active Segment","Received [STRING]");
end

--################# @Madman07, Assassin21
function ENT:SpawnFunction(p,t)
	local ent = ents.Create("stargate_supergate");
	ent:SetPos(p:GetPos());
	ent:Spawn();
	ent:Activate();
	ent:SetAngles(p:GetAngles() + Angle(0,180,0));
	ent:SetWire("Dialing Mode",-1);
	return ent;
end

--##################@Madman07,Assassin21
function ENT:OnRemove()
	self:StopActions();
	self.Entity:DisActivateLights(true);
	self:RemoveGateFromList();

	if timer.Exists("LowPriorityThink"..self:EntIndex()) then timer.Remove("LowPriorityThink"..self:EntIndex()) end
	if timer.Exists("ConvarsThink"..self:EntIndex()) then timer.Remove("ConvarsThink"..self:EntIndex()) end
	if timer.Exists("Spawning"..self:EntIndex()) then timer.Destroy("Spawning"..self:EntIndex()); end

	for i=1, 72 do
		if IsValid(self.Segments[1]) then
			local ent = self.Segments[1];
			table.remove(self.Segments, 1);
			ent:Remove();
		end
	end
	if self.Entity.Target != nil then
		if self.Entity.Target:IsValid() and self.Entity.Target.IsOpen == true then
			self.Entity.Target:Close()
		end
	end
	self.Entity:Remove()
end

--###################Instant Dial light for EH jumping @Assassin21
function ENT:InstantLightUp()
	for i = 1,72 do
		self:Fade(self.EffectSegments[i], true);
	end
end

--################# Overwrite base code, we dont want flicker
function ENT:OnTakeDamage(dmg)
	// WormholeJump call is in gate_nuke
end

--################# @Madman07,Assassin21 Light Effect
function ENT:LightUp(Tick)

	local i=1;
	local ent = self.Entity;

	timer.Create( "Effects"..self:EntIndex(), Tick, 72, function()
		if (IsValid(ent)) then
			self:Fade(self.EffectSegments[i], true);
			self:SetWire("Active Segment",i);

			local pos = self.Segments[i]:GetPos();
			local e = self.Segments[i];

			timer.Create("Zaping"..e:EntIndex()..math.Rand(0,100),0.07,5,function()
				-- hmm, i decreased them as spawn effect is also nice and les laggy

				local fx3 = EffectData()
					fx3:SetStart(pos);
					fx3:SetOrigin(pos);
					fx3:SetScale(50);
					fx3:SetMagnitude(50);
					fx3:SetEntity(e);
				util.Effect("TeslaHitBoxes",fx3);

			end);
	        /*
			local ed = EffectData()
				ed:SetEntity(e)
			util.Effect( "old_propspawn", ed, true, true )
	        */
			i=i+1;
		end

	end )

end

--################# Segments Fadding @Madman07
function ENT:Fade(segment, tofull)
	if tofull then
		segment.direction = 16;
		segment.alpha = 0;
	else
		segment.direction = -16;
		segment.alpha = 255;
	end
	timer.Create("FadeSegmentss"..segment:EntIndex(),0.001,16,function()
		if (IsValid(segment)) then
			segment.alpha = segment.alpha + segment.direction;
			if (not tofull and segment.alpha < 17 ) then segment.alpha = 0 end
			if (tofull and segment.alpha > 237 ) then segment.alpha = 255 end
			segment:SetColor(Color(255,255,255,segment.alpha))
		end
	end);
end

--################# @Madman07,Assassin21 Light Effect
--Madman, do NOT remove this, your fix failed
--next time you chang this, check if it works ingame, before upload
function ENT:LightUps(Tick)

	local i=1;
	local ent = self.Entity;

	timer.Create( "Effectss"..self:EntIndex(), Tick, 72, function()
		if (not IsValid(ent)) then return end
		self:Fades(self.EffectSegments[i], true);
		self:SetWire("Active Segment",i);

		local pos = self.Segments[i]:GetPos();
		local e = self.Segments[i];

		timer.Create("Zappings"..e:EntIndex()..math.Rand(0,100),0.07,5,function()
			if (not IsValid(e)) then return end
			-- hmm, i decreased them as spawn effect is also nice and les laggy

			local fx3 = EffectData()
				fx3:SetStart(pos);
				fx3:SetOrigin(pos);
				fx3:SetScale(50);
				fx3:SetMagnitude(50);
				fx3:SetEntity(e);
			util.Effect("TeslaHitBoxes",fx3);

		end);
        /*
		local ed = EffectData()
			ed:SetEntity(e)
		util.Effect( "old_propspawn", ed, true, true )
        */
		i=i+1;

	end )

end

--################# Segments Fadding @Madman07
function ENT:Fades(segment, tofull)
	if tofull then
		segment.direction = 16;
		segment.alpha = 0;
	else
		segment.direction = -16;
		segment.alpha = 255;
	end
	timer.Create("FadeSegmentss"..segment:EntIndex(),0.001,13,function()
		if (IsValid(segment)) then
			segment.alpha = segment.alpha + segment.direction;
			if (not tofull and segment.alpha < 17 ) then segment.alpha = 0 end
			if (tofull and segment.alpha > 237 ) then segment.alpha = 255 end
			segment:SetColor(Color(255,255,255,segment.alpha))
		end
	end);
end

--################# Sound @LLapp, Assassin21
function ENT:GateSound()
	self.ActiveSound = util.PrecacheSound(self.Sounds.Dial);
    self.ActiveSound = CreateSound(self.Entity, Sound(self.Sounds.Dial));
    self.ActiveSound:Play();
	--self.ActiveSound:ChangeVolume(100);
end

--################# @Madman07 Disactivate Light Effect
function ENT:DisActivateLights(instant,fail)
	if (not self.Active and not fail) then return; end
	timer.Destroy("Effectss"..self:EntIndex());
	timer.Destroy("Effects"..self:EntIndex());
	timer.Destroy("FadeSegmentss"..self:EntIndex());
	for i=1, 72 do
		if (IsValid(self.Entity) and IsValid(self.Segments[i])) then -- because i will use same funciton in some other place
			self.Entity:SetNetworkedBool("chevron"..i,false);
		end
		if IsValid(self.Segments[i]) then -- because i will use same funciton in some other place

			local ent = self.Segments[i]:EntIndex();
			if timer.Exists("Zapping"..ent) then timer.Destroy("Zapping"..ent); end
			--if timer.Exists("Effects") then timer.Destroy("Effects"); end

			-- we want to fade out or just remove whole gate?
			if instant then
				if IsValid(self.EffectSegments[i]) then self.EffectSegments[i]:Remove(); end
			else
				if IsValid(self.EffectSegments[i]) then self:Fade(self.EffectSegments[i], false); end
			end

		end
	end
	self:SetWire("Active Segment",0);
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "stargate_supergate", StarGate.CAP_GmodDuplicator, "Data" )
end