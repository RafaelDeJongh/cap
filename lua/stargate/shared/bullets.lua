/*
	Stargate Bullet Lib for GarrysMod10
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

--################# Instead of overwriting the FireBullets function twice (shield/eventhorizon) to recognize bullets, we create a customhook here @aVoN
--################# I know that hooks are good way of doing that, but some gmod update broke then and i had nbo idea how to fix them, so i turend it ent side into a function @Mad
StarGate.Bullets = StarGate.Bullets or {};
local MEnt = FindMetaTable("Entity");
if(not MEnt) then return end;
if(not StarGate.Bullets.__FireBullets) then StarGate.Bullets.__FireBullets = MEnt.FireBullets end;

--################# Redefine Entity:FireBullets @aVoN
function MEnt:FireBullets(bullet)
	if(not bullet) then return end;
	local original_bullet = table.Copy(bullet);
	local qued = {}; -- We qued bullets which have not been overwritten - Fire then "normally"
	local override = false; -- If set to true, we will shoot the bullets instead of letting the engine decide
	-- The modified part now, to determine if we hit a shield!
	local num = bullet.Num or 1; bullet.Num = 1; -- Just ONE bullet drawn by FireBullets. The others are getting shot by the loop
	local spread = bullet.Spread or Vector(0,0,0); bullet.Spread = Vector(0,0,0);
	local direction = (bullet.Dir or Vector(0,0,0));
	local pos = bullet.Src or self:GetPos();
	local rnd = {};
	-- Calculate the spread. Must be in a separate for loop. Doing this in the loop below seems to always result the same random numer (Don't ask me why...)
	for i=1,num do
		rnd[i] = {math.Rand(-1,1),math.Rand(-1,1)};
	end
	--################# If we hit anything, run the hook
	for i=1,num do
		local dir = Vector(direction.x,direction.y,direction.z); -- We need a "new fresh" vector
		--Calculate Bullet-Spread!
		if(spread and spread ~= Vector(0,0,0)) then
			-- Two perpendicular vectors to the direction vector (to calculate the spread-cone)
			local v1 = (dir:Cross(Vector(1,1,1))):GetNormalized();
			local v2 = (dir:Cross(v1)):GetNormalized();
			dir = dir + v1*spread.x*rnd[i][1] + v2*spread.y*rnd[i][2];
			-- Instead letting the engine decide to add randomness, we are doing it (Just for the trace)
			bullet.Dir = dir;
		end
		local trace = StarGate.Trace:New(pos,dir*16*1024,{self,self:GetParent()});
		if(hook.Call("StarGate.Bullet",GAMEMODE,self,bullet,trace)) then
			override = true;
		else
			table.insert(qued,table.Copy(bullet));
		end
	end
	--################# Fire old bullets
	if(override) then
		-- Remaining shots - Engine has nothinh to say now!
		for _,v in pairs(qued) do
			StarGate.Bullets.__FireBullets(self,v);
		end
	else
		StarGate.Bullets.__FireBullets(self,original_bullet);
	end
end

local function InitPostEntity( )

	// get existing
	local settings = physenv.GetPerformanceSettings();

	// change velocity for bullets
	settings.MaxVelocity = 20000;

	// set
	physenv.SetPerformanceSettings( settings );


end
hook.Add( "InitPostEntity", "LoadPhysicsModule", InitPostEntity );