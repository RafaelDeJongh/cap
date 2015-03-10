/*
	Energy Hit for GarrysMod10
	Copyright (C) 2007  aVoN

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

EFFECT.LastPos = {}; -- Saves last positions so we wont draw too much smoke (which looks ugly!)
--################# Init @aVoN
function EFFECT:Init(data)
	local pos = data:GetOrigin();
	local e = data:GetEntity();
	local vel = Vector(0,0,0);
	local scale = data:GetScale();
	if not scale then scale = 1 end
	if(e and e:IsValid()) then
		vel = e:GetVelocity();
	end
	local color = data:GetAngles();
	self.Color = Color(color.p,color.y,color.r);
	local norm = data:GetNormal();
	local em = ParticleEmitter(pos);
	-- ######################## Sound
	sound.Play("weapons/mortar/mortar_explode"..math.random(1,3)..".wav",pos,80,math.random(80,120));
	-- ######################## Glowing particles
	for i=1,128 do
		local pt = em:Add("sprites/gmdm_pickups/light",pos+VectorRand()*math.random(4,6)*scale);
		pt:SetVelocity(norm*math.random(50,100)+VectorRand()*math.random(20,80)*scale+vel/10);
		pt:SetDieTime(math.random(1,8)/10);
		pt:SetStartAlpha(255);
		pt:SetEndAlpha(0);
		pt:SetStartSize(4*scale);
		pt:SetEndSize(1*scale);
		pt:SetColor(self.Color.r,self.Color.g,self.Color.b);
		--pt:VelocityDecay(false);
	end
	for i =1,12 do
		local pt = em:Add("sprites/gmdm_pickups/light",pos+VectorRand()*math.random(4,6)*scale);
		pt:SetVelocity(VectorRand()*10*scale+vel/10);
		pt:SetDieTime(1.5);
		pt:SetStartAlpha(255);
		pt:SetEndAlpha(0);
		pt:SetStartSize(24*scale);
		pt:SetEndSize(24*scale);
		pt:SetColor(self.Color.r,self.Color.g,self.Color.b);
		--pt:VelocityDecay(false);
	end
	-- ######################## Decal on the wall
	if(StarGate.VisualsWeapons("cl_staff_scorch")) then
		util.Decal("RedGlowFade",pos+norm*10,pos-norm*10);
		util.Decal("SmallScorch",pos+norm*10,pos-norm*10);
	end
	-- ######################## Smoke
	if(data:GetMagnitude() ~= -1 and StarGate.VisualsWeapons("cl_staff_smoke")) then
		-- ######################## Smoke "AI" - do not add too much of long lasting smoke!
		local time = CurTime();
		local draw_smoke = true;
		for k,v in pairs(self.LastPos) do
			if(k+8 > time) then
				if((v-pos):Length() < 40) then
					draw_smoke = false;
					break;
				end
			else
				self.LastPos[k] = nil;
			end
		end
		-- Get the surface color (colorize smoke)
		local c = render.GetSurfaceColor(pos+norm,pos-norm*10)*255;
		c.r = math.Clamp(c.r+40,0,255);
		c.g = math.Clamp(c.g+40,0,255);
		c.b = math.Clamp(c.b+40,0,255);
		-- Short lasting smoke
		local pt = em:Add("particles/smokey",pos+norm*32*scale);
		pt:SetVelocity(norm*100*scale);
		pt:SetDieTime(0.4);
		pt:SetStartAlpha(200);
		pt:SetStartSize(32*scale);
		pt:SetEndSize(math.random(50,140)*scale);
		pt:SetRoll(0);
		pt:SetColor(c.r,c.g,c.b);
		if(draw_smoke) then
			-- Long lasting smoke
			local pt = em:Add("particles/smokey",pos+norm*16*scale);
			pt:SetVelocity(norm*math.random(1,5)*scale);
			pt:SetDieTime(math.random(15,40));
			pt:SetStartAlpha(math.random(50,150));
			pt:SetStartSize(math.random(16,32)*scale);
			pt:SetEndSize(math.random(128,512)*scale);
			pt:SetRoll(0);
			pt:SetColor(c.r,c.g,c.b);
			self.LastPos[time] = pos;
		end
	end
	--em:Finish();
	-- ######################## Dynamic light
	if(StarGate.VisualsWeapons("cl_staff_dynlights")) then
		local dynlight = DynamicLight(0);
		dynlight.Pos = pos;
		dynlight.Size = 300*scale;
		dynlight.Decay = 300*scale;
		dynlight.R = self.Color.r;
		dynlight.G = self.Color.g;
		dynlight.B = self.Color.b;
		dynlight.DieTime = CurTime()+1;
	end
end

function EFFECT:Think() return false end; -- Make it die instantly
function EFFECT:Render() end
