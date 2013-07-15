/*
	Eventhorizon opening effect for GarrysMod10
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

EFFECT.Material = Material("Zup/Stargate/eventhorizon_establish");
-- Taken from the collapse effect. Looks also cool on opening sequence
EFFECT.Collapse = Material("Zup/Stargate/eh_closing"); -- Thanks to flyboi who sent me this good material! (We will play it reversed!)
--################# Init @aVoN
function EFFECT:Init(data)
	if (not StarGate.VisualsMisc("cl_stargate_effects",true)) then return end
	local e = data:GetEntity()
	if(not (e and e:IsValid())) then return end;
	local mdl = e:GetModel();
	if(not (mdl and mdl ~= "" and mdl ~= "models/error.mdl")) then return end; -- Stops crashing ppl
	if(self.Material:GetName() == "___error") then return end; -- Also fixed ppl crashing
	if(self.Collapse:GetName() == "___error") then return end; -- Also fixed ppl crashing
	self.Angle = math.Rand(-20,20); -- Random angle for the collapse effect
	self.Entity:SetModel(mdl);
	self.Entity:SetPos(e:GetPos());
	self.Entity:SetAngles(e:GetAngles());
	self.Entity:SetParent(e);
	self.LifeTime = data:GetScale(); -- How long does the effect last?
	self.Entity:SetColor(Color(255,255,255,1)); -- Make us nearly invisible (but not completely or it wont be drawn!)
	self.Delay = 0.5;
	self.Spawned = CurTime();
	self.Parent = e;
	e.CurrentHorizonEffect = self.Entity;
	self.FrameRate = 25; -- This is for the collapse effect
	self.FrameEnd = 17; -- The last frame of the animated texture above
	self.Size = e:BoundingRadius()*1.4; -- The "Collapse's" size
	self.Draw = true;
	self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA);
end

--################# Think @aVoN
function EFFECT:Think() return (self.Draw and (self.Spawned+self.LifeTime) > CurTime()) end;

--################# Render @aVoN
function EFFECT:Render()
	if(self.Draw and not (self.Parent and self.Parent:IsValid() and self.Parent.CurrentHorizonEffect == self.Entity)) then
		self.Draw = false;
		return;
	end
	if(not self.Draw) then return end; -- Stops crashing ppl
	if(CurTime()-self.Spawned < self.Delay/3) then return end;
	self.StartedCollapse = self.StartedCollapse or CurTime();
	local frame = math.floor((CurTime()-self.StartedCollapse)*self.FrameRate);
	if(frame <= self.FrameEnd) then
		local pos = self.Entity:GetPos();
		local normal = self.Entity:GetForward();
		-- Took me 3 hours to figure out how to manually animate a texture. Well, that's the solution
		self.Collapse:SetInt("$frame",self.FrameEnd-frame);
		render.SetMaterial(self.Collapse);
		render.DrawQuadEasy(pos,normal,self.Size,self.Size,Color(255,255,255,255),self.Angle); -- Draw from the front
		render.DrawQuadEasy(pos,-1*normal,self.Size,self.Size,Color(255,255,255,255),-1*self.Angle); -- Draw from the back
	end
	if(CurTime()-self.Spawned < self.Delay) then return end;
	--IT MUST NEVER BE 0 OR IT WILL INSTANTLY STOP DRAWING! I HATE VALVE (or maybe garry?) IMPLEMENTING THIS SHIT! (maybe added for resource saving? who KNOWs!)
	local mul = math.Clamp((CurTime()-self.Spawned-self.Delay)/(self.LifeTime-self.Delay),0,1);
	if(mul > 0) then
		self.Entity:SetColor(Color(255,255,255,math.Clamp(mul*130,1,130)));
		render.MaterialOverride(self.Material);
		self.Entity:DrawModel();
		render.MaterialOverride(0);
		-- Not cutting this down somewhere makes the following effects UGLY white. Don't ask em why.
		/*if(mul < 0.8) then
			if(self.Parent and self.Parent:IsValid()) then
				self.Parent:SetAlpha(math.Clamp(mul*50,1,100));
			end
		end   */
		-- don't know what this should do, but in gmod13 it create bug
	end
end
