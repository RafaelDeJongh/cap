/*
	Cloaking Effect for GarrysMod10
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

if (StarGate==nil or StarGate.MaterialCopy==nil) then return end
EFFECT.Material = StarGate.MaterialCopy("CloakingMuzzle","models/shadertest/predator");

local Friends = {};

net.Receive("Stargate.Cloak.Friends",function(len)
	local tbl = {}
	for k,v in pairs(Friends) do
		if (IsValid(k)) then tbl[k] = v end
	end
	Friends = tbl;
	local ent = net.ReadEntity();
	if (not IsValid(ent)) then return end
	Friends[ent] = net.ReadTable();
end)

--################### Init @aVoN
function EFFECT:Init(data)
	local e = data:GetEntity();	
	if(e == LocalPlayer()) then return end; -- Do not draw this on me. Looks ugly
	if(not IsValid(e)) then return end;
	local mdl = e:GetModel();
	if(not (mdl and mdl ~= "" and mdl ~= "models/error.mdl")) then return end;
	local scale = data:GetScale();
	--###################Define, what we are currently doing: Engage cloak or disengage?
	local time = CurTime();
	if(scale > 0) then
		self.Engage = true;
	elseif(scale < 0) then
		self.Engage = false;
	else return end;
	self.LifeTime = math.abs(scale);
	self.Created = time;
	--################### Use shaders (Config)?
	if(self.LifeTime > 1) then
		self.UseShader = StarGate.VisualsMisc("cl_cloaking_shader");
	else
		self.UseShader = StarGate.VisualsMisc("cl_cloaking_hitshader");
	end
	--################### Disable shaders entity based?
	if(e:GetClass() == "prop_ragdoll" or e:IsPlayer() or e:IsNPC()) then
		self.NoShader = true;
	end
	--################### Old effect still running? - Tell the old effect our data instead of creating a new effect instead
	if(IsValid(e.CurrentCloak)) then
		e.CurrentCloak.UseShader = self.UseShader;
		if(e.CurrentCloak.PermaDraw) then -- Permadraw
			if(self.Engage) then
				if(self.LifeTime <= 1 and (e.CurrentCloak.LifeTime <= 1 or (e.CurrentCloak.LifeTime + e.CurrentCloak.Created < time))) then
					-- Never mind, just a hit effect. Draw this!
					e.CurrentCloak.LifeTime = self.LifeTime;
					e.CurrentCloak.Created = time;
				end
				return; -- KEEP OLD
			end
			e.CurrentCloak:Remove();
		else -- Normal draw
			if(e.CurrentCloak.LifeTime == self.LifeTime) then
				if(e.CurrentCloak.Engage == self.Engage) then
					e.CurrentCloak.Created = time;
					return; -- KEEP OLD
				end
				self.Created = 2*time - e.CurrentCloak.LifeTime - e.CurrentCloak.Created; -- Make it start fading where the other effect stopped before
				e.CurrentCloak:Remove();
			elseif(self.LifeTime > e.CurrentCloak.LifeTime) then
				e.CurrentCloak:Remove();
			else return end; -- KEEP OLD
		end
	end
	local color = e:GetNetworkedVector("cloak_color",Vector(255,255,255));
	local alpha = e:GetNWInt("alpha",255);
	local pos = e:GetPos();
	self.Color = Color(color.x,color.y,color.z,alpha);
	self.Entity:SetModel(mdl);
	self.Entity:SetPos(pos);
	self.Entity:SetMaterial(e:GetMaterial());
	self.Entity:SetAngles(e:GetAngles());
	self.Entity:SetSkin(e:GetSkin() or 0);
	self.Entity:SetParent(e);
	self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA);
	local start_alpha = 1;
	if(self.Engage and self.LifeTime > 1) then start_alpha = 255 end; -- Only 255 alpha, when it's not a short flicker (less than 1 sec) or when it engages the field (aka starts cloaking)
	self.Entity:SetColor(Color(self.Color.r,self.Color.g,self.Color.b,start_alpha));
	self.Parent = e;
	self.Entity.NextUse = {TogglePods = CurTime(), ToggleDoor = CurTime(), ToggleBulk = CurTime(), ToggleWeps = CurTime(),}; // Jumper Settings
	e.CurrentCloak = self.Entity;
	
	self.Draw = true;
end

--################### The Functions below are to do with the Jumper, I.E it's animations @ Liam0102(RononDex)
function EFFECT:ToggleJumperWeps(instant)

	local e = self.Entity;
	local cd = self.Parent.CloakData;
	
	if(e.NextUse.ToggleWeps < CurTime()) then
		if(cd.WepPods) then
			e.WepSeq = e:LookupSequence("wepo");
		else
			e.WepSeq = e:LookupSequence("wepc");
		end
		e:ResetSequence(e.WepSeq);
		e:SetPlaybackRate(1);
		e.NextUse.ToggleWeps = CurTime()+1;
	end

end

function EFFECT:ToggleJumperDoor(instant)

	local e = self.Entity;
	local cd = self.Parent.CloakData;
	
	if(e.NextUse.ToggleDoor < CurTime()) then
		if(cd.Door) then
			if(cd.BulkHead) then
				e.DoorSeq = e:LookupSequence("bodoorc")
			else
				e.DoorSeq = e:LookupSequence("bcdoorc")
			end
		else
			if(cd.BulkHead) then
				e.DoorSeq = e:LookupSequence("bodooro")
			else
				e.DoorSeq = e:LookupSequence("bcdooro")
			end
		end
		e:ResetSequence(e.DoorSeq);
		e:SetPlaybackRate(0.675);
		e.NextUse.ToggleWeps = CurTime()+1;
	end
end

function EFFECT:ToggleJumperBulkHead(instant)

	local e = self.Entity;
	local cd = self.Parent.CloakData;
	
	if(e.NextUse.ToggleBulk < CurTime()) then
		if(cd.BulkHead) then
			if(cd.Door) then
				e.BulkSeq = e:LookupSequence("dobulkc")
			else
				e.BulkSeq = e:LookupSequence("dcbulkc")
			end
		else
			if(cd.Door) then
				e.BulkSeq = e:LookupSequence("dobulko")
			else
				e.BulkSeq = e:LookupSequence("dcbulko")
			end
		end
		e:ResetSequence(e.BulkSeq);
		e:SetPlaybackRate(0.8);
		e.NextUse.ToggleWeps = CurTime()+1;
	end

end

function EFFECT:ToggleJumperPods(instant)

	local e = self.Entity;
	local cd = self.Parent.CloakData;
	
	if(e.NextUse.TogglePods < CurTime()) then
		if(cd.Pods) then
			e.PodSeq = e:LookupSequence("epodo");
		else
			e.PodSeq = e:LookupSequence("epodc");
		end
		e:ResetSequence(e.PodSeq);
		e:SetPlaybackRate(0.9);
		e.NextUse.TogglePods = CurTime()+1;
	end

end

function EFFECT:CheckJumper()

	if(self.Parent:GetClass()=="puddle_jumper") then
		if(self.Parent.CloakData.Cloaked) then
			if(IsValid(self.Entity)) then
				if(!self.StartAnim) then
					local cd = self.Parent.CloakData;
					local e = self.Entity;
					if(cd.Pods) then
						e:ResetSequence(e:LookupSequence("epodc"));
					elseif(cd.WepPods) then
						e:ResetSequence(e:LookupSequence("wepc"));
					elseif(cd.Door) then
						if(cd.BulkHead) then
							e:ResetSequence(e:LookupSequence("bodoorc"));
						else
							e:ResetSequence(e:LookupSequence("bcdoorc"));
						end
					elseif(cd.BulkHead) then
						if(!cd.Door) then
							e:ResetSequence(e:LookupSequence("dcbulkc"));
						end
						
					//elseif(cd.BulkHead) then
					//	if(cd.Door) then
					//		e:ResetSequence(e:LookupSequence("dobulkc"));
					//	else
					//		e:ResetSequence(e:LookupSequence("dcbulkc"));
					//	end
					end
					self.StartAnim = true;
				end
			end
		end
	end

end

--################### Think @aVoN
function EFFECT:Think()
	self.Draw = (self.Created or 0) + (self.LifeTime or 0) > CurTime();
	if(not IsValid(self.Parent)) then return false end; -- We aren't valid - Stop us!
	
	self:CheckJumper();
	
	local draw = self.Draw or self.PermaDraw; -- Should we draw?
	if(draw and not self.HasBeenDrawn) then -- We shall draw but we haven't been drawn yet. Force a draw (mostly for "VisibleForOwner")
		self:Render(true);
		return true;
	end
	if(not draw) then self:Render(true) end;-- We shall not draw anymore - so we died! Anyway, run the drawhook atleast one time (force) so the color etc is getting reset
	return draw;
end

--################### Render the effect @aVoN
function EFFECT:Render(draw_anyway)
	if(not IsValid(self.Parent)) then
		self.Draw = nil;
		self.PermaDraw = nil;
		return; -- FIXME: Add some drawstuff in here...
	end
	if(not (self.Draw or self.PermaDraw or draw_anyway)) then return end;
	self.HasBeenDrawn = true;
	-- Must be calced everytime (gay server->client delay)
	local color = self.Parent:GetNWVector("cloak_color",Vector(255,255,255));
	local alpha = self.Parent:GetNWInt("alpha",255);
	self.Color = Color(color.x,color.y,color.z,alpha);
	local multiply = (self.Created + self.LifeTime - CurTime())/self.LifeTime;
	local refract = 0; -- Dummy
	--################### Lifetime <= 1 means: do a sinus fade effec instead of a linear 255->0 or 0->255
	if(self.LifeTime <= 1) then
		multiply = math.sin(math.pi*(1 - multiply))/3;
		refract = multiply;
	else
		refract = math.sin(math.pi*(1 - multiply^2));
		if(not self.Engage) then multiply = 1 - multiply end; -- We are fading out
		refract = refract*math.exp(-3*multiply); -- Add a bit damping to the effect!
	end
	local min_alpha = 1;
	local alpha = self.Color.a*multiply;
	--################### To show this only to the Owner, we need to do this...
	local immune = self.Parent:GetNWEntity("cloak_player",false);
	if (immune!=false) then
		if(immune == LocalPlayer() or CPPI and Friends[immune] and table.HasValue(Friends[immune],LocalPlayer())) then
			min_alpha = 130;
			if(self.Engage) then self.PermaDraw = true end;
		end
	end
	alpha = math.Clamp(alpha,min_alpha,self.Color.a); -- Avoids some ugly sideeffects if your uncloaking from "Visible for owner" mode
	if(self.NoShader) then
		self.Parent:SetColor(Color(self.Color.r,self.Color.g,self.Color.b,alpha));
	else
		-- Permanently setting of the color
		self.Entity:DrawModel();
		self.Entity.AutomaticFrameAdvance = true;
		self.Entity:SetColor(Color(self.Color.r,self.Color.g,self.Color.b,alpha));
		if(not self.Draw) then return end;
		--################### Refract is always limited to time. But not the "always-drawing" above for the owner
		if(not self.UseShader or not self.Material) then return end;
		self.Material:SetFloat("$refractamount",refract);
		render.UpdateScreenEffectTexture();
		render.MaterialOverride(self.Material);
		self.Entity:DrawModel();
		render.MaterialOverride();
	end
end
