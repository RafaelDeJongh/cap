--[[
	Tokra Shield
	Copyright (C) 2011 Madman07
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
AddCSLuaFile("box.lua");
include("box.lua")

AddCSLuaFile("bullets.lua");
include("bullets.lua");

StarGate.Trace:Add("tokra_shield",
	function(e,values,trace,in_box)
		return true;
	end
);

ENT.CAP_NotSave = true;

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:SetModel("models/Madman07/shields/box.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetColor(Color(0,0,0,0));
	self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.Entity:SetCustomCollisionCheck(true);

	self.Initpos = self:GetPos()
	self.Initang = self:GetAngles()
	self.HitDelay = {};

	self.Enabled = false;
	self.RayModel = {};
	self:SetNetworkedBool("DoClientSide", false);
end

-----------------------------------COLLISION SCALE----------------------------------

function ENT:CreateCollision(Gen1, Gen2)
	if not IsValid(Gen1) then return end
	if not IsValid(Gen2) then return end

	local convex = {};
	local length = Gen1:GetPos():Distance(Gen2:GetPos());
	self.Entity:SetNWInt("Len", length);

	for _, vertex in pairs(TokraBoxModel) do
		local vec = Vector(vertex.x*length,vertex.y,vertex.z);
		table.insert(convex, Vertex(vec, 1, 1, Vector( 0, 0, 1 )));
	end
	if (table.getn(convex) == 0) then return end //safefail

	self.Entity:PhysicsFromMesh(convex);
	local phys = self.Entity:GetPhysicsObject();
	if IsValid(phys) then
		phys:EnableCollisions(true);
		phys:EnableMotion(false);
	end

	self:SetNWBool("DoClientSide", true);
end

function ENT:Think()
	if not IsValid(self.Gen1) or not IsValid(self.Gen2) then self:Remove() return end
	self:SetPos(self.Initpos)
	self:SetAngles(self.Initang)

	self.Entity:NextThink(CurTime()+0.1)
	return true
end

-----------------------------------COLLISION----------------------------------

function ENT:Immunity(Gen1, Gen2)
	self.Gen1 = Gen1;
	self.Gen2 = Gen2;
end

function ENT:PhysicsCollide( data, physobj )
	local e = data.HitEntity
	if (self.HitDelay[e]) then return end -- give it some time to fly away

	local class = e:GetClass();
	if (class == "worldspawn" or self.Gen1 == e or self.Gen2 == e) then return end

	local velo = data.TheirOldVelocity;
	local normal = data.HitNormal;
	local pos = data.HitPos;

	local phys = e:GetPhysicsObject();
	 local strength = 1;
	if(phys and phys:IsValid()) then
		strength = math.ceil(phys:GetMass()*velo:Length()/10000);
	end

	self.HitDelay[e] = true;
	self:Reflect(e, velo, normal, pos);

	timer.Create("Delay"..e:EntIndex(),0.1,1, function() if IsValid(self) then self.HitDelay[e] = false; end end);

	 self:DrawBubbleEffect(pos, normal, strength, false, true);
end

-----------------------------------REFLECT----------------------------------

 function ENT:Reflect(e, velo, normal, pos)
	local IS_NPC = e:IsNPC();
	if(not IS_NPC and velo == Vector(0,0,0)) then return end; -- Not moving = no collision!
	local class = e:GetClass();
	local phys = e:GetPhysicsObject();

	//Props
	if(phys:IsValid() and not (IS_NPC or e:IsPlayer())) then
		//Anyone holds this object (Makes theses MingeBags unavailable to move props with physgun into the shield with the intention to exploit it)
		if(e:IsPlayerHolding()) then
			local id = e:EntIndex();
			phys:EnableMotion(false);
			timer.Create("Ungrab"..id,0.2,0,
				function()
					if(e and phys and e:IsValid() and phys:IsValid()) then
						if(e:IsPlayerHolding()) then return end;
						phys:EnableMotion(true);
						phys:Wake();
					end
					timer.Destroy("Ungrab"..id);
				end
			);
			return;
		end
		//Removes all old velocity from it before
		phys:EnableMotion(false);
		phys:EnableMotion(true);
		phys:Wake();
		//Now apply force!
		phys:ApplyForceOffset(normal*phys:GetMass()*1000,pos-20*normal);
	else
		local old_vel = e:GetVelocity():Length();
		e:SetLocalVelocity(-1*normal*old_vel*1.5);
		e:SetVelocity(-1*normal*old_vel*1.5);
	end
end

-----------------------------------EFFECT----------------------------------

function ENT:DrawBubbleEffect(pos, normal, strength, turn_off, hit)
	if (hit) then
		local fx = EffectData();
		fx:SetOrigin(pos);
		fx:SetEntity(self);
		fx:SetNormal(normal)
		fx:SetScale(strength);
		util.Effect("shield_core_hit",fx,true,true);
	end
 end

function ENT:Hit(e,pos,dmg,normal)
	self:DrawBubbleEffect(pos, normal, dmg, false, true);
	return true;
end