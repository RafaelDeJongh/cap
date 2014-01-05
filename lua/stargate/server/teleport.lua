/*
	Stargat Lib for GarrysMod10
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

--##################################
--              Teleportation special behaviour class
--##################################

-- The reason, this is not in the event horizon sent itself is, it needs to be loaded before the SENTs.

StarGate.Teleport = StarGate.Teleport or {};
StarGate.Teleport.Class = StarGate.Teleport.Class or {};

--################# Adds an entity to the "special behaviour class" @aVoN
function StarGate.Teleport:Add(class,func)
	self.Class[class] = func;
end

--################# Called by the event horizon @aVoN
function StarGate.Teleport:__Run(class,e,...)
	local ret;
	if(self.Class[class]) then
		ret = self.Class[class](e,...);
	end
	if(ret ~= true and ret ~= false and IsValid(ret)) then return ret end;
	return e;
end


--################# Here are some examples

--##### Set changed hoverball heigh to the hoverball to make it not spazz out
StarGate.Teleport:Add("gmod_hoverball",
	function(e,pos,ang,vel,old_pos,old_ang,old_vel,ang_delta)
		if (e.TargetZ) then e.TargetZ = e.TargetZ + (pos.z-old_pos.z); end
	end
);
--##### Same like for hoverball, but for wire
StarGate.Teleport:Add("gmod_wire_hoverball",
	function(e,pos,ang,vel,old_pos,old_ang,old_vel,ang_delta)
		if(e.SetTargetZ and e.GetTargetZ) then
			e:SetTargetZ(e:GetTargetZ() + (pos.z-old_pos.z));
		end
	end
);
--##### RPG Missiles have to be removed and recreated on the other side! (We need sadly to unset the owner, or the new rocket will follow the old user's RPG laserdot)
StarGate.Teleport:Add("rpg_missile",
	function(e,pos,ang,vel,old_pos,old_ang,old_vel,ang_delta)
		e:StopSound("Missile.Accelerate");
		e:Remove();
		e = ents.Create("rpg_missile");
		e:Spawn();
		e:Activate();
		return e; -- Make sure, the stargate is now calculation with the new entity!
	end
);
--##### We need to reset a players aimvector, or the shuttle may move back into the gate and will be destroyed, because the players aimvector is still into the old direction
/*local function shuttle(e,pos,ang,vel,old_pos,old_ang,old_vel,ang_delta)
	-- Move a players view
	if(IsValid(e.Pilot)) then
		e.Pilot:SetEyeAngles(e.Pilot:GetAimVector():Angle() + Angle(0,ang_delta.y+180,0));
	end
end
StarGate.Teleport:Add("shuttle",shuttle);
StarGate.Teleport:Add("shuttle_viper",shuttle);
StarGate.Teleport:Add("jumper",shuttle);*/
--##### Hoverboard
StarGate.Teleport:Add("modulus_hoverboard",
	function(e,pos,ang,vel,old_pos,old_ang,old_vel,ang_delta)
		if(e.GetDriver) then
			local p = e:GetDriver();
			if(IsValid(p)) then
				p:SetEyeAngles(p:GetAimVector():Angle() + Angle(0,ang_delta.y+180,0));
			end
		end
	end
);