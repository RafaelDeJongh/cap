/*
	Eventhorizon SENT for GarrysMod10
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

--################# Allowed for teleport? @aVoN
function ENT:Allowed(e,allow_parented)
	local class = e:GetClass();
	local phys = e:GetPhysicsObject();
	if(
		-- Must have a valid physics object and has to be unfrozen (except on crossbow_bolt or rpg_missile)
		(
			phys and phys:IsValid() and phys:IsMoveable() and
			-- Do not teleport parente stuff or it may crash the server
			(allow_parented or not e:GetParent():IsValid()) and
			(
				--Players
				(e:IsPlayer() and not e:InVehicle()) or
				-- Vehicles
				e:IsVehicle() or
				-- NPCs
				e:IsNPC() or
				-- Weapons
				e:IsWeapon() or
				-- Allow props and constraints
				(class:find("prop_[prv]") or class:find("phys_")) or
				-- SENT's but not stargates
				(e.Type ~= nil and not class:find("stargate_"))
			)
		) or
		-- Grenades from weapons are always allowed
		class == "npc_grenade_frag" or
		class == "rpg_missile" or
		class == "grenade_ar2" or
		class == "crossbow_bolt" or
		class == "npc_satchel" or
		class == "prop_combine_ball" or
		class == "hunter_flechette" or -- Hunter flechette
		class == "grenade_helicopter" or -- Heli bombs
		class == "weapon_striderbuster" or -- Magnusson device
		class == "grenade_spit" -- Antlion poison blasts
	) then
		return true;
	end
	return false;
end

--################# Bones for vehicle teleportation @aVoN
function ENT:GetBones(e,pos)
	-- And as well, get the bones of an object
	local bones = {};
	if(e:IsVehicle() or e:GetClass() == "prop_ragdoll") then
		for i=0,e:GetPhysicsObjectCount()-1 do
			local bone = e:GetPhysicsObjectNum(i);
			if(bone:IsValid()) then
				table.insert(bones,{
					Entity=bone,
					Position=e:WorldToLocal(bone:GetPos()),
					Velocity=e:WorldToLocal(pos+bone:GetVelocity()),
				});
			end
		end
	end
	return bones;
end

--################# Retrieves an entities "Lenght", so it won't get stuck in a wall if you teleport it @aVoN
function ENT:GetEntityLenght(e,pos,fwd,lenght)
	if(lenght == 4096) then return 4096 end; -- Just stops CPU extensive calcs below if we are bigger than 4096.
	local offset = self.Entity:WorldToLocal(pos).x;
	local radius = e:BoundingRadius(); -- We use the bounding radius if calculation using the "better way" is too small.
	if(offset+radius <= lenght) then return lenght end; -- We are smaller compared to our previous lenght - So this object does not increase the size: Do not calc the stuff below because it might be CPU extensive.
	-- This is now a correct calculation of the length
	return math.Clamp(self.Entity:WorldToLocal(e:NearestPoint(pos+fwd)).x+offset,lenght,4096);
end

function ENT:GetAllGates(closed)
	local sg = {};
	for _,v in pairs(ents.FindByClass("stargate_*")) do
		if(v.IsStargate and not (closed and (v.IsOpen or v.Dialling))) then
			table.insert(sg,v);
		end
	end
	return sg;
end

function ENT:BlockedCFD(target,e)
	if (not IsValid(target)) then return false; end
    local pos = target:GetPos();
    for _,v in pairs(ents.FindByClass("call_forwarding_device")) do
     local e_pos = v:GetPos();
     local dist = (e_pos - pos):Length();
     if(dist <= 1000) then
	     local add = true;
	     for _,gate in pairs(self:GetAllGates()) do
	       if(gate ~= target:GetParent() and (gate:GetPos() - e_pos):Length() < dist) then
		       add = false;
		       break;
		     end
	     end
	     if(add and e:IsValid() and (e:IsPlayer() or e:IsNPC()))then
		     if(not target.Outbound and target.IsOpen and v.Activated)then
              return true;
           end
	     end
     end
    end
	return false;
end

--################# Prepares the teleport for the entity e and the attached entities a @aVoN
function ENT:PrepareTeleport(t)
	-- The BaseEntity (the one, which came first to the eventhorizon)
	local e = t.Entity;
	-- EventHorizons (Me,Target)
	local g ={self.Entity,self.Target}
	-- teleport us to the same passed gate, if the modul is exist and activated on he target gate @Llapp
	for _,gate in pairs(self:GetAllGates()) do
		if(gate == self.Target:GetParent()) then
       local pos = self.Target:GetPos();
	     for _,v in pairs(ents.FindByClass("call_forwarding_device")) do
		     local e_pos = v:GetPos();
		     local dist = (e_pos - pos):Length();
		     if(dist <= 1000) then
			     local add = true;
			     for _,gate in pairs(self:GetAllGates()) do
			       if(gate ~= self.Target:GetParent() and (gate:GetPos() - e_pos):Length() < dist) then
				       add = false;
				       break;
				     end
			     end
			     if(add and e:IsValid() and (e:IsPlayer() or e:IsNPC()))then
				     if(not gate.Outbound and gate.IsOpen and v.Activated)then
	              g ={self.Entity,self.Entity}
	            end
			     end
		     end
	     end
 		end
	end
	-- Positions of the EventHorizons and BaseEntity
	local p= {e:GetPos(),g[1]:GetPos(),g[2]:GetPos()};
	-- Angles
	local AngleDelta = g[2]:GetAngles()-g[1]:GetAngles();
	-- Return table
	local ret = {Attached={}};
	-- We need this for length calculation, so props wont get stuck after teleportation in a wall on the other side
	local fwd = self.Entity:GetForward()*4096; -- You should never have any bigger props - If yes, you seriously fail at using the gates
	local lenght = self:GetEntityLenght(e,p[1],fwd,0);
	-- ######### Calculate new positions,angles and velocity for attached
	for _,v in pairs(t.Attached) do
		local vel = v:GetVelocity();
		local ang = v:GetAngles();
		local pos = v:GetPos();
		local data = {
			Entity=v,
			Position={
				New=e:WorldToLocal(pos),
				Old=pos,
			},
			Velocity={
				New=e:WorldToLocal(vel+p[1]),
				Old=vel,
			},
			Angles={
				Old=ang,
				New=ang+AngleDelta,
				Delta=AngleDelta,
			},
			Bones=self:GetBones(v,pos),
		}
		lenght = self:GetEntityLenght(v,pos,fwd,lenght);
		table.insert(ret.Attached,data);
	end
	-- ######### Calculate new positions,angles and velocity for constraints
	-- No we don't do. Why? I found out, constraints are at the same placer - always. so, don't change them
	-- ######### Now change the base-entity itself
	local rotation_matrix = MMatrix.RotationMatrix(g[2]:GetUp(),180); -- It will rotate the new positions and velocity correctly to the enter/exit positions.
	local vel = e:GetVelocity();
	local ang = e:GetAngles();
	local new_pos = g[1]:WorldToLocal(p[1]); new_pos.x = 0; -- Making the x coordinate = 0 makes the prop getting teleported directly on the EH!
	ret.Entity={
		Entity=e;
		Position={
			New=g[2]:LocalToWorld(rotation_matrix*new_pos),
			Old=p[1],
		},
		Velocity={
			New=g[2]:LocalToWorld(rotation_matrix*g[1]:WorldToLocal(vel + p[2])) - p[3],
			Old=vel,
		},
		Angles={
			Old=ang,
			New=ang+AngleDelta,
			Delta=AngleDelta,
		},
		Bones=self:GetBones(e,p[1]),
	}
	-- ######### Calculate the heigh of the object, so it won't get stuck on the other sides ground
	-- FIXME: Seemed sometimes not to work properly. Invent a new check!
	local height = g[1]:BoundingRadius();
	local dir = Vector(0,0,height);
	local trace={
		-- On our side
		util.QuickTrace(p[1],-1*dir,g[1]:GetTraceIgnoredEntities(e)),
		-- On the other event horizon
		util.QuickTrace(ret.Entity.Position.New+dir,-2*dir,g[2]:GetTraceIgnoredEntities()),
	}
	if(trace[1].Hit and trace[2].Hit) then
		local add_height = 5 + (1 - 2*trace[2].Fraction + trace[1].Fraction)*height;
		ret.Entity.Position.New = ret.Entity.Position.New + Vector(0,0,add_height);
	end
	-- ######### Calculate the lenght offset
	-- Do a similar thing now for the length/size of our "thing" we put into the eventhorizon, or it might get stuck on the other side (what we seriously do not want). - I hade some bad experiences with my puddle jumper getting stucked in a wall
	local dir = g[2]:GetForward();
	local trace = util.QuickTrace(p[3]-20*dir,-4096*dir,g[2]:GetTraceIgnoredEntities()); -- The -20*dir is a sort of "grace"-offset to make sure it does not collide really with anything
	ret.Entity.Position.New = ret.Entity.Position.New + dir*math.Clamp(lenght - (1-trace.Fraction)*4096,0,4096);
	return ret;
end

--################# Get's every entity which should be ignored by a trace. For example, using it on the event horizon causes also getting the gate and the iris @aVoN
function ENT:GetTraceIgnoredEntities(...)
	local t = {};
	for _,v in pairs({...}) do
		table.insert(t,v);
	end
	table.insert(t,self.Entity);
	local parent = self.Entity:GetParent();
	if(IsValid(parent)) then
		table.insert(t,parent);
		if(IsValid(parent.Iris)) then
			table.insert(t,parent.Iris);
		end
	end
	return t;
end

--################# Retrieves the valid entites for a teleport from a given entity @aVoN
function ENT:GetEntitiesForTeleport(e)
	if(self:Allowed(e)) then
		local entities = {};
		--################# Attached Props and constraints
		local attached = StarGate.GetConstrainedEnts(e); -- Based on Tad2020's faster method to catch attached entities
		if(not attached) then attached = {e} end;
		--################# Filter specific entities
		-- FIXME: Check, if the stuff with "gmod_spawner" works right. I shrinked this function to have 1 instead of 3 for loops
		for _,v in pairs(attached) do
			if(v == self:GetParent()) then return false end; -- No stuff which is attached to the gate
			if(v:GetClass() == "gmod_spawner") then -- Do not teleport stuff which is attached to an gmod-spawner
				return {Entity=e,Attached={}};
			elseif(self:Allowed(v,true)) then -- Valid prop? If not, do not teleport the whole contraption!
				if(v ~= e and not IsValid(v:GetParent())) then -- test fix for not teleport parents by AlexALX (ent should be teleported with its parent automatically)
					table.insert(entities,v);
				end
			else
				return false;
			end
		end
		return {Entity=e,Attached=entities};
	end
	return false;
end

--################# Teleportation function for the EntityTables @aVoN
function ENT:TeleportEntity(t,base,basedata)
	-- Quick reference
	local g = {self.Entity,self.Target};
	local pos = t.Position;
	local bones = t.Bones;
	local e = t.Entity;
	local ang = t.Angles;
	local vel = t.Velocity;
	if(e == base) then -- Prop is the BaseEntity.
		--This thing here fixes the crashing bug for StaffBlasts and Drones, when they fly through the gate and collide before they actually were teleported (or during that time)
		-- I will not do this on the other entities to save resources because this is mainly for shots wich aren't constrained to any other things.
		-- Furthermore thirdparty SENTs will take their profits too with this method when they are "blasts" or "shots". And I actually do not know any Entity which can be constrained
		-- and uses Touch/StartTouch/EntTouch/PhysicsCollide and removes itself when this happens besides these "shots"
		local keys = {"Touch","StartTouch","EndTouch","PhysicsCollide","PhysicsSimulate"}; -- Backing up old functions
		local backup = {};
		for _,v in pairs(keys) do
			if(e[v]) then
				backup[v] = e[v];
				e[v] = function() end; -- Dummy
			end
		end
		timer.Simple(0.2,
			function()
				if(IsValid(e)) then
					for k,v in pairs(backup) do
						e[k] = v;
					end
				end
			end
		);
	else
		pos.New = base:LocalToWorld(pos.New);
		vel.New = base:LocalToWorld(vel.New)-base:GetPos();
		--pos.New = LocalToWorld(pos.New,basedata.Angles.New,basedata.Position.New,basedata.Angles.New);
	end
	-- ######### Player teleport
	if(e:IsPlayer()) then
		-- Start teleport effect
		umsg.Start("StarGate.CalcView.TeleportEffectStart",e);
		umsg.End();
		e.__PreviousMoveType = e.__PreviousMoveType or e:GetMoveType();
		e:SetMoveType(MOVETYPE_NOCLIP); -- Needed, or person dont get teleported correctly
		timer.Simple(0,
			function()
				if(IsValid(e)) then
					e:SetMoveType(e.__PreviousMoveType or 2);
					e.__PreviousMoveType = nil;
				end
			end
		);
		e:SetPos(pos.New);
		e:SetEyeAngles(e:GetAimVector():Angle() + Angle(0,ang.Delta.y+180,0));
		e:SetVelocity(vel.New-vel.Old);
	-- ######### Vehicle teleport
	elseif(e:IsVehicle()) then
		local ang = ang.New + Angle(0,180,0);
		-- This is a workaround: Vehicles should never have a pitch or roll if entering or exiting a gate (prevents them from spawning in ground and bug around)
		ang.r = 0;
		ang.p = 0;
		self:CleanBufferVars(e)
		e.___dir = 1;
		e:SetAngles(ang);
		e:SetPos(pos.New);
		-- ######### Move the bones of the entity
		if(bones) then
			for _,v in pairs(bones) do
				v.Entity:SetPos(e:LocalToWorld(v.Position));
				v.Entity:SetVelocity(e:LocalToWorld(v.Velocity)-e:GetPos());
			end
		end
	-- ######### normal Entity teleport (The "rest")
	else
		-- ######### Some special entity behaviour
		local class = e:GetClass();
		local immunity = e.__StargateTeleport;
		e = StarGate.Teleport:__Run(class,e,pos.New,ang.New,vel.New,pos.Old,ang.Old,vel.Old,ang.Delta);
		e.__StargateTeleport = immunity; -- Avoids a bug if we create a new prop (like it went wrong on the RPG missiles)
		if(not IsValid(e)) then return {} end; -- Must be a table, because in ENT:Teleport we "index" this entity (or we atleast try to)
		self:CleanBufferVars(e)
		e.___dir = 1;
		local phys = e:GetPhysicsObject();
		-- ######### Teleport
		e:SetPos(pos.New);
		if(e:IsNPC()) then ang.Delta.p = 0 ang.Delta.r = 0 end -- Remove roll and pitch from NPCs
		e:SetAngles(ang.Old + ang.Delta + Angle(0,180,0));
		e:SetVelocity(-1*vel.Old+vel.New) -- Substract old velocity and add the new
		-- Because this doesn't have always an effect, we also apply force
		if(phys:IsValid()) then
			local ma = phys:GetMass();
			timer.Simple(0.05,function() if phys:IsValid() then phys:ApplyForceCenter(vel.New*ma) end end); -- Apply power so it has velocity again
		end

		-- ######### Move the bones of the entity
		if(bones) then
			for _,v in pairs(bones) do
				v.Entity:SetPos(e:LocalToWorld(v.Position));
				v.Entity:SetVelocity(e:LocalToWorld(v.Velocity)-e:GetPos());
			end
		end
	end
	return e;
end

--################# Teleports a whole contraption based on the entity given here @aVoN
function ENT:Teleport(e,block,attached)
	if(not attached) then
		attached = self:GetEntitiesForTeleport(e);
	end
	-- We are blocked. Kill this entity
	if(block) then
		self:DestroyEntity(e);
	end
	if(attached) then
		if(block) then
			-- Kill attached entities
			for _,v in pairs(attached.Attached) do
				self:DestroyEntity(v);
			end
		else
			--################# The immunity table, so an event horizon will not destroy an entity, which just exited an EH to slowly
			local immunity = {__TARGET=self.Target,__LastTeleport=CurTime()};
			immunity[e] = true;
			e.__StargateTeleport = immunity; -- Register this table to the base entity
			--################# Prepared teleportation - Modify angles, positions and velocity
			local entities = self:PrepareTeleport(attached);
			-- Teleport base Entity first (all other entities are "local" to that ent!
			self:TeleportEntity(entities.Entity,e);
			-- And now for all attached props too
			for _,v in pairs(entities.Attached) do
				local ent = self:TeleportEntity(v,e,entities.Entity);
				immunity[ent] = true;
				ent.__StargateTeleport = immunity;
			end
		end
	end
end

--################# The entity which should get teleported has been destroyed: Shield blocked or wrong side entered? @aVoN
function ENT:DestroyEntity(e)
	if(not IsValid(e)) then return end;
	if(e:IsPlayer()) then
		e:SetParent(); -- Unparent, when he is maybe parented to a SENT
		if (not e:HasGodMode()) then
			e:StripWeapons();
			e:KillSilent();
		end
	else
		if(e:IsVehicle()) then
			-- If it's a vehicle, kill the driver of it
			for _,v in pairs(player.GetAll()) do
				if(v:GetParent() == e) then
					if (not v:HasGodMode()) then
						v:StripWeapons();
						v:KillSilent();
					end
					break;
				end
			end
		elseif(e:GetClass() == "rpg_missile") then -- RPG Missile? Stop annoying looping sound
			e:StopSound("Missile.Accelerate");
		end
		e:Remove();
	end
end
