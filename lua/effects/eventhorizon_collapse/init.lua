/*
	Eventhorizon collapse effect for GarrysMod10
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
EFFECT.Material = Material("zup/stargate/eventhorizon_establish"); -- Normal "white" overlay
EFFECT.Collapse = Material("zup/stargate/eh_closing"); -- Thanks to flyboi who sent me this good material!
--################# Init @aVoN
function EFFECT:Init(data)
	if (not StarGate.VisualsMisc("cl_stargate_effects",true)) then return end
	local e = data:GetEntity();
	if(not (e and e:IsValid())) then return end;
	local mdl = e:GetModel();
	if(not (mdl and mdl ~= "" and mdl ~= "models/error.mdl")) then return end; -- Stops crashing ppl
	if(self.Material:GetName() == "___error") then return end; -- Also fixed ppl crashing
	if(self.Collapse:GetName() == "___error") then return end; -- Also fixed ppl crashing
	self.Angle = math.Rand(-20,20);
	self.Entity:SetModel(mdl);
	self.Entity:SetPos(e:GetPos());
	self.Entity:SetAngles(e:GetAngles());
	self.Entity:SetParent(e);
	self.Entity:SetColor(Color(255,255,255,1));
	--################# For hhe collapse effect
	self.FrameRate = 25; -- This is for the collapse effect
	self.FrameEnd = 17; -- The last frame of the animated texture above
	self.LifeTime = 3.3;
	self.Spawned = CurTime();
	self.Parent = e;
	self.LastMul = 0;
	self.Size = e:BoundingRadius()*1.4; -- The "Collapse's" size
	self:SetRenderBounds(Vector(1,1,1)*-1024,Vector(1,1,1)*1024);
	e.CurrentHorizonEffect = self.Entity;
	self.Draw = true;
	self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA);
end

--################# Think @aVoN
function EFFECT:Think()
	if(not (self.Draw and (self.Spawned+self.LifeTime) > CurTime())) then
		if(IsValid(self.Parent)) then
			self.Parent:SetNoDraw(true); -- Stop drawing the EH if the animation exited (but maybe the Render hook hasnt been run)
		end
		return false;
	end
	return true;
end

--################# Render @aVoN
function EFFECT:Render()
	if(not (self.Parent and self.Parent:IsValid() and self.Parent.CurrentHorizonEffect == self.Entity)) then
		self.Draw = nil;
		return;
	end
	if(not self.Draw) then return end; -- Stops crashing ppl

	-- test fix for client crash
	if (self.Collapse:GetName()!="zup/stargate/eh_closing") then
		self.Collapse = Material("zup/stargate/eh_closing");
	end
	if (self.Material:GetName()!="zup/stargate/eventhorizon_establish") then
		self.Material = Material("zup/stargate/eventhorizon_establish");
	end

	self.Parent.AllowBacksideDrawing = nil; -- Disable backside drawing!
	local mul = math.sin(math.pi*(CurTime()-self.Spawned)/self.LifeTime);
	if(mul > 0) then
		local pow = 10;
		if(self.LastMul > mul or self.StartedCollapse) then
			self.Parent.DrawRipple = false; -- stop ripple effect if enabled before
			self.Parent:SetNoDraw(true);
			pow = 70; -- Makes it much much faster disappear than it appeared!
			-- Lets start the real "collapse effect". The other is only the white fade
			-- Really big thank's to flyboi who sent me this cool material:
			self.StartedCollapse = self.StartedCollapse or CurTime();
			local frame = math.floor((CurTime()-self.StartedCollapse)*self.FrameRate);
			if(frame <= self.FrameEnd and self.Collapse:GetName()=="zup/stargate/eh_closing" and frame>=0 and frame<=17) then
				self.Parent:SetAlpha(1); -- If we are drawing the closing animation: Make the EH at low alpha!
				self.Entity:SetColor(Color(255,255,255,255));
				local pos = self.Entity:GetPos();
				local normal = self.Entity:GetForward();
				-- Took me 3 hours to figure out how to manually animate a texture. Well, that's the solution
				self.Collapse:SetInt("$frame",frame);
				render.SetMaterial(self.Collapse);
				render.DrawQuadEasy(pos,normal,self.Size,self.Size,Color(255,255,255,255),self.Angle); -- Draw from the front
				render.DrawQuadEasy(pos,-1*normal,self.Size,self.Size,Color(255,255,255,255),-1*self.Angle); -- Draw from the back
				render.MaterialOverride(0);
			else
				self.Parent:SetNoDraw(true);
				self.Draw = false;
				return;
			end
		else
			if (IsValid(self.Parent)) then
				self.Parent:SetAlpha(math.Clamp(255*(1-mul^pow)^0.4,1,255));
			end
			self.Entity:SetColor(Color(185,185,205,math.Clamp((mul^pow)*255,1,255)));
			render.MaterialOverride(self.Material);
			self.Entity:DrawModel();
			render.MaterialOverride();
		end
		self.LastMul = mul;
	end
end
