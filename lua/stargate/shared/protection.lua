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
		if(m:find("dev_link") or (m:find("link_tool") and Environments) or (m=="wire" or m=="wire_adv" or m=="wire_debugger") or (m == "goauld_iris" or m == "stargate_iris")) then return end;
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

--################# Fix for pickup disabled/disallowed swep.
function StarGate.Hook.PlayerCanPickupWeapon(p,w)
	if (not IsValid(p) or not IsValid(w)) then return end
	if (StarGate.CFG:Get("cap_disabled_swep",w:GetClass(),false)) then return false end
	if (StarGate.CFG:Get("swep_groups_only",w:GetClass(),false)) then
		local tbl = StarGate.CFG:Get("swep_groups_only",w:GetClass(),""):TrimExplode(",");
		local disallow = true;
		local exclude = false;
		if (table.HasValue(tbl,"exclude_mod")) then exclude = true; disallow = false; end
		for k,v in pairs(tbl) do
			if (v=="add_shield" or v=="exclude_mod") then continue end
			if (p:IsUserGroup(v)) then
				disallow = exclude;
				break;
			end
		end
		if (table.Count(tbl)==0) then disallow = false end
		if (disallow) then return false; end
	end
end
hook.Add("PlayerCanPickupWeapon","StarGate.Hook.PlayerCanPickupWeapon",StarGate.Hook.PlayerCanPickupWeapon);

if (CPPI) then
	hook.Add("StarGate.Player.CanModifyGate","StarGate.CPPI.CanModify.Gate",function(ply,ent)
		if not ent:CPPICanTool(ply,"stargatemodify") then return false end
	end)

	hook.Add("StarGate.Player.CanModify.Ring","StarGate.CPPI.CanModify.Ring",function(ply,ent)
		if not ent:CPPICanTool(ply,"ringmodify") then return false end
	end)

	hook.Add("StarGate.Player.CanModify.AtlantisTransporter","StarGate.CPPI.CanModify.AtlantisTransporter",function(ply,ent)
		if not ent:CPPICanTool(ply,"atlantistransportermodify") then return false end
	end)

	local function CapIsFriend(ply,owner)
		if (IsValid(owner) and owner.CPPIGetFriends) then
			local tbl = owner:CPPIGetFriends();
			if (type(tbl)=="table") then
				if (table.HasValue(tbl,ply)) then return true end
			end
		end
		return false
	end

	hook.Add("StarGate.AntiPrior.Noclip","StarGate.CPPI.AntiPrior",function(ply,ent)
		if (ent.Immunity==0 and CapIsFriend(ply,ent.Owner)) then return false end
	end)
	hook.Add("StarGate.TollanDisabler.CanBlockWeapon","StarGate.CPPI.TollanDisabler",function(ply,weapon,ent)
		if (CapIsFriend(ply,ent.Owner)) then return false end
	end)
end

end

-- disable usage C tool menu for gatespawner ents
function StarGate.Hook.CanProperty(p,t,e)
	if(IsValid(e) and (e:GetNWBool("GateSpawnerProtected",false) or e.Untouchable) and not DEBUG) then
		return false;
	end
end
hook.Add("CanProperty","StarGate.Hook.CanProperty",StarGate.Hook.CanProperty);