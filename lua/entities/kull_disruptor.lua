ENT.Type = "anim"

ENT.Base = "energy_pulse"

ENT.RenderGroup = RENDERGROUP_BOTH

if SERVER then

if (1==1) then return end -- this ent is disabled, because it isn't used anywhere

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
AddCSLuaFile()

function ENT:Initialize()

	self.BaseClass.Initialize(self)
	self.Radius = 25
	self.Damage = 0

	if(self.Phys and self.Phys:IsValid()) then
		self.Phys:SetMass(40);
	end
end

hook.Add("PlayerDeath", "DeathEvent", function(victim, weapon, killer)

	 if (IsValid(victim) and victim.zapMode and victim.zapMode >= 1 ) then
		victim.zapMode = 0
		timer.Destroy("SpeedResetZap2")
		timer.Destroy("zapModeReset2")
		timer.Destroy("SpeedResetZap3")
		timer.Destroy("zapModeReset3")

		GAMEMODE:SetPlayerSpeed(victim, 250, 500)
	end
end)

function ENT:Explode()

	self:Blast("energy_explosion",self:GetPos(),self,Vector(1,1,1), false);
	self:Destroy();
end

function ENT:Blast(effect,pos,ent,norm)

	local fx = EffectData();
	fx:SetOrigin(pos);
	fx:SetNormal(norm);
	fx:SetEntity(ent);
	if(not smoke) then
		fx:SetScale(-1);
	else
		fx:SetScale(1);
	end
	fx:SetMagnitude(self.Size);
	--fx:SetAngles(Angle(self.Entity:GetColor()));
	local color = self.Entity:GetColor();
	fx:SetAngles(Angle(color.r,color.g,color.b));
	util.Effect(effect,fx,true,true)

	entsround = ents.FindInSphere(self.Entity:GetPos(), self.Radius)

	for k,v in pairs(entsround) do
		if not v:IsPlayer() then return end
		v.zapMode = (v.zapMode or 0) + 1
		if v.zapMode == 1 then
			GAMEMODE:SetPlayerSpeed(v, 75, 76)
			PrintMessage( HUD_PRINTTALK, "zapMode is 2")
			timer.Create( "SpeedResetZap2", math.random( 5, 10 ), 1, function()
				if v.zapMode == 1 or v.zapMode == 2 then
					GAMEMODE:SetPlayerSpeed(v, 250, 500)
				end
			end )

			timer.Create( "zapModeReset2", math.random( 12, 15 ), 1, function()
				v.zapMode = 0
			end )

		elseif v.zapMode == 2 then
			timer.Destroy("SpeedResetZap2")
			timer.Destroy("ZapModeReset2")
			v:TakeDamage( 20, self )
			GAMEMODE:SetPlayerSpeed(v, 1, 2)
			PrintMessage( HUD_PRINTTALK, "zapMode is 3")
			timer.Create( "SpeedResetZap3", math.random( 5, 10 ), 1, function()
			if v.zapMode == 1 or v.zapMode == 2 then
					GAMEMODE:SetPlayerSpeed(v, 250, 500)
				end
			end )

			timer.Create( "zapModeReset3", math.random( 12, 15 ), 1, function()
				v.zapMode = 1
			end )

		elseif v.zapMode >= 3 then
			v:TakeDamage( 200, self )

			PrintMessage( HUD_PRINTTALK, "zapMode is 3")
		end
	end
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("kull_disruptor",SGLanguage.GetMessage("entity_kd"))
end

function ENT:Initialize()



	self.BaseClass.Initialize(self)

	self.Sizes = {40,40,250}

	self.DrawShaft = false

	self.InstantEffect = false

end

end