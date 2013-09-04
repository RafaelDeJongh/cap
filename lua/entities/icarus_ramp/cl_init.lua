/*   Copyright 2012 by AlexALX   */
/* Smoke code from SGC Ramp by Llapp */

include('shared.lua') ;
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("ramp",SGLanguage.GetMessage("ramp_kill"));
end

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self.Entity:GetPos());
end

function ENT:Think()
    ran = math.random(230,255);
	ran2 = math.random(0,5);
	die = math.random(-0.3,0);
	start = math.random(0,2);
	alph = math.random(3,5);
    rantime = math.random(0,2); --
	if(self.Entity:GetNetworkedBool("icarus_smoke",false) and IsValid(self.Entity))then
		timer.Simple( rantime, function()
		    if(IsValid(self.Entity))then
                self:SmokeTopRight();
                self:SmokeTopLeft();
			end
	    end )
	end
end

function ENT:SmokeTopRight()
		local UP = Vector(0,0,90);
		local roll = math.Rand(-20,20)
		local rand = math.random(-15,15);
		local angle = self.Entity:GetUp()*(-110)+self.Entity:GetRight()*(-40+rand)+self.Entity:GetForward()*rand
		local pos = self.Entity:GetPos() + self.Entity:GetForward()*(-190) + self.Entity:GetRight()*(-90) - self.Entity:GetUp()*(-260)
		local particle = self.Emitter:Add("Llapp/particles/Smoke01_Main",pos)
		particle:SetVelocity(UP+angle)
		particle:SetDieTime(0.6+die)
		particle:SetStartAlpha(50+alph)
		particle:SetEndAlpha(0)
		particle:SetStartSize(20+start)
		particle:SetEndSize(22+ran2)
		particle:SetColor(ran,ran,ran)
	    particle:SetRoll(roll)
		particle:SetRollDelta(0.1)
		particle:SetAirResistance( 10 );
		self.Emitter:Finish()
end

function ENT:SmokeTopLeft()
		local UP = Vector(0,0,90);
		local roll = math.Rand(-90,90)
		local rand = math.random(-15,15);
		local angle = self.Entity:GetUp()*(-110)+self.Entity:GetRight()*(40+rand)+self.Entity:GetForward()*rand
		local pos = self.Entity:GetPos() + self.Entity:GetForward()*(-190) + self.Entity:GetRight()*(90) - self.Entity:GetUp()*(-260)
		local particle = self.Emitter:Add("Llapp/particles/Smoke01_Main",pos)
		particle:SetVelocity(UP+angle)
		particle:SetDieTime(0.6+die)
		particle:SetStartAlpha(50+alph)
		particle:SetEndAlpha(0)
		particle:SetStartSize(20+start)
		particle:SetEndSize(22+ran2)
		particle:SetColor(ran,ran,ran)
	    particle:SetRoll(roll)
		particle:SetRollDelta(0.1)
		particle:SetAirResistance( 10 );
		self.Emitter:Finish()
end