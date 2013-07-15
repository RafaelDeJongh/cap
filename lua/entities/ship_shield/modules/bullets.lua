/*
	Shield SENT for GarrysMod10
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
-- Conditions (if we hit or not is defined in ini/cl.init!)
--################# This is the workaround for stopping bullets (FROM SWEPS AND SENTS ONLY!) getting into a shield @aVoN
hook.Add("StarGate.Bullet","StarGate.ShieldShip.Bullet",
	function(self,bullet,trace)
		local e = trace.Entity;
		if(IsValid(e) and e:GetClass() == "ship_shield") then
			-- Call the callback (e.g. to draw effects like bullet tracers!)
			if(bullet.Callback) then
				local dmg = DamageInfo();
				dmg:SetDamage(bullet.Damage or 0);
				bullet.Callback(self,trace,dmg);
			end
			if(SERVER) then
				--Draw a bullet tracer into the Shield
				if(bullet.Tracer ~= 0) then
					local fx = EffectData();
					fx:SetStart(bullet.Src);
					fx:SetOrigin(trace.HitPos);
					fx:SetScale(5000);
					fx:SetNormal(trace.HitNormal);
					util.Effect(bullet.TracerName or "Tracer",fx,true,true);
				end
				e:Hit(self,trace.HitPos,(bullet.Damage or 20)/20,-1*trace.Normal);
			end
			return true; -- Tell we override the original bullet!
		end
	end
);
