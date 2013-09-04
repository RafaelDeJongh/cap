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
include("shared.lua");
ENT.Glow = StarGate.MaterialFromVMT(
	"StaffGlow",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/light_glow01"
		"$nocull" 1
		"$additive" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
);
ENT.Shaft = Material("effects/ar2ground2");
ENT.LightSettings = "cl_staff_dynlights_flight";
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("energy_pulse",SGLanguage.GetMessage("energy_pulse_kill"));
end
ENT.RenderGroup = RENDERGROUP_BOTH;

--################### Init @aVoN
function ENT:Initialize()
	self.Created = CurTime();
	self.DrawShaft = true;
	self.InstantEffect = not (self.Entity:GetClass() == "energy_pulse");
	self.Sounds = self.Sounds or {Sound("pulse_weapon/staff_flyby1.mp3"),Sound("pulse_weapon/staff_flyby2.mp3")};
	local snd = {}; -- Must be overwritten because garry's inheritance scripts interferes...
	for _,v in pairs(self.Sounds) do
		table.insert(snd,v);
	end
	self.Sounds = snd;
	local size = self.Entity:GetNetworkedInt("Size", 0);
	self.Sizes={20+size*3,20+size*3,180+size*10}; -- X,Y and shaft-leght!
end

--################### Draw the shot @aVoN
function ENT:Draw()
	if(not self.StartPos) then self.StartPos = self.Entity:GetPos() end; -- Needed for several workarounds
	local start = self.Entity:GetPos();
	local color = self.Entity:GetColor();
	if(self.DrawShaft) then
		local velo = self.Entity:GetVelocity();
		local dir = -1*velo:GetNormalized();
		-- Mainly a workaround for servers: The shots appeared to have their trails really late. Seems like the velocity simply was 0
		if(velo:Length() < 400) then
			if(self.StartPos) then
				dir = (self.StartPos-self.Entity:GetPos()):GetNormalized();
			end
		end
		local length = math.Clamp((self.Entity:GetPos()-self.StartPos):Length(),0,self.Sizes[3]);
		render.SetMaterial(self.Shaft);
		render.DrawBeam(
			self.Entity:GetPos(),
			self.Entity:GetPos()+dir*length,
			self.Sizes[1],
			1,
			0,
			color
		);
	end
	render.SetMaterial(self.Glow);
	for i =1,2 do
		render.DrawSprite(
			start,
			self.Sizes[2],self.Sizes[2],
			color
		);
	end
end

--################### Think: Play sounds! @aVoN
function ENT:Think()
	local size = self.Entity:GetNWInt("Size", 0);
	self.Sizes={20+size*3,20+size*3,180+size*10}; -- X,Y and shaft-leght!
	-- ######################## Flyby-light
	if(StarGate.VisualsWeapons(self.LightSettings)) then
		local color = self.Entity:GetColor();
		local r,g,b = color.r,color.g,color.b;
		local dlight = DynamicLight(self:EntIndex());
		if(dlight) then
			dlight.Pos = self.Entity:GetPos();
			dlight.r = r;
			dlight.g = g;
			dlight.b = b;
			dlight.Brightness = 1;
			dlight.Decay = 300;
			dlight.Size = 300;
			dlight.DieTime = CurTime()+0.5;
		end
	end
	local time = CurTime();
	-- ######################## Flyby-noise and screenshake!
	if((time-self.Created >= 0.1 or self.InstantEffect) and time-(self.Last or 0) > 0.3) then
		local p = LocalPlayer();
		local pos = self.Entity:GetPos();
		local norm = self.Entity:GetVelocity():GetNormal();
		local dist = p:GetPos()-pos;
		local len = dist:Length();
		local dot_prod = dist:DotProduct(norm)/len;
		if(math.abs(dot_prod) < 0.5 and dot_prod ~= 0) then
			-- Vector math: Get the distance from the player orthogonally to the projectil's velocity vector
			local intensity = math.sqrt(1 - dot_prod^2)*len;
			self.Entity:EmitSound(self.Sounds[math.random(1,#self.Sounds)],100*(1-intensity/2500),math.random(80,120));
			p:ConCommand("_StarGate.StaffBlast.ScreenShake "..tostring(pos)); -- Sadly, util.ScreenShake fails clientside so we need to tell the server that we want screenshake!
			self.Last = time;
		end
	end
	self.Entity:NextThink(time);
	return true;
end
