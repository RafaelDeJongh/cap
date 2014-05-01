/*
	Zat-Tracer Effect for GarrysMod10
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
EFFECT.ZatShot = Material("jintopack/trail");
EFFECT.ZatBeam = Material("effects/tool_tracer");

--################### Init @aVoN
function EFFECT:Init(data)
	self.endpos = data:GetStart();
	if(self.endpos == Vector(0,0,0)) then return end;
	self.ZatShot = Material("jintopack/trail");
	self.ZatBeam = Material("effects/tool_tracer");
	self.Created = CurTime();
	self.scale = 10;
	self.speed = 15000;
	self.Color = {Color(40,142,255,255),Color(138,193,255,255)};
	self.ShotLength = 130; -- Tracers energy-beam length
	self.BeamFraction = 0;
	self.Owner = data:GetEntity();
	self.Entity:SetParent(self.Owner);
	-- Feeded by the server
	self.IsSpectating = false;
	self.start = data:GetOrigin();
	if(data:GetScale() == 1) then
		self.IsSpectating = true;
	end
	local sgn = {1,-1};
	self.sgn = sgn[math.random(1,2)]; -- For the Zat-Sinus effect: make it start from top or from below (randomness is cool)
	-- Mainbeam texturecoordinate randomness
	self.MainBeamTexCoord = {math.random(-2,2)/10,math.random(-1,1)/10};
	self.Life = true;
	self:SetRenderBoundsWS(self.start,self.endpos);
end

--################### Render the tracer @aVoN
function EFFECT:Render()
	if(not self.Life) then return end;
	if(not self.normal) then
		-- Failsafe
		if(not (self.Owner and self.Owner:IsValid())) then
			self.Life = false;
			return;
		end
		-- Calculate normal and shootpos
		local viewmodel;
		if(self.Owner == LocalPlayer() and not self.IsSpectating) then
			viewmodel = self.Owner:GetViewModel();
		else
			if(self.Owner:IsPlayer()) then
				viewmodel = self.Owner:GetActiveWeapon();
			else
				-- For NPCs (Because NPC:GetActiveWeapon() is currently serverside)
				-- http://www.garrysmod.com/bugs/view.php?id=802 and http://www.garrysmod.com/bugs/view.php?id=801
				viewmodel = self.Owner:GetNetworkedEntity("zat");
			end
		end
		-- Failsafe
		if(IsValid(viewmodel)) then
			local attach = viewmodel:GetAttachment(1);
			-- Failsafe
			if(not (attach and attach.Pos)) then
				self.Life = false;
				return;
			end
			self.start = attach.Pos;
		end
		self.normal = (self.endpos-self.start):GetNormalized();
		self.length =(self.endpos-self.start):Length();
		-- Avoid ugly beams on too short distances
		if(self.length < 500) then
			self.MainBeamTexCoord = {-0.1,-0.1};
		end
		self.MainBeamStart = self.start;
	end
	-- The main-Beam is getting established
	render.SetMaterial(self.ZatBeam);
	local multiplyer = math.sin((CurTime()-self.Created)*self.speed/2000);
	if(multiplyer < 0) then self.Life = false end;
	self.Color[1].a = 255*math.Clamp(multiplyer,0,1);
	self.Color[2].a = self.Color[1].a;
	if(multiplyer > self.BeamFraction) then self.BeamFraction = multiplyer end;
	render.DrawBeam(self.MainBeamStart,self.start+(self.endpos-self.start)*self.BeamFraction,self.scale*2,self.MainBeamTexCoord[1],self.MainBeamTexCoord[2],self.Color[1]);
	-- Create a tracer beam - The actual energy-beam
	if((self.Color[1].a >= 150 or self.Started)) then
		self.Started = self.Started or CurTime();
		local delta = (CurTime()-self.Started)*self.speed*self.normal;
		-- We reached the End completely - Stop the effect
		local length = delta:Length();
		if(length >= self.length*3) then
			self.Life = false;
			return;
		end
		self.MainBeamStart = self.start+delta/5; -- Let the mainbeam shrink
		if(length >= self.length) then return end; -- End for the tracer
		local start = self.start+self.normal*self.ShotLength;
		local endpos = self.start;
		render.SetMaterial(self.ZatShot);
		render.DrawBeam(start+delta,endpos+delta,self.scale*4,1,0,self.Color[2]);
		-- That adds some cool particles (the sinus-wave)
		local em = ParticleEmitter(self.Entity:GetPos());
		for i=1,math.floor(FrameTime()*self.speed/5) do
			local diff = delta+self.normal*i*5;
			local pos = self.start+diff+Vector(0,0,self.sgn*self.scale*math.sin(diff:Length()/70))
			local pt = em:Add("sprites/gmdm_pickups/light",pos);
			--pt:SetVelocity(VectorRand()*math.random(5,15)+Vector(0,0,-math.random(75,150)));
			pt:SetDieTime(2000/self.speed);
			pt:SetStartAlpha(self.Color[2].a);
			pt:SetEndAlpha(0);
			pt:SetStartSize(math.random(5,16));
			pt:SetStartSize(5);
			pt:SetEndSize(0);
			pt:SetRoll(0);
			pt:SetRollDelta(math.random(-10,10));
			pt:SetColor(40,142,255);
		end
		--em:Finish();
	end
end

--################### Think @aVoN
function EFFECT:Think()
	if(self.Life) then self.Entity:SetRenderBoundsWS(self.start,self.endpos) end;
	return self.Life
end
