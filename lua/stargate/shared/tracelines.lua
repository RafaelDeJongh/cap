/*
	Stargate Lib for GarrysMod10
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
--						Traclines - To stop them on lua drawn physboxes
--#########################################

StarGate.Trace = StarGate.Trace or {};
StarGate.Trace.Entities = StarGate.Trace.Entities or {};
StarGate.Trace.Classes = StarGate.Trace.Classes or {};

--################# Deephook to ents.Create serverside @aVoN
if SERVER then
	hook.Add("OnEntityCreated","StarGate.OnEntityCreated",function(e)
		if(not IsValid(e) or not StarGate.Trace) then return end;
		if(StarGate.Trace.Classes[e:GetClass()]) then
			StarGate.Trace:GetEntityData(e);
		end
	end)
end

--################# Add a class to check to the tracesline calculation @aVoN
function StarGate.Trace:Add(c,condition)
	self.Classes[c] = {Condition=condition};
	for _,v in pairs(ents.FindByClass(c)) do
		self:GetEntityData(v);
	end
end

--################# Adds a condition-function to the specific entity. This function decides if the trace goes through the BoundingBox or not @aVoN
function StarGate.Trace:AddCondition(c,condition)
	if(self.Classes[c]) then
		self.Classes[c] = {Condition=condition};
	end
end

--################# Remoces such a class @aVoN
function StarGate.Trace:Remove(c)
	self.Classes[c] = nil;
	for k,_ in pairs(self.Entities) do
		if(k:IsValid()) then
			if(k:GetClass() == c) then
				self.Entities[k] = nil;
			end
		else
			self.Entities[k] = nil;
		end
	end
end

--################# Is the vector given inside the box or outside of it? @aVoN
function StarGate.Trace:InBox(pos,Min,Max)
	if(
		(pos.x >= Min.x and pos.x <= Max.x) and
		(pos.y >= Min.y and pos.y <= Max.y) and
		(pos.z >= Min.z and pos.z <= Max.z)
	) then
		return true;
	end
	return false;
end
-- Because this might also be usefull for other scripts, were defininig this global
StarGate.InBox = function(a,b,c) return StarGate.Trace:InBox(a,b,c) end;

--################# Updates the entities OBB Datas @aVoN
function StarGate.Trace:GetEntityData(e)
	if(IsValid(e)) then
		local time = CurTime();
		if(not self.Entities[e] or self.Entities[e].Last + 1 < time) then
			local offset = e:OBBCenter(); -- We need the OBB's relatively to the Entiti's position, not to the OBBCenter
			self.Entities[e] = {
				Min = e:OBBMins()+offset,
				Max = e:OBBMaxs()+offset,
				--Radius = e:BoudingRadius(),
				Last = time,
			}
		end
		return true;
	else
		self.Entities[e] = nil;
		return false;
	end
end

--################# Helper Function: Makes the direction vector longer and checks if the hitpos is within a specific range (== hit wall) @aVoN
function StarGate.Trace:HitWall(coordinate,pos,norm,mul,Min,Max,len,hit_normal)
	local old = norm;
	local norm = norm*mul; -- Make the normal hit the wall
	local length = norm:Length(); -- The new normal's length!
	if(length <= len) then -- The necessary normal length is shorter than the trace's length (we haven't hit anything before we hit the actual object!)
		-- Check, if the remaining two coordinates are within the Min/Max range!
		local hit = pos + norm;
		if(
			-- The coordinate == "x,y,z" is because of rounding issues. The checked variable has to get skipped - It is on the wall! Sometimes we have 1.999999999 ~= 2
			(coordinate == "x" or hit.x >= Min.x and hit.x <= Max.x) and
			(coordinate == "y" or hit.y >= Min.y and hit.y <= Max.y) and
			(coordinate == "z" or hit.z >= Min.z and hit.z <= Max.z)
		) then
			return {HitPos=hit,Fraction=length/len,HitNormal=hit_normal}; -- The hitpos and fraction!
		end
	end
end

--################# This checks one coordinate of the trace's normal @aVoN
function StarGate.Trace:CheckCoordinate(coordinate,pos,norm,Min,Max,len,in_box)
	-- I will not check if the trace start position is exactly on a wall, neither I will check, if the start pos is exactly in the center of this entity.
	-- Doing this would need me to add some more special exeptions where the probability for these cases are < 0.1% (except you are forcing it)
	local hit_normal = Vector(0,0,0); hit_normal[coordinate] = 1;
	--################# We are inside the bounding box - Trace to one wall!
	if(in_box) then
		local mul = 0;
		if(norm[coordinate] > 0) then -- Norm == 0 has been avoided in StarGate.Trace:New
			-- The multiplier so the coordinate we're checking is exact on the wall's surface
			mul = math.abs((pos[coordinate] - Max[coordinate])/norm[coordinate]);
			hit_normal = -1*hit_normal;
		else
			mul = math.abs((pos[coordinate] - Min[coordinate])/norm[coordinate]);
		end
		return self:HitWall(coordinate,pos,norm,mul,Min,Max,len,hit_normal);
	else
		--################# We are outside the bounding box.
		if(pos[coordinate] < Min[coordinate] and norm[coordinate] > 0) then -- We are below the Minimum and the normal goes up => We can hit
			local mul = math.abs((pos[coordinate] - Min[coordinate])/norm[coordinate]); -- The multiplier so the coordinate we're checking is exact on the wall's surface
			return self:HitWall(coordinate,pos,norm,mul,Min,Max,len,-1*hit_normal);
		elseif(pos[coordinate] > Max[coordinate] and norm[coordinate] < 0) then --Above Max, norm down
			local mul = math.abs((pos[coordinate] - Max[coordinate])/norm[coordinate]);
			return self:HitWall(coordinate,pos,norm,mul,Min,Max,len,hit_normal);
		end
	end
end

--################# Start a traceline which can hit Lua Drawn BoundingBoxes @aVoN
function StarGate.Trace:New(start,dir,ignore)
	-- Clients need to add new entities inside this function (Server uses "HookBased" with ents.Create which uses less reouces!)
	if CLIENT then
		for k,_ in pairs(self.Classes) do
			for _,v in pairs(ents.FindByClass(k)) do
				self:GetEntityData(v);
			end
		end
	end
	local trace = util.QuickTrace(start,dir,ignore);
	--This is better and faster than using table.HasValue(ignore,e) (nested for loops)
	local quick_ignore = {};
	if(type(ignore) == "table") then
		for _,v in pairs(ignore) do
			quick_ignore[v] = true;
		end
	elseif(ignore) then
		quick_ignore[ignore] = true;
	end
	local len = dir:Length()*trace.Fraction; -- First of all: The length of the trace.
	local norm_world = dir:GetNormal(); -- Get Normal of the dir vector (world coordinates!)
	-- We need to sort all entities first according to their distance to the trace-start, or we hit a prop behind a prop instead of the one infront
	-- Problem noticed by Lynix here: http://img140.imageshack.us/img140/7589/gmflatgrass0017bj9.jpg
	local traced_entities = {} -- Lynix modification

	for e,_ in pairs(self.Entities) do
		if(not quick_ignore[e]) then
			if(self:GetEntityData(e)) then -- Update dimension data and check, if the ent is valid!
				local class = e:GetClass();
				local v = self.Entities[e]; -- The real values now, update by the if above!
				local pos = e:WorldToLocal(start);
				local in_box = false;

				if (class == "shield_core_buble") then
					in_box = StarGate.IsInShieldCore(e, start);
				elseif (class == "shield") then
					in_box = (e:GetPos():Distance(start)<v.Max.x); -- in sphere! Not box!!! @ AlexALX
				else
					in_box = self:InBox(pos,v.Min,v.Max);
				end

				if (self.Classes and self.Classes[class] and (not self.Classes[class].Condition or self.Classes[class].Condition(e,{start,dir,ignore},trace,in_box))) then
					local e_pos = e:GetPos();
					local norm = e:WorldToLocal(e_pos+norm_world); -- Get the normal (local coordinates!)
					local hit;
					local hit2;
					-- We need to check to what side the start pos is the nearest and if the normal (to that side where we checking it) isn't zero
					if (class == "shield_core_buble") then // go ahead with my method @Mad
						if StarGate.IsRayBoxIntersect(start, trace.HitPos, e) then // check, if we intersecting bounding box - save cpu if we are not
							local a = not in_box;
							local dir2 = dir;
							if in_box then dir2 = -1*dir end // fix shoting if we are inside, and not shape - to get hitpos on right side (not opposite)
							if (e.ShShap == 2) then a = in_box end // small fix for box shape, i fucked triangles directions
							hit2 = StarGate.RayPhysicsPluckerIntersect(trace, dir2, e, a);
						end
					elseif (class == "tokra_shield") then // go ahead with my method @Mad
						//if StarGate.IsRayBoxIntersect(start, trace.HitPos, e) then // check, if we intersecting bounding box - save cpu if we are not
							//local a = not in_box;
							////local dir2 = dir;
							//if in_box then dir2 = -1*dir end // fix shoting if we are inside, and not shape - to get hitpos on right side (not opposite)
							//if (e.ShShap == 2) then a = in_box end // small fix for box shape, i fucked triangles directions
							hit2 = StarGate.RayPhysicsPluckerIntersect(trace, dir, e, true);
							// this code not working, need something to do @ AlexALX
						//end
					else
						if(norm.x ~= 0) then
							hit = self:CheckCoordinate("x",pos,norm,v.Min,v.Max,len,in_box);
						end
						if(not hit and norm.y ~= 0) then
							hit = self:CheckCoordinate("y",pos,norm,v.Min,v.Max,len,in_box);
						end
						if(not hit and norm.z ~= 0) then
							hit = self:CheckCoordinate("z",pos,norm,v.Min,v.Max,len,in_box);
						end

						-- very ugly, but atleast works, with bugs...
						-- I have no idea how make function "CheckCoordinate" works with sphere @ AlexALX
						if (not hit and class=="shield" and not in_box and self:InBox(pos,v.Min,v.Max)) then
							hit = {HitPos=pos,Fraction=0.8,HitNormal=norm}
						end

					end

					if(hit) then
						-- Update the trace data with new and correct values
						trace.Hit = true;
						trace.HitPos = e:LocalToWorld(hit.HitPos);
						trace.HitNonWorld = true;
						trace.HitNoDraw = false;
						trace.HitBox = 0;
						trace.Hit = true;
						trace.HitGroup = 0;
						trace.MatType = 0;
						trace.PhysicsBone = 0;
						trace.HitSky = false;
						trace.HitWorld = false;
						trace.Fraction = hit.Fraction;
						trace.HitNormal = e:LocalToWorld(hit.HitNormal)-e_pos;
						trace.Entity = e;
						table.insert(traced_entities,table.Copy(trace)); -- Lynix modification
						--break;
					end
					if(hit2) then
						-- Update the trace data with new and correct values, my values are already scaled so i made another if condition @Mad
						trace.Hit = true;
						trace.HitPos = hit2.HitPos;
						trace.HitNonWorld = true;
						trace.HitNoDraw = false;
						trace.HitBox = 0;
						trace.Hit = true;
						trace.HitGroup = 0;
						trace.MatType = 0;
						trace.PhysicsBone = 0;
						trace.HitSky = false;
						trace.HitWorld = false;
						trace.Fraction = hit2.Fraction;
						trace.HitNormal = hit2.HitNormal;
						trace.Entity = e;
						table.insert(traced_entities,table.Copy(trace)); -- Lynix modification
						--break;
					end

				end
			end
		end
	end
	-- START OF Lynix modification
	if(#traced_entities > 0) then
		local min = 10000000000; -- Random startvalue
		for _,v in pairs(traced_entities) do
			local dist = trace.StartPos:Distance(v.HitPos);
			if(dist < min) then
				min = dist;
				trace = v;
			end
		end
	end
	-- END OF Lynix modification
	return trace;
end
