ENT.Type 		= "anim";
ENT.Base 		= "base_anim";
ENT.PrintName	= "Tac";
ENT.Author		= "Ronon Dex, Boba Fett";
ENT.Contact		= "";
ENT.Spawnable        = false
ENT.AdminSpawnable   = false
ENT.RenderGroup = RENDERGROUP_BOTH

if (1==1) then return end -- temporary disabled

if SERVER then
	AddCSLuaFile();
	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetModel("models/boba_fett/tac/w_tac.mdl");
		self:SetRenderMode(RENDERMODE_NORMAL);

		self.MaxShoots = StarGate.CFG:Get("TAC","max_shoots",50);
		self.MaxTargets = StarGate.CFG:Get("TAC","max_targets",5);
		self.ThinkInterval = StarGate.CFG:Get("TAC","shoot_interval",0.5);
		self.Range = StarGate.CFG:Get("TAC","range",800);

		self.Shoots = 0;
	end


	function ENT:Think()

		if(self.IsThrownTac) then
			if(self.Stun or self.Kill) then
				self.Targets = 0;
				for k,v in pairs(ents.FindInSphere(self:GetPos(),self.Range)) do
					if(v:IsPlayer() and v:Alive() or v:IsNPC()) then
						if(IsValid(v)) then
							if(not (v==self.Owner)) then
								if(self.Kill) then
									if (self.MaxTargets>0 and self.Targets>=self.MaxTargets) then
										return;
									end
									local allow = hook.Call("StarGate.Tac.DamagePlayer",nil,v,self);
									if (allow==nil or allow) then
										if (self.MaxShoots>0 and self.Shoots>=self.MaxShoots) then
											self:Destroy();
											return;
										end
										local bullet = {}
										bullet.Src		= self:GetPos();
										bullet.Attacker = self;
										bullet.Dir		= (v:LocalToWorld(v:OBBCenter()) - self:GetPos()):GetNormal();
										bullet.Spread		= Vector(0.01,0.01,0.01);
										bullet.Num		= 1;
										bullet.Damage		= 200;
										bullet.Force		= 55;
										bullet.Tracer		= 1;
										bullet.TracerName	= "zat_tracer";
										self:FireBullets(bullet);
										self.Shoots = self.Shoots+1;
										self.Targets = self.Targets+1;
									end
								elseif(self.Stun) then
									local ent = v;
									timer.Simple(3, function()
										if(IsValid(ent) and (ent:IsPlayer() and ent:Alive() or ent:IsNPC()) and not ent.Stunned) then
											if(IsValid(self)) then
												local allow = hook.Call("StarGate.Tac.StunPlayer",nil,ent,self);
												if (allow==nil or allow) then
													self:StunEnt(ent);
													self.Stun = false;
													//timer.Simple(10, function() self:Remove() end);
													self:ResetSwep();
													self:Remove();
												end
											end
										end
									end);
								end
							end
						end
					end
				end
			end
		end

		self:NextThink(CurTime()+self.ThinkInterval)
		return true
	end

	function ENT:StartSmoke()
		if(self.Smoke) then
			for i=1,6 do
				local sfx = EffectData()
					sfx:SetOrigin(self:GetPos())
				util.Effect("tac_smoke",sfx);
			end
			self:ResetSwep();
			self:Remove()
		end
	end

	--########### Stun the player or NPC @RononDex, Person8880
	function ENT:StunEnt( Ent )

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

					Ent:SetNWInt("TacStunned",CurTime());

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

					timer.Create( "TacStun"..EntID, 10, 1, function()
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

					timer.Create( "TacStun"..EntID, 10, 1, function()
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

	function ENT:OnTakeDamage()

		self:Destroy()

	end

	function ENT:Destroy()
		local e = self;

		for k,v in pairs(ents.FindInSphere(e:GetPos(),200)) do
			if(IsValid(v)) then
				if(not (v==self)) then
					local allow = hook.Call("StarGate.Tac.KillOrDamage",nil,v,self);
					if (allow==nil or allow) then
						if(v:IsPlayer()) then
							if(not (v==self.Owner) and not v:HasGodMode()) then
								v:Kill();
							end
						elseif(v:IsNPC()) then
							v:Health(0);
						else
							v:TakeDamage(100);
						end
					end
				end
			end
		end
		local fx = EffectData();
			fx:SetOrigin(e:GetPos());
			fx:SetMagnitude(50);
		util.Effect("Explosion", fx, true, true);
		e:Remove();

		self:ResetSwep();
	end

	function ENT:ResetSwep()
		local tac = self.Owner:GetWeapon("weapon_sg_tac");
		if(IsValid(tac)) then
			tac.ThrownTac = false;
			tac.CanThrow = true;
		end
	end
end

if CLIENT then

	local started = false;
	function ENT:Draw()
		self:DrawModel();
	end

	function ENT:Think()

		started = LocalPlayer():GetNWInt("TacStunned");

	end

	function FlashStun()
		if(not started) then return end;
		local time = CurTime()-started;
		local mul = math.cos(math.Clamp(time,0,1)*2*math.pi); -- Will do the job in 1/4 second
		if(mul < 0 or time > 0.25) then
			started = nil;
			return;
		end
		surface.SetDrawColor(255,255,255,mul*255);
		surface.DrawRect(0,0,ScrW(),ScrH());
	end
	hook.Add("HUDPaint","TacStunFlash",FlashStun)
end