/*
	Zat'nik'tel for GarrysMod10
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
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("weapon")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");
SWEP.Sounds = {Shot={Sound("zat/zat_shot1.mp3"),Sound("zat/zat_shot2.mp3")},Deploy=Sound("zat/zat_engage.mp3"),Holster=Sound("zat/zat_holster.mp3")};
-- Theses entities can't get dissolved!
SWEP.ProtectedEntities = {
	"func_",
	"prop_door_rotating",
}

--################### Init the SWEP @aVoN
function SWEP:Initialize()
	-- Sets how fast and how much shots an NPC shall do
	self:SetNPCFireRate(0.8);
	self:SetNPCMinBurst(0);
	self:SetNPCMaxBurst(0);
	-- Set holdtype, depending on NPCs, so it doesn't look too strange
	timer.Simple(0.2,
		function()
			if(not (self and self.SetWeaponHoldType)) then return end;
			if(self.Owner and self.Owner:IsValid() and self.Owner:IsNPC()) then
				local class = self.Owner:GetClass();
				if(class ~= "npc_metropolice" and class:find("combine")) then
					self:SetWeaponHoldType("ar2");
				end
			end
		end
	);
	self.MaxSize = StarGate.CFG:Get("zat","max_size",110);
	self.KillDistance = StarGate.CFG:Get("zat","kill_distance",100);
	self.DissolveDistance = StarGate.CFG:Get("zat","dissolve_distance",60);
	self:SetWeaponHoldType("pistol");
end

--################### Initialize the shot @aVoN
function SWEP:SVPrimaryAttack(fast)
	local snd = self.Sounds.Shot[1];
	local delay = 0.4;
	if(fast) then
		delay = 0;
		snd = self.Sounds.Shot[2];
	end
	self.Owner:EmitSound(snd,90,math.random(96,102));
	-- Maily needed for NPCs, because NPC:GetActiveWeapon() is currently Serverside. Furthermore, I can't put that into "Deploy" because it isn't called on NPCs
	-- http://www.garrysmod.com/bugs/view.php?id=802 and http://www.garrysmod.com/bugs/view.php?id=801
	self.Owner:SetNetworkedEntity("zat",self.Weapon);
	-- Tracer and shot
	timer.Simple(delay,function() if IsValid(self) then self:DoShoot(); end end);
end

--################### Start a target-Trace @aVoN
function SWEP:TraceForTargets(pos,normal,exception)
	local targets = {};
	local trace = StarGate.Trace:New(pos,normal*8192,exception);
	if(trace.Hit and IsValid(trace.Entity)) then -- We hit one person directly.
		targets[1]=trace.Entity;
	else -- Not hit anyone - Do a circular trace to increase the probability to hit someone!
		local ang = normal:Angle();
		local euler_matrix = MMatrix.EulerRotationMatrix(ang.p,ang.y,ang.r);
		for i=1,10 do
			local rad = math.rad(i*36);
			local origin = euler_matrix*(10*Vector(0,math.cos(rad),math.sin(rad)));
			trace = StarGate.Trace:New(origin+pos,normal*8192,exception);
			if(trace.Hit and trace.Entity:IsValid() and not table.HasValue(targets,trace.Entity)) then
				table.insert(targets,trace.Entity);
				break;
			end
		end
	end
	return trace,targets;
end

--################### Do the shot @aVoN
function SWEP:DoShoot()
	local p = self.Owner;
	if(not IsValid(p)) then return end;
	if(self.Owner:IsPlayer()) then self:TakePrimaryAmmo(1) end; -- Take one Ammo
	local pos = p:GetShootPos();
	-- This checks, if we are actually shooting in first person mode or spectating out selve from a camera (Workaround due to clientside limitations)
	local spectating = 1;
	if(p:IsPlayer() and p:GetViewEntity() == p) then spectating = 0 end;
	--################### Multiple-Tracelines to hit an enemy much better
	local trace,targets = self:TraceForTargets(pos,p:GetAimVector(),p);
	--################### Muzzle
	local fx = EffectData();
	fx:SetScale(0);
	fx:SetOrigin(pos);
	fx:SetEntity(p);
	fx:SetAngles(Angle(40,142,255));
	fx:SetRadius(64);
	util.Effect("energy_muzzle",fx,true);
	--################### The Zat-Tracer
	local fx = EffectData();
	fx:SetScale(spectating);
	fx:SetOrigin(pos);
	fx:SetStart(trace.HitPos);
	fx:SetEntity(p);
	util.Effect("zat_tracer",fx,true);
	--################### Hit the shield? Do a flicker effect FIXME: I Really should movethese HasEnergy <=> Depleted shit to the shield soon
	if(IsValid(trace.Entity)) then
		local class = trace.Entity:GetClass();
		if(class == "shield") then
			if(trace.Entity:Hit(self.Weapon,trace.HitPos,3,-1*trace.Normal)) then return end;
		elseif(class == "shield_core_buble") then
			if(trace.Entity:Hit(self.Weapon,trace.HitPos,3,trace.Normal)) then return end;
		elseif(class == "event_horizon") then
			-- Event horizon! Make the shot go through! (This will make the zat only go through ONE (1!) time. So for any idiot, trying to shout the shot through 1000 gates: Be disappointed. It's not my intention to add idiotic-special cases!)
			if(IsValid(trace.Entity.Target) and trace.Entity:GetForward():DotProduct(trace.Normal) < 0) then
				local pos,normal = trace.Entity:TeleportVectorWithEffect(trace.HitPos,trace.Normal);
				trace,targets = self:TraceForTargets(pos,normal,{p,trace.Entity,trace.Entity.Target}); -- Reset the traces!
				-- Now draw a new Zat-Trace!
				local fx = EffectData();
				fx:SetScale(1);
				fx:SetOrigin(pos);
				fx:SetStart(trace.HitPos);
				util.Effect("zat_tracer",fx,true);
				-- I have no clue, why this is necessary, but atleast one person has a problem with this line http://mantis.39051.vs.webtropia.com/view.php?id=7
				if(IsValid(trace.Entity)) then
					trace.Entity:EmitSound(self.Sounds.Shot[2],90,math.random(96,102));
				end
			else
				trace.Entity:EnterEffect(trace.HitPos,math.random(5,10));
				trace.Entity:EmitSound(trace.Entity.Sounds.Teleport[math.random(1,#trace.Entity.Sounds.Teleport)],90,math.random(90,110));
				return;
			end
		end
	end
	if(#targets == 0 and trace.Hit) then -- Still nothing?, well do a FindInSphere
		targets = ents.FindInSphere(trace.HitPos,50);
		-- Only allow props with physics
		for k,v in pairs(targets) do
			if(not v:GetPhysicsObject():IsValid()) then targets[k] = nil end;
		end
	end
	--################### Hiteffect
	if(trace.Hit and not trace.HitSky and not (trace.Entity and trace.Entity:IsValid())) then
		self:StunEffect(NULL,trace.HitPos+trace.HitNormal*10,0); -- Nothing hit - Just to zapping on the e.g. the wall
	end
	--################### Check for near objects - The will get stunned too
	targets = self:FindNearEnts(targets);
	--################### Dissolve check
	local disallow_dissolve = {}; -- Just a table where I put (constrained) ents into which are not allowed to get dissolved
	local already_checked = {}; -- Just so I don't need to do the check again and again
	--################### We hit something
	for k,v in pairs(targets) do
		if(IsValid(v) and v.ZatMode ~= 3 and not v.ZatIgnore) then -- Only valid props which are physically
			local phys = v:GetPhysicsObject();
			if(phys:IsValid()) then
				local class = v:GetClass();
				local pos = v:GetPos();
				local health = v:Health();
				-- Quick-reference. Makes the script faster than calling v:IsNPC() all the time
				local IS_NPC = v:IsNPC();
				local IS_PLAYER = v:IsPlayer();
				local low_hp = ((IS_NPC or IS_PLAYER) and health ~= 0 and health < 20 and health ~= 8); -- For NPCs and Players
				--################### Needed for disintegration and the size of the hiteffect
				local size = v:BoundingRadius();
				local dist = (v:NearestPoint(trace.HitPos)-trace.HitPos):Length();
				self:StunEffect(v,pos,size*math.Clamp(dist/25,1,10));
				--################### Apply some recoil to the prop we hit
				if(v == trace.Entity) then
					phys:ApplyForceOffset(math.Clamp(phys:GetMass(),0,500)*(trace.Normal*0.7+VectorRand()*0.3)*100,trace.HitPos);
				end
				--################### Paralyze
				if((not v.LastZat or v.LastZat+15 < CurTime()) and not low_hp) then
					if(health > 1) then
						v:TakeDamage(1,p); -- Apply some damage - Just to draw an Hit effect on the hud on player's screen and play NPC's pain-noise
					end
					if(IS_PLAYER) then
						-- Old health and armor
						local armor = v:Armor();
						-- New health and armor
						local new_health = math.Clamp(health-health/(1.3*math.Clamp(armor/100,1,5))+math.random(-20,20),10,health);
						local new_armor = math.Clamp(armor-armor/3+math.random(-20,20),0,armor);
						v:SetHealth(new_health);
						v:SetArmor(new_armor);
						--################### Slowdown
						-- Garry fucked up SprintDisable/Enable with the latest updates
						--v:SprintDisable();
						--timer.Create("StarGate.UnParalyze",4,1,v.SprintEnable,v);
						-- I hope this is not interfearing with any gamemodes... Blame garry if the zat makes you slow down permanently then!
						GAMEMODE:SetPlayerSpeed(v,150,150);
						timer.Destroy("StarGate.UnParalyze"); -- Always start a fresh timer!
						timer.Create("StarGate.UnParalyze",4,1,function() if IsValid(v) then GAMEMODE:SetPlayerSpeed(v,250,500) end end);
						if(new_health >= 150) then return end; -- He has had too much health. He will need more hits to die!
					elseif(IS_NPC) then
						local new_health = math.Clamp(health/2 + math.random(-20,20),1,health);
						v:SetHealth(new_health);
						--################### Clear the NPC's state and sequence to make them stop for a moment
						v:ExitScriptedSequence();
						if(class == "npc_antlionguarg") then
							v:SetNPCState(NPC_STATE_IDLE);
						else
							local previous_state = v:GetNPCState();
							v:SetNPCState(NPC_STATE_NONE);
							timer.Simple(2,function() if(v:IsValid()) then v:SetNPCState(previous_state) end end);
						end
						if(new_health >= 90) then return false end;
					end
					v.ZatMode = 1;
				--################### Kill
				elseif((v.ZatMode == 1 or low_hp) and dist < self.KillDistance) then
					if(IS_PLAYER or IS_NPC) then
						v:SetHealth(1); -- Small health, easier kill
						local offset = Vector(0,0,50);
						if(IS_NPC) then
							offset = Vector(0,0,30); -- A bit more down
						else
							v:SetArmor(0); -- Remove all armor
						end
						v:TakeDamage(10,p); -- Will kill, definately (Exept for rollermines)
						--################### Check for NPC-Ragdolls to make them dissovle when hit with the next shot
						if(IS_NPC) then
							for _,v in pairs(ents.FindInSphere(pos,60)) do
								if(IsValid(v) and v:GetClass() == "prop_ragdoll") then
									-- Make the NPC's ragdoll valid for dissolve
									v.ZatMode = 2;
									v.LastZat = CurTime();
									-- Apply some force to the ragdoll
									if (IsValid(v:GetPhysicsObject())) then
										v:GetPhysicsObject():ApplyForceCenter((trace.Normal*0.7+VectorRand()*0.3)*60000);
									end
									break;
								end
							end
						else
							v.LastZat = nil;
							return;
						end
					else
						-- Destroy breakable props
						if(phys:IsMoveable() and health ~= 0) then
							v:SetHealth(1);
							v:TakeDamage(10,p);
						end
					end
					v.ZatMode = 2;
				--################### Disintegrate (Either allowed on valid props or ragdolls)
				elseif(v.ZatMode == 2 and StarGate.CFG:Get("zat","dissolve",true)) then
					if((not disallow_dissolve[v] and not IS_PLAYER and not self:MapObject(v) and phys:IsMoveable() and size < self.MaxSize and dist < self.DissolveDistance) or class == "prop_ragdoll") then
						--################### It is constrained - Check with what and decide whether to dissolve or not
						if(not already_checked[v] and constraint.HasConstraints(v)) then
							local entities = StarGate.GetConstrainedEnts(v,8);
							if(entities) then
								local allow = true;
								if(#entities > 20) then -- Contraption bigger than 20 props - Don't allow dissolve!
									allow = false;
								else
									for _,e in pairs(entities) do
										already_checked[e] = true;
										-- Constrained to World = Energy goes into the world - No dissolve possible
										if(e:IsWorld()) then
											allow = false;
											break;
										end
										-- Valid phyisical object?
										local phys = e:GetPhysicsObject();
										if(phys:IsValid()) then
											-- One part is frozen: So the whole contraption can't get dissolved
											if(not phys:IsMoveable()) then
												allow = false;
												break;
											end
											local size = e:BoundingRadius();
											if(size > 110 or ((e:NearestPoint(pos)-pos):Length()+size) > self.MaxSize) then
												allow = false;
												break;
											end
										end
									end
								end
								-- Tell the script, not to check the ents which are marked as "undissolveable"
								if(not allow) then
									for _,e in pairs(entities) do
										disallow_dissolve[e] = true;
										e.ZatMode = nil;
										e.LastZat = nil;
									end
									return;
								end
							end
						end
						--################### Do the dissolve effect
						local desintegration_time = 2;
						local fx = EffectData()
						fx:SetScale(desintegration_time);
						fx:SetEntity(v);
						v:SetRenderMode(2);
						v:SetKeyValue("renderamt",0);
						util.Effect("zat_disintegrate",fx);
						v:SetCollisionGroup(COLLISION_GROUP_DEBRIS);
						timer.Simple(desintegration_time+0.3,function() if(v:IsValid()) then v:Remove() end end);
						v.ZatMode = 3; -- Killed!
					end
				end
				v.LastZat = CurTime();
			end
		end
	end
end

--################### The Zat-Stun-Effect @aVoN
function SWEP:StunEffect(e,pos,size)
	local fx = EffectData();
	fx:SetOrigin(pos);
	fx:SetScale(size); -- A type of refect ammount. As bigger the Entity is, as less energy-zaps
	fx:SetEntity(e);
	util.Effect("zat_impact",fx,true);
	-- Create a dummy SENT, so we can have the TeslaHitboxes where we shot
	local e = e;
	if(not e) then
		e = ents.Create("prop_dynamic_override");
		e:SetKeyValue("rendermode",10);
		e:SetColor(Color(255,255,255,1));
		e:SetModel("models/gibs/hgibs.mdl");
		e:SetPos(pos);
		e:Spawn();
		e:Fire("Kill",0,1.1);
	end
	--################### Do zapping-effects
	if(IsValid(e)) then
		timer.Create("Zapping"..e:EntIndex(),0.1,math.floor(10/math.Clamp(((size or 0)/100 or 1),1,5)),function()
			local fx = EffectData()
			fx:SetStart(pos);
			fx:SetOrigin(pos);
			fx:SetScale(10);
			fx:SetMagnitude(10);
			fx:SetEntity(e);
			util.Effect("TeslaHitBoxes",fx);
		end);
	end
end

--################### Findes near ents @aVoN
function SWEP:FindNearEnts(entities,checked,passes)
	local checked = checked or {};
	local passes = (passes or 0)+1;
	for _,e in pairs(entities) do
		if(not checked[e]) then
			checked[e] = true;
			local radius = e:BoundingRadius();
			if(radius < 120) then
				local pos = e:GetPos();
				for _,v in pairs(ents.FindInSphere(pos,radius+50)) do -- Finding entities near that prop in most cases
					if(not checked[v] and v:GetPhysicsObject():IsValid()) then
						-- Check for distance between both entities
						local my_nearest = v:NearestPoint(pos);
						if(#entities == 6) then break end;
						if((e:NearestPoint(my_nearest)-my_nearest):Length() < 30) then
							table.insert(entities,v);
						end
					end
				end
				if(#entities == 6) then break end;
			end
		end
	end
	if(#entities < 6 and passes < 4) then -- Whatever comes first - Too much entities or too much passes will break the recursive search
		return self:FindNearEnts(entities,checked,passes);
	end
	return entities;
end

--################### We dont want dematerialize mapobjects @aVoN
function SWEP:MapObject(e)
	if(e:GetModel():find("*")) then return true end;
	local class = e:GetClass();
	for _,v in pairs(self.ProtectedEntities) do
		if(class:find(v)) then return true end;
	end
	return false;
end
