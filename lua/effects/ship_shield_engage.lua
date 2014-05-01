/*
	Stargate Shield for GarrysMod10
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

EFFECT.Materiala = Material("effects/shielda");
EFFECT.Materialb = Material("effects/shieldb");

--################# Init @aVoN
function EFFECT:Init(data)
	if(not StarGate.VisualsMisc("cl_shield_bubble")) then return end;
	self.Radius = data:GetScale();
	self.Alpha = 0;
	local e = data:GetEntity();
	if(not e:IsValid()) then return end;
	-- Color (also needed for the other shield bubble
	local color = e:GetNetworkedVector("shield_color",Vector(1,1,1));
	self.Color = Color(color.x,color.y,color.z);
	local magnitude = math.ceil(data:GetMagnitude());
	local hit = false;
	if(magnitude == 2) then hit = true end;
	if(magnitude == 1) then self.TurnOff = true end;
	-- We already have one bubble. Do not this effect, rather extend the other older...
	local shield = e.ShieldBubble;
	if(IsValid(shield)) then
		if(self.TurnOff) then
			shield:Remove();
		elseif(hit) then
			if((CurTime()-shield.Created)/shield.LifeTime > 0.04) then
				shield.StartWithFullAlpha = true; -- Start at full alpha instead to avoid ugly side effects
			end
			shield.Created = CurTime();
			self:Remove();
			return;
		end
	end
	e.ShieldBubble = self.Entity;
	--self.Entity:SetParent(e); -- Parent to the shield so it moves along with it
	-- This above was the old method. Sadly, it looks ugly when the hit effect does the same barrel roll like your ship
	self.JumperLast = false;
	self.IsJumper = false;
	local model = e:GetNWString("shield_model","");
	if (model == "sg_vehicle_shuttle") then self.Entity:SetModel(Model("models/Madman07/shields/destiny_shield.mdl"));
	elseif (model == "sg_vehicle_hatak") then self.Entity:SetModel(Model("models/Madman07/shields/hatak_shield.mdl"));
	elseif (model == "sg_vehicle_daedalus") then self.Entity:SetModel(Model("models/Madman07/shields/daedalus_shield.mdl"));
	elseif (model == "sg_vehicle_aurora") then self.Entity:SetModel(Model("models/Madman07/shields/aurora_shield.mdl"));
	elseif (model == "puddle_jumper") then self.IsJumper = true;
	elseif (model == "puddle_jumperv4") then self.IsJumper = true;
	else self.Entity:SetModel(Model("models/zup/shields/200_shield.mdl")); end
	if self.IsJumper then
		if e:GetNWBool("shield_jumper_open") then
			self.Entity:SetModel("models/Madman07/shields/jumper_shield_open.mdl");
		else
			self.Entity:SetModel("models/Madman07/shields/jumper_shield_close.mdl");
		end
		self.JumperLast = e:GetNWBool("shield_jumper_open");
	end

	self.Entity:SetPos(e:GetPos());
	self.Entity:SetColor(Color(color.x*255,color.y*255,color.z*255,1));
	self.Entity:SetRenderMode( RENDERMODE_TRANSALPHA );
	self.Draw = true;
	self.Created = CurTime();
	self.LifeTime = 1;
	self.Parent = e;
end

--################# Think @aVoN
function EFFECT:Think()
	if self.IsJumper then
		local status = self.Parent:GetNWBool("shield_jumper_open");
		if self.JumperLast != status then
			if status then
				self.Entity:SetModel("models/Madman07/shields/jumper_shield_open.mdl");
			else
			self.Entity:SetModel("models/Madman07/shields/jumper_shield_close.mdl");
			end
			self.JumperLast = status;
		end
	end

	return (self.Draw and self.Created + self.LifeTime > CurTime());
end

--################# Render @aVoN
function EFFECT:Render()
	if(not (self.Parent and self.Parent:IsValid())) then self.Draw = nil end;
	if(not self.Draw) then return end;
	self.Entity:SetPos(self.Parent:GetPos()); -- Instead of parenting (look in Init why I'm doing it)
	--################# This is actually the part which makes the effect in different sizes.
	-- It is created a new render target which's size is simply changed
	local multiply = (CurTime()-self.Created)/self.LifeTime;
	if(multiply >= 0) then
		if(self.StartWithFullAlpha and multiply < 0.5) then
			multiply = 0.5;
		end
		local alpha = math.Clamp(math.Clamp(math.sin(multiply*math.pi)*1.3,0,1)*70,1,70);
		local size = self.SizeMultiplier;
		if(self.TurnOff) then
			-- When the shield collapes, we will add a shrinking effect
			alpha = math.Clamp(140*(1-multiply)^10,1,140);
		end
		self.Entity:SetColor(Color(self.Color.r*255,self.Color.g*255,self.Color.b*255,alpha));
		render.MaterialOverride(self.Materiala);
		-- Thanks to catdaemon telling me the existance about this function. Makes everything easier compared with difficult cam3D and normal resize
		self.Entity:SetAngles(self.Parent:GetAngles());
		self.Entity:DrawModel();

		-- Turn off or fail effect
		render.MaterialOverride(self.Materialb);
		self.Entity:SetAngles(self.Parent:GetAngles());
		self.Entity:DrawModel();

		render.MaterialOverride(nil);
	end
end
