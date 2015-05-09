ENT.Type 		= "anim";
ENT.Base 		= "base_anim";
ENT.PrintName	= "Wraith Grenade";
ENT.Author		= "Ronon Dex, Boba Fett";
ENT.Contact		= "";
ENT.Spawnable        = false
ENT.AdminSpawnable   = false
ENT.RenderGroup = RENDERGROUP_BOTH

if SERVER then
	AddCSLuaFile();
	function ENT:Initialize()
		self:SetModel("models/pg_props/pg_weapons/pg_wraith_hands_granate_w.mdl");
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		
		self.DetectRange = StarGate.CFG:Get("wraith_grenade","detect_range",200);
		self.BlastRange = StarGate.CFG:Get("wraith_grenade","blast_range",200);
		
		self:SetRenderMode(RENDERMODE_NORMAL);

		self.Mine = false;
	end
	
	function ENT:Think()
		if(not self.Mine) then
			timer.Simple(5, function()
				if(IsValid(self)) then
					self:Explode();
				end
			end)
		else
			if(self.CanExplode < CurTime()) then
				for k,v in pairs(ents.FindInSphere(self:GetPos(),self.DetectRange)) do
					if(v:IsPlayer() or v:IsNPC()) then
						if(v != self.Owner) then
							self:Explode();
						end
					end
				end
			end
		end
	end
	
	function ENT:Use()
		if(self.Mine) then
			self.Owner:GiveAmmo(1,"grenade");
			self:Remove();
		end
	end
	
	function ENT:Explode()

		for k,v in pairs(ents.FindInSphere(self:GetPos(),self.BlastRange)) do
			if(IsValid(v)) then
				if(not (v==self)) then
					if(v:IsPlayer()) then
						if(not (v==self.Owner) and not v:HasGodMode()) then
							v:Kill();
						end
					elseif(v:IsNPC()) then
						v:SetHealth(0);
						v:TakeDamage(100);
					else
						v:TakeDamage(100);
					end
				end
			end
		end
		local fx = EffectData();
			fx:SetOrigin(self:GetPos());
			fx:SetMagnitude(50);
		util.Effect("Explosion", fx, true, true);
		self:Remove();
	end
	
end