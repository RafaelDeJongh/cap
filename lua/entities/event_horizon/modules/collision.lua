/*
	New physics collision code
	Created by AlexALX (c) 2012

	Sorry RononDex, but this code created from from scratch, and only one line your here...
*/

-- It seems like there is still physics crash sometimes, and i have no idea why, but still, much less that in original code

-- returning false means they can pass through it

function ShouldEHEntitiesCollide(ent1,ent2)
	if ent1 == ent2 then return true end
	local enta, entb = ent1, ent2
	if (not IsValid(enta) || not IsValid(entb)) then return true end

	local eh, ent, tent, ent_dir, tent_bdir;

	local eha, ehb;
	local entab, entbb;
	local enta_dir, entb_dir;
	local eha_valid, ehb_valid;
	local enta_bdir, entb_bdir = 0,0;
	local noupdate = false;

	-- may prevent physics crash, but still sometimes crash somewhy(
	-- v2.0 may prevent crash better now
	if (enta.___last_entb!=nil and entb.___last_enta!=nil and enta.___last_entb == entb:EntIndex() and entb.___last_entb == enta:EntIndex()) then

		if (enta.___last_res!=nil) then
			local res = enta.___last_res;
			eha,entab,enta_dir,eha_valid,enta_bdir = res[1],res[2],res[3],res[4],res[5];
		end
		if (entb.___last_res!=nil) then
			local res = entb.___last_res;
			ehb,entbb,entb_dir,ehb_valid,entb_bdir = res[1],res[2],res[3],res[4],res[5];
		end

		enta.___last_entb = nil;
		enta.___last_enta = nil;
		entb.___last_enta = nil;
		entb.___last_entb = nil;
		enta.___last_res = nil;
		entb.___last_res = nil;
		--print("PREVENT PHYSICS CRASH");
		noupdate = true;

	else
		eha, ehb = enta:GetNetworkedEntity("PhysEntity",NULL), entb:GetNWEntity("PhysEntity",NULL);
		entab, entbb = enta:GetNWBool("PhysBuffered",false), entb:GetNWBool("PhysBuffered",false);
		enta_dir, entb_dir = enta:GetNWInt("PhysBufferedDir",0),entb:GetNWInt("PhysBufferedDir",0);
		eha_valid, ehb_valid = eha:IsValid(),ehb:IsValid();
	end

	if (not noupdate) then
		entb.___last_enta = enta:EntIndex();
		enta.___last_entb = entb:EntIndex();
		enta.___last_res = {eha,entab,enta_dir,eha_valid,enta_bdir};
		entb.___last_res = {ehb,entbb,entb_dir,ehb_valid,entb_bdir};
	end

	if (eha_valid and ehb_valid or entab and entbb) then
		if (enta_dir!=0 and entb_dir!=0 and enta_dir!=entb_dir) then
			return false
		end
		return
	elseif (eha_valid and entab) then
		eh = eha;
		ent = enta;
		ent_dir = enta_dir;
		tent_bdir = entb_bdir;
		tent = entb;
	elseif (ehb_valid and entbb) then
		eh = ehb;
		ent = entb;
		ent_dir = entb_dir;
		tent_bdir = enta_bdir;
		tent = enta;
	else
		return
	end

	-- if collide with gate
	if (tent.IsStargate) then
		return
	end

	local bdir = 0
	if (tent_bdir!=0) then
		bdir = tent_bdir;
	else
		-- @RononDex line
		if (eh:GetForward():DotProduct((tent:GetPos()-eh:GetPos()):GetNormalized()) < 0) then
			bdir = -1
		else
			bdir = 1
		end
		if (not noupdate) then
			tent.___last_res[5] = bdir;
		end
	end

	if(ent_dir!=0 and ent_dir!=bdir)then
		return false;
	end

	return
end
-- not add it server-side if convar disabled, client-side will not create problems and disabled in eh so can stay
if (CLIENT or SERVER and GetConVar("stargate_physics_clipping"):GetBool()) then
	hook.Add( "ShouldCollide", "ShouldEHEntitiesCollide", ShouldEHEntitiesCollide )
end

-- And hey, now its also work client-side!