--[[
	Satellite Blast Wave
	Copyright (C) 2010 Madman07

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

]]--

include("shared.lua");
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("sat_blast_wave",SGLanguage.GetMessage("sat_blask_wave"));
end

function ENT:Initialize()

	self.Relative = 0
	self.StartPos = self:GetEntPos()
	self.Emitter = ParticleEmitter(self.StartPos)

end

function ENT:Draw()
end

function ENT:Think()

	self.Relative = self:GetEntRadius()/1000;

	if self.Relative > 15 then return end

	if (self.Relative < 6) then
		local num = self.Relative*25
		local ang = Angle(90, 0, 0)
		local fw = ang:Up()
		local ri = ang:Right()
		local spawn = {}

		for i=1,num do
			local Ang = i*math.pi*2/num
			spawn[i] = self.StartPos+self.Relative*1000*(math.sin(Ang)*ri+math.cos(Ang)*fw)
		end


		for i=1,num do

			local part = self.Emitter:Add("sprites/gmdm_pickups/light", spawn[i])
			part:SetVelocity(Vector(0,0,0))
			part:SetDieTime(0.5)
			part:SetStartAlpha(255)
			part:SetEndAlpha(0)
			part:SetStartSize(math.random(600,680))
			part:SetEndSize(math.random(520,600))
			part:SetRoll(math.Rand(20, 80))
			part:SetRollDelta(math.random(-1, 1))
			part:SetColor(255,math.random(100,200),math.random(50,100))

			local part2 = self.Emitter:Add("sprites/gmdm_pickups/light", self.StartPos)
			part2:SetVelocity(Vector(0,0,0))
			part2:SetDieTime(0.5)
			part2:SetStartAlpha(255)
			part2:SetEndAlpha(0)
			part2:SetStartSize(math.random(600,680))
			part2:SetEndSize(math.random(520,600))
			part2:SetRoll(math.Rand(20, 80))
			part2:SetRollDelta(math.random(-1, 1))
			part2:SetColor(255,math.random(100,200),math.random(50,100))

		end

	end

end
