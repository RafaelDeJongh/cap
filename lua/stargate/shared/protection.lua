/*
	Stargate - Protection System for GarrysMod10
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

--#########################################
--						Protection and Restrictions for entities
--#########################################

-- ############### Physgun/Gravgun picking up disabler @aVoN
function StarGate.Hook.PhysgunPickup(p,e)
	if(IsValid(e) and (e:GetNWBool("GateSpawnerProtected",false) or e.Untouchable) and not DEBUG) then
		return false;
	end
end
hook.Add("PhysgunPickup","StarGate.Hook.PhysgunPickup",StarGate.Hook.PhysgunPickup);
hook.Add("CanPlayerUnfreeze","StarGate.Hook.CanPlayerUnfreeze",StarGate.Hook.PhysgunPickup);

if (SERVER) then

hook.Add("GravGunPunt","StarGate.Hook.PhysgunPickup",StarGate.Hook.PhysgunPickup);
hook.Add("GravGunPickupAllowed","StarGate.Hook.PhysgunPickup",StarGate.Hook.PhysgunPickup);

-- ############### Disallow toolgun @aVoN
function StarGate.Hook.CanTool(p,t,m)
	local e = t.Entity;
	if(IsValid(e) and (e.GateSpawnerProtected or e.Untouchable) and not DEBUG) then
		local m = m or "";
		local allow = hook.Call("StarGate.Player.CanToolOnProtectedGate",GAMEMODE,p,e,m);
		if(allow == true) then return end; -- He can!
		if(allow == false) then return false end; -- He cant!
		if(m:find("dev_link") or (m:find("link_tool") and Environments) or (m=="wire" or m=="wire_adv" or m=="wire_debugger") or ((m == "goauld_iris" or m == "stargate_iris") and (p:IsAdmin() or p:IsSuperAdmin()))) then return end;
		return false;
	end
end
hook.Add("CanTool","StarGate.Hook.CanTool",StarGate.Hook.CanTool);

--################# Sorry guys, this function must break all you other hooks, when he isn't allowed to spawn @aVoN
function StarGate.Hook.PlayerCanSpawn(p)
	if(p and p.DisableSpawning) then return false end;
end
hook.Add("PlayerSpawnProp","StarGate.Hook.PlayerCanSpawn",StarGate.Hook.PlayerCanSpawn);
hook.Add("PlayerSpawnEffect","StarGate.Hook.PlayerCanSpawn",StarGate.Hook.PlayerCanSpawn);
hook.Add("PlayerSpawnNPC","StarGate.Hook.PlayerCanSpawn",StarGate.Hook.PlayerCanSpawn);
hook.Add("PlayerSpawnVehicle","StarGate.Hook.PlayerCanSpawn",StarGate.Hook.PlayerCanSpawn);
hook.Add("PlayerSpawnObject","StarGate.Hook.PlayerCanSpawn",StarGate.Hook.PlayerCanSpawn);
hook.Add("PlayerSpawnSENT","StarGate.Hook.PlayerCanSpawn",StarGate.Hook.PlayerCanSpawn);
hook.Add("PlayerSpawnRagdoll","StarGate.Hook.PlayerCanSpawn",StarGate.Hook.PlayerCanSpawn);

--################# No suicide for you @aVoN
function StarGate.Hook.PlayerCanSuicide(p)
	if(p.DisableSuicide) then return false end;
end
hook.Add("CanPlayerSuicide","StarGate.Hook.PlayerCanSuicide",StarGate.Hook.PlayerCanSuicide);

--################# No noclip for you @aVoN
function StarGate.Hook.PlayerNoClip(p)
	if(p.DisableNoclip) then return false	end;
end
hook.Add("PlayerNoClip","StarGate.Hook.PlayerNoClip",StarGate.Hook.PlayerNoClip);

--################# Protect a player before his own dexgun/staff blasts @aVoN
function StarGate.Hook.PlayerShouldTakeDamage(p,a)
	if(p == a) then
		local w = p:GetActiveWeapon();
		if(not IsValid(w)) then return end;
		w = w:GetClass();
		if(w == "weapon_dexgun" or w == "weapon_staff" or w == "ori_staff_weapon" or w == "weapon_asura") then return false end;
	end
end
hook.Add("PlayerShouldTakeDamage","StarGate.Hook.PlayerShouldTakeDamage",StarGate.Hook.PlayerShouldTakeDamage);

end

-- disable usage C tool menu for gatespawner ents
function StarGate.Hook.CanProperty(p,t,e)
	if(IsValid(e) and (e:GetNWBool("GateSpawnerProtected",false) or e.Untouchable) and not DEBUG) then
		return false;
	end
end
hook.Add("CanProperty","StarGate.Hook.CanProperty",StarGate.Hook.CanProperty);