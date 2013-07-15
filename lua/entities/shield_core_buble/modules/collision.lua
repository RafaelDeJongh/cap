function ShieldCoreShouldCollide(ent1, ent2)
	if ent1 == ent2 then return true end
	if (!ent1:IsValid() || !ent2:IsValid()) then return true end

	local class  = "shield_core_buble";
	local world = "worldspawn";
	local shield;
	local hitent;

	// fast check, if we hitted other shield core (prevent errors)
	if ((ent1:GetClass() == class) and (ent2:GetClass() == class)) then return false end

	// fast check, if we hitted other prop (here was a bug!)
	if (ent1:GetClass() == ent2:GetClass()) then return end

	if (ent1:GetClass() == class) then
		shield = ent1;
		hitent = ent2;
	elseif (ent2:GetClass() == class) then
		shield = ent2;
		hitent = ent1;
	else return
	end

	if hitent:IsPlayer() then shield:PlayerPush(hitent) end

	local hitclass = hitent:GetClass();
	local shieldown = shield.Parent:GetOwner();
	local hitown = hitent:GetOwner();

	// smal check for not colliding with world, shield generator
	if (hitclass == world or shield.Parent == hitent) then return false end

	 // if enabled and ((hit ent is player or prop owner in table) or (player or prop owner is immunity))
	if (shield.Enabled and ((table.HasValue(shield.nocollide, hitent) or table.HasValue(shield.nocollide, hitent:GetOwner()))
	or (shield.Parent.Immunity and (shieldown == hitent or shieldown == hitown)) )) then
		if hitent:IsPlayer() then shield:PlayerPush(hitent) end // ugly but maybe will work:p
		return false
	else
		return
	end
end
hook.Add( "ShouldCollide", "ShieldCoreShouldCollide", ShieldCoreShouldCollide )