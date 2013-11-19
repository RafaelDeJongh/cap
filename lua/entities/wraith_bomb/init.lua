if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end

AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");
include("shared.lua");

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
	self:CreateWireInputs("Detonate","Yield","Power","Timer");

	self.Yield = self.Yield;
	self.Timer = self.Timer;
	self.Power = self.Power;


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
		self.Yield = v;
	elseif(k=="Power") then
		self.Power = v;
	elseif(k=="Timer") then
		self.Timer = v;
	end
end


function ENT:Use(p)

	if IsValid(self) then
		self:Detonate();
	end
end

function ENT:Detonate()

	self.Charging = true;
	self:SetNetworkedVector("shield_color",Vector(0.69,0.93,0.93))
	local e = self.Entity;
	timer.Simple(self.Timer, function()
		if (not IsValid(e)) then return end
		for _,v in pairs(ents.FindInSphere(e:GetPos(),e.Yield)) do
			if IsValid(v) then
				if v:IsPlayer() then
					e:Stun(v);
				elseif v:IsNPC() then
					e:Stun(v);
				end
			end
		end
		self.Charging = false;
		local fx = EffectData();
			fx:SetOrigin(e:GetPos());
			fx:SetEntity(e);
			fx:SetScale(self.Yield);
			fx:SetMagnitude(0.1);
		util.Effect("shield_engage",fx,true,true);

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
		if Ent:IsPlayer() then
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
					if IsValid( Ent ) and Ent.Stunned and not Ent:HasGodMode() then
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
					if ent == Ragdoll and Ent.Stunned and not Ent:HasGodMode() then
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

				timer.Create( "WraithStun"..EntID, 10, 1, function()
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

				timer.Create( "WraithStun"..EntID, self.Timer, 1, function()
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
