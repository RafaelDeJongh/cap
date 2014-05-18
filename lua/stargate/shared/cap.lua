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