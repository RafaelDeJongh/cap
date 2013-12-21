/*
	Staff Weapon for GarrysMod10
	Copyright (C) 2007  aVoN
	Rewrited by Madman07, 2011
	Rewrote Damage System to Stun by RononDex 2012

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

if SERVER then

--################# HEADER #################
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("weapon")) then return end
AddCSLuaFile();

ENT.CAP_NotSave = true;
ENT.Untouchable = true;
ENT.IgnoreTouch = true;
ENT.NoAutoClose = true; -- Will not cause an autoclose event on the stargates!
ENT.CDSIgnore = true; -- CDS Immunity
function ENT:gcbt_breakactions() end; ENT.hasdamagecase = true; -- GCombat invulnarability!

--################# SENT CODE ###############

--################### Init @aVoN, Madman07
function ENT:Initialize()
	self.Entity:PhysicsInitSphere(self.Size/10,"metal");
	self.Entity:SetCollisionBounds(-1*Vector(1,1,1)*self.Size/10,Vector(1,1,1)*self.Size/10);
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self:DrawShadow(false)
	-- Config
	self.Radius = 20+30*self.Size;  --StarGate.CFG:Get("staff","radius",50);
	self.Damage = 30+40*self.Size;  --StarGate.CFG:Get("staff","damage",150);
	self.MaxPasses = 5; --StarGate.CFG:Get("staff","maxpasses",5);
	self.Passes = 1;
	self.Passed = {}; -- Necessary, so you can shoot out of Catdaemons shield
	local r,g,b = self.Entity:GetColor();
	if(r == 255 and g == 255 and b == 255) then
		self.Entity:SetColor(Color(math.random(230,255),200,120,255));
	end

	--PhysObject
	self:PhysWake()
	self.Phys = self.Entity:GetPhysicsObject();
	local vel = self.Direction*self.Speed+VectorRand()*self.Random;
	if(self.Phys and self.Phys:IsValid()) then
		self.Phys:SetMass(self.Size*10);
		self.Phys:EnableGravity(false);
		self.Phys:SetVelocity(vel);-- end
	end
	self.Entity:SetLocalVelocity(vel)
	self.Created = CurTime();

	self.CoreNotCollide = self.Owner.CoreNotCollide;
	self.CoreEntity = self.Owner.CoreEntity;
end

--################# Prevent PVS bug/drop of all networkes vars (Let's hope, it works) @aVoN
function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end;

--################# Think for physic @Mad
function ENT:PhysicsUpdate(phys)
	local vel = phys:GetVelocity();
	if (math.abs(vel.x)<500 and math.abs(vel.y)<500 and math.abs(vel.z)<500) then -- faster than length?
		self:Destroy();
	end
end

function ENT:Touch(ent)
	if (ent:GetClass() == "shield" or ent:GetClass() == "ship_shield") then
		self:Destroy();
	end
end

function ENT:Think(ply)
	local phys = self:GetPhysicsObject();
	if IsValid(phys) then phys:Wake(); end

	if IsValid(self.Player and self.Ragdoll) then
		if self.Player.Stunned then
			self.Player:SetPos(self.Ragdoll:GetPos());
		end
	end

end

--################### Make the shot blast @aVoN, Madman07
function ENT:PhysicsCollide( data, physobj )
	local e = data.HitEntity;

	if (e) then
		if e.IgnoreTouch then return end; -- Gloabal for anyone, who want's to make his scripts "staff-passable"
		if self.Passed[e] then return end; -- We already passed this entity. Don't touch it again
		if (self.CoreNotCollide and self.CoreEntity == e) then return end; -- avoid owner shields

		local pos = data.HitPos;
		local world = e:IsWorld()
		local owner = self.Entity:GetOwner();
		if (owner == nil) then owner = self.Entity; end
		local hitnormal = data.HitNormal;
		local class = e:GetClass()

		if world then hitnormal = -1*hitnormal; end

		if (owner == e) then return end
		for _,v in pairs(self.Ignore) do
			if (v == e) then return end
		end

		-- Shield Thing
		if (not world and self.Passed[e] == nil) then
			if not e:GetPhysicsObject():IsValid() then self.Passed[e] = true return end; -- Invalid physics object?
			if (class == "ivisgen_collision") then self.Passed[e] = true return end; -- Catdaemon's cloaking device
			if e.nocollide then -- Catdaemon's and avon shield?
				if(e.nocollide[owner]) then
					e.nocollide[e] = true;
					self.Passed[e] = true;
					return;
				end
				self.Passed[e] = false;
			end
		end

		-- ######################## The blast
		local dir = self.Direction*10;
		local hitsmoke = true;
		if (hitnormal:Length() == 0) then hitsmoke = false end;

		local trace = util.TraceLine({start=pos-dir,endpos=pos+dir,filter={self.Entity,owner}});
		if trace then
			if trace.HitSky then self.Entity:Destroy() return end;
			if (trace.MatType == MAT_FLESH or trace.MatType == MAT_METAL or trace.MatType == MAT_GLASS) then hitsmoke = false end
		end

		hitsmoke = false

		self:Stun(e);

		self:Destroy();

	end
end

--########### Stun the player or NPC @RononDex, Person8880
function ENT:Stun( Ent )

	self.Phys = self.Entity:GetPhysicsObject()
	if self.Phys and self.Phys:IsValid() then
		self.Phys:SetMass( 1 )
	end
	self.Entity:PhysicsInitSphere( 1, "metal" )
	self.Entity:SetCollisionBounds( -1 * Vector(1,1,1), Vector(1,1,1) )

	if IsValid( Ent ) then

		local allow = hook.Call("StarGate.Player.Stun",nil,Ent,self.Owner);
		if (allow==false) then return end

		if Ent:IsPlayer() and not Ent:HasGodMode() then
			if not Ent.Stunned then
				local model = Ent:GetModel()
				local Ragdoll = ents.Create( "prop_ragdoll" )
				local EntID = Ent:EntIndex()

				Ent.Stunned = true
				Ent:Freeze( true )
				Ent:SetNoDraw( true )
				Ent:SetNotSolid( true )
				Ent:DrawViewModel( false )
				Ent:DrawWorldModel( false )
				Ent:SendLua( "LocalPlayer().Stunned = true" )
				Ent:SetNetworkedEntity( "StunRagdoll", Ragdoll )

				Ragdoll:SetModel( model )
				Ragdoll:SetPos( Ent:GetPos() )
				Ragdoll.Owner = self.Owner
				Ragdoll:Spawn()
				Ragdoll:Activate()
				--Kill the player when their ragdoll is destroyed, in case a Stargate eats it or something...
				Ragdoll:CallOnRemove( "RagdollRemoved", function()
					if IsValid( Ent ) and Ent.Stunned then
						if timer.Exists( "EnergyPulseStun"..EntID ) then
							timer.Destroy( "EnergyPulseStun"..EntID )
						end
						Ent.Stunned = nil
						Ent:SendLua( "LocalPlayer().Stunned = nil" )
						Ent:SetNWEntity( "StunRagdoll", NULL )
						Ent:Freeze( false )
						Ent:SetNoDraw( false )
						Ent:SetNotSolid( false )
						Ent:DrawViewModel( true )
						Ent:DrawWorldModel( true )
						Ent:SetPos( Ragdoll:GetPos() )
						Ent:Kill()
					end

					hook.Remove( "EntityTakeDamage", "StunRagdollDamage"..EntID )
				end )

				--Damage hook to transfer damage on the ragdoll to the player, killing them if necessary.
				hook.Add( "EntityTakeDamage", "StunRagdollDamage"..EntID, function( ent, dmginfo )
					if ent == Ragdoll and Ent.Stunned then
					    local inflictor = dmginfo:GetInflictor()
					    local attacker = dmginfo:GetAttacker()
					    local amount = dmginfo:GetDamage()
						if dmginfo:GetDamageType() == 1 then
							amount = amount * 0.05
						end
						local NewHP = Ent:Health() - amount
						if NewHP <= 0 then
							Ent.Stunned = nil
							Ent:SendLua( "LocalPlayer().Stunned = nil" )
							Ent:SetNWEntity( "StunRagdoll", NULL )
							Ent:Freeze( false )
							Ent:SetNoDraw( false )
							Ent:SetNotSolid( false )
							Ent:DrawViewModel( true )
							Ent:DrawWorldModel( true )
							Ent:SetPos( Ragdoll:GetPos() )
							Ent:Kill()

							Ragdoll:Remove()
						else
							Ent:SetHealth( NewHP )
						end
					end
				end )

				timer.Create( "EnergyPulseStun"..EntID, 10, 1, function()
					if IsValid( Ent ) and Ent.Stunned then
						Ent.Stunned = nil
						Ent:SendLua( "LocalPlayer().Stunned = nil" )
						Ent:SetNWEntity( "StunRagdoll", NULL )
						Ent:Freeze( false )
						Ent:SetNoDraw( false )
						Ent:SetNotSolid( false )
						Ent:DrawViewModel( true )
						Ent:DrawWorldModel( true )
						if IsValid( Ragdoll ) then
							Ent:SetPos( Ragdoll:GetPos() )
						end
					end

					hook.Remove( "EntityTakeDamage", "StunRagdollDamage"..EntID )

					if IsValid( Ragdoll ) then
						Ragdoll:Remove()
					end
				end )
			end
		elseif Ent:IsNPC() then
			if not Ent.Stunned then
				local model = Ent:GetModel()
				local Weapon = Ent:GetActiveWeapon()
				local Ragdoll = ents.Create( "prop_ragdoll" )
				local EntID = Ent:EntIndex()

				local State = Ent:GetNPCState()
				Ent:SetNPCState( NPC_STATE_NONE )
				Ent:SetNoDraw( true )
				Ent:SetNotSolid( true )
				Ent:CapabilitiesRemove( CAP_USE_WEAPONS )
				Ent.Stunned = true

				if IsValid( Weapon ) then
					Weapon:SetNoDraw( true )
				end

				Ragdoll:SetModel( model )
				Ragdoll:SetPos( Ent:GetPos() )
				Ragdoll.Owner = self.Owner
				Ragdoll:Spawn()
				Ragdoll:Activate()
				--Kill the NPC when their ragdoll is destroyed.
				Ragdoll:CallOnRemove( "RagdollRemoved", function()
					if IsValid( Ent ) and Ent.Stunned then
						if timer.Exists( "EnergyPulseStun"..EntID ) then
							timer.Destroy( "EnergyPulseStun"..EntID )
						end
						Ent.Stunned = nil
						Ent:SetNoDraw( false )
						Ent:SetNotSolid( false )
						Ent:SetPos( Ragdoll:GetPos() )
						Ent:SetHealth( 0 )
						Ent:SetNPCState( NPC_STATE_DEAD )
					end

					hook.Remove( "EntityTakeDamage", "StunRagdollDamage"..EntID )
				end )
				--This can be a bit buggy, the NPCs sometimes just stand there for a few seconds then die after being flung around.
				hook.Add( "EntityTakeDamage", "StunRagdollDamage"..EntID, function( ent, dmginfo)
					if ent == Ragdoll then
					    local infl = dmginfo:GetInflictor()
					    local att = dmginfo:GetAttacker()
					    local amount = dmginfo:GetDamage()
					    if (IsValid(Ent)) then
							local NewHP = Ent:Health() - amount
							if NewHP <= 0 then
								Ent.Stunned = nil
								Ent:SetNoDraw( false )
								Ent:SetNotSolid( false )
								Ent:SetPos( Ragdoll:GetPos() )
								Ent:SetHealth( 0 )
								Ent:SetNPCState( NPC_STATE_DEAD )

								Ragdoll:Remove()
							else
								Ent:SetHealth( NewHP )
							end
						end
					end
				end )

				timer.Create( "EnergyPulseStun"..EntID, 10, 1, function()
					if IsValid( Ent ) and Ent.Stunned then
						Ent.Stunned = nil
						Ent:SetNPCState( State )
						Ent:SetNoDraw( false )
						Ent:SetNotSolid( false )
						Ent:SetPos( Ragdoll:GetPos() )
						Ent:CapabilitiesAdd( CAP_USE_WEAPONS )

						if IsValid( Weapon ) then
							Weapon:SetNoDraw( false )
						end
					end

					hook.Remove( "EntityTakeDamage", "StunRagdollDamage"..EntID )

					if IsValid( Ragdoll ) then
						Ragdoll:Remove()
					end
				end )
			end
		end
	end

	local fx = EffectData()
	fx:SetStart( Ent:GetPos() )
	fx:SetOrigin( Ent:GetPos() )
	fx:SetScale( 10 )
	fx:SetMagnitude( 10 )
	fx:SetEntity( Ent )
	util.Effect( "TeslaHitBoxes", fx )
end

-- ########################  TELEPORT
function ENT.FixAngles(self,pos,ang,vel,old_pos,old_ang,old_vel,ang_delta)
	self:PhysWake()
	self.Direction = vel:GetNormalized();
	local vel2 = self.Direction*self.Speed+VectorRand()*self.Random;
	if(self.Phys and self.Phys:IsValid()) then
		self.Phys:SetVelocity(vel2);
	end
	self.Entity:SetLocalVelocity(vel2)
end
StarGate.Teleport:Add("energy_pulse_stun",ENT.FixAngles);

--################### Setup @Mad
function ENT:PrepareBullet(dir, rand, spd, size, ignore)
	self.Direction = dir;
	self.Random = rand;
	self.Speed = spd;
	self.Size = size;
	self.Entity:SetNWInt("Size", size);
	self.Ignore = ignore or {};
end

--################### Destroys this entity without fearing to crash! @aVoN
function ENT:Destroy()
	self.PhysicsCollide = function() end; -- Dummy
	self.Touch = self.PhysicsCollide;
	self.StartTouch = self.Touch;
	self.EndTouch = self.Touch;
	self.Think = self.Touch;
	self.PhysicsUpdate = self.Touch;
	self:SetTrigger(false);
	local e = self.Entity;
	timer.Simple(0,
		function()
			if(IsValid(e)) then e:Remove() end;
		end
	);
end

--################### Earthquake! @aVoN
concommand.Add("_StarGate.StaffBlast.ScreenShake",
	function(p,_,arg)
		if(IsValid(p)) then
			util.ScreenShake(Vector(unpack(arg)),2,2.5,1,700);
		end
	end
);

end

if CLIENT then

if (StarGate==nil or StarGate.MaterialFromVMT==nil) then return end
ENT.Glow = StarGate.MaterialFromVMT(
	"StaffGlow",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/light_glow01"
		"$nocull" 1
		"$additive" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
);
ENT.Shaft = Material("effects/ar2ground2");
ENT.LightSettings = "cl_staff_dynlights_flight";
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("energy_pulse",SGLanguage.GetMessage("energy_pulse_kill"));
end
ENT.RenderGroup = RENDERGROUP_BOTH;

--################### Init @aVoN
function ENT:Initialize()
	self.Created = CurTime();
	self.DrawShaft = true;
	self.InstantEffect = not (self.Entity:GetClass() == "energy_pulse");
	self.Sounds = self.Sounds or {Sound("pulse_weapon/staff_flyby1.mp3"),Sound("pulse_weapon/staff_flyby2.mp3")};
	local snd = {}; -- Must be overwritten because garry's inheritance scripts interferes...
	for _,v in pairs(self.Sounds) do
		table.insert(snd,v);
	end
	self.Sounds = snd;
	local size = self.Entity:GetNetworkedInt("Size", 0);
	self.Sizes={20+size*3,20+size*3,180+size*10}; -- X,Y and shaft-leght!
end

--################### Draw the shot @aVoN
function ENT:Draw()
	if(not self.StartPos) then self.StartPos = self.Entity:GetPos() end; -- Needed for several workarounds
	local start = self.Entity:GetPos();
	local color = self.Entity:GetColor();
	if(self.DrawShaft) then
		local velo = self.Entity:GetVelocity();
		local dir = -1*velo:GetNormal();
		-- Mainly a workaround for servers: The shots appeared to have their trails really late. Seems like the velocity simply was 0
		if(velo:Length() < 400) then
			if(self.StartPos) then
				dir = (self.StartPos-self.Entity:GetPos()):GetNormalized();
			end
		end
		local length = math.Clamp((self.Entity:GetPos()-self.StartPos):Length(),0,self.Sizes[3]);
		render.SetMaterial(self.Shaft);
		render.DrawBeam(
			self.Entity:GetPos(),
			self.Entity:GetPos()+dir*length,
			self.Sizes[1],
			1,
			0,
			color
		);
	end
	render.SetMaterial(self.Glow);
	for i =1,2 do
		render.DrawSprite(
			start,
			self.Sizes[2],self.Sizes[2],
			color
		);
	end
end

--################### Think: Play sounds! @aVoN
function ENT:Think()
	local size = self.Entity:GetNWInt("Size", 0);
	self.Sizes={20+size*3,20+size*3,180+size*10}; -- X,Y and shaft-leght!
	-- ######################## Flyby-light
	if(StarGate.VisualsWeapons(self.LightSettings)) then
		local color = self.Entity:GetColor();
		local r,g,b = color.r,color.g,color.b;
		local dlight = DynamicLight(self:EntIndex());
		if(dlight) then
			dlight.Pos = self.Entity:GetPos();
			dlight.r = r;
			dlight.g = g;
			dlight.b = b;
			dlight.Brightness = 1;
			dlight.Decay = 300;
			dlight.Size = 300;
			dlight.DieTime = CurTime()+0.5;
		end
	end
	local time = CurTime();
	-- ######################## Flyby-noise and screenshake!
	if((time-self.Created >= 0.1 or self.InstantEffect) and time-(self.Last or 0) > 0.3) then
		local p = LocalPlayer();
		local pos = self.Entity:GetPos();
		local norm = self.Entity:GetVelocity():GetNormal();
		local dist = p:GetPos()-pos;
		local len = dist:Length();
		local dot_prod = dist:DotProduct(norm)/len;
		if(math.abs(dot_prod) < 0.5 and dot_prod ~= 0) then
			-- Vector math: Get the distance from the player orthogonally to the projectil's velocity vector
			local intensity = math.sqrt(1 - dot_prod^2)*len;
			self.Entity:EmitSound(self.Sounds[math.random(1,#self.Sounds)],100*(1-intensity/2500),math.random(80,120));
			p:ConCommand("_StarGate.StaffBlast.ScreenShake "..tostring(pos)); -- Sadly, util.ScreenShake fails clientside so we need to tell the server that we want screenshake!
			self.Last = time;
		end
	end
	self.Entity:NextThink(time);
	return true;
end
--Calculate the player's view when they are stunned.
local function CalcView( ply, pos, angles, fov )
	if ply.Stunned then
		local Ragdoll = ply:GetNWEntity( "StunRagdoll" )
		if IsValid( Ragdoll ) then
			local EyesID = Ragdoll:LookupAttachment( "eyes" )
			local Eyes = Ragdoll:GetAttachment( EyesID )

			return {
				origin = Eyes.Pos,
				angles = Eyes.Ang,
				fov = fov
			}
		else
			return {
				orgin = pos,
				angles = angles,
				fov = fov
			}
		end
	end
end
hook.Add( "CalcView", "EnergyPulseStun", CalcView )

end