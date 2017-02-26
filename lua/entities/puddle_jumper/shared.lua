if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Base = "base_anim"
ENT.Type = "vehicle"

ENT.PrintName = "Puddle Jumper"
ENT.Author = "RononDex, Iziraider, Rafael De Jongh"
ENT.Category = "Stargate Carter Addon Pack: Ships"
ENT.AutomaticFrameAdvance = true

list.Set("CAP.Entity", ENT.PrintName, ENT);

function ENT:InJumper(p)
	local bound1,bound2 = self:GetCollisionBounds();
	local pos = self:WorldToLocal(p:GetPos());
	if((pos.x > bound1[1]+20) and (pos.x < bound2[1]-100) and (pos.y > bound1[2]+70) and (pos.y < bound2[2]-70) and (pos.z > bound1[3]) and (pos.z < bound2[3])) then
		return true;
	end
	return false;
end