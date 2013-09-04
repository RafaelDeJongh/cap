if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

ENT.RingModel = "models/Madman07/ancient_rings/ring.mdl";
ENT.BaseModel = "models/Madman07/ancient_rings/ring.mdl";

ENT.OriFix = 0;

function ENT:SpawnFunction(p,tr)
	if (not tr.Hit) then return end;
	local e = ents.Create("ring_base_goauld");
	e:SetModel(e.BaseModel);
	e:SetPos(tr.HitPos);
	e:Spawn();
	e:Activate();
	local ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360
	e:SetAngles(ang);
	local phys = e:GetPhysicsObject();
	if IsValid(phys) then phys:EnableMotion(false) end
	e:CartersRampsRing(tr);
	return e;
end