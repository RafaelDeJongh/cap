if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Wraith Stun Bomb"
ENT.Author = "Ronon Dex"
ENT.Instructions= ""
ENT.Contact = ""
ENT.Category = "Stargate Carter Addon Pack: Weapons"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.RenderGroup = RENDERGROUP_BOTH

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end

AddCSLuaFile();

function ENT:SpawnFunction(p,t)

	local e = ents.Create("wraith_bomb");
	e:SetPos(t.HitPos + Vector(0,0,10));
	e:Spawn();
	e:Activate();
	return e;

end

function ENT:Initialize()

	self.Entity:SetModel("models/Assassin21/wraith_bomb/stunner_bomb.mdl");

	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);
	self:CreateWireInputs("Detonate","Yield","Power","Timer");

	self.Yield = self.Yield or 100;
	self.Timer = self.Timer or 5;
	self.Power = self.Power or 5;

	self.EffectSize = 20;

	local phys = self:GetPhysicsObject();
	if IsValid(phys) then
		phys:Wake();
		phys:SetMass(100);
	end

end

function ENT:TriggerInput(k,v)
	if(k=="Detonate") then
		if((v or 0) >= 1) then
			self:Detonate();
		end
	elseif(k=="Yield") then
		self.Yield = math.Clamp(v,100,1000);
	elseif(k=="Power") then
		self.Power = math.Clamp(v,5,30);
	elseif(k=="Timer") then
		self.Timer = math.Clamp(v,5,60);
	end
end


function ENT:Use(p)

	if IsValid(self) then
		self:Detonate();
	end
end

function ENT:Effect()
	local fx = EffectData();
		fx:SetOrigin(self:GetPos());
		fx:SetEntity(self);
		fx:SetScale(self.EffectSize);
		fx:SetMagnitude(0.1);
	util.Effect("shield_engage",fx,true,true);
end

function ENT:Think()

	if(self.Charging) then
		self:Effect();
		if(self.Detonated) then
			self.EffectSize = math.Approach(self.EffectSize,self.Yield,self.Yield/50);
			for k,v in pairs(ents.FindInSphere(self:GetPos(),self.EffectSize)) do
				local allow = hook.Call("StarGate.WraithBomb.Stun",nil,v,self);
				if (allow==nil or allow) then
					if IsValid(v) then
						if v:IsPlayer() or v:IsNPC() then
							self:Stun(v);
						end
					end
				end
			end
		end
	end
end

function ENT:Detonate()
	if (self.Disabled) then return end
	self.EffectSize = 20; -- reset old value;
	self.Detonated = false; -- reset old value
	self.Charging = true;
	self.Disabled = true;
	self:SetNetworkedVector("shield_color",Vector(0.69,0.93,0.93))
	local e = self.Entity;
	timer.Simple(self.Timer, function()
		self.Detonated = true;
		if (not IsValid(e)) then return end
		timer.Simple(10.0,function()
			if (IsValid(e)) then
				e.Charging = false;
			end
		end);
		timer.Simple(self.Power+5,function()
			if (IsValid(e)) then
				e.Disabled = false;
			end
		end);
	end);

end


--########### Stun the player or NPC @RononDex, Person8880
function ENT:Stun( Ent )

	-- for what is this? Create bug after activation...
	/*self.Phys = self.Entity:GetPhysicsObject()
	if self.Phys and self.Phys:IsValid() then
		self.Phys:SetMass( 1 )
	end
	self.Entity:PhysicsInitSphere( 1, "metal" )
	self.Entity:SetCollisionBounds( -1 * Vector(1,1,1), Vector(1,1,1) ) */

	if IsValid( Ent ) then
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
				Ent:SetNWEntity( "StunRagdoll", Ragdoll )

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
						local amount = dmginfo:GetDamage();
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

				timer.Create( "WraithStun"..EntID, self.Power, 1, function()
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
				hook.Add( "EntityTakeDamage", "StunRagdollDamage"..EntID, function( ent, dmginfo )
					if (not IsValid(Ent)) then return end
					local amount = dmginfo:GetDamage();
					if ent == Ragdoll then
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
				end )

				timer.Create( "WraithStun"..EntID, self.Power, 1, function()
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

end

if CLIENT then

function ENT:Draw() self:DrawModel() end;

--Calculate the player's view when they are stunned.
local function CalcView( ply, pos, angles, fov )
	if ply.Stunned then
		local Ragdoll = ply:GetNetworkedEntity( "StunRagdoll" )
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
hook.Add( "CalcView", "WraithStun", CalcView )

end