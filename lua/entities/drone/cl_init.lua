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
if (StarGate==nil or StarGate.MaterialFromVMT==nil) then return end
ENT.Glow = StarGate.MaterialFromVMT(
	"DroneSprite",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/light_glow01"
		"$nocull" 1
		"$additive" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
);
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("drone",SGLanguage.GetMessage("drone_kill"));
end

--################### Init @aVoN
function ENT:Initialize()
	self.Created = CurTime();
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
	if(StarGate.VisualsWeapons("cl_drone_glow")) then
		-- The sprite on the drone
		render.SetMaterial(self.Glow);
		render.DrawSprite(
			self.Entity:GetPos(),
			self.Size,self.Size,
			Color(255,210,100,255)
		);
	end
	-- Drone has to fade out
	if(self.Entity:GetNWBool("fade_out")) then
		self.Alpha = math.Clamp(self.Alpha-FrameTime()*80,0,255);
		self.Entity:SetColor(Color(255,255,255,self.Alpha));
	end
	self.Entity:DrawModel();
end

--################# Think (From StaffWeapon flyby code) @aVoN
function ENT:Think()
	if(self.Entity:GetNWBool("turn_off")) then return end;
	-- ######################## Flyby-noise
	if((self.Last or 0)+0.6 <= CurTime() and (CurTime()-self.Created) >= 0.05) then
		local v = self.Entity:GetVelocity();
		local v_len = v:Length();
		local d = (LocalPlayer():GetPos()-self.Entity:GetPos());
		local d_len = d:Length();
		if(d_len <= 700) then
			self.Last = CurTime();
			-- Vector math: Get the distance from the player orthogonally to the projectil's velocity vector
			local intensity = math.sqrt(1-(d:DotProduct(v)/(d_len*v_len))^2)*d_len;
			self.Entity:EmitSound(Sound("weapons/drone_flyby.mp3"),100*(1-intensity/1000),math.random(80,120));
		end
	end
end
