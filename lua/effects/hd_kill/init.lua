/*
	Hand Device Beam for GarrysMod10
	Copyright (C) 2007 aVoN

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
EFFECT.Material1 = StarGate.MaterialCopy("HandBeam","generic_laser");
EFFECT.Material2 = StarGate.MaterialFromVMT(
	"HandGlow",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/light_glow01"
		"$nocull" 1
		"$additive" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
);
--################### Init @aVoN
function EFFECT:Init(data)
	local e = data:GetEntity();
	if(not (e and e:IsValid())) then return end;
	if(e:IsNPC()) then return end; -- NPC currently not supported due to limitations (Lua state of some necessary functions - I asked garry to make them shared next update)
	if(e.HandBeam and e.HandBeam:IsValid()) then return end; -- No double beams
	e.HandBeam = self.Entity;
	self.Entity:SetParent(e);
	self.Range = 200; -- maximum distance to hit a target
	self.IsSpectating = util.tobool(data:GetScale()); -- Are we specting out self? If yes, render the effect differently
	self.Start = e:GetPos();
	self.End = self.Start+e:GetAimVector()*self.Range;
	self.Parent = e;
	self.TimeOut = 0.25; -- How much seconds a player can aim not on a target but the beam will still be drawn on his head
	self.Draw = true;
end

--################### Think @aVoN
function EFFECT:Think()
	if(self.Draw) then self.Entity:SetRenderBoundsWS(self.Start,self.End) end;
	return self.Draw;
end

--################### Render the tracer @aVoN
function EFFECT:Render()
	if(not (self.Parent and self.Parent:IsValid())) then
		self.Draw = nil;
	else
		local is_me = (self.Parent == LocalPlayer());
		if((is_me and self.Parent:KeyDown(IN_ATTACK)) or (not is_me and self.Parent:GetNetworkedBool("shooting_hand",false))) then
			if(self.Parent:GetNWBool("handdevice_depleted",false)) then
				self.Parent:SetNetworkedBool("handdevice_depleted",false);
				self.Draw = nil;
			end
		else
			self.Draw = nil;
			self.Parent.HandBeam = nil;
			--self.Entity:Remove();
		end
	end
	if(not self.Draw) then return end
	--################### Calculate shootpos
	local viewmodel;
	if(self.Parent == LocalPlayer() and not self.IsSpectating) then
		viewmodel = self.Parent:GetViewModel();
	else
		if(self.Parent:IsPlayer()) then
			viewmodel = self.Parent:GetActiveWeapon();
		else
			-- THIS PART IS STILL A COPY & PASTE FROM MY ZAT - I asked garry to put theses functions to shared (GetAimVector and GetActiveWeapon)
			-- For NPCs (Because NPC:GetActiveWeapon() is currently serverside)
			-- http://www.garrysmod.com/bugs/view.php?id=802 and http://www.garrysmod.com/bugs/view.php?id=801
			viewmodel = self.Parent:GetNWEntity("zat");
		end
	end
	if(not (viewmodel and viewmodel:IsValid())) then self.Draw = false return end; -- Failsafe
	local attach = viewmodel:GetAttachment(1);
	if(not (attach and attach.Pos)) then self.Draw = false return end; -- Failsafe
	self.Start = attach.Pos;
	--################### Autoaim for the head
	local time = CurTime();
	local normal = self.Parent:GetAimVector();
	local pos = self.Parent:GetShootPos();
	local trace = util.QuickTrace(pos,normal*self.Range,self.Parent);
	if(trace.Hit) then
		if(trace.Entity and trace.Entity:IsValid()) then
			self.Target = trace.Entity;
			self.LastAim = time;
		elseif((self.LastAim or 0) + self.TimeOut < time) then
			self.Target = nil;
		end
	elseif((self.LastAim or 0) + self.TimeOut < time) then
		self.Target = nil;
	end
	local valid = false;
	if(self.Target and self.Target:IsValid()) then
		if(self.Target:IsNPC()) then
			self.End = self.Target:GetPos() + Vector(0,0,60);
			valid = true;
		elseif(self.Target:IsPlayer()) then
			self.End = self.Target:GetShootPos();
			valid = true;
		end
	end
	if(valid) then
		-- Well we found the endpos, but correct this a little bit to hit the NPC's/Players real face and not somwhere inside his head
		local trace = util.QuickTrace(pos,(self.End - self.Start):GetNormalized()*self.Range,self.Parent);
		if(trace.Hit) then
			self.End = trace.HitPos;
		end
	else
		if(trace.Hit) then
			self.End = trace.HitPos;
		else
			self.End = self.Start+normal*self.Range;
		end
	end
	--################### Draw the beam
	local sin = math.sin(time*math.pi*2);
	local dist = (self.Start - self.End):Length();
	local tex1 = time*2;
	local tex2 = tex1 - dist/128;
	-- Draw the actual beam
	render.SetMaterial(self.Material1);
	render.DrawBeam(
		self.Start,
		self.End,
		5,
		tex1,
		tex2,
		Color(255,128,0,255)
	);
	render.SetMaterial(self.Material2);
	-- Draw a muzzle light
	render.DrawSprite(
		self.Start,
		64,64,
		Color(255,128,0,200 + 55*sin)
	);
	-- Drawn the effect on the end
	render.DrawSprite(
		self.End,
		24,24,
		Color(255,128,0,200 + 55*sin)
	);
end
