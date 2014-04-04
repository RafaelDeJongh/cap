/*
	Staff Weapon for GarrysMod10
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
	local n = data:GetNormal();
	if(data:GetScale() == -1) then n = Vector(0,0,0) end; -- Exploding in the air has no surface normal!
	local size = data:GetMagnitude();
	local color = data:GetAngles();
	self.Color = Color(255,200,120);
	self.FlameColor = Color(255,200,120);
	if(color ~= Angle(0,0,0)) then
		self.Color = Color(color.p,color.y,color.r);
		self.FlameColor = self.Color; -- Someone wants to colorize the explosion too...
	end
	-- HitSound
	sound.Play("ambient/explosions/explode_"..math.random(1,5)..".wav",pos,90,math.random(80,120));
	local em = ParticleEmitter(pos)
	-- ######################## Draw smoke
	if(StarGate.VisualsWeapons("cl_staff_smoke")) then
		-- ######################## Smoke "AI" - do not add too much of long lasting smoke!
		local time = CurTime();
		local draw_smoke = true;
		for k,v in pairs(self.LastPos) do
			if(k+8 > time) then
				if((v-pos):Length() < 100) then
					draw_smoke = false;
					break;
				end
			else
				self.LastPos[k] = nil;
			end
		end
		-- Get surface color (colorize the smoke)
		local c = render.GetSurfaceColor(pos+n,pos-n*10)*255;
		c.r = math.Clamp(c.r+40,0,255);
		c.g = math.Clamp(c.g+40,0,255);
		c.b = math.Clamp(c.b+40,0,255);
		for i=0,5 do
			-- The long lasting smoke will only be "spawnable" every 8 seconds if the last shots are neared than 100 units
			if(draw_smoke) then
				local pt = em:Add("particles/smokey",pos+n*16);
				pt:SetVelocity(n*math.random(1,5));
				pt:SetDieTime(math.random(5,15));
				pt:SetStartAlpha(math.random(50,150));
				pt:SetStartSize(math.random(40,80));
				pt:SetEndSize(math.random(128,256));
				pt:SetRoll(0);
				pt:SetColor(c.r,c.g,c.b);
				self.LastPos[time] = pos;
			end
			-- Short lasting smoke
			local pt = em:Add("particles/smokey",pos+n*32);
			pt:SetVelocity(n*100);
			pt:SetDieTime(0.4);
			pt:SetStartAlpha(200);
			pt:SetStartSize(60);
			pt:SetEndSize(math.random(128,256));
			pt:SetRoll(0);
			pt:SetColor(c.r,c.g,c.b);
		end
	end
	-- ######################## Flame/Explosion
	for i=0,50 do
		local pt = em:Add("particles/flamelet"..math.random(1,5),pos+n*math.random(20,40));
		pt:SetVelocity(VectorRand()*math.random(30,50)+n*math.random(40,80));
		pt:SetLifeTime(0);
		pt:SetDieTime(math.random(1,3));
		pt:SetStartAlpha(math.random(200,255));
		pt:SetEndAlpha(0);
		pt:SetStartSize(20+size*5);
		pt:SetEndSize(0);
		pt:SetRoll(math.random(-360,360));
		pt:SetRollDelta(math.random(-2,2));
		pt:SetColor(self.FlameColor.r,self.FlameColor.g,self.FlameColor.b);
	end
	--em:Finish();
	if(StarGate.VisualsWeapons("cl_staff_scorch")) then
		util.Decal("Scorch",pos+n*10,pos-n*10);
	end
	-- ######################## Dynamic light
	if(StarGate.VisualsWeapons("cl_staff_dynlights")) then
		local dynlight = DynamicLight(0);
		dynlight.Pos = pos;
		dynlight.Size = 668+size*500;
		dynlight.Decay = 1024;
		dynlight.R = self.Color.r;
		dynlight.G = self.Color.g;
		dynlight.B = self.Color.b;
		dynlight.DieTime = CurTime()+3;
	end
end

function EFFECT:Think() return false end;
function EFFECT:Render() end
