/*
	Cloaking for GarrysMod10
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

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Cloaking"
ENT.Author = "aVoN"
ENT.WireDebugName = "Cloaking"

ENT.CAP_NotSave = true

ENT.Spawnable = false
ENT.AdminSpawnable = false

if CLIENT then

if (StarGate==nil or StarGate.MaterialCopy==nil) then return end
ENT.Material = StarGate.MaterialCopy("CloakMuzzle","effects/strider_bulge_dudv");

--################### Init @aVoN
function ENT:Initialize()
	self.Created = CurTime();
end

--################### Init @aVoN
function ENT:Draw()
	if(render.GetDXLevel() >= 90) then
		local size = self.Entity:GetNetworkedInt("size") + 100;
		local parent =  self.Entity:GetNWEntity("parent",self.Entity);
		if (IsValid(parent)) then
			local multiply = math.Clamp(parent:GetVelocity():Length()/30000,0,1)*math.Clamp((CurTime() - self.Created)/2,0,1);
			self.Material:SetFloat("$refractamount",multiply);
		end
		render.UpdateScreenEffectTexture();
		render.SetMaterial(self.Material);
		render.DrawSprite(self.Entity:GetPos(),size,size,Color(255,255,255,255));
	end
end
/*
-- HACKY HACKY HACKY HACKY HACKY @aVoN
-- Stops making players "recognizeable" if they are cloaked (E.g. by looking at them - Before you e.g. saw "Catdaemon - Health 100" if you lookaed at a cloaked player. Now, you dont see anything if he is cloaked
if(util._Cloak_TraceLine) then return end;
util._Cloak_TraceLine = util.TraceLine;
function util.TraceLine(...)
	local t = util._Cloak_TraceLine(...);
	if(t and IsValid(t.Entity)) then
		if(t.Entity:IsPlayer()) then
			if(t.Entity:GetNWBool("CloakCloaked",false)) then t.Entity = NULL end;
		end
	end
	return t;
end

-- New much better way without overriding color/alpha on players @ AlexALX
hook.Add("PrePlayerDraw","StarGate.Cloak", function(p)
		if (not IsValid(p)) then return end
		local cloaked = p:GetNWBool("CloakCloaked",NULL);
		if(cloaked == true) then
			return true -- cloak
		end
	end
);*/

-- Stops making players "recognizeable" if they are cloaked (E.g. by looking at them - Before you e.g. saw "Catdaemon - Health 100" if you lookaed at a cloaked player. Now, you dont see anything if he is cloaked
hook.Add("HUDDrawTargetID","StarGate.Cloak", function()
	local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end
	if (!trace.HitNonWorld) then return end

	if (trace.Entity:IsPlayer()) then
		if(trace.Entity:GetNWBool("CloakCloaked",false)) then return false end;
	end
end);

end

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end

--################# HEADER #################
AddCSLuaFile();

ENT.Sounds = {Hit=Sound("shields/shield_hit.mp3")};
ENT.IgnoreTouch = true; -- For staff blasts
ENT.NotTeleportable = true;
ENT.NoDissolve = true;
ENT.CDSIgnore = true; -- CDS Immunity
function ENT:gcbt_breakactions() end; ENT.hasdamagecase = true; -- GCombat invulnarability!

--################# SENT CODE ###############

util.AddNetworkString("Stargate.Cloak.Friends");

--################# Init @aVoN
function ENT:Initialize()
	self.Size = self.Size or 300; -- Make it by default at least fit for one player
	self.Parent = self.Entity:GetParent();
	self:SetNetworkedInt("size",self.Size);
	self:SetNWEntity("parent",self.Parent);
	self.Entity:SetMoveType(MOVETYPE_NONE);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:PhysicsInitSphere(self.Size); -- Seems even when it say "Sphere" to create a Cubic PhysObject
	self.Entity:DrawShadow(false);
	self.Entity:SetNotSolid(true);
	local classnames = StarGate.CFG:Get("cloaking","classnames",""):lower();
	self.Disallowed = {};
	for _,v in pairs(classnames:TrimExplode(",")) do
		self.Disallowed[v] = true;
	end
	local exceptions = StarGate.CFG:Get("cloaking","exceptions",""):lower();
	self.Exceptions = {};
	for _,v in pairs(exceptions:TrimExplode(",")) do
		self.Exceptions[v] = true;
	end
	local offset = Vector(self.Size,self.Size,self.Size);
	self.Entity:SetCollisionBounds(-1*offset,offset);
	-- To be compatible to Catdaemons shield and/or my staffweapon, I will use the same Table name and method like he does
	self.nocollide = {};
	if (self.Size>1) then
		for _,v in pairs(ents.FindInSphere(self.Entity:GetPos(),self.Size)) do
			local class = v:GetClass():lower();
			if(IsValid(v) and not v:IsWeapon() and not self.Disallowed[class]) then
				-- Should fix some fuck with adv dupe (but not all!)
				local movetype = v:GetMoveType();
				if(class ~= "prop_physics" and (not v:CreatedByMap() or movetype == MOVETYPE_VPHYSICS) or movetype == MOVETYPE_VPHYSICS and v:GetSolid() == SOLID_VPHYSICS) then
					if(not (movetype == MOVETYPE_NONE)) then -- Fix for wraith harvestere'd things
						self.nocollide[v] = true;
						-- Add deriving entities (e.g. Stargate Chevrons)
						for _,vv in pairs(v:GetDerived()) do
							self.nocollide[vv] = true;
						end
					end
				end
			end
		end
	end
	--################# Fetch all things in a sphere to make it nocollide
	self.nocollide[game.GetWorld()] = true;
	-- Constrained? Add constrained entities to the list, but only do 30 passes to save performances (must fit for most contraptions)
	if(self.Parent.CloakAttached and constraint.HasConstraints(self.Parent)) then
		for _,v in pairs(StarGate.GetConstrainedEnts(self.Parent,60)) do
			self.nocollide[v] = true;
			-- Add deriving entities (e.g. Stargate Chevrons)
			for _,vv in pairs(v:GetDerived()) do
				self.nocollide[vv] = true;
			end
			if (v.IsUniverseGate) then
				self.nocollide[v.Gate] = true;
				self.nocollide[v.Chevron] = true;
				for k,s in pairs(v.Symbols or {}) do
					self.nocollide[s] = true;
				end
			end
		end
	end

	-- After we got all entities for cloaking, cloak them now!
	for k,_ in pairs(self.nocollide) do
		if(IsValid(k) and k ~= self.Entity) then
			-- Cloak all entities
			if(not (IsValid(k.IsCloaked))) then
				self:Cloak(k,true);
			else
				self.nocollide[k] = nil;
			end
		end
	end

	if CPPI then
		local owner = self.Parent:GetVar("Owner");
		if(owner and owner:IsValid() and owner:IsPlayer() and owner.CPPIGetFriends) then
			local tbl = owner:CPPIGetFriends();
			if (type(tbl)=="table") then
				net.Start("Stargate.Cloak.Friends");
				net.WriteEntity(owner);
				net.WriteTable(owner:CPPIGetFriends());
				net.Broadcast();
			end
		end
	end

	-- The most important thing: Makes the cloak trigger Touch() events, even when it's not solid. Only call it here after we ran the shit above!
	self.Entity:SetTrigger(true);
	local phys = self.Entity:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:EnableCollisions(false);
	end
end

--################# Prevent PVS bug/drop of all networkes vars (Let's hope, it works) @aVoN
function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end;

--################# The most important part - This cloaks the props (if not already cloaked) @aVoN
function ENT:StartTouch(e)
	if(self.Size == 1) then return end; -- Just "cloak attached" props...
	if(not IsValid(e)) then return end;
	if(self.nocollide[e]) then return end; -- We have already cloaked this!
	if(IsValid(e.IsCloaked)) then return end; -- Cloaked by another (valid) cloaking gen
	if(self.Disallowed[e:GetClass():lower()]) then return end; -- Do not allow theses classes!
	if(e:GetMoveType() == MOVETYPE_NONE) then return end; -- Do not cloak stuff in a wraith harvester!
	-- Show cloaking fade on all props
	if(self.Parent.Owner ~= e) then
		self:FieldPenetrated(e);
	end
	if(not e.IgnoreTouch) then
		self:Cloak(e,true);
		-- Cloak deriving entities of this too! (E.g. the parented chevrons on stargates)
		for _,v in pairs(e:GetDerived()) do
			self:Cloak(v,true);
		end
		if (e.IsUniverseGate) then
			self:Cloak(e.Gate,true);
			self:Cloak(e.Chevron,true);
			for k,s in pairs(e.Symbols or {}) do
				self:Cloak(s,true);
			end
		end
	end
end

--################# This uncloakes the props (if not already uncloaked) @aVoN
function ENT:EndTouch(e)
	if(self.Size == 1) then return end; -- Just "cloak attached" props...
	if(not IsValid(e)) then return end;
	if(not self.nocollide[e]) then return end; -- Not cloaked by us!
	--if(not (e.IsCloaked and e.IsCloaked:IsValid() and e.IsCloaked == self.Entity)) then return end; -- Cloaked by another (valid) cloaking gen
	--if(e:IsWeapon() and e:GetParent():IsValid()) then return end; -- No weapons, someone holds
	self:Cloak(e,false);
	-- Cloak deriving entities of this too! (E.g. the parented chevrons on stargates)
	for _,v in pairs(e:GetDerived()) do
		self:Cloak(v,false);
	end
	if (e.IsUniverseGate) then
		self:Cloak(e.Gate,false);
		self:Cloak(e.Chevron,false);
		for k,s in pairs(e.Symbols or {}) do
			self:Cloak(s,false);
		end
	end
	-- Show cloaking fade on all props
	local cloak = self.Entity;
	if(self.Parent.Owner ~= e) then
		-- Doing that in a timer avoids ugly flickering
		timer.Simple(0.2,
			function()
				if(IsValid(cloak) and IsValid(e)) then
					self:FieldPenetrated(e,true);
				end
			end
		);
	end
end

--################# What shall we do now, when we are going to get deleted? @aVoN
function ENT:OnRemove()
	-- First of all, stop the touch thingies interfering!
	self.StartTouch = function() end;
	self.EndTouch = function() end;
	local uncloak_table = table.Copy(self.nocollide); -- Must be a copy, or it will fail if we are using self.nocollide directly: We are "indexing" it and at the same time we delete stuff from it. That was the actual "not uncloaking everything correctly" bug
	for k,_ in pairs(uncloak_table) do
		if(IsValid(k)) then
			self:Cloak(k,false);
			-- Uncloak deriving entities (e.g. for the chevrons on the stargate) - REMOVEd due to problems. Should not be necessary here anymore
			--[[
			for _,v in pairs(k:GetDerived()) do
				self:Cloak(v,false);
			end
			--]]
		end
	end
end

--################# When the field is penetrated, we make all cloaked props visible for a short moment @aVoN
function ENT:FieldPenetrated(e,check_last_penetrated)
	local time = CurTime();
	if(not e.CloakStart or (e.CloakStart and CurTime() - e.CloakStart > 2)) then
		for k,_ in pairs(self.nocollide) do
			if(k ~= e and k and k:IsValid() and (not check_last_penetrated or (time-(k.LastPenetrated or 0)) > 1.2)) then
				self:CloakingEffect(k,0.7);
				k.LastPenetrated = time;
			end
		end
	end
end

--################# Draw the cloaking effect @aVoN
function ENT:CloakingEffect(e,scale)
	local fx = EffectData();
	local pos = e:GetPos();
	fx:SetOrigin(pos);
	fx:SetStart(pos);
	fx:SetEntity(e);
	fx:SetScale(scale);
	util.Effect("cloaking",fx,true,true);
end

--################# Cloak an entity @aVoN
function ENT:Cloak(e,b)
	if(e:IsWeapon()) then return end;
	if((e:GetModel() or ""):find("*")) then return end; -- Do not cloak brushes (like athmospheres in spacebuild)
	local phys = e:GetPhysicsObject();
	local class = e:GetClass();
	if(e:GetCollisionGroup() == COLLISION_GROUP_PROJECTILE or phys:IsValid() or class == "prop_dynamic") then
		local time = CurTime();
		if((e.LastCloakEvent or 0) + 0.1 > time) then return end;
		e.LastCloakEvent = time;
		-- Undo our old timers
		local id = "cloak"..e:EntIndex();
		if(timer.Exists(id.."end1")) then
			timer.Destroy(id.."end1");
			if(e.OldAlpha and b) then
				local color = self:GetColor();
				e:SetColor(Color(color.r,color.g,color.b,e.OldAlpha));
				e:SetRenderMode(e.CloakRenderMode);
				--e:SetKeyValue("renderamt",e.OldAlpha); -- OLD METHOD
				e.OldAlpha = nil;
			end
		end

		if(timer.Exists(id.."end2")) then timer.Destroy(id.."end2") end;
		if(timer.Exists(id.."start")) then timer.Destroy(id.."start") end;
		if(timer.Exists(id.."matstart1")) then timer.Destroy(id.."matstart1") end;
		if(timer.Exists(id.."matstart2")) then timer.Destroy(id.."matstart2") end;

		-- Handle cloaking!
		if(b) then
			if(not e.OldAlpha) then
				local color = e:GetColor();
				-- Must be NW'ed, so cloaked props can be seen by the owner (if he wishes too) - Handled in the cloak effect
				e:SetNWVector("cloak_color",Vector(color.r,color.g,color.b));
				e:SetNWInt("alpha",color.a);
				e.OldAlpha = color.a; -- So we wont accidently take the color of a cloaked prop when it goes into field, fast out and back into it
			end
			e.CloakStart = time;
			if(self.Parent.ImmuneOwner and not e.CloakNoDraw) then
				local owner = self.Parent:GetVar("Owner");
				if(owner and owner:IsValid() and owner:IsPlayer()) then
					e:SetNWEntity("cloak_player",owner);
				end
			else
				e:SetNWEntity("cloak_player",self.Entity); -- Must be here as dummy SENT
			end
			if(self.Parent.PhaseShifting) then
				e.CloakCollisionGroup = e:GetCollisionGroup();
				e:SetCollisionGroup(COLLISION_GROUP_WORLD);
			end
			local alpha = 0;
			-- Some special SENTs need to get drawn. Alpha 0 stops drawing at all (even Lua ENT:Draw functions). Workaround for eg harvester
			if(self.Exceptions[e:GetClass()]) then alpha = 1 end;
			-- Avoids lag in multiplayer
			timer.Create(id.."start",0.1,1,
				function()
					if(IsValid(e)) then
						e.CloakRenderMode = e:GetRenderMode();
						e:SetRenderMode(RENDERMODE_TRANSALPHA);  -- Old Method - Rendermode may fuck up some visuals so we use SetColor instead
						--e:SetKeyValue("renderamt",alpha);  -- Old Method
						local color = e:GetColor();
						e:SetColor(Color(color.r,color.g,color.b,alpha));
						e.Material = e:GetMaterial();
						if (e:IsPlayer() or e:IsNPC()) then
							e.__SGCloacked = true;
							if (e:IsPlayer()) then
								e:SetNetworkedBool("CloakCloaked",true);
							end
							if (IsValid(e:GetActiveWeapon())) then
								e:GetActiveWeapon().WeaponRenderMode = e:GetActiveWeapon():GetRenderMode()
								if (e:GetActiveWeapon():GetMaterial()!="models/effects/vol_light001") then
									e:GetActiveWeapon().WeaponMaterial = e:GetActiveWeapon():GetMaterial();
								else
									e:GetActiveWeapon().WeaponMaterial = "";
								end
								e:GetActiveWeapon():SetRenderMode( RENDERMODE_TRANSALPHA )
								e:GetActiveWeapon():Fire( "alpha", alpha, 0 )
								local color = e:GetActiveWeapon():GetColor();
								e:GetActiveWeapon():SetColor(Color(color.r,color.g,color.b,alpha))
								timer.Create(id.."matstart1",2.0,1,function() if IsValid(e) then e:GetActiveWeapon():SetMaterial( "models/effects/vol_light001" ) end end)
							end
						end
						timer.Create(id.."matstart2",2.0,1,function() if IsValid(e) then e:SetMaterial( "models/effects/vol_light001" ) end end)
					end
				end
			);
			e.IsCloaked = self.Entity;
			self:CloakingEffect(e,2);
			self.nocollide[e] = true;
		else
			local delay = math.Clamp(time - (e.CloakStart or 0),0,2);
			-- Make it reset it's alpha
			local old_alpha = e.OldAlpha;
			local function reset_cloak(e)
				if(IsValid(e)) then
					if(e:IsPlayer() or e:IsNPC()) then old_alpha = 255 end; -- Should fix problems with harvesters
					--e:SetKeyValue("renderamt",old_alpha or 255); -- Old Method
					e:SetRenderMode(e.CloakRenderMode);
					local color = e:GetColor();
					e:SetColor(Color(color.r,color.g,color.b,old_alpha or 255));
					if ((e:IsPlayer() or e:IsNPC()) and IsValid(e:GetActiveWeapon())) then
						if (e:GetActiveWeapon().WeaponRenderMode!=nil) then
							e:GetActiveWeapon():SetRenderMode(e:GetActiveWeapon().WeaponRenderMode);
						end
						e:GetActiveWeapon():Fire("alpha", old_alpha, 0);
						local color = e:GetActiveWeapon():GetColor();
						e:GetActiveWeapon():SetColor(Color(color.r,color.g,color.b,old_alpha))
					end
					e.OldAlpha = nil;
				end
			end
			if (e:IsPlayer() or e:IsNPC()) then
				e.__SGCloacked = false;
				if (e:IsPlayer()) then
					e:SetNetworkedBool("CloakCloaked",false);
				end
				if (IsValid(e:GetActiveWeapon()) and e:GetActiveWeapon().WeaponMaterial!=nil) then
					e:GetActiveWeapon():SetMaterial(e:GetActiveWeapon().WeaponMaterial);
				end
			end
			e:SetMaterial(e.Material);
			timer.Create(id.."end1",delay-0.1,1,function() reset_cloak(e) end); -- The first uncloak (make sure things will be synched with the effect)
			timer.Create(id.."end2",delay+0.3,4,function() reset_cloak(e) end); -- The last effect - Make really, sure, everything has his correct alpha (For multiplayer to compensate lag)
			if(e.CloakCollisionGroup) then
				e:SetCollisionGroup(e.CloakCollisionGroup);
				e.CloakCollisionGroup = nil;
			end
			e.CloakStart = nil;
			e.IsCloaked = nil;
			self:CloakingEffect(e,-2);
			self.nocollide[e] = nil;
		end
	end
end

hook.Add("PlayerDeath","StarGate.Cloak.PlayerDeath",function(ply)
	ply.__SGCloacked = false;
	ply:SetNetworkedBool("CloakCloaked",false);
end)

hook.Add("PlayerSilentDeath","StarGate.Cloak.PlayerDeath",function(ply)
	ply.__SGCloacked = false;
	ply:SetNetworkedBool("CloakCloaked",false);
end)

hook.Add("PlayerSwitchWeapon", "StarGate.WeaponCloak.Changed", function(ply, oldWeapon, newWeapon)
	if (not ply or not IsValid(ply) or not ply:IsPlayer() or not IsValid(oldWeapon) or not IsValid(newWeapon)) then return nil end

	if (ply.__SGCloacked==true) then
		if (oldWeapon.WeaponMaterial!=nil) then
			oldWeapon:SetMaterial(oldWeapon.WeaponMaterial);
		end
		if (oldWeapon.WeaponRenderMode!=nil) then
			oldWeapon:SetRenderMode(oldWeapon.WeaponRenderMode);
		end
		oldWeapon:Fire("alpha", 255, 0);
		local color = oldWeapon:GetColor();
		oldWeapon:SetColor(Color(color.r,color.g,color.b,255))

		timer.Simple(0.05,function()
			if (IsValid(newWeapon)) then
				newWeapon.WeaponRenderMode = newWeapon:GetRenderMode()
				newWeapon.WeaponMaterial = newWeapon:GetMaterial();
				newWeapon:SetRenderMode( RENDERMODE_TRANSALPHA )
				newWeapon:Fire( "alpha", 0, 0 )
				newWeapon:SetMaterial( "models/effects/vol_light001" )
				local color = newWeapon:GetColor();
				newWeapon:SetColor(Color(color.r,color.g,color.b,0))
			end
		end)
	end
end)

end