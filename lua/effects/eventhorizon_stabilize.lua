/*
	Eventhorizon stabilize effect for GarrysMod10
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

EFFECT.Material = Material("zup/stargate/eventhorizon_establish");
--################# Init @aVoN
function EFFECT:Init(data)
	if (not StarGate.VisualsMisc("cl_stargate_effects",true)) then return end
	local e = data:GetEntity()
	if(not (e and e:IsValid())) then return end;
	local mdl = e:GetModel();
	if(not (mdl and mdl ~= "" and mdl ~= "models/error.mdl")) then return end; -- Stops crashing ppl
	if(self.Material:GetName() == "___error") then return end; -- Also fixed ppl crashing
	self.Entity:SetModel(mdl);
	self.Entity:SetPos(data:GetOrigin());
	self.Entity:SetAngles(e:GetAngles());
	self.Entity:SetParent(e);
	self.LifeTime = data:GetScale(); -- How long does the effect last?
	self.FadeTime = math.Clamp(0.7,0,self.LifeTime); -- How long does the effect need to fade out?
	self.Spawned = CurTime();
	self.LastMul = 0;
	self.Parent = e;
	self:SetRenderBounds(Vector(1,1,1)*-1024,Vector(1,1,1)*1024);
	self.Draw = true;
	self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA);
	self.Main = util.tobool(data:GetRadius())
	if (self.Main) then
		e.CurrentHorizonEffect = self.Entity;
	else
		e.CurrentHorizonEffect2 = self.Entity;
	end
end

--################# Think @aVoN
function EFFECT:Think()
	local valid = (self.Draw and (self.Spawned+self.LifeTime) > CurTime());
	if(not valid and IsValid(self.Parent) and self.Parent.SetAlpha and self.Main) then
		self.Parent:SetAlpha(255); -- May fix that bug where the EH gets opened and stays "half invisible"
		--self.Parent.AllowBacksideDrawing = true; -- This tells the "EH-Backside" only to draw at 150
	end
	return valid;
end

--################# Render @aVoN
function EFFECT:Render()
	if(self.Draw and not (self.Parent and self.Parent:IsValid() and (self.Main and self.Parent.CurrentHorizonEffect==self.Entity or not self.Main and self.Parent.CurrentHorizonEffect2==self.Entity))) then
		self.Draw = false;
		return;
	end
	if(not self.Draw) then return end; -- Stops crashing ppl

	if (self.Material:GetName()!="zup/stargate/eventhorizon_establish") then
		self.Material = Material("zup/stargate/eventhorizon_establish");
	end

	local mul = 1;
	local diff = self.LifeTime-self.FadeTime;
	if(diff+self.Spawned < CurTime()) then
		mul = 1-math.Clamp((CurTime()-(self.Spawned+diff))/self.FadeTime,0,1);
	end
	-- Start the horizon's ripple effect
	if(self.Main and self.LastMul > mul) then
		self.Parent.DrawRipple = true;
	end
	self.LastMul = mul;
	self.Entity:SetColor(Color(255,255,255,mul*130));
	-- This is a workaround. It will regulated the alpha of the EH to go "down" to it's "Maximum Limit". So from the front it stays at 255, but from the back it will go down from 255 to 150 slowly so it doesnt look so sloppy from behind
	if(self.Main and IsValid(self.Parent) and self.Parent.SetAlpha) then
		self.Parent:SetAlpha(mul*350,true);
	end
	render.MaterialOverride(self.Material);
	self.Entity:DrawModel();
	render.MaterialOverride(0);
end
