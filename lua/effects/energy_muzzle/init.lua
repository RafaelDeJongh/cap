/*
	Energy Weapon Muzzle for GarrysMod10
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

if (StarGate==nil or StarGate.MaterialFromVMT==nil) then return end

EFFECT.Glow = StarGate.MaterialFromVMT(
	"MuzzleSprite",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/light_glow01"
		"$nocull" 1
		"$additive" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
);
EFFECT.Size = 64;
EFFECT.Color = Color(255,200,120);

--################### Init @aVoN
function EFFECT:Init(data)
	self.Parent = data:GetEntity();
	if(not IsValid(self.Parent)) then return end;
	self.Entity:SetParent(self.Parent);
	local radius = tonumber(data:GetRadius()) or 1;
	if(radius > 1) then
		self.Size = radius;
	end
	self.Entity:SetRenderBounds(Vector(1,1,1)*self.Size*(-2),Vector(1,1,1)*self.Size*2);
	local color = data:GetAngles();
	if(color ~= Angle(0,0,0)) then
		self.Color = Color(color.p,color.y,color.r);
	end
	-- ######################## Dynamic light
	-- Gets the visual-setting's name according to the weapon.
	local e = self.Parent;
	local class = e:GetClass();
	if(e:IsPlayer()) then e = e:GetActiveWeapon() end;
	if(IsValid(e)) then class = e:GetClass():gsub("weapon_","") end;
	if(class == "staff_weapon_glider") then class = "staff" end; -- Damn workaround!
	if(StarGate.VisualsWeapons("cl_"..(class or "").."_dynlights")) then
		local dynlight = DynamicLight(0);
		dynlight.Pos = data:GetOrigin();
		dynlight.Size = 300;
		dynlight.Decay = 300;
		dynlight.R = self.Color.r;
		dynlight.G = self.Color.g;
		dynlight.B = self.Color.b;
		dynlight.DieTime = CurTime()+1;
	end
	self.Draw = true;
end

--################### Render the effect @aVoN
function EFFECT:Render()
	if(not IsValid(self.Parent)) then return end;
	local start = self.Parent:GetPos();
	if(self.Parent.GetShootPos) then
		start =self.Parent:GetShootPos();
	end
	local viewmodel
	if(self.Parent == LocalPlayer()) then
		viewmodel = self.Parent:GetViewModel();
	else
		if(self.Parent.GetActiveWeapon) then
			viewmodel = self.Parent:GetActiveWeapon();
		end
	end
	if(not IsValid(viewmodel)) then return end;
	local attach = viewmodel:GetAttachment(1);
	if(not attach) then return end;
	start = attach.Pos;
	render.SetMaterial(self.Glow);
	render.DrawSprite(
		start,
		self.Size,
		self.Size,
		self.Color
	);
end

--################### Think @aVoN
function EFFECT:Think()
	self.Size = math.Clamp(self.Size-150*FrameTime(),0,1337);
	return (self.Size > 0 and self.Draw);
end
