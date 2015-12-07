/*
	Eventhorizon SENT for GarrysMod10
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

--[[
--################# This is a helper function. If you use my TraceClass, you can use this to determine a correct position and direction vector from the other gate @aVoN
function ENT:GetTeleportedVector(pos,dir)
	if(IsValid(self.Target)) then
		local g = {self.Entity,self.Target};
		local up = g[2]:GetUp();
		if(not self.RotationMatrix or up ~= self.LastUp) then
			self.RotationMatrix = MMatrix.RotationMatrix(up,180); -- Saves performances and stops calculating the CPU Extensive RotMatrix allover again
			self.LastUp = up;
		end
		local target_dir = (g[2]:LocalToWorld(self.RotationMatrix*g[1]:WorldToLocal(dir + g[1]:GetPos()))-g[2]:GetPos());
		local target_pos = g[2]:LocalToWorld(self.RotationMatrix*g[1]:WorldToLocal(pos));
		return target_pos,target_dir;
	else
		return pos,dir;
	end
end
]]

-- fix provided by Divran
function ENT:GetTeleportedVector(Pos,Dir)
	local Target = self.Target
	if (!Target) then return Pos, Dir end
	
	Pos = self:WorldToLocal(Pos)
	Pos.y = Pos.y * -1
	Pos = Target:LocalToWorld(Pos)
	
	Dir = self:WorldToLocal(self:GetPos()+Dir)
	Dir.x = Dir.x * -1
	Dir.y = Dir.y * -1
	Dir = Target:GetPos() - Target:LocalToWorld(Dir)
	
	return Pos, Dir * -1
end

--################# This not only retrieves the teleported vector, it will also add the gulping sound and will add animations @aVoN
function ENT:TeleportVectorWithEffect(pos,dir)
	local g = {self.Entity,self.Target};
	local pos2,dir2 = self:GetTeleportedVector(pos,dir);
	g[1]:EnterEffect(pos,math.random(5,10));
	g[1]:EmitSound(g[1].Sounds.Teleport[math.random(1,#g[1].Sounds.Teleport)],90,math.random(90,110));
	if(IsValid(g[2])) then
		g[2]:EnterEffect(pos2,math.random(5,10));
		g[2]:EmitSound(g[2].Sounds.Teleport[math.random(1,#g[1].Sounds.Teleport)],90,math.random(90,110));
	end
	return pos2,dir2;
end

--################# This makes bullets being able to shoot through the EH @aVoN
-- Register EH SENT to the trace class
if (StarGate.Trace) then StarGate.Trace:Add("event_horizon"); end

-- We need a fake entity from which we will shoot the teleportet bullet from, otherwise bullet traces looks strange
local FakeBulletEntity = NULL;
if (SERVER) then FakeBulletEntity = ents.Create("info_null"); end

hook.Add("StarGate.Bullet","StarGate.EHBullet",
	function(self,bullet,trace)
		local e = trace.Entity; -- Fast index
		if(IsValid(e) and e:GetClass() == "event_horizon") then
			-- Call the callback (e.g. to draw effects like bullet tracers!)
			if(bullet.Callback) then
				local dmg = DamageInfo();
				dmg:SetDamage(bullet.Damage or 0);
				bullet.Callback(self,trace,dmg);
			end
			--####### Just actually "teleport" the bullet serverside!
			if(SERVER and e:IsOpen() and not e.ShuttingDown and not e.Unstable) then
				local target = e.Target; -- Quick-Index
				--Draw a bullet tracer into the Entering-EH by a custom effect
				if(bullet.Tracer ~= 0) then
					local fx = EffectData();
					fx:SetStart(bullet.Src);
					fx:SetOrigin(trace.HitPos);
					fx:SetScale(5000);
					fx:SetNormal(trace.HitNormal);
					util.Effect(bullet.TracerName or "Tracer",fx,true,true);
				end
				if((e:GetForward():DotProduct(bullet.Dir) > 0)) then -- Don't teleport this bullet (we shot from the backside!)
					e:EnterEffect(trace.HitPos,math.random(5,10));
					e:EmitSound(e.Sounds.Teleport[math.random(1,#e.Sounds.Teleport)],90,math.random(90,110));
					return true;
				end
				local parent = e:GetParent();
				if(IsValid(parent) and parent:IsBlocked(true)) then return true end; -- We are blocked by an iris - Don't teleport anything!
				-- This timer stops annoying lags (e.g. with the shotgun)
				timer.Simple(0.07,
					function()
						-- Draw the enter and passing effect on the EH
						if(not IsValid(e)) then return end;
						e:EnterEffect(trace.HitPos,math.random(5,10));
						e:EmitSound(e.Sounds.Teleport[math.random(1,#e.Sounds.Teleport)],90,math.random(90,110));
						if(not IsValid(target)) then return end;
						local pos,dir = e:GetTeleportedVector(trace.HitPos,bullet.Dir); -- Teleported position and direction
						--####### Target-Gate blocked by an iris?
						local parent = target:GetParent(); -- The actual stargate device
						if(IsValid(parent) and parent:IsBlocked(true)) then
							parent:HitIris(NULL,pos,dir);
							return;
						end
						--####### Now, fire a new, passed bullet from the other EH
						local bullet = table.Copy(bullet);
						bullet.Attacker = bullet.Attacker or self;
						if((bullet.Tracer or 0) > 0) then bullet.Tracer = 1 end; -- The bullet, which exits the second EH shall always have a Tracer!
						bullet.Dir = dir;
						bullet.Src = pos+2*dir;
						if (not IsValid(FakeBulletEntity)) then FakeBulletEntity = ents.Create("info_null"); end -- fix
						FakeBulletEntity:FireBullets(bullet); -- FIRE ZEH MISSLES!
						-- Draw the enter and passing effect on the EH
						target:EnterEffect(pos,math.random(5,10));
						target:EmitSound(target.Sounds.Teleport[math.random(1,#target.Sounds.Teleport)],90,math.random(90,110));
					end
				);
			end
			return true; -- Tell we override the original bullet!
		end
	end
);