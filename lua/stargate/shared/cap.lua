--[[
	A global library with  bunch of usefull
	functions often used in entities on both sides
	Copyright (C) 2011 Madman07
]]--

function StarGate.GetMultipleOwnerClientSide(ent) // Ugly, no validation, but works :p
	local own = ent;
	if IsValid(own) then
		if own:IsPlayer() then return own end

		own = ent:GetOwner()
		if IsValid(own) then
			if own:IsPlayer() then return own end

			own = ent:GetOwner()
			if IsValid(own) then
				if own:IsPlayer() then return own end
			end
		end
	end
end

function StarGate.LOSVector(startpos, endpos, filter, radius)
	if (not startpos or not endpos) then return false end
	local tracedata = {
		start = startpos,
		endpos = endpos,
		filter = filter,
		mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER + CONTENTS_WINDOW//clever tracer, we can see trough glass
	}
	local trace = util.TraceLine(tracedata);

	local x = math.abs(endpos.x-trace.HitPos.x) < radius; // way faster than P1:Distance(P2)  (no roots, etc)
	local y = math.abs(endpos.y-trace.HitPos.y) < radius;
	local z = math.abs(endpos.z-trace.HitPos.z) < radius;

	return x and y and z;
end

function StarGate.TableRemove(reftable, value)
	local new_t = {};
	for _,v in pairs(reftable) do
		if (v ~= value) then
			table.insert(new_t,v);
		end
	end
	return new_t;
end

function StarGate.WorldToScreen(vWorldPos,vPos,vScale,aRot)
    local vWorldPos=vWorldPos-vPos;
    vWorldPos:Rotate(Angle(0,-aRot.y,0));
    vWorldPos:Rotate(Angle(-aRot.p,0,0));
    vWorldPos:Rotate(Angle(0,0,-aRot.r));
    return vWorldPos.x/vScale,(-vWorldPos.y)/vScale;
end

function StarGate.IsInScreenBox(boxx, boxy, sizex, sizey, x, y)
	if ((x > boxx and x < boxx+sizex) and (y > boxy and y < boxy+sizey)) then
		return true
	else
		return false
	end
end

function StarGate.IsInEllipsoid(pos, ent, dimension)
	local pos2 = ent:WorldToLocal(pos);

	local d = pos2.x^2/dimension.x^2;
	local e = pos2.y^2/dimension.y^2;
	local f = pos2.z^2/dimension.z^2;

	return d+e+f<1;
end

function StarGate.IsInCuboid(pos, ent, dimension)
	local pos2 = ent:WorldToLocal(pos);

	local d = math.abs(pos2.x/dimension.x);
	local e = math.abs(pos2.y/dimension.y);
	local f = math.abs(pos2.z/dimension.z);

	return not (d<1 and e<1 and f<1);
end

function StarGate.IsInAltantisoid(pos, ent, dimension)
	local pos2 = ent:WorldToLocal(pos);
	local is_in;

	// if its higher than 2/5 c
	if (pos2.z > (2*dimension.z/5)) then
		is_in = StarGate.IsInEllipsoid(pos, ent, dimension);
	else
		dimension.z = dimension.z/2;
		is_in = StarGate.IsInEllipsoid(pos, ent, dimension); // lower than 2/5c its flatened
	end

	return is_in;
end

function StarGate.IsInShieldCore(ent, v)
	if (ent.ShShap == 1) then
		return StarGate.IsInEllipsoid(v, ent, ent:GetTraceSize());
	elseif (ent.ShShap == 2) then
		return StarGate.IsInCuboid(v, ent, ent:GetTraceSize());
	elseif (ent.ShShap == 3) then
		return StarGate.IsInAltantisoid(v, ent, ent:GetTraceSize());
	end
end

function StarGate.RayPhysicsPluckerIntersect(trace, dir, ent, in_shape)
	local hitted, hitpos, hitnorm, fraction;
	local TA, TB, TC;
	local a0, a1, a2, a3, a4, a5;
	local b0, b1, b2, b3, b4, b5;
	local c0, c1, c2, c3, c4, c5;
	local A, B;

	local LA = ent:WorldToLocal(trace.StartPos);
	local LB = ent:WorldToLocal(trace.HitPos)

	// Plucker ray coefs.
	local r0 = LA.x*LB.y - LB.x*LA.y;
	local r1 = LA.x*LB.z - LB.x*LA.z;
	local r2 = LA.x      - LB.x;
	local r3 = LA.y*LB.z - LB.y*LA.z;
	local r4 = LA.z      - LB.z;
	local r5 = LB.y      - LA.y;

	local hit; //imaginary variable

	// ran over every triangle in physics
	for i=1, table.getn(ent.RayModel), 3 do

		if in_shape then // if in shield then counter clock wise order
			TA = ent.RayModel[i];
			TB = ent.RayModel[i+1];
			TC = ent.RayModel[i+2];
		else
			TA = ent.RayModel[i+2];
			TB = ent.RayModel[i+1];
			TC = ent.RayModel[i];
		end

		// Plucker triangle coefs.
		a0 = TA.x*TB.y - TB.x*TA.y;
		a1 = TA.x*TB.z - TB.x*TA.z;
		a2 = TA.x      - TB.x;
		a3 = TA.y*TB.z - TB.y*TA.z;
		a4 = TA.z      - TB.z;
		a5 = TB.y      - TA.y;

		b0 = TB.x*TC.y - TC.x*TB.y;
		b1 = TB.x*TC.z - TC.x*TB.z;
		b2 = TB.x      - TC.x;
		b3 = TB.y*TC.z - TC.y*TB.z;
		b4 = TB.z      - TC.z;
		b5 = TC.y      - TB.y;

		c0 = TC.x*TA.y - TA.x*TC.y;
		c1 = TC.x*TA.z - TA.x*TC.z;
		c3 = TC.y*TA.z - TA.y*TC.z;

		// helper coefs.
		A = r0 * a4 + r1 * a5 + r3 * a2;
		B = r0 * b4 + r1 * b5 + r3 * b2;

		// calculate intersection (only true, false)
		if (A + r2 * a3 + r4 * a0 + r5 * a1 < 0) then hit = false;
		elseif (B + r2 * b3 + r4 * b0 + r5 * b1 < 0) then hit = false;
		elseif (r2 * c3 + r4 * c0 + r5 * c1 - A - B < 0) then hit = false;
		else
			local aa = ent:LocalToWorld(TA);
			local bb = ent:LocalToWorld(TB);
			local cc = ent:LocalToWorld(TC);

			// calculate intersection point for our triangle, there will be just one triangle so dont worry
			hitted, hitpos, hitnorm, fraction = StarGate.RayTriangleIntersect(trace.StartPos, dir, aa, bb, cc);
			break;
		end

	end

	//return data or nil
	if hitted then
		return {HitPos=hitpos, Fraction=fraction, HitNormal=hitnorm};
	else
		return nil;
	end
end

function StarGate.RayTriangleIntersect(start, dir, v1, v2, v3)
	local norm = (v2-v1):Cross(v3-v2):GetNormal(); // get normal of the triangle
	local dot = norm:DotProduct(v2-v1); // get dot product for further use

	// Now find plane (defined by DISTANCE, NORMAL) from three points
	local dist = -1*(v1:DotProduct(norm));

	// Find line/plane intersection
	local den = norm:DotProduct(dir);

	// If den is 0 line is parallel to plane
	if (den == 0) then return false end

	// trace fraction
	local t = (-1*(norm:DotProduct(start) + dist)) / den;

	// and our point
	local p = start+dir*t;

	debugoverlay.Line(v1, v2, 2, Color(255,255,255), true);
	debugoverlay.Line(v2, v3, 2, Color(255,255,255), true);
	debugoverlay.Line(v1, v3, 2, Color(255,255,255), true);

	//is it really intersecting?
	if StarGate.PointInTriangle(p, v1,v2,v3) then
		norm = (v2-v1):Cross(v3-v2):GetNormal(); // do one more time jsut to be sure
		return true, p, norm, t;
	else return false, nil, nil, nil;
	end
end

function StarGate.SameSide(p1,p2, a,b)
    local cp1 = (b-a):Cross(p1-a);
    local cp2 = (b-a):Cross(p2-a);
	if (cp1:DotProduct(cp2) >=0) then return true;
    else return false end
end

function StarGate.PointInTriangle(p, a,b,c)
    if (StarGate.SameSide(p,a, b,c) and StarGate.SameSide(p,b, a,c) and StarGate.SameSide(p,c, a,b)) then return true
    else return false end
end

function StarGate.IsRayBoxIntersect(start, hit, ent)
	local box_size = ent:GetTraceSize();

	// Put line in box space
	local new_start = ent:WorldToLocal(start);
	local new_end = ent:WorldToLocal(hit);

	// Get line midpoint and extent
	local LMid = (new_start + new_end) / 2;
	local L = (new_start - LMid);
	local LExt = Vector(math.abs(L.x), math.abs(L.y), math.abs(L.z));

	// Use Separating Axis Test
	// Separation vector from box center to line center is LMid, since the line is in box space
	if (math.abs(LMid.x) > (box_size.x + LExt.x)) then return false end
	if (math.abs(LMid.y) > (box_size.y + LExt.y)) then return false end
	if (math.abs(LMid.z) > (box_size.z + LExt.z)) then return false end

	// Crossproducts of line and each axis
	if (math.abs(LMid.y*L.z - LMid.z*L.y)  >  (box_size.y*LExt.z + box_size.z*LExt.y) ) then return false end
	if (math.abs(LMid.x*L.z - LMid.z*L.x)  >  (box_size.x*LExt.z + box_size.z*LExt.x) ) then return false end
	if (math.abs(LMid.x*L.y - LMid.y*L.x)  >  (box_size.x*LExt.y + box_size.y*LExt.x) ) then return false end

	// No separating axis, the line intersects
	return true;
end

--################# Instead of overwriting the FireBullets function twice (shield/eventhorizon) to recognize bullets, we create a customhook here @aVoN
--################# I know that hooks are good way of doing that, but some gmod update broke then and i had nbo idea how to fix them, so i turend it ent side into a function @Mad
StarGate.Bullets = StarGate.Bullets or {};


hook.Add("EntityFireBullets","StarGate.EntityFireBullets",function(self,bullet)
	if(not bullet) then return end;
	local original_bullet = table.Copy(bullet);
	local override = false; -- If set to true, we will shoot the bullets instead of letting the engine decide
	-- The modified part now, to determine if we hit a shield!
	local spread = bullet.Spread or Vector(0,0,0); bullet.Spread = Vector(0,0,0);
	local direction = (bullet.Dir or Vector(0,0,0));
	local pos = bullet.Src or self:GetPos();
	local rnd = {};
	rnd = {math.Rand(-1,1),math.Rand(-1,1)};
	--################# If we hit anything, run the hook
	local dir = Vector(direction.x,direction.y,direction.z); -- We need a "new fresh" vector
	--Calculate Bullet-Spread!
	if(spread and spread ~= Vector(0,0,0)) then
		-- Two perpendicular vectors to the direction vector (to calculate the spread-cone)
		local v1 = (dir:Cross(Vector(1,1,1))):GetNormalized();
		local v2 = (dir:Cross(v1)):GetNormalized();
		dir = dir + v1*spread.x*rnd[1] + v2*spread.y*rnd[2];
		-- Instead letting the engine decide to add randomness, we are doing it (Just for the trace)
		bullet.Dir = dir;
	end
	local trace = StarGate.Trace:New(pos,dir*16*1024,{self,self:GetParent()});
	if(hook.Call("StarGate.Bullet",GAMEMODE,self,bullet,trace)) then
		return false
	else
		return
	end
end)

local function InitPostEntity( )

	// get existing
	local settings = physenv.GetPerformanceSettings();

	// change velocity for bullets
	settings.MaxVelocity = 20000;

	// set
	physenv.SetPerformanceSettings( settings );


end
hook.Add( "InitPostEntity", "LoadPhysicsModule", InitPostEntity );

--####################
-- stargateextras.lua
--####################

StarGate.CYCLE_INTERVAL = 0.2 -- Number of seconds between Think() calls
--StarGate.COOLING_PER_CYCLE = 300 -- Amount of heat lost by a stargate per Think cycle
--StarGate.STARGATE_DEFAULT_ENERGY_CAPACITY = 580000
--StarGate.STARGATE_DEFAULT_ENERGY_DRAIN = StarGate.STARGATE_DEFAULT_ENERGY_CAPACITY / 2280 * StarGate.CYCLE_INTERVAL

function StarGate.IsEntityValid(entity)
   return IsValid(entity)
end

function StarGate.GetEntityCentre(entity)
   if(entity == nil or not IsValid(entity)) then
      Msg("Entity passed to GetEntityCentre(entity) cannot be nil.\n")
      return
   end

   return entity:LocalToWorld(entity:OBBCenter())
end

function StarGate.IsStargateOpen(gate)
   return gate.open == true || gate.IsOpen == true
end

function StarGate.IsStargateOutbound(gate)
   return StarGate.IsStargateOpen(gate) == true && (gate.outbound == true || gate.Outbound == true)
end

function StarGate.GetRemoteStargate(localGate)
   return localGate.other_gate || localGate.Target
end

function StarGate.IsIrisClosed(gate)
   return gate.irisclosed == true || (gate.Iris ~= nil && gate.Iris.IsActivated == true)
end

function StarGate.IsStargateDialling(gate)
   return gate.inuse == true || gate.Dialling == true
end

function StarGate.IsProtectedByGateSpawner(entity)
   return entity:GetNetworkedBool("GateSpawnerProtected", false) || entity.GateSpawnerProtected == true
end

--################ DrFattyJr's Functions

function StarGate.GetEntityCentre2(entity) -- Get the centre of the gate
  if(entity == nil) then
    Msg("Entity passed to GetEntityCentre(entity) cannot be nil.\n")
    return
  end

  local min,max = entity:WorldSpaceAABB()
	local offset = (min+max)/2

	return offset
end

function StarGate.FindEntInsideSphere(pos, rad, class) -- Made my own because the other one can't be called client side :(
	local ent = {}
	for _,v in pairs(ents.FindByClass(class)) do
		local dis = v:GetPos():Distance(pos)
		if dis < rad then
			table.insert(ent, v)
		end
	end
	return ent
end

function StarGate.ShieldTrace(pos, dir, filter)
	local tr = StarGate.Trace:New(pos, dir, filter)
	local aim = (dir-pos):GetNormal()
	tr.HitShield = false

	if(IsValid(tr.Entity)) then 		-- special execption for when hitting avon's shield
		local class = tr.Entity:GetClass()
		if(class == "shield") then 	--This is a  ridiculously complex way of actually finding where the spherical shield is and not the cubic bounding box if anybody knows of a better way PLEASE tell me
			local pos2 = tr.Entity:GetPos()
			local rad = tr.Entity:GetNetworkedInt("size",0)
			local relpos = tr.HitPos-pos2
			local a = aim.x^2+aim.y^2+aim.z^2
			local b = 2*(relpos.x*aim.x+relpos.y*aim.y+relpos.z*aim.z)
			local c = relpos.x^2+relpos.y^2+relpos.z^2-rad^2
			local dist = (-1*b-(b^2-4*a*c)^0.5)/(2*a)	-- Thank god for Brahmagupta

			if tostring(dist) == "-1.#IND" then 	-- Sometimes the trace will hit the bounding box but end up not actually hitting the round shield and this should mean that dist is a non-real number
				tr = StarGate.ShieldTrace(tr.HitPos, dir, tr.Entity, true)
			elseif dist < 0 then -- If the trace starts in the sphere the dist will be negative.
				dist = (-1*b+(b^2-4*a*c)^0.5)/(2*a)
				tr.HitPos = tr.HitPos+aim*dist
				tr.HitNormal = (tr.HitPos-pos2):GetNormal()
				tr.HitShield = true
			else
				tr.HitPos = tr.HitPos+aim*dist
				tr.HitNormal = (tr.HitPos-pos2):GetNormal()
				tr.HitShield = true
			end
		end
	end

	return tr
end

function StarGate.ArePointsInsideAShield(points) -- Thanks PyroSpirit for the help :})<<<(P.S. It has a moustache).
	local IsInShield = {}
	local num = table.getn(points)
	for i=1,num do
		IsInShield[i] = false
	end

	for _,v in pairs (ents.FindByClass("shield")) do
		local Pos = v:GetPos()
		local rad = v:GetNWInt("size")+200
		if ((not v:GetNWBool("depleted", false)) and (not v:GetNWBool("containment",false))) then
			for i=1,num do
				local dis = points[i]:Distance(Pos)
				if dis <= rad then
				 	IsInShield[i] = true
				end
			end
		end
	end

	for _,v in pairs (ents.FindByClass("shield_core_buble")) do
		local Pos = v:GetPos()
		local rad = v:GetNWInt("SGESize")+200
		if not v:GetNWBool("depleted", false) then
			for i=1,num do
				local dis = points[i]:Distance(Pos)
				if dis <= rad then
				 	IsInShield[i] = true
				end
			end
		end
	end


	return IsInShield
end

function StarGate.IsEntityShielded(entity)
   local isInShield = StarGate.ArePointsInsideAShield({entity:GetPos()})
   return isInShield[1]
end

function StarGate.FindInsideRotatedBox(centre, min, max, ang) 	-- THANK YOU aVoN!!!!!!! :}}}) <<<This one gets 3 moustaches.
	local entities = ents.FindInSphere(centre,(min-max):Length()/2)
	local directions = {}
	local RotationMatrix = MMatrix.EulerRotationMatrix(ang.p,ang.y,ang.r)
	for _,v in pairs(entities) do
		directions[v] = RotationMatrix*(v:GetPos()-centre)
	end
	for k,v in pairs(entities) do
		local pos = directions[v];
		-- Snipplet taken from aVoN's tracelin-class of the stargatepack
		if not (
			(pos.x >= min.x and pos.x <= max.x) and
			(pos.y >= min.y and pos.y <= max.y) and
			(pos.z >= min.z and pos.z <= max.z)
		) then
			entities[k] = nil;
		end
	end
	return entities
end

function StarGate.GetTeleportedVector2(ent1, ent2, pos, aim)
    local pos1 = ent1:LocalToWorld(ent1:OBBCenter())
    local pos2 = ent2:LocalToWorld(ent1:OBBCenter())
    local dir1 = pos-pos1
    local ang1 = ent1:GetAngles()
    local ang2 = ent2:GetAngles()
    local rpos = pos2+(dir1:Angle()-ang1+ang2):Forward()*(dir1:Length())
    local v = ((-1*aim):Angle()-ang1+ang2):Forward()
    local rdir = 2*(ang2:Forward():DotProduct(v))*(ang2:Forward())-v

    return rpos, rdir
end

-- StarGate.Trace:Add("p_shield",
    -- function(e,values,trace,in_box)
        -- local energy = e:GetNWInt("energy")
        -- if energy > 0 then
            -- if not in_box then
                -- return true;
            -- end
        -- end
    -- end
-- );

-- ent1 = The ent where seeing has line of sight
-- enttab = the table of ents your trying to see
-- postab = the corosponding table of positions
function StarGate.LOS(ent1, enttab, postab)
	local num = table.getn(enttab)
	local hitent = {}
	local hitentpos = {}
	local trace = {
		start = ent1.SplodePos,
		filter = ent1,
		mask = MASK_NPCWORLDSTATIC
	}

	for i=1,num do
		trace.endpos = postab[i]
		local tr = util.TraceLine(trace)
		if (tr.Fraction > 0.99) then
			table.insert(hitent, enttab[i])
			table.insert(hitentpos, postab[i])
		end
	end

	local size = table.getn(hitent)
	local inshield = StarGate.ArePointsInsideAShield(hitentpos, 50)

	for i=1,size do
		if inshield[i] then
			hitent[i] = nil
			hitentpos[i] = nil
		end
	end

	return hitent,hitentpos
end

StarGate.EventHorizonTypes = StarGate.EventHorizonTypes or {}
function StarGate.RegisterEventHorizon(type,data)
	StarGate.EventHorizonTypes[type] = data
end