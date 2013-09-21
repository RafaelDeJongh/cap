/*
	Stargate SENT for GarrysMod10
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

--################# HEADER #################
include("shared.lua");
ENT.RenderGroup = RENDERGROUP_OPAQUE -- This FUCKING THING avoids the clipping bug I have had for ages since stargate BETA 1.0. DAMN!

ENT.LightPositions = {
	Vector(8,88.2829,104.5427),
	Vector(8,134.7614,23.2695),
	Vector(8,118.6142,-68.3697),
	Vector(8,-118.5464,-68.4004),
	Vector(8,-134.9181,22.6665),
	Vector(8,-86.8867,105.0110),
	Vector(8,0.0461,136.2538),
	Vector(8,47.0651,-128.8588),
	Vector(8,-46.6631,-128.9825),
}
ENT.SpritePositions = {
	Vector(8,84.7845,100.6584),
	Vector(8,128.5390,23.2034),
	Vector(8,114.1802,-65.6066),
	Vector(8,-113.6151,-65.8050),
	Vector(8,-130.3172,22.9665),
	Vector(8,-84.0521,100.6424),
	Vector(8,0.1143,131.3542),
	Vector(8,44.9670,-123.5822),
	Vector(8,-45.0003,-123.5938),
}

ENT.ChevronSprite = Material("effects/multi_purpose_noz");

--################# SENT CODE ###############


--##################################
--#### Name/Address/Private Handling
--##################################


--################# Get the address of this gate @aVoN
-- ATTENTION: Make sure, this will be ALWAYS uppercased!
function ENT:GetGateAddress()
	return self:GetNetworkedString("Address",""):upper();
end

--################# Set a gate address @aVoN
function ENT:SetGateAddress(s)
	if(s and (s:len() == 6 or s == "")) then
		LocalPlayer():ConCommand("_StarGate.SetValue "..self.Entity:EntIndex().." Address \""..s.."\"");
	end
end

--################# Get the group of this gate by AlexALX
-- ATTENTION: Make sure, this will be ALWAYS uppercased!
function ENT:GetGateGroup()
	return self:GetNWString("Group",""):upper();
end

--################# Set a gate group by AlexALX
function ENT:SetGateGroup(s)
	if(s and (s:len() == 2 or s:len() == 3 and self.Entity:GetClass() == "stargate_universe")) then
		LocalPlayer():ConCommand("_StarGate.SetValue "..self.Entity:EntIndex().." Group \""..s.."\"");
	end
end

--################# Get the name of this gate @aVoN
function ENT:GetGateName()
	return self:GetNWString("Name","");
end

--################# Set the gate's name @aVoN
function ENT:SetGateName(s)
	if(s) then
		LocalPlayer():ConCommand("_StarGate.SetValue "..self.Entity:EntIndex().." Name \""..s.."\"");
	end
end

--################# Is the stargate private? @aVoN
function ENT:GetPrivate()
	return self:GetNWBool("Private",false);
end

--################# Set Private state @aVoN
function ENT:SetPrivate(b)
	LocalPlayer():ConCommand("_StarGate.SetValue "..self.Entity:EntIndex().." Private "..tostring(b));
end

--################# Is the stargate local? by AlexALX
function ENT:GetLocale()
	if (not self:GetNWBool("SG_GROUP_SYSTEM")) then return false; end
	return self:GetNWBool("Locale",false);
end

--################# Set local state by AlexALX
function ENT:SetLocale(b)
	LocalPlayer():ConCommand("_StarGate.SetValue "..self.Entity:EntIndex().." Locale "..tostring(b));
end

function ENT:GetGalaxy()
	return self:GetNWBool("Galaxy",false);
end

function ENT:SetGalaxy(b)
	LocalPlayer():ConCommand("_StarGate.SetValue "..self.Entity:EntIndex().." Galaxy "..tostring(b));
end

--################# Is the stargate blocked? by AlexALX
function ENT:GetBlocked()
	if (self:GetNetworkedInt("SG_BLOCK_ADDRESS")<=0 or self:GetNetworkedInt("SG_BLOCK_ADDRESS")==1 and self:GetClass()!="stargate_universe") then return false; end
	return self:GetNWBool("Blocked",false);
end

--################# Set Blocked state by AlexALX
function ENT:SetBlocked(b)
	LocalPlayer():ConCommand("_StarGate.SetValue "..self.Entity:EntIndex().." Blocked "..tostring(b));
end

--################# Dials a gate @aVoN
function ENT:DialGate(address,mode,nox)
	if(not mode) then mode = false end; -- Nil seems to be "true'ed" with util.tobool!
	if (nox) then
		LocalPlayer():ConCommand("_StarGate.SetValue "..self.Entity:EntIndex().." NoxDial "..address);
	else
		LocalPlayer():ConCommand("_StarGate.SetValue "..self.Entity:EntIndex().." Dial "..tostring(mode).." "..address);
	end
end

--################# Stops Dialling a Gate or closes it  @aVoN
function ENT:AbortDialling()
	LocalPlayer():ConCommand("_StarGate.SetValue "..self.Entity:EntIndex().." AbortDialling true");
end

--##################################
--#### Color and Lights
--##################################

--################# Draws tiny sprites on the gate - Makes it look cooler! @aVoN
-- Does not work with ENT.RenderGroup = RENDERGROUP_OPAQUE
-- It only works with RENDERGROUP_BOTH or RENDERGROUP_TRANLUSCENT
-- But sadly then the ring sometimes clips (Strange behaviour).

function ENT:Draw()
	if (not IsValid(self.Entity)) then return end
	self.Entity:DrawModel();
	if(not self.ChevronColor) then return end;
	render.SetMaterial(self.ChevronSprite);
	local col = Color(self.ChevronColor.r,self.ChevronColor.g,self.ChevronColor.b,100); -- Decent please -> Less alpha
	for i=1,9 do
		if(self.Entity:GetNWBool("chevron"..i,false)) then
			local endpos = self.Entity:LocalToWorld(self.SpritePositions[i]);
			if StarGate.LOSVector(EyePos(), endpos, LocalPlayer(), 10) then
				render.DrawSprite(endpos,24,24,col);
			end
		end
	end
end

-- And for some obvious reasons, the hooks "Pre/PostDrawOpaque/Translucent" do not work anymore.
-- SO: FUCK OFF SPRITES - We have to life without them

local stargates = {};
function ENT:Initialize()
	table.insert(stargates,self.Entity);
end

--################# Think function, to set the gates address @aVoN
function ENT:Think()
	--######### Dynamic Lights, toggleable by the client!
	if(StarGate.VisualsMisc==nil or not StarGate.VisualsMisc("cl_stargate_dynlights")) then return end;
	if(self.ChevronColor and (self.NextLight or 0) < CurTime()) then
		self.NextLight = CurTime()+0.001;
		for i=1,9 do
			if(self.Entity:GetNWBool("chevron"..i,false)) then
				-- Clientside lights, yeah! Can be toggled by clients this causes much less lag when deactivated. Method below is from Catdaemon's harvester
				local dlight = DynamicLight(self:EntIndex()..i);
				if(dlight) then
					dlight.Pos = self.Entity:LocalToWorld(self.LightPositions[i]);
					dlight.r = self.ChevronColor.r;
					dlight.g = self.ChevronColor.g;
					dlight.b = self.ChevronColor.b;
					dlight.Brightness = 0.5;
					dlight.Decay = 150;
					dlight.Size = 150;
					dlight.DieTime = CurTime()+1;
				end
			end
		end
	end
end


--##################################
--#### VGUI/Dial Menu
--##################################

--################# Show the addresse of a gate when set @aVoN
hook.Add("HUDPaint","StarGate.Hook.HUDPaint.ShowAddressAndGroupAndName",
	function()
		local x,y = gui.MousePos();
		if(x == 0 and y == 0) then -- Avoids this popping up, if the dial dialogue is opened
			local p = LocalPlayer();
			if(IsValid(p)) then
				local trace = LocalPlayer():GetEyeTrace();
				if(trace.Hit and IsValid(trace.Entity)) then
					local e = trace.Entity;
					local color = Color(255,255,255,255);
					if (e.IsStargate and e:GetBlocked()) then color = Color(255,0,0,255); end
					if(e.IsGroupStargate and e:GetNetworkedBool("SG_GROUP_SYSTEM")) then
						local address = e:GetGateAddress();
						local group = e:GetGateGroup();
						if(address != "" and group != "") then
							local name = e:GetGateName();
							if(name == "") then name = "N/A" end;
							local message = SGLanguage.GetMessage("stargate_address")..": "..address.." - "..SGLanguage.GetMessage("stargate_group")..": "..group.." - "..SGLanguage.GetMessage("stargate_name")..": "..name;
							if (e:GetClass()=="stargate_universe") then
								message = SGLanguage.GetMessage("stargate_address")..": "..address.." - "..SGLanguage.GetMessage("stargate_type")..": "..group.." - "..SGLanguage.GetMessage("stargate_name")..": "..name;
							end
							draw.WordBox(8,40,ScrH()/2,message,"Default",Color(50,50,75,100),color);
						end
					elseif(e.IsGroupStargate and e:GetClass()!="stargate_universe") then
						local address = e:GetGateAddress();
						if(address ~= "") then
							local name = e:GetGateName();
							if(name == "") then name = "N/A" end;
							local galaxy = e:GetGalaxy();
							if galaxy then galaxy = SGLanguage.GetMessage("stargate_galaxy_y")
							else galaxy = SGLanguage.GetMessage("stargate_galaxy_n") end
							local message = SGLanguage.GetMessage("stargate_address")..": "..address.." - "..SGLanguage.GetMessage("stargate_name")..": "..name.." - "..SGLanguage.GetMessage("stargate_galaxy")..": "..galaxy;
							draw.WordBox(8,40,ScrH()/2,message,"Default",Color(50,50,75,100),color);
						end
					elseif(e.IsStargate) then
						local address = e:GetGateAddress();
						if(address != "") then
							local name = e:GetGateName();
							if(name == "") then name = "N/A" end;
							local message = SGLanguage.GetMessage("stargate_address")..": "..address.." - "..SGLanguage.GetMessage("stargate_name")..": "..name;
							draw.WordBox(8,40,ScrH()/2,message,"Default",Color(50,50,75,100),color);
						end
					end
				end
			end
		end
	end
);

--##################################
--#### DHD helper functions
--##################################

--################# Find's all DHD's which may call this gate @aVoN
function ENT:FindDHD()
	local pos = self.Entity:GetPos();
	local dhd = {};
	for _,v in pairs(ents.FindByClass("dhd_*")) do
		if (v.IsGroupDHD) then
			local e_pos = v:GetPos();
			local dist = (e_pos - pos):Length(); -- Distance from DHD to this stargate
			if(dist <= self.Entity:GetNetworkedInt("DHDRange",1000)) then
				-- Check, if this DHD really belongs to this gate
				local add = true;
				for _,gate in pairs(self:GetAllGates()) do
					if(gate ~= self.Entity and (gate:GetPos() - e_pos):Length() < dist) then
						add = false;
						break;
					end
				end
				if(add) then
					table.insert(dhd,v);
				end
			end
		end
	end
	return dhd;
end

--################# Find's special DHD's which may power this gate @Mad
function ENT:FindPowerDHD()
	local pos = self.Entity:GetPos();
	local dhd = {};
	local posibble_dhd = {}

	table.Add(posibble_dhd, ents.FindByClass("mobile_dhd"));
	table.Add(posibble_dhd, ents.FindByClass("goauld_dhd_prop"));
	table.Add(posibble_dhd, ents.FindByClass("gravitycontroller"));
	table.Add(posibble_dhd, ents.FindByClass("destiny_console"));
	table.Add(posibble_dhd, ents.FindByClass("dhd_*"));

	-- ramp energy for sgu
	if(self.Entity:GetClass() == "stargate_universe")then
	    for _,v in pairs(ents.FindInSphere(self.Entity:GetPos(),100)) do
            if(IsValid(v) and not v:GetClass():find("stargate_"))then
   	            if(StarGate.RampOffset.Gates[v:GetModel()])then
   	            	local add = true;
 					local e_pos = v:GetPos();
					local dist = (e_pos - pos):Length(); -- Distance from ramp to this stargate
					for _,gate in pairs(self:GetAllGates()) do
						if(gate ~= self.Entity and (gate:GetPos() - e_pos):Length() < dist) then
							add = false;
							break;
						end
					end
					if(add) then
				    	table.insert(dhd,v);
						return dhd;
					end
     			end
			end
        end
	end

	for _,v in pairs(posibble_dhd) do
		local e_pos = v:GetPos();
		local dist = (e_pos - pos):Length(); -- Distance from DHD to this stargate
		if(dist <= self.Entity:GetNetworkedInt("DHDRange",1000)) then
			-- Check, if this DHD really belongs to this gate
			local add = true;
			for _,gate in pairs(self:GetAllGates()) do
				if(gate ~= self.Entity and (gate:GetPos() - e_pos):Length() < dist) then
					add = false;
					break;
				end
			end
			if (v:GetClass():find("dhd_") and v:GetNWBool("Destroyed",false) and not util.tobool(self.Entity:GetNetworkedInt("SG_ENERGY_DHD_K"))) then
				add = false;
			end
			if(add) then
				table.insert(dhd,v);
			end
		end
	end

	return dhd;
end

--################# Find's Black holes
function ENT:FindBlackHole()
	local pos = self.Entity:GetPos();
	local hole = false;

	for _,v in pairs(ents.FindByClass("black_hole_power")) do
		local e_pos = v:GetPos();
		local dist = (e_pos - pos):Length(); -- Distance from hole to this stargate
		if(dist <= self.Entity:GetNetworkedInt("DHDRange",1000)*4) then
			if not hole then hole = true; end
		end
	end

	return hole;
end

--################# Check connection type and prepare basic energy calculation
function ENT:CheckConnection(chevs)
	if (not self:GetNWBool("HAS_RD",false)) then return true end -- without RD always have energy

	local Sclass = self:GetClass();

	local isgalaxy = 0;
	local issgu = 0;

	-- calculate power consumption, notusual gates take much more energy
	-- make global variables, used in next function
	if (chevs==8) then self.ConnectionGalaxy = true
	else self.ConnectionGalaxy = false end
	if self.ConnectionGalaxy then isgalaxy = 1; end

	if (chevs==9 or Sclass == "stargate_supergate") then self.ConnectionSGU = true
	else self.ConnectionSGU = false end
	if self.ConnectionSGU then issgu = 1; end
	if (Sclass == "stargate_supergate") then issgu = 2; end

	-- our consumption, used in next funciton
	self.EnergyConsume = (self.GalaxyConsumption*isgalaxy + self.SGUConsumption*issgu + 1);
end

--################# Check if gate are powered somehow and if source is capable of handling gate consumption
function ENT:CheckEnergy(target,chevs)
	if (not self:GetNWBool("HAS_RD",false)) then return true end -- without RD always have energy
	if(not util.tobool(self:GetNetworkedInt("SG_ENERGY")))then return true end;
	if(self:GetNWBool("GateSpawnerSpawned",false) and not util.tobool(self:GetNetworkedInt("SG_ENERGY_SP")))then return true end;
	self:CheckConnection(chevs);
	local energy = false;
	local en = self:GetNetworkedInt("RD_ENERGY",0);
	local distance = 100;
	--if(IsValid(target)) then distance = (self:GetPos() - target:GetPos()):Length(); end;
	if (target.pos) then distance = (self:GetPos() - target.pos):Length(); end
	local consume = distance * self.EnergyConsume;
	if (self.ConnectionSGU) then consume = consume + self.SGUAdd; elseif (self.ConnectionGalaxy) then consume = consume + self.GalaxyAdd; else consume = consume + self.ChevAdd; end
	if(not self.ConnectionSGU and not self.ConnectionGalaxy)then consume = consume / self.ChevConsumption end;
	if (self.ConnectionSGU) then
		consume = consume*2;
	else
		consume = consume*5;
	end
	--  energy :)
	if(en >= consume)then energy = true else energy = false end;
	if(not self.ConnectionSGU and not self.ConnectionGalaxy and not energy) then
		for k,v in pairs(self:FindPowerDHD()) do -- look for other power sources -- look for dhd :)
			if(IsValid(v))then energy = true end
		end
	end
	if(self:FindBlackHole())then energy = true end; -- black hole can power everything
    return energy;
end

--################# Gets all (valid) gates @aVoN
function ENT:GetAllGates(closed)
	local sg = {};
	local super = "stargate_supergate";
	local class = self.Entity:GetClass();
	for _,v in pairs(ents.FindByClass("stargate_*")) do
		if(v.IsStargate and not (closed and (v.IsOpen or v.Dialling))) then
			if ((class == super and v:GetClass() == super) or (class != super and v:GetClass() != super)) then
				table.insert(sg,v);
			end
		end
	end
	return sg;
end