/*
	Drone for GarrysMod10
	Copyright (C) 2007  Zup

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
include("shared.lua");
language.Add("302missile",Language.GetMessage("entity_f302"));

--################### Init @aVoN
function ENT:Initialize()
	self.Created = CurTime();
	self.Emitter=ParticleEmitter(self:GetPos())
end

--################# Draw @aVoN
function ENT:Draw()

	local pos = self.Entity:GetPos();
	self.Size = self.Size or 60;
	self.Alpha = self.Alpha or 255;
	local time = self.Entity:GetNetworkedInt("turn_off",false);
	if(time) then
		-- Drone turns off (But only, when the Trail has been removed before)
		if(time+1 < CurTime()) then
			self.Size = math.Clamp((2-CurTime()+(time+1))*60,0,60);
		end
	end

	if((self)and(self:IsValid())) then
		self:ThrusterEffect(true)
	elseif(time) then
		self:ThrusterEffect(false)
	end

	-- Drone has to fade out
	if(self.Entity:GetNWBool("fade_out")) then
		self.Alpha = math.Clamp(self.Alpha-FrameTime()*80,0,255);
		self.Entity:SetColor(Color(255,255,255,self.Alpha));
	end
	self.Entity:DrawModel();
end

function ENT:ThrusterEffect()

	local pos = self:GetAttachment(self:LookupAttachment("Engine")).Pos
	local roll = math.Rand(-90,90)
	local normal = (self.Entity:GetForward() * -1):GetNormalized()

	local fx = self.Emitter:Add("sprites/orangecore1",pos)
	fx:SetVelocity(normal*2)
	fx:SetDieTime(0.05)
	fx:SetStartAlpha(255)
	fx:SetEndAlpha(255)
	fx:SetStartSize(15)
	fx:SetEndSize(5)
	fx:SetColor(math.Rand(220,255),math.Rand(220,255),195)
	fx:SetRoll(roll)

	local heatwv = self.Emitter:Add("sprites/heatwave",pos)
	heatwv:SetVelocity(normal*2)
	heatwv:SetDieTime(0.2)
	heatwv:SetStartAlpha(255)
	heatwv:SetEndAlpha(255)
	heatwv:SetStartSize(20)
	heatwv:SetEndSize(10)
	heatwv:SetColor(255,255,255)
	heatwv:SetRoll(roll)

end