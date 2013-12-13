--[[
	Shield Core Buble
	Copyright (C) 2011 Madman07
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.CAP_NotSave = true;

AddCSLuaFile("modules/bullets.lua");
AddCSLuaFile("modules/sphere.lua");
AddCSLuaFile("modules/box.lua");
AddCSLuaFile("modules/atlantis.lua");
include("modules/bullets.lua");
include("modules/collision.lua");
include("modules/sphere.lua")
include("modules/box.lua")
include("modules/atlantis.lua")

StarGate.Trace:Add("shield_core_buble",
	function(e,values,trace,in_box)
		if(not e.Depleted and e.Enabled) then
			local own = e;
			if (type(values[3]) == "table") then
				own = StarGate.GetMultipleOwner(values[3][1]);
				if (IsValid(values[3][1])) then
					values[3][1]:SetNetworkedEntity("SC_Owner", own); // for clientside prediction
				end
			else
				own = StarGate.GetMultipleOwner(values[3]);
				if (IsValid(values[3])) then
					values[3]:SetNWEntity("SC_Owner", own);
				end
			end
			if not IsValid(own) then return true end

			if (table.HasValue(e.nocollide, own) or (e.Parent.Immunity and e.Parent.Owner == own)) then
				return false
			else
				return true
			end
		else
			return false
		end
	end
);

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetColor(Color(0,0,0,0));
	self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA);
	self.Entity:SetCustomCollisionCheck(true);

	self.Enabled = false;
	self.nocollide = {};
	self.nocollideID = {};
	self.Depleted = false;

	self.Radius = 0.01;
	self.Size = Vector(1,1,1);
	self.RayModel = {};

	self.IsShieldCore = true;
	self.HitDelay = {};
end

-----------------------------------COLLISION SCALE----------------------------------

function ENT:SetCollisionScale(model, size)
	local vect, vec;
	local convex = {}
	local ShieldModel;
	local mod = 1;

	if (model == "models/Madman07/shields/sphere.mdl") then ShieldModel = SphereModel;
	elseif (model == "models/Madman07/shields/box.mdl") then ShieldModel = BoxModel;  mod = 2;
	elseif (model == "models/Madman07/shields/atlantis.mdl") then ShieldModel = AtlantisModel;  mod = 3; end

	for _, vertex in pairs(ShieldModel) do
		vec = Vector(vertex.y*size.y,vertex.x*size.x,vertex.z*size.z); -- hm, somewhy it should be y,x,z not x,y,z
		vect = Vertex(vec, 1, 1, Vector( 0, 0, 1 ) )
		table.insert(convex, vect);
		table.insert(self.RayModel, vec);
	end

	if (table.getn(convex) == 0) then return end //safefail

	if (size.x > size.y) then
		if (size.x > size.z) then self.Radius = size.x
		else self.Radius = size.z end
	else
		if (size.y > size.z) then self.Radius = size.y
		else self.Radius = size.z end
	end
	self.Size = size*256;

	self.Entity:PhysicsFromMesh(convex)
	local phys = self.Entity:GetPhysicsObject();
	phys:EnableCollisions(true)
	phys:EnableMotion(false)
	self:SetCollisionBounds(-1*self.Radius*Vector(1,1,1)*256,self.Radius*Vector(1,1,1)*256)

	self:SetNWBool("DoPhysicClientside", true);
	self:SetNWInt("PhysicModel", mod);
	self:SetNWVector("PhysicScale", size);

	self:SetNWInt("SGESize",self.Radius);

	self:SetNWVector("TraceSize",self.Size);

	self:SetNotSolid(true);
	self.ShShap = mod;
end

function ENT:GetTraceSize()
	return self.Size;
end

function ENT:IsEntityInShield()
	for _,v in pairs(ents.GetAll()) do
		if StarGate.IsInShieldCore(v, self.Entity) then
			table.insert(self.nocollide, v);
			table.insert(self.nocollideID, v:EntIndex()); //tracelines
		end
	end
end

-----------------------------------STATUS----------------------------------

function ENT:Status(status)
	self.Enabled = status;
	if status then
		self:DrawBubbleEffect(Vector(1,1,1), Vector(1,1,1), 1, false, false);
		self:SetNotSolid(false);
		self:SetNWBool("Enabled",true); // tracelines
		self:IsEntityInShield();
		self:SetNWString("NoCollideID", string.Implode(" ", self.nocollideID)); // tracelines
	else
		self.nocollide = nil;
		self.nocollide = {};
		self:DrawBubbleEffect(Vector(1,1,1), Vector(1,1,1), 1, true, false);
		self:SetNWBool("Enabled",false);
		self:SetNotSolid(true);
	end
end

-----------------------------------COLLISION----------------------------------

function ENT:PhysicsCollide( data, physobj )
	local e = data.HitEntity
	if (e == self or e == self.Parent) then return end
	if (e:GetClass() == "worldspawn") then return end
	if (self.HitDelay[e]) then return end -- give it some time to fly away
	if e.CoreNotCollide and e.CoreEntity == self then return end -- bullets?

	local velo = data.TheirOldVelocity;
	local normal = data.HitNormal;
	local pos = data.HitPos;
	self.LastEnt = e;

	local phys = e:GetPhysicsObject();
	local strength = 5;
	if(phys and phys:IsValid()) then
		strength = math.ceil(phys:GetMass()*velo:Length()/10000);
	end

	self.HitDelay[e] = true;
	self:Reflect(e, velo, normal, pos);

	timer.Create("Delay"..e:EntIndex(),0.1,0, function() if (IsValid(self)) then self.HitDelay[e] = false; end end);

	self.Parent:Hit(strength,normal,pos);
	self:DrawBubbleEffect(pos, normal, strength, false, true);
end

-----------------------------------REFLECT----------------------------------

function ENT:Reflect(e, velo, normal, pos)
	local IS_NPC = e:IsNPC();
	if(not IS_NPC and velo == Vector(0,0,0)) then return end; -- Not moving = no collision!
	local class = e:GetClass();
	local phys = e:GetPhysicsObject();

	-- Props
	if(phys:IsValid() and not (IS_NPC or e:IsPlayer())) then
		-- Anyone holds this object (Makes theses MingeBags unavailable to move props with physgun into the shield with the intention to exploit it)
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
		-- Removes all old velocity from it before
		phys:EnableMotion(false);
		phys:EnableMotion(true);
		phys:Wake();
		-- Now apply force!
		phys:ApplyForceOffset(normal*phys:GetMass()*1000,pos-20*normal);
	else
		local old_vel = e:GetVelocity():Length();
		e:SetLocalVelocity(-1*normal*600);
		e:SetVelocity(-1*normal*600);
	end
end

-----------------------------------EFFECT----------------------------------

function ENT:DrawBubbleEffect(pos, normal, strength, turn_off, hit)
	if IsValid(self.Parent) then
		if self.Parent.Draw then -- if Atlantis type
			if (not hit) then
				local fx = EffectData();
				fx:SetEntity(self.Parent);
				if(turn_off) then
					fx:SetMagnitude(0);
				else
					fx:SetMagnitude(1);
				end
				util.Effect("shield_core_flash_atl",fx,true,true);
			else
				local fx = EffectData();
				fx:SetOrigin(pos);
				fx:SetEntity(self);
				fx:SetNormal(normal)
				fx:SetScale(strength);
				util.Effect("shield_core_hit_atl",fx,true,true);
			end

		else
			if (hit) then
				local fx = EffectData();
				fx:SetOrigin(pos);
				fx:SetEntity(self);
				fx:SetNormal(normal)
				fx:SetScale(strength);
				util.Effect("shield_core_hit",fx,true,true);
			end

			local fx = EffectData();
			fx:SetEntity(self.Parent);
			if(turn_off) then
				fx:SetMagnitude(1);
			elseif(hit) then
				fx:SetMagnitude(2);
			else
				fx:SetMagnitude(0);
			end
			util.Effect("shield_core_flash",fx,true,true);
		end
	end
end

-----------------------------------HIT----------------------------------

function ENT:Hit(e,pos,dmg,normal)
	if(not self.Parent.Depleted) then
		if(self.Parent.Strength > 2) then
			normal = normal or Vector(0,0,0);
			self.Parent:Hit(dmg,normal,pos);
			self:DrawBubbleEffect(pos, normal, dmg, false, true);
		else
			self:Status(false);
			self.Parent:EmitSound(self.Parent.Sounds.Disengage,90,math.random(90,110));
			self.Parent.Depleted = true;
			self.Depleted = true;
			self.Entity:SetNWBool("depleted",true); -- For the traceline class - Clientside
		end
	end
end

-----------------------------------BORDER DETECTION----------------------------------

function ENT:PlayerPush(ply)
	if (self.Pushing) then return end
	local border = Vector(10,10,10);
	local len = ply:GetVelocity():Length();

	if self:IsEntOnBorder(ply, border) then ply:SetMoveType(MOVETYPE_WALK) end

	if (len > 750) then
		if (len > 1250) then
			border = Vector(15,15,15);
		end
		if (len > 1750) then
			border = Vector(25,25,25);
		end

		if self:IsEntOnBorder(ply, border) then
			ply:SetMoveType(MOVETYPE_WALK);

			local pos = ply:GetPos();
			local normal = (-ply:GetPos()+self.Entity:GetPos()):GetNormal();
			self:Reflect(ply, ply:GetVelocity(), normal, pos);
			self:DrawBubbleEffect(pos, normal, 10, false, true);
			self.Pushing = true;
			timer.Simple(0.1,function() self.Pushing = false end)
		end
	end
end

function ENT:IsEntOnBorder(ent, border)
	local in_range = false;
	local in_range2 = false;

	if (self.ShShap == 1) then
		in_range = StarGate.IsInEllipsoid(ent:GetPos(), self.Entity, self.Size + border);
		in_range2 = StarGate.IsInEllipsoid(ent:GetPos(), self.Entity, self.Size - border);
	elseif (self.ShShap == 2) then
		in_range = StarGate.IsInCuboid(ent:GetPos(), self.Entity, self.Size + border);
		in_range2 = StarGate.IsInCuboid(ent:GetPos(), self.Entity, self.Size - border);
	elseif (self.ShShap == 3) then
		in_range = StarGate.IsInAltantisoid(ent:GetPos(), self.Entity, self.Size + border);
		in_range2 = StarGate.IsInAltantisoid(ent:GetPos(), self.Entity, self.Size - border);
	end

	if in_range and not in_range2 then return true
	else return false end
end

local function CalcDmgProtect(ent, inflictor, attacker, ammount, dmginfo)
	if (IsValid(ent) and ent:IsPlayer()) then
		if IsValid(inflictor) then
			local class = inflictor:GetClass();
			if (class == "tokra_shield" or class == "shield_core_buble") then
				dmginfo:SetDamage(0);
			end

			local start = inflictor:LocalToWorld(inflictor:OBBCenter()) - inflictor:GetVelocity():GetNormal()*20; //move it a bit into attacker side (better protect for shield and staff)
			local endpos = ent:LocalToWorld(ent:OBBCenter());

			debugoverlay.Line(start, endpos, 20, Color(255,255,255));
			local dir2 = endpos - start;

			local trace = StarGate.Trace:New(start,dir2,inflictor);

			if IsValid(trace.Entity) then
				local class2 = trace.Entity:GetClass();
				if (class2 == "shield_core_buble" or class2 == "tokra_shield") then
					if(trace.Entity:Hit(attacker, trace.HitPos, dmginfo:GetDamage()*10, -1*trace.Normal)) then return end;
				end
				if (trace.Entity != ent) then
					local dmg = 2-math.Clamp(start:Distance(endpos)/100, 0, 2);
					dmginfo:SetDamage(dmg); //small damage relative to distance
				end
			end
		end
	end
end
hook.Add("EntityTakeDamage", "CAP.GlobalDamageProtect",CalcDmgProtect)