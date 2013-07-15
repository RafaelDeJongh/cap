StarGate.CYCLE_INTERVAL = 0.2 -- Number of seconds between Think() calls
StarGate.COOLING_PER_CYCLE = 300 -- Amount of heat lost by a stargate per Think cycle
StarGate.STARGATE_DEFAULT_ENERGY_CAPACITY = 580000
StarGate.STARGATE_DEFAULT_ENERGY_DRAIN = StarGate.STARGATE_DEFAULT_ENERGY_CAPACITY / 2280 * StarGate.CYCLE_INTERVAL

function StarGate.IsEntityValid(entity)
   return IsValid(entity)
end

function StarGate.GetEntityCentre(entity)
   if(entity == nil or not IsValid(entity)) then
      error("Entity passed to GetEntityCentre(entity) cannot be nil.\n")
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
    error("Entity passed to GetEntityCentre(entity) cannot be nil.\n")
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
