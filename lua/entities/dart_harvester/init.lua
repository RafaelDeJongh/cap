/*
	Wraith Harveserfor GarrysMod10
	Copyright (C) 2007  Catdaemon

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
--################# Header
if (not StarGate.CheckModule("ship")) then return end
-- Includes
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");
-- Defines
ENT.Sounds = {
	SuckLoop=Sound("tech/wraith_cullbeam.wav"),
	Spit=Sound("ambient/levels/labs/electric_explosion4.wav"),
	Suck=Sound("ambient/levels/labs/electric_explosion1.wav"),
	Shutdown={Sound("ambient/levels/labs/electric_explosion2.wav"),Sound("vehicles/apc/apc_shutdown.wav")},
}
--################# SENT CODE

--################# Init @Catdaemon
function ENT:Initialize()
 	self.Sound = CreateSound(self,self.Sounds.SuckLoop);
	--self.Entity:SetModel("models/props_c17/pottery03a.mdl"); -- Done by the STOOL now @aVoN
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetNetworkedBool("on",false);
	-- Use the StarGate Pack's config @aVoN
	self.MaxEnts = StarGate.CFG:Get("harvester","max_ents",5);
	self.AllowConstrained = StarGate.CFG:Get("harvester","allow_constrained",false);
	self.AllowPlayers = StarGate.CFG:Get("harvester","allow_players",true);
	self.AllowFrozen = StarGate.CFG:Get("harvester","allow_frozen",false);
	self.ConsumeEnergy = StarGate.CFG:Get("harvester","energy",100);
	self.Disallowed = {};
	for _,v in pairs(StarGate.CFG:Get("harvester","disallowed_entities",""):TrimExplode(",")) do
		self.Disallowed[v] = true;
	end
	self.Ents={};
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:Wake();
	end
end

--################# OnRemove @Catdaemon
function ENT:OnRemove()
	self.Sound:Stop()
	self.Entity:Spit(true)
end

--################# Turns on or off @aVoN
function ENT:TurnOn(b)
	local state = self.Entity:GetNetworkedBool("on");
	if(b and not state) then
		self.Entity:SetNetworkedBool("on",true);
		self.Sound:Play();
		self.Sound:SetSoundLevel(85);
		self.Entity:NextThink(CurTime());
	elseif(state) then
		self.Entity:SetNWBool("on",false);
		self.Sound:FadeOut(1);
	end
end

--################# Spit, it out! @Catdaemon,aVoN
function ENT:Spit(override)
	local pos = self.Entity:GetPos();
	--local trace = util.QuickTrace(pos,self:GetBeamNormal(),self.Entity);
	local trace = StarGate.Trace:New(pos,self:GetBeamNormal(),self.Entity)
	for k,v in pairs(self.Ents) do
		if(k:IsValid()) then
			-- Respawn effect
			local fx = EffectData();
			fx:SetStart(pos);
			fx:SetOrigin(trace.HitPos);
			fx:SetEntity(k);
			fx:SetScale(0); -- 0 means "spit out";
			util.Effect("wraithbeam",fx);
			self.Entity:EmitSound(self.Sounds.Spit,90,130);
			-- Special settings for a player
			if(k:IsPlayer()) then
				k:SetParent(nil);
				k.DisableSpawning = nil; -- Allow him again to spawn things
				k.DisableSuicide = nil; -- Allow him to commit suicide again
				k.DisableNoclip = nil;
				k:UnSpectate();
				k:DrawViewModel(true);
				k:DrawWorldModel(true);
				k:Spawn();
				-- Just to be 100% sure!
				k:SetColor(Color(255,255,255,255));
				timer.Simple(0,
					function()
						if(k and k:IsValid()) then
							k:SetColor(Color(255,255,255,255)); -- Make sure!
						end
					end
				);
				-- FIXME: Does sometimes not work. Timer is NO SOLUTION as the fucking timer lags players
				for _,w in pairs(v.Weapons) do
					if(not k:HasWeapon(w)) then
						k:Give(w);
					end
				end
				-- This is a workaround for my own scripts. Using SelectWeapon two times (or just frequently) results into a spawnlag
				if(v.ActiveWeapon) then
					k.DefaultWeapon = v.ActiveWeapon;
					timer.Simple(0,
						function()
							-- We found out, WeaponManager is either in the wrong addon-load-order or not installed. So select it this way!
							if(k:IsValid() and k.DefaultWeapon) then
								k:SelectWeapon(k.DefaultWeapon);
								k.DefaultWeapon = nil;
							end
						end
					);
				end
			end
			-- General settings
			k:SetMoveType(v.MoveType);
			k:SetSolid(v.Solid);
			k:SetParent(nil); -- Again!
			k:SetPos(trace.HitPos-trace.HitNormal*k:OBBMins().z);
			k:SetAngles(Angle(0,0,0));
			--Failsafe
			timer.Simple(0.5,
				function()
					if(k and k:IsValid()) then
						k:SetColor(v.Color);
						k:SetRenderMode(v.RenderMode);
					end
				end
			);
			-- Fix up the bones
			-- Now, let's change the bone's positions!
			for _,bone in pairs(v.Bones) do
				if(bone.Entity:IsValid()) then
					bone.Entity:SetPos(k:LocalToWorld(bone.Position));
				end
			end
			-- Wake the entity up
			if(v.MoveType==MOVETYPE_VPHYSICS) then
				local phys=k:GetPhysicsObject();
				if(phys:IsValid()) then
					phys:EnableMotion(true);
					phys:Wake();
				end
			end
			self.Ents[k]=nil;
			k.LastWraith = CurTime(); -- Necessary to avoid ugly conflicts
			if(not override) then break end;
		else
			self.Ents[k]=nil;
		end
	end
end

--################# Init @Catdaemon,aVoN
function ENT:Allowed(e)
	if(not (self.Ents[e] or self.Disallowed[e:GetClass()]) or e:GetModel():find("*")) then -- "*" in modelname is always a brush/map entity
		return true;
	end
	return false
end

--################# Get's an entities bone's for suckup (taken from my teleportation module) @aVoN
function ENT:GetBones(e)
	-- And as well, get the bones of an object
	local bones = {};
	if(e:IsVehicle() or e:GetClass() == "prop_ragdoll") then
		for i=0,e:GetPhysicsObjectCount()-1 do
			local bone = e:GetPhysicsObjectNum(i);
			if(bone:IsValid()) then
				table.insert(bones,{
					Entity=bone,
					Position=e:WorldToLocal(bone:GetPos()),
					--Velocity=e:WorldToLocal(pos+bone:GetVelocity()), -- Not required
				});
			end
		end
	end
	return bones;
end

--################# Think @Catdaemon,aVoN
function ENT:Think()
	if(self.Entity:GetNWBool("on") and table.Count(self.Ents) < self.MaxEnts) then
		local pos = self.Entity:GetPos();
		--local trace = util.QuickTrace(pos,self:GetBeamNormal(),self.Entity);
		local trace = StarGate.Trace:New(pos,self:GetBeamNormal(),self.Entity);
		if(trace.Entity:IsValid() and trace.Entity:GetClass() == "shield") then
			trace.Entity:Hit(self.Entity,trace.HitPos,0);
		end
		local time = CurTime();
		for _,v in pairs(ents.FindInSphere(trace.HitPos,100)) do
			if (IsValid(self:GetParent()) and v==self:GetParent()) then continue end -- Prevent fucking crash! @ AlexALX
			if(table.Count(self.Ents) >= self.MaxEnts) then return end;
			if(v ~= self.Entity and (pos-trace.HitPos):Length() > 110 and self:Allowed(v) and (v.LastWraith or 0)+0.7 < time) then
				if(not (v:IsConstrained() and not self.AllowConstrained) and not v:GetParent():IsValid()) then
					local phys = v:GetPhysicsObject();
					if((phys:IsValid() and (self.AllowFrozen or phys:IsMoveable())) or (v:IsPlayer() and self.AllowPlayers)) then
						local fx = EffectData()
						fx:SetStart(v:GetPos());
						fx:SetEntity(v);
						fx:SetOrigin(pos);
						fx:SetScale(1); -- 1 means "suck in"
						util.Effect("wraithbeam",fx);
						--self.Entity:EmitSound(self.Sounds.Suck,90,100);
						-- Store restore informations
						local restore ={
							MoveType=v:GetMoveType(),
							Solid=v:GetSolid(),
							Color = v:GetColor(),
							Bones = self:GetBones(v),
							RenderMode = v:GetRenderMode(),
						};
						-- Attach the Entity to the harvester
						v:SetRenderMode( RENDERMODE_TRANSALPHA );
						v:SetColor(Color(0,0,0,0));
						v:SetSolid(SOLID_NONE);
						v:SetMoveType(MOVETYPE_NONE);
						v:SetPos(pos);
						v:SetParent(self.Entity);
						-- Now, let's change the bone's positions!
						for _,bone in pairs(restore.Bones) do
							bone.Entity:SetPos(v:LocalToWorld(bone.Position));
						end
						-- Make players spectate the harvester
						if(v:IsPlayer()) then
							v.DisableSpawning = true; -- Can't spawn props
							v.DisableSuicide = true; -- Can't suicide
							v.DisableNoclip = true; -- Disallows him to move or change his movetypez
							v:Spectate(OBS_MODE_CHASE);
							v:SpectateEntity(self.Entity);
							v:DrawViewModel(false);
							v:DrawWorldModel(false);
							restore.Weapons={};
							for _,w in pairs(v:GetWeapons()) do
								table.insert(restore.Weapons,w:GetClass());
							end
							local w = v:GetActiveWeapon();
							if(w and w:IsValid()) then
								restore.ActiveWeapon = w:GetClass();
							end
							v:StripWeapons();
						end
						self.Ents[v] = restore;
						-- We will just add ONE entity every 0.2 seconds (better, trust me)
						self.Entity:NextThink(CurTime()+0.2);
						return true;
					end
				end
			end
		end
		self.Entity:NextThink(CurTime()+0.2);
		return true;
	else
		self.Entity:NextThink(CurTime()+1);
		return true;
	end
end
