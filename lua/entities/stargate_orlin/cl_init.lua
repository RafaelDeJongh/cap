/*
	Stargate Orlin for GarrysMod10
	Copyright (C) 2010  Llapp
*/

include("shared.lua");
ENT.ChevronColor = Color(255,255,205);

ENT.Category = Language.GetMessage("stargate_category");
ENT.PrintName = Language.GetMessage("stargate_orlin");

ENT.LightPositions = {
	Vector(3.7, 0, 45),
	Vector(3.7, 36.5, 26.5),
	Vector(3.7, 43, -14),
	Vector(3.7, 20.6, -40.5),
	Vector(3.7, -20, -40.5),
	Vector(3.7, -43, -14.5),
	Vector(3.7, -36.5, 26.1),
}
ENT.SpritePositions = {
	Vector(3.7, 0, 45),
	Vector(3.7, 36.5, 26.5),
	Vector(3.7, 43, -14),
	Vector(3.7, 20.6, -40.5),
	Vector(3.7, -20, -40.5),
	Vector(3.7, -43, -14.5),
	Vector(3.7, -36.5, 26.1),
}

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self.Entity:GetPos());
end

function ENT:Draw()
	self.Entity:DrawModel();
	if(not self.ChevronColor) then return end;
	render.SetMaterial(self.ChevronSprite);
	local col = Color(self.ChevronColor.r,self.ChevronColor.g,self.ChevronColor.b,120); -- Decent please -> Less alpha
	for i=1,9 do
		if(self.Entity:GetNetworkedBool("chevron"..i,false)) then
			local endpos = self.Entity:LocalToWorld(self.SpritePositions[i]);
			if StarGate.LOSVector(EyePos(), endpos, LocalPlayer(), 5) then
				render.DrawSprite(endpos,6,6,col);
			end
		end
	end
end

function ENT:Think()
    ran = math.random(180,235);
	ran2 = math.random(0,5);
	die = math.random(-0.3,0);
	start = math.random(0,2);
	alph = math.random(0,5);
    rantime = math.random(0,2); --
	if(self.Entity:GetNWBool("smoke",true) and IsValid(self.Entity))then
		timer.Simple( rantime, function()
		    if(IsValid(self.Entity))then
                self:SmokeRight();
				self:WaveRight();
                self:SmokeLeft();
				self:WaveLeft();
			end
	    end )
	end
end

function ENT:SmokeRight()
	local UP = Vector(0,0,50);
	local roll = math.Rand(-90,90)
	local rand = math.random(-15,15);
	local angle = self.Entity:GetUp()*(-130)+self.Entity:GetRight()*(-20+rand)+self.Entity:GetForward()*rand
	local pos = self.Entity:GetPos() + self.Entity:GetRight()*(-40) - self.Entity:GetUp()*(-25) + self.Entity:GetForward()*(2)
	local particle = self.Emitter:Add("Llapp/particles/Smoke01_Main",pos)
	particle:SetVelocity(UP+angle)
	particle:SetDieTime(0.7+die)
	particle:SetStartAlpha(140+alph)
	particle:SetEndAlpha(0)
	particle:SetStartSize(7+start)
	particle:SetEndSize(7+start)
	particle:SetColor(ran,ran,ran)
	particle:SetRoll(roll)
	particle:SetRollDelta(1)
	particle:SetAirResistance( 20 );
	self.Emitter:Finish()
end

function ENT:WaveRight()
    local UP = Vector(0,0,50);
	local roll = math.Rand(-90,90)
	local rand = math.random(-15,15);
	local angle = self.Entity:GetUp()*(-130)+self.Entity:GetRight()*(-20+rand)+self.Entity:GetForward()*rand
	local pos = self.Entity:GetPos() + self.Entity:GetRight()*(-40) - self.Entity:GetUp()*(-25) + self.Entity:GetForward()*(2)
	local particle = self.Emitter:Add("sprites/heatwave",pos)
	particle:SetVelocity(UP+angle)
	particle:SetDieTime(0.6+die)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(7+start)
	particle:SetEndSize(7+ran2)
	particle:SetColor(0,95,155)
	particle:SetRoll(roll)
	particle:SetRollDelta(1)
	particle:SetAirResistance( 20 );
	self.Emitter:Finish()
end

function ENT:SmokeLeft()
	local UP = Vector(0,0,50);
	local roll = math.Rand(-90,90)
	local rand = math.random(-15,15);
	local angle = self.Entity:GetUp()*(-130)+self.Entity:GetRight()*(10+rand)+self.Entity:GetForward()*rand
	local pos = self.Entity:GetPos() + self.Entity:GetRight()*(45) - self.Entity:GetUp()*(15)
	local particle = self.Emitter:Add("Llapp/particles/Smoke01_Main",pos)
	particle:SetVelocity(UP+angle)
	particle:SetDieTime(0.6+die)
	particle:SetStartAlpha(140+alph)
	particle:SetEndAlpha(0)
	particle:SetStartSize(7+start)
	particle:SetEndSize(7+start)
	particle:SetColor(ran,ran,ran)
	particle:SetRoll(roll)
	particle:SetRollDelta(1)
	particle:SetAirResistance( 20 );
	self.Emitter:Finish()
end

function ENT:WaveLeft()
    local UP = Vector(0,0,50);
	local roll = math.Rand(-90,90)
	local rand = math.random(-15,15);
	local angle = self.Entity:GetUp()*(-130)+self.Entity:GetRight()*(10+rand)+self.Entity:GetForward()*rand
	local pos = self.Entity:GetPos() + self.Entity:GetRight()*(45) - self.Entity:GetUp()*(15)
	local particle = self.Emitter:Add("sprites/heatwave",pos)
	particle:SetVelocity(UP+angle)
	particle:SetDieTime(0.5+die)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(7+start)
	particle:SetEndSize(7+ran2)
	particle:SetColor(0,95,155)
	particle:SetRoll(roll)
	particle:SetRollDelta(1)
	particle:SetAirResistance( 20 );
	self.Emitter:Finish()
end