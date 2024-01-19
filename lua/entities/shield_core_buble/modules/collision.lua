function ShieldCoreShouldCollide(ent1, ent2)
	if ent1 == ent2 then return true end
	if not (ent1:IsValid() and ent2:IsValid()) then return true end

	local class = "shield_core_buble"
	local world = "worldspawn"
	local shield, hitent

	-- Fast check if we hit another shield core to prevent errors
	if ent1:GetClass() == class and ent2:GetClass() == class then return false end

	-- Fast check if we hit the same class (bug fix)
	if ent1:GetClass() == ent2:GetClass() then return end

	if ent1:GetClass() == class then
		shield = ent1
		hitent = ent2
	elseif ent2:GetClass() == class then
		shield = ent2
		hitent = ent1
	else
		return
	end

	if hitent:IsPlayer() then
		shield:PlayerPush(hitent)
	end

	local hitclass = hitent:GetClass()
	local shieldown = shield.Parent:GetOwner()
	local hitown = hitent:GetOwner()

	-- Small check for not colliding with world, shield generator
	if hitclass == world or shield.Parent == hitent then
		return false
	end

	-- If enabled and ((hit ent is a player or prop owner in the table) or (player or prop owner is immunity))
	if shield.Enabled and (
		(table.HasValue(shield.nocollide, hitent) or table.HasValue(shield.nocollide, hitown)) or
		(shield.Parent.Immunity and (shieldown == hitent or shieldown == hitown))
	) then
		if hitent:IsPlayer() then
			shield:PlayerPush(hitent)
		end
		return false
	else
		return
	end
end

hook.Add("ShouldCollide", "ShieldCoreShouldCollide", ShieldCoreShouldCollide)
