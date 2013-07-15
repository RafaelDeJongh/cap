/*   Copyright 2010 by Llapp   */

include('shared.lua') ;
language.Add("ramp",Language.GetMessage("ramp_kill"));

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self.Entity:GetPos());
end

function ENT:Think()
    ran = math.random(230,255);
	ran2 = math.random(0,5);
	die = math.random(-0.3,0);
	start = math.random(0,2);
	alph = math.random(0,5);
    rantime = math.random(0,2); --
	if(self.Entity:GetNetworkedBool("sgc_smoke",true) and IsValid(self.Entity))then
		timer.Simple( rantime, function()
		    if(IsValid(self.Entity))then
                self:SmokeTopRight();
                self:SmokeBottomRight();
                self:SmokeTopLeft();
                self:SmokeBottomLeft();
			end
	    end )
	end
end

function ENT:SmokeTopRight()
		local UP = Vector(0,0,50);
		local roll = math.Rand(-90,90)
		local rand = math.random(-15,15);
		local angle = self.Entity:GetUp()*(-170)+self.Entity:GetRight()*(-50+rand)+self.Entity:GetForward()*rand
		local pos = self.Entity:GetPos() + self.Entity:GetRight()*(-120) - self.Entity:GetUp()*(-75)
		local particle = self.Emitter:Add("Llapp/particles/Smoke01_Main",pos)
		particle:SetVelocity(UP+angle)
		particle:SetDieTime(0.6+die)
		particle:SetStartAlpha(50+alph)
		particle:SetEndAlpha(0)
		particle:SetStartSize(7+start)
		particle:SetEndSize(11+ran2)
		particle:SetColor(ran,ran,ran)
	    particle:SetRoll(roll)
		particle:SetRollDelta(1)
		particle:SetAirResistance( 20 );
		self.Emitter:Finish()
end

function ENT:SmokeTopLeft()
		local UP = Vector(0,0,50);
		local roll = math.Rand(-90,90)
		local rand = math.random(-15,15);
		local angle = self.Entity:GetUp()*(-170)+self.Entity:GetRight()*(50+rand)+self.Entity:GetForward()*rand
		local pos = self.Entity:GetPos() + self.Entity:GetRight()*(120) - self.Entity:GetUp()*(-75)
		local particle = self.Emitter:Add("Llapp/particles/Smoke01_Main",pos)
		particle:SetVelocity(UP+angle)
		particle:SetDieTime(0.6+die)
		particle:SetStartAlpha(50+alph)
		particle:SetEndAlpha(0)
		particle:SetStartSize(7+start)
		particle:SetEndSize(11+ran2)
		particle:SetColor(ran,ran,ran)
	    particle:SetRoll(roll)
		particle:SetRollDelta(1)
		particle:SetAirResistance( 20 );
		self.Emitter:Finish()
end

function ENT:SmokeBottomRight()
		local UP = Vector(0,0,50);
		local roll = math.Rand(-90,90)
		local rand = math.random(-15,15);
		local angle = self.Entity:GetUp()*(-200)+self.Entity:GetRight()*(-10+rand)+self.Entity:GetForward()*rand
		local pos = self.Entity:GetPos() + self.Entity:GetRight()*(-140) - self.Entity:GetUp()*20
		local particle = self.Emitter:Add("Llapp/particles/Smoke01_Main",pos)
		particle:SetVelocity(UP+angle)
		particle:SetDieTime(0.6+die)
		particle:SetStartAlpha(50+alph)
		particle:SetEndAlpha(0)
		particle:SetStartSize(7+start)
		particle:SetEndSize(11+ran2)
		particle:SetColor(ran,ran,ran)
	    particle:SetRoll(roll)
		particle:SetRollDelta(1)
		particle:SetAirResistance( 20 );
		self.Emitter:Finish()
end

function ENT:SmokeBottomLeft()
		local UP = Vector(0,0,50);
		local roll = math.Rand(-90,90)
		local rand = math.random(-15,15);
		local angle = self.Entity:GetUp()*(-200)+self.Entity:GetRight()*(10+rand)+self.Entity:GetForward()*rand
		local pos = self.Entity:GetPos() + self.Entity:GetRight()*(140) - self.Entity:GetUp()*20
		local particle = self.Emitter:Add("Llapp/particles/Smoke01_Main",pos) --trails/smoke
		particle:SetVelocity(UP+angle)
		particle:SetDieTime(0.6+die)
		particle:SetStartAlpha(50+alph)
		particle:SetEndAlpha(0)
		particle:SetStartSize(7+start)
		particle:SetEndSize(11+ran2)
		particle:SetColor(ran,ran,ran)
	    particle:SetRoll(roll)
		particle:SetRollDelta(1)
		particle:SetAirResistance( 20 );
		self.Emitter:Finish()
end
