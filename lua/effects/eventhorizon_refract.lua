/*
	Eventhorizon refract effect for GarrysMod10
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

-- WHY I ADDED THIS.
-- Well some people dislike the event horizon beeing non-refractable. But I added this for purpose due to several problems I got with refract (aka. Clipping Bugs).
-- So people can turn on this now clientside if they wish to.
-- And the othere reason, why this is in effect form is, the SENT needs to have ENT.RenderGroup = RENDERGROUP_OPAQUE enabled, or it will also do a clipping bug.
-- Now, the effect is the only thing which can start clipping but not the event horizon. Further more, you can turn off the event horizon's refract so nobody is losing anything

EFFECT.Material = Material("zup/stargate/effect_03");
--################# Init @aVoN
function EFFECT:Init(data)
	if(not StarGate.VisualsMisc("cl_stargate_ripple")) then return end;
	local e = data:GetEntity()
	if(not (e and e:IsValid())) then return end;
	local mdl = e:GetModel();
	if(not (mdl and mdl ~= "" and mdl ~= "models/error.mdl")) then return end; -- Stops crashing ppl
	if(self.Material:GetName() == "___error") then return end; -- Also fixed ppl crashing
	self.Entity:SetModel(mdl);
	self.Entity:SetPos(e:GetPos());
	self.Entity:SetAngles(e:GetAngles());
	self.Entity:SetParent(e);
	self.Created = CurTime();
	self.Delay = 0.6;
	self.Refract = 0;
	self.Parent = e;
	self.Draw = true;
	self.OneTimeActivated = false;
	self:SetRenderBounds(Vector(1,1,1)*-1024,Vector(1,1,1)*1024);
	self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA);
end

--################# Think @aVoN
function EFFECT:Think() return self.Draw end;

--################# Render @aVoN
function EFFECT:Render()
	if(self.Draw and not IsValid(self.Parent)) then
		self.Draw = false;
		return;
	end
	if(not self.Draw) then return end; -- Stops crashing ppl
	if(self.Parent.DrawRipple) then -- Controlled by the other effects like "opening" and "closing"
		if(self.Parent.AllowBacksideDrawing) then
			self.Parent:SetAlpha(255); -- Fix up that the EH disappears sometimes
		end
		local dx = render.GetDXLevel();
		if(dx >= 80) then
			local multiplier = 1;
			if(dx == 80 or dx == 81) then multiplier = 0.2 end; -- Fix for DX8 users, because there, the shader looks ugly
			-- Fade in the effect
			if(self.Refract < 1) then
				self.Started = self.Started or CurTime();
				self.Refract = math.Clamp((CurTime()-self.Started)/self.Delay,0,1);
			end
			local dist = (self.Entity:GetPos()-LocalPlayer():GetPos()):Length();
			self.Material:SetFloat("$refractamount",multiplier*self.Refract*0.01*math.Clamp(500/dist,1,5));
			render.UpdateScreenEffectTexture(); -- Necessary for shaders or they can't get drawn (like the refract)
			render.UpdateRefractTexture(); -- Fixes issues with RTCam on the event horizon
			render.MaterialOverride(self.Material);
			self.Entity:DrawModel();
			render.MaterialOverride(0);
			self.OneTimeActivated = true;
		end
	elseif(self.Parent.DrawRipple == nil) then
		-- Well, the effect which initilize the ripple havent done this because we actually weren't in their FieldOfView- So do workaround here (Nobody will mention this, trust me)
		if(not self.OneTimeActivated and self.Created + 2 < CurTime()) then
			self.OneTimeActivated = true; -- Don't do this activation twice
			self.Parent.DrawRipple = true;
			self.Refract = 1; -- Start with instant ripple!
		end
	end
end
