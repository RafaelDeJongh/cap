/*
	Stargate Entity Lib for GarrysMod10
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

--#########################################
--						SENT related additions
--#########################################

--################# Compensates velocity @aVoN
-- Imagine, you are flying fast with your "deathglider" and shoot a staff pulse. When you are too fast (which happens quite often) you hit your own blast and explodes -- on your vehicle. This function compensates this and either return true (allow explode) or false (do not allow)
-- Input is a table: {Velocity="SENT's velocity",BaseVelocity="Velocity of the cannon",Time="Creation time of the shot",Delay="Delay - Modificator of the whole thing"}
function StarGate.CanTouch(data)
	if(data.BaseVelocity and data.Velocity and data.Time) then
		data.Delay = data.Delay or 0.04;
		local delay = data.Delay;
		local speed = data.BaseVelocity:Length(); -- Weapon of the canon
		-- Only apply this when we are moving into the shoot direction. Or it may collide with the vehicle, it is attached on
		if(math.abs(math.acos(data.Velocity:GetNormal():DotProduct(data.BaseVelocity:GetNormal()))) <= math.pi/2) then
			delay = data.Delay*speed/200;
		end
		if(data.Time+delay <= CurTime()) then
			return true;
		end
		return false;
	end
	return true;
end

--################# Calculates the velocity offset for a "blast" so it won't collide with it's cannon @aVoN
-- This is a same usefull function like the one above. This basically compares the shot's direction and the canon's velocity. According to these data, it will output am
-- offset value, so the cannon will never collide with it's own shot when moving fast
-- Input is a table: {Direction=Velocity_OfTheProjectile,Velocity=Cannons_Velocity,BoundingMax=MaximumBoundingBox_Distance_In_ShootDirection,Tolerance = MaximumOffset}
function StarGate.VelocityOffset(data)
	if(data.Direction and data.Velocity) then
		data.Tolerance = data.Tolerance or 200;
		data.BoundingMax = data.BoundingMax or 0;
		local dnorm = data.Direction:GetNormal();
		local vnorm = data.Velocity:GetNormal();
		return (data.BoundingMax+math.Clamp(vnorm:DotProduct(dnorm),0,1)*math.Clamp(data.Velocity:Length()/5,0,data.Tolerance))*dnorm;
	end
	return Vector(0,0,0);
end

--################# This is to avoid this ugly behaviour that vehicles spazz out when hit by a util.BlastDamage with more than 10 units of power @aVoN
function StarGate.BlastDamage(attacker,owner,pos,rad,dmg)
	-- Freeze vehicles or they spazzout
	local vehicles = {};
	for _,v in pairs(ents.FindInSphere(pos,rad)) do
		if(v:IsVehicle()) then
			vehicles[v] = {Velocity = v:GetVelocity(),Bones = {}}; -- Save old velocity of the vehicle and the bones, so a hit car does not appruply stops driving!
			for k=0,v:GetPhysicsObjectCount()-1 do
				local phys = v:GetPhysicsObjectNum(k);
				if(phys:IsValid()) then
					vehicles[v].Bones[k] = phys:GetVelocity();
					phys:EnableMotion(false);
				end
			end
		end
	end
	-- GCombat compatibility (Make things burst, yarr harr!)
	if(gcombat) then
		gcombat.hcgexplode(pos,rad,dmg,4);
	end
	-- CombatDamageSystem - Basically does the same like the the upper code for GCombat
	if(cds_damagepos) then
		cds_damagepos(pos,dmg/100,50,rad,attacker);
	end
	-- The real blast damage
	util.BlastDamage(attacker,owner,pos,rad,dmg);
	-- fix for stargates @ AlexALX
	-- and i know, its ugly, but better that nothing
	if (rad<200) then
		local dmginfo = DamageInfo();
		dmginfo:SetDamage(dmg);
		dmginfo:SetAttacker(attacker);
		dmginfo:SetInflictor(owner);
		dmginfo:SetDamageType(DMG_BLAST);
		dmginfo:SetDamagePosition(pos);
		for _,v in pairs(ents.FindInSphere(pos,1)) do
			if (v.IsStargate) then
				v:TakeDamageInfo(dmginfo);
			end
		end
	end
	-- Unfreeze all previosly frozen vehicles. Nees to be in a null-timer, or the Blast above isn't completely faded out this Frame and will affect the vehicles accidently
	timer.Simple(0,
		function()
			for e,v in pairs(vehicles) do
				e:SetVelocity(v.Velocity);
				for k=0,e:GetPhysicsObjectCount()-1 do
					local phys = e:GetPhysicsObjectNum(k);
					if(phys:IsValid()) then
						phys:EnableMotion(true);
						phys:SetVelocity(v.Bones[k]);
					end
				end
			end
			if(table.Count(vehicles) > 0) then
				-- Add a slight BlastDamage to vehicles to make them fall upside down or somthing like that
				util.BlastDamage(attacker,owner,pos,rad,10);
			end
		end
	);
end

--################# When the owner has been set to a SENT or it's "Parent" with ENT:SetVar("Owner",Player) on the cannon and ENT:SetOwner(Cannon) on the projectile, you will retrieve the correct Owner and Attacker for usage in a util.BlastDamage @aVoN
function StarGate.GetAttackerAndOwner(e)
	-- Owner/Attacker
	if(not (e and e:IsValid())) then return NULL,NULL end;
	local owner = e:GetOwner();
	local attacker = e;
	if(owner and owner:IsValid()) then
		if(type(owner) == "Player") then
			attacker = owner:GetActiveWeapon();
		elseif(owner.Owner) then
			owner = owner.Owner;
		end
	end
	if(not (attacker and attacker:IsValid())) then attacker = e end;
	if(not (owner and owner:IsValid())) then owner = e end;
	return attacker,owner
end

--################# A modification of Tad2020's GetAllConstrainedEntities function -This basically also fetches the worldentity and has a MaxPasses offset to save performance
function StarGate.GetConstrainedEnts(ent,max_passes,passes,entities,cons)
	if(not IsValid(ent)) then return {},{} end;
	local entities,cons = (entities or {}),(cons or {});
	local passes = (passes or 0)+1;
	if(max_passes and passes > max_passes) then return end;
	if(not entities[ent]) then
		if(not constraint.HasConstraints(ent)) then return {},{} end;
		entities[ent] = ent;
		for _,v in pairs(ent.Constraints) do
			if(not cons[v]) then
				cons[v] = v;
				for i=1,6 do
					local e = v["Ent"..i];
					if(e) then
						if(e:IsValid()) then
							StarGate.GetConstrainedEnts(e,max_passes,passes,entities,cons);
						elseif(not entities[e] and e:IsWorld()) then
							entities[e] = e;
						end
					end
				end
			end
		end
	end
	return table.ClearKeys(entities),table.ClearKeys(cons);
end

-- Fix for gmod duplicator and gmod saving system by AlexALX
-- it will not save stage of entity, but fix all bugs with crashes or broken duplications.
function StarGate.CAP_GmodDuplicator(ply,Data)
	Data.Class = scripted_ents.Get(Data.Class).ClassName

	local ent = ents.Create( Data.Class )
	if not IsValid(ent) then return false end

	if ( Data.Model ) then ent:SetModel( Data.Model ) end
	if ( Data.Angle ) then ent:SetAngles( Data.Angle ) end
	if ( Data.Pos ) then ent:SetPos( Data.Pos ) end
	if ( Data.ModelScale ) then ent:SetModelScale( Data.ModelScale, 0 ) end
	if ( Data.ColGroup ) then ent:SetCollisionGroup( Data.ColGroup ) end
	if ( Data.Name ) then ent:SetName( Data.Name ) end

	if (Data.GateSpawnerSpawned and Data.GateSpawnerID) then
		ent.GateSpawnerSpawned = true;
		ent:SetNetworkedBool("GateSpawnerSpawned",true);
		ent.GateSpawnerID = Data.GateSpawnerID;
	end

	--duplicator.DoGeneric( ent, data )
	ent:Spawn()
	ent:Activate()
	duplicator.DoGenericPhysics( ent, ply, Data )

	return ent;
end

--##################################
-- 				Deriving Entity Material/Color
--##################################

local meta = FindMetaTable("Entity");
if(meta and not meta.__SetMaterial) then

	--################# Set Derive @aVoN
	meta.__SetMaterial = meta.SetMaterial;
	meta.SetDerive = function(self,e)
		-- Unset old derived parent first
		if(IsValid(self.__DeriveParent)) then
			for k,v in pairs(self.__DeriveParent:GetDerived()) do
				if(v == self) then
					self.__DeriveParent.__DerivedEntities[k] = nil;
				end
			end
		end
		-- Set new derived parent
		if(IsValid(e) and e ~= self) then
			self.__DeriveParent = e;
			e.__DerivedEntities = e.__DerivedEntities or {};
			table.insert(e.__DerivedEntities,self);
			-- Copy Material and Color now!
			self:SetMaterial(e:GetMaterial());
			self:SetColor(e:GetColor());
			self:SetRenderMode(e:GetRenderMode());
		else
			self.__DeriveParent = nil; -- No Valid entity given
		end
	end

	--################# Gets the Parent, this entity derives from @aVoN
	meta.GetDerive = function(self)
		return self.__DeriveParent or NULL;
	end

	--################# Get Entities which are deriving from this ENT @aVoN
	meta.GetDerived = function(self)
		-- Just return a sequential table with onl valid entities!
		local t = {};
		for _,v in pairs(self.__DerivedEntities or {}) do
			if(IsValid(v)) then
				table.insert(t,v);
			end
		end
		return t;
	end

	--################# Sets the Nowdraw to the Derving entities too @aVoN
	meta.__SetNoDraw = meta.SetNoDraw;
	meta.SetNoDraw = function(self,...)
		if(not IsValid(self)) then return end;
		self:__SetNoDraw(...);
		if(self.__DerivedEntities) then
			for _,v in pairs(self.__DerivedEntities) do
				if(IsValid(v)) then
					v:__SetNoDraw(...);
				end
			end
		end
	end

	--################# SetMaterial @aVoN
	meta.SetMaterial = function(self,...)
		if(not IsValid(self)) then return end;
		-- Default behaviour
		self:__SetMaterial(...);
		-- Deriving Extra
		if(self.__DerivedEntities) then
			for _,v in pairs(self.__DerivedEntities) do
				if(IsValid(v)) then
					v:SetMaterial(...);
				end
			end
		end
	end

	--################# SetColor @aVoN
	meta.__SetColor = meta.SetColor;
	meta.SetColor = function(self,...)
		if(not IsValid(self)) then return end;
		-- Default behaviour
		self:__SetColor(...);
		-- Deriving Extra
		if(self.__DerivedEntities) then
			for _,v in pairs(self.__DerivedEntities) do
				if(IsValid(v)) then
					v:SetColor(...);
				end
			end
		end
	end

	--################# SetColor @aVoN
	meta.__SetRenderMode = meta.SetRenderMode;
	meta.SetRenderMode = function(self,...)
		if(not IsValid(self)) then return end;
		-- Default behaviour
		self:__SetRenderMode(...);
		-- Deriving Extra
		if(self.__DerivedEntities) then
			for _,v in pairs(self.__DerivedEntities) do
				if(IsValid(v)) then
					v:SetRenderMode(...);
				end
			end
		end
	end

	--################# K/V Setting @aVoN
	meta.__SetKeyValue = meta.SetKeyValue;
	meta.SetKeyValue = function(self,...)
		if(not IsValid(self)) then return end;
		-- Default behaviour
		self:__SetKeyValue(...);
		-- Deriving Extra
		if(self.__DerivedEntities) then
			local key = (({...})[1] or ""):lower();
			if(
				key == "renderamt" or
				key == "rendercolor" or
				key == "renderfx" or
				key == "rendermode"
			) then
				for _,v in pairs(self.__DerivedEntities) do
					if(IsValid(v)) then
						v:SetKeyValue(...);
					end
				end
			end
		end
	end

	--################# ent_fire commands @aVoN
	meta.__Fire = meta.Fire;
	meta.Fire = function(self,...)
		if(not IsValid(self)) then return end;
		-- Default behaviour
		self:__Fire(...);
		-- Deriving Extra
		if(self.__DerivedEntities) then
			local key = (({...})[1] or ""):lower();
			if(
				key == "color" or
				key == "alpha"
			) then
				for _,v in pairs(self.__DerivedEntities) do
					if(IsValid(v)) then
						v:Fire(...);
					end
				end
			end
		end
	end
end

local meta = FindMetaTable("Player");
if(meta and not meta.__GodEnable) then
	meta.__GodEnable = meta.GodEnable
	function meta:GodEnable()
	   self.__pGodMode = true
	   self:__GodEnable()
	end

	meta.__GodDisable = meta.GodDisable
	function meta:GodDisable()
	   self.__pGodMode = false
	   self:__GodDisable()
	end

	function meta:HasGodMode()
	   return self.__pGodMode or false;
	end

	hook.Add("PlayerDeath","Player.Death.ResetGod",function(ply)
		ply.__pGodMode = false;
	end)
end