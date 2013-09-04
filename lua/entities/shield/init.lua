/*
	Stargate Shield for GarrysMod10
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

--################# HEADER #################
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
AddCSLuaFile("modules/bullets.lua");
include("shared.lua");
include("modules/bullets.lua");

ENT.Sounds = {Hit=Sound("shields/shield_hit.mp3")};
ENT.NotTeleportable = true;
ENT.NoDissolve = true;
ENT.CDSIgnore = true; -- CDS Immunity
function ENT:gcbt_breakactions() end; ENT.hasdamagecase = true; -- GCombat invulnarability!

-- Register shield SENT to the trace class (everything else is handled in bullets.lua)
StarGate.Trace:Add("shield",
	function(e,values,trace,in_box)
		if(not e.Parent.Depleted) then
			if((e.Parent.Containment and in_box) or (not e.Parent.Containment and not in_box)) then
				return true;
			end
		end
	end
);

--################# SENT CODE ###############

--################# Init @aVoN
function ENT:Initialize()
	self.Size = self.Size or 80; -- Make it by default at least fit for one player
	self.Created = CurTime();
	self.Entity:SetMoveType(MOVETYPE_NONE);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:PhysicsInitSphere(self.Size); -- Seems even when it say "Sphere" to create a Cubic PhysObject
	self.Entity:DrawShadow(false);
	self.Entity:SetTrigger(true); -- The most important thing: Makes the shield trigger Touch() events, even when it's not solid
	self.Entity:SetNotSolid(true);
	self.AllowContainment = StarGate.CFG:Get("shield","allow_containment",true);
	local offset = Vector(self.Size,self.Size,self.Size);
	self.Entity:SetCollisionBounds(-1*offset,offset);
	-- To be compatible to Catdaemons shield and/or my staffweapon, I will use the same Table name and method like he does
	self.nocollide = {};
	self.HasHitShield = {};
	self.Parent = self.Entity:GetParent();
	self.IsAvonShield = true;
	self.AntiNoclip = false;

	self.TraceSize = Vector(self.Size, self.Size, self.Size);
	self.Entity:SetNetworkedVector("TraceSize",self.TraceSize);

	-- Imunity to the owner?
	if(self.Parent.ImmuneOwner) then
		self.nocollide[self.Parent.Owner] = true;
	end
	if(self.Parent.DrawBubble) then
		self.Entity:SetNWInt("size",self.Size); -- Necessary for the bubble effect.
		local e = self.Entity;
		-- Wait a little time, until the NW data from above is synched with the client
		timer.Simple(0.3,
			function()
				if(e and e:IsValid()) then
					e:DrawBubbleEffect();
				end
			end
		);
	end
	local multi_shield = StarGate.CFG:Get("shield","multiple_shields",false); -- Allow multiple shields?
	--################# Fetch all things in a sphere to make it nocollide
	for _,v in pairs(ents.FindInSphere(self.Entity:GetPos(),self.Size)) do
		if(not multi_shield and v ~= self.Entity and v:GetClass() == "shield") then
			-- We are smaller - We have to go :(
			if(v.Size >= self.Size) then
				self.Parent:Status(false);
				self.Entity.Disable = true;
				self.Entity:Remove();
				return;
			else
				-- You are smaller! Yarhar, die!
				v.Parent:Status(false);
				v.Disable = true;
				v:Remove();
			end
		end
		self.nocollide[v] = true;
		v.CDSIgnore = true; -- Make it immuned to damage by CDS!
	end
	self.Passed = {};
	self:AddAthmosphere(); -- Add athmosphere to the shield (if turned on in on a planet or in an athmosphere)
	-- When we checked new things for "Collision or no Collision", we put them in here to be sure not to check again (speedup!)
	self.nocollide[game.GetWorld()] = true;
	-- Constrained? Add constrained entities to the list, but only do 10 passes to save performances (must fit for most contraptions)
	if(constraint.HasConstraints(self.Parent)) then
		local entities = StarGate.GetConstrainedEnts(self.Parent,10);
		if(entities) then
			for _,v in pairs(entities) do
				self.nocollide[v] = true;
				v.CDSIgnore = true; -- Make it immuned to damage by CDS!
			end
		end
	end
	-- Fixes a bug with "draw-on-passing". Sents who aren't awake do not trigger Touch! So wake them!
	for k,_ in pairs(self.nocollide) do
		if(k:IsValid()) then
			local phys = k:GetPhysicsObject();
			if(phys:IsValid()) then
				phys:Wake();
			end
		end
	end
	local phys = self.Entity:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:EnableCollisions(false);
	end
end

function ENT:GetTraceSize()
	return self.TraceSize;
end

--################# Prevent PVS bug/drop of all networkes vars (Let's hope, it works) @aVoN
function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end;

--################# Draw bubble effect, when turning it off @aVoN
function ENT:OnRemove()
	self:RemoveAthmosphere();
	self.GettingDeleted = true;
	for v,_ in pairs(self.nocollide) do
		if(IsValid(v)) then
			v.CDSIgnore = nil; -- Remove CDS immunity from the props again!
		end
	end
	if(IsValid(self.Parent) and not self.Parent.Depleted) then
		-- Has to be drawn on the shield emitter!
		self.DrawBubbleEffect(self.Parent,true);
	end
end

--################# StartTouch @aVoN
function ENT:StartTouch(e)
	if(not IsValid(self.Parent)) then return end;
	if(not IsValid(e)) then return end;
	-- This starts the effect on players who own the shield, but won't reflect them
	if(self.Parent.Containment and self.AllowContainment) then
		self.nocollide[e] = true;
	end
	if(self.nocollide[e]) then
		e.CDSIgnore = true; -- Make it immuned to damage by CDS!
	end
	if(self.Parent.ImmuneOwner and e == self.Parent.Owner) then
		self:HitEffect(e,e:LocalToWorld(e:OBBCenter()),5);
	elseif(self.Parent.PassingDraw and (self.nocollide[e] or (self.Parent.Containment and self.AllowContainment))) then
		if(self.Created + 0.2 < CurTime()) then
			-- Fixes a bug, where the "Draw on Passing" effect appears just right after the shield depleted and its now loaded with full strength (activbated) again
			if(self.HasHitShield[e]) then return end;
			self.HasHitShield[e] = true;
			-- When something is allowed to pass the shield, shall the effect be drawn?
			self:HitEffect(e,e:LocalToWorld(e:OBBCenter()),5);
		end
	end
end

--################# When something got into the shield and is "reflected constantly" we don't want it to take energy more than one time
function ENT:EndTouch(e)
	if(self.GettingDeleted) then return end; -- Prevents the "Draw on Passing" effect, if a shield is getting depleted (Stops client crashing)
	if(not IsValid(self.Parent)) then return end;
	if(self.Parent.Depleted) then return end; -- Prevents the "Draw on Passing" effect, if a shield is getting depleted (Stops client crashing)
	self.HasHitShield[e] = nil;
	-- Fixes a few bugs: E.g. if you delete a prop it will call this function before it is invalid => It will draw the "DrawOnPassing" effect but the prop is deleted.
	timer.Simple(0,
		function()
			if(not IsValid(self) or not IsValid(self.Parent) or not e:IsValid()) then return end;
			-- This starts the effect on players who own the shield, but won't reflect them
			if(self.Parent.ImmuneOwner and e == self.Parent.Owner) then
				self:HitEffect(e,e:LocalToWorld(e:OBBCenter()),5);
			elseif(self.nocollide[e]) then
				e.CDSIgnore = nil; -- Remove CDS immunity!
				if(self.Parent.Containment and self.AllowContainment) then
					self:Touch(e,true);
				elseif(self.Parent.PassingDraw) then
					self:HitEffect(e,e:LocalToWorld(e:OBBCenter()),5);
				end
			end
		end
	);
end

--################# The most important part - Recognizes entering props and reflects them @aVoN
function ENT:Touch(e,override)
	-- fix for player, when touch shield, it will be like sphere, not box.
	if not e.IgnoreShield and IsValid(e) and not override and e:GetPos():Distance(self.Entity:GetPos())>self.Size then self:EndTouch(e); self:StartTouch(e); return end
	-- it have small bug in containment mode (player sucks into the shield as box), maybe later will fix

	if(not e or (self.nocollide[e] and not override) or e.IgnoreShield) then return end;

	if(not self.Parent:IsValid()) then
		self.Entity:Remove();
		return;
	end
	if(self.Parent.Containment and self.AllowContainment and not override) then return end;

	if(not self.Passed[e]) then
		self.Passed[e] = true;
		local parent = e:GetParent();
		if(
			not e:IsValid() or -- Not valid - HUH? How did this then touched us?
			self.nocollide[e:GetOwner()] or self.nocollide[parent] or -- For shots started from the inside like CombineBalls
			(e:GetPos()-self.Entity:GetPos()):Length() <= self.Size/2 or -- Entity collided just inside the shield, and that in half-radius - In most cases, owner of the shield spawned it @aVoN
			IsValid(parent) -- Do not reflect parented props - Simply ignore them!
		) then
			self.nocollide[e] = true;
			e.CDSIgnore = true; -- Add CDS immunity!
			return;
		end
	end
	-- Bounce
	if(self.Parent.Strength > 0) then
		local cons_check = ((e.LastConstraintCheck or 0)+2 < CurTime());
		self:Reflect(e,not cons_check);
		-- Reflect a bit more (like ships )- so they won't take the complete energy of a shield when colliding and it will "really" get reflected (more force)
		if(constraint.HasConstraints(e) and cons_check) then
			local time = CurTime();
			local entities = StarGate.GetConstrainedEnts(e,3); -- Maxcheck 3 seems to be OK
			for _,v in pairs(entities) do
				if(v ~= e) then
					self:Reflect(v,true);
				end
				v.LastConstraintCheck = time;
			end
		end

		-- for support another addons/ents
		if (e.CAPOnShieldTouch) then
			e:CAPOnShieldTouch(self);
		end

		-- cartman300 code, edited by AlexALX
		if self.AntiNoclip then
	        if (e:IsPlayer() and e:GetMoveType()==MOVETYPE_NOCLIP) then
	            e:SetMoveType(MOVETYPE_WALK)
	            timer.Simple(0.2, function()
	            	if (IsValid(e)) then
	                	e:SetMoveType(MOVETYPE_NOCLIP)
	              	end
	            end);
	        end
	    end
	else
		-- Make the shield not touching anything anymore when enegry = 0
		if(not self.Parent.Depleted) then
			--self.Parent:SetOverlayText("Shield (Depleted)\nSize: "..self.Size);
			self:DrawBubbleEffect(true); -- Set turnoff effect
			self.Parent:EmitSound(self.Parent.Sounds.Disengage,90,math.random(90,110));
			self.Parent.Depleted = true;
			self.Entity:SetNWBool("depleted",true); -- For the traceline class - Clientside
			self.Entity:SetTrigger(false);
			self:RemoveAthmosphere();
		end
	end
end

--################# Reflect the thing @aVoN
function ENT:Reflect(e,do_not_draw_hit)
	local velo = e:GetVelocity();
	local IS_NPC = e:IsNPC();
	if(not IS_NPC and velo == Vector(0,0,0)) then return end; -- Not moving = no collision!
	local class = e:GetClass();
	local e_pos = e:LocalToWorld(e:OBBCenter());
	local pos = self.Entity:GetPos();
	local phys = e:GetPhysicsObject();
	local normal = (e_pos-pos):GetNormalized();
	if(self.Parent.Containment) then normal = -1*normal end; -- It's a containment field. Don't let anyone out!
	-- First, we trigger the Entity's Touch trigger and make sure, the shield and the entity are synchronized (Makes staffblasts explode where they hit the shield)
	if(e.Touch) then e:Touch(self.Entity) end
	if(e.StartTouch) then e:StartTouch(self.Entity) end;
	-- Now, we will override the Entitiy's ENT:PhysicsSimulate() function for a moment (To e.g. reflect Catdaemons shuttle or other SENTs which otherwise wouldn't get reflected)
	if(e.PhysicsSimulate and not e.AlreadyOverwritten) then
		local old_PhysicsSimulate = e.PhysicsSimulate;
		e.AlreadyOverwritten = true;
		e.PhysicsSimulate = function() end;
		-- Reset old
		timer.Simple(1,
			function()
				if(e and e:IsValid()) then
					e.PhysicsSimulate = old_PhysicsSimulate;
					e.AlreadyOverwritten = nil;
				end
			end
		);
	end
	-- Props
	if(phys:IsValid() and not (IS_NPC or e:IsPlayer())) then
		-- Anyone holds this object (Makes theses MingeBags unavailable to move props with physgun into the shield with the intention to exploit it)
		if(e:IsPlayerHolding()) then
			local id = e:EntIndex();
			phys:EnableMotion(false);
			timer.Create("Ungrab"..id,0.2,0,
				function()
					if(e and phys and e:IsValid() and phys:IsValid()) then
						if(e:IsPlayerHolding()) then return end;
						phys:EnableMotion(true);
						phys:Wake();
					end
					timer.Destroy("Ungrab"..id);
				end
			);
			return;
		end
		-- Removes all old velocity from it before
		phys:EnableMotion(false);
		phys:EnableMotion(true);
		phys:Wake();
		-- Now apply force!
		phys:ApplyForceOffset(normal*phys:GetMass()*1000,e_pos-20*normal);
	elseif(class == "rpg_missile") then
		e:SetLocalVelocity(normal*1000);
		e:SetAngles(normal:Angle());
		e:SetHealth(0); -- Take his health
		-- Shoot a bullet on it (Catdaemons Idea), to make it fall down
		self.Entity:FireBullets({Num=1,Src=e_pos,Dir=Vector(0,0,0),Spread=Vector(0,0,0),Tracer=0,Force=1,Damage=100});
		e.IgnoreShield = true; -- Do not register it anymore
	else
		local vel = normal*600;
		if(class=="crossbow_bolt") then
			vel = normal*1000;
		end
		e:SetLocalVelocity(vel);
	end
	-- Make the player killable by his own shot
	if(class == "crossbow_bolt" or class == "rpg_missile" or class == "prop_combine_ball") then
		e:SetOwner(self.Entity);
	end
	if(not do_not_draw_hit) then
		self:HitShield(e,e_pos,phys,class,normal);
	end
end

--################# Draws an hiteffect, drains energy and makes the baseprop "wobbly" @aVoN
function ENT:HitShield(e,pos,phys,class,normal)
	-- Zapping
	local fx = EffectData();
	fx:SetStart(e:GetPos());
	fx:SetOrigin(pos);
	fx:SetScale(10);
	fx:SetMagnitude(10);
	fx:SetEntity(e);
	util.Effect("TeslaHitBoxes",fx,true,true);
	-- Hit effect
	if(not self.HasHitShield[e]) then
		self.HasHitShield[e] = true;
		local strength = 5;
		if(phys and phys:IsValid()) then
			strength = math.ceil(phys:GetMass()*e:GetVelocity():Length()/20000);
		end
		-- Draw the hiteffect- But in that function.
		self:HitEffect(e,pos,strength);
		-- Drain energy
		if(not (e:IsNPC() or e:IsPlayer() or class=="rpg_missile")) then
			self.Parent:Hit(strength,normal,pos);
		end
	end
end

--################# Draw the Hit Effect @aVoN
function ENT:HitEffect(e,pos,strength)
	-- Hit sound
	local time = CurTime();
	if((self.NextSound or 0) < time) then
		sound.Play(self.Sounds.Hit,pos,math.random(70,100),math.random(90,110));
		self.NextSound = time +math.random(2,3)/10;
	end
	-- Draw the hiteffect- But in that function.
	local shield = self.Entity;
	local function draw_effect(shield)
		if(IsValid(shield)) then
			local fx = EffectData();
			fx:SetOrigin(pos);
			fx:SetEntity(shield);
			fx:SetScale(strength);
			util.Effect("shield_hit",fx,true,true);
			shield:DrawBubbleEffect(_,true);
		end
	end
	if(e and IsValid(e) and e:IsPlayer()) then
		timer.Simple(0.1,function() draw_effect(shield) end); -- Let's hope this fixes the shield not beeing drawn, when you run against it in multiplayer. It did for me for my gore addon (same problems)
	else
		draw_effect(shield);
	end
end

--################# Draw a bubble effect @aVoN
function ENT:DrawBubbleEffect(turn_off,hit)
	-- First one is when we delete this SENT, or it will throw an error (there is no self.Parent on shield_generator)
	if(self.DrawBubble or (IsValid(self.Parent) and self.Parent.DrawBubble)) then
		local fx = EffectData();
		fx:SetOrigin(self.Entity:GetPos());
		fx:SetEntity(self.Entity);
		fx:SetScale(self.Size);
		if(turn_off) then
			fx:SetMagnitude(1);
		elseif(hit) then
			fx:SetMagnitude(2);
		else
			fx:SetMagnitude(0);
		end
		util.Effect("shield_engage",fx,true,true);
	end
end

--################# Adds an athmosphere to the shield @aVoN
function ENT:AddAthmosphere()
	-- Really, I don't like SB2 overriding these things (self.planet). Lemmi guess: It's doing this in a think... :(
	if(SB_Add_Environment and not self.Athmosphere and self.Parent.planet) then
		-- The enviroment must be set on the Parent, or self.Parent.planet will return this new enviroment instead of the "real" planet
		self.Athmosphere = SB_Add_Environment(self.Parent,self.Size,self.Parent.gravity,1,1,288);
	end
end

--################# Adds an athmosphere to the shield @aVoN
function ENT:RemoveAthmosphere()
	if(self.Athmosphere) then
		SB_Remove_Environment(self.Athmosphere);
		self.Athmosphere = nil;
	end
end

--################# As requested, add an athmosphere to the shield, when it's turned on (on a planet!) @aVoN
function ENT:Think()
	if (IsValid(self.Parent) and self.Parent.AntiNoclip != nil) then
		self.AntiNoclip = self.Parent.AntiNoclip
	end
	if(SB_Update_Environment and self.Athmosphere) then
		local gravity = 0;
		if(self.Parent.planet) then gravity = self.Parent.gravity or 0 end;
		SB_Update_Environment(self.Athmosphere,self.Size,gravity,1,1,288);
		self.Entity:NextThink(CurTime()+1);
		return true;
	end
end

--################# The hit function (for external usage) @aVoN
function ENT:Hit(e,pos,dmg,normal)
	if(not self.Parent.Depleted) then
		if(self.Parent.Strength > 0) then
			normal = normal or Vector(0,0,0);
			self:HitEffect(e,pos,dmg);
			if(dmg and dmg ~= 0) then
				self.Parent:Hit(dmg,normal,pos);
			end
			return true;
		else
			self.Parent:SetOverlayText("Shield (Depleted)\nSize: "..self.Size);
			self:DrawBubbleEffect(true); -- Set close effect (we are depleted!
			self.Parent:EmitSound(self.Parent.Sounds.Disengage,90,math.random(90,110));
			self.Parent.Depleted = true;
			self.Entity:SetNWBool("depleted",true); -- For the traceline class - Clientside
			self.Entity:SetTrigger(false);
			self:RemoveAthmosphere();
		end
	end
end
