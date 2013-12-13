/*
	Goauld Iris/Shield for GarrysMod10
	Copyright (C) 2007  aVoN, 2010 Madman07
*/

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Goauld Iris"
ENT.Author = "aVoN, Madman07"
ENT.WireDebugName = "Goauld Iris"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if SERVER then

--################# HEADER #################
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end
AddCSLuaFile();

ENT.NotTeleportable = true;
ENT.NoDissolve = true;
ENT.IsIris = true; -- We are an iris, lol
ENT.CDSIgnore = true; -- CDS Immunity
function ENT:gcbt_breakactions() end; ENT.hasdamagecase = true; -- GCombat invulnarability!

ENT.Sounds = {
	Open=Sound("stargate/iris_atlantis_open.mp3"),
	Close=Sound("stargate/iris_atlantis_close.mp3"),
	Hit=Sound("stargate/iris_atlantis_hit.mp3"),
	Idle=Sound("stargate/iris_atlantis_loop.wav"),
	OpenEnergy=Sound("stargate/iris_open_atlantis.mp3"),
	Fail=Sound("buttons/button19.wav"),
}

--################# Init @aVoN
function ENT:Initialize()
	self.Entity:SetModel("models/Madman07/shields/goauld_iris.mdl");

	self.Entity:SetRenderMode(RENDERMODE_NONE)
	self.Entity:SetMoveType(MOVETYPE_NONE);
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD);
	self.Entity:SetSolid(SOLID_NONE);
	self.Entity:DrawShadow(false);
	self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA);
	self.Entity:SetColor(Color(0,0,0,0))

	self.NextAction = 0;
	self:CreateWireInputs("Activate","Toggle");
	self:CreateWireOutputs("Activated");
	self.LastMoveable = true;

	-- Always spawn frozen, except we are welded to something (prevents it from falling into the map's ground)
	self.Phys = self.Entity:GetPhysicsObject();
	self.Phys:SetMass(5000); -- Avoids playing running against it making it snap back so they die
	if(#StarGate.GetConstrainedEnts(self.Entity,1) == 0) then
		self.Phys:EnableMotion(false);
	end

	self.IsActivated = false;
	self:SetNetworkedVector("Col", Vector(200,100,0));
	self.GateLink = NULL;
	timer.Create("StarGateIrisCheck"..self:EntIndex(),10.0,0,function()
		local remove = true;
		if (IsValid(self) and IsValid(self.GateLink) and constraint.HasConstraints(self)) then
			local entities = StarGate.GetConstrainedEnts(self,2);
			if(entities) then
				for k,v in pairs(entities) do
					if(v.IsStargate and v==self.GateLink) then
						remove = false;
					end
				end
			end
		else
			remove = true;
		end
		if (remove) then self:Remove(); end
	end);

	if (pewpew and pewpew.NeverEverList and not table.HasValue(pewpew.NeverEverList,self.Entity:GetClass())) then table.insert(pewpew.NeverEverList,self.Entity:GetClass()); end -- pewpew support
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:Think()
	-- have energy check for energy and eat it at same time, shorter code
	if(self.IsActivated) then
		if(self.HasRD) then
			local gate = self:FindGate();
			if IsValid(gate) and gate.IsStargate and not gate:HaveEnergy(true,true) then self:TrueActivate(true) end
		end
	end
	self.Entity:NextThink(CurTime()+0.5)
	return true
end

--################# Finds a gate @aVoN
function ENT:FindGate()
	local gate;
	local dist = 150;
	local pos = self.Entity:GetPos();
	for _,v in pairs(ents.FindByClass("stargate_*")) do
		if(v.IsStargate and v:GetClass() != "stargate_supergate") then
			local sg_dist = (pos - v:GetPos()):Length();
			if(dist >= sg_dist) then
				dist = sg_dist;
				gate = v;
			end
		end
	end
	return gate;
end

--################# Set this Busy (in that time, a player cant change the status) @aVoN
function ENT:SetBusy(delay)
	self.NextAction = CurTime() + (delay or 0);
end

function ENT:StartTouch(e)
	if (e.IsStargate or IsValid(e:GetParent()) and e:GetParent().IsStargate) then return end
	self:HitEffect(e,e:LocalToWorld(e:OBBCenter()),5);
end

function ENT:HitIris(e,pos,velo)
	self.Entity:EmitSound(self.Sounds.Hit,90,math.random(98,103));
	self:HitEffect(e,pos,5, true);
end

function ENT:Remove()
	if(self.IdleSound) then self.IdleSound:Stop() end;
	for _,v in pairs(self.Sounds) do
		self.Entity:StopSound(v);
	end
end

function ENT:OnRemove()
	if(self.IdleSound) then self.IdleSound:Stop() end;
	for _,v in pairs(self.Sounds) do
		self.Entity:StopSound(v);
	end
	timer.Remove("StarGateIrisCheck"..self:EntIndex());
	timer.Remove("StarGateIrisProtCheck"..self:EntIndex());
end

function ENT:OnTakeDamage(  dmginfo )
	if (not self.IsActivated) then return end
	self.Entity:EmitSound(self.Sounds.Hit,90,math.random(98,103));
	self:HitEffect(self.Entity,dmginfo:GetDamagePosition(),1);
end

function ENT:HitEffect(e,pos,strength, side)
	local pos1 = self:WorldToLocal(pos);
	local pos2 = pos1:GetNormalized()*2;

	local tracedata = {}
		if side then
			tracedata.start = pos-pos2
			tracedata.endpos = pos+pos2
		else
			tracedata.start = pos+pos2
			tracedata.endpos = pos-pos2
		end
	local trace = util.TraceLine(tracedata)

	local fx = EffectData();
		fx:SetOrigin(pos);
		fx:SetEntity(self);
		fx:SetNormal(trace.HitNormal)
		fx:SetScale(strength);
	util.Effect("shield_core_hit",fx,true,true);
end

function ENT:DrawBuble(grow)
	self.Entity:SetNWBool("StopBuble", true); -- update
	self.Entity:SetNWBool("StopBuble", false);
	-- should be delayed!
	timer.Simple(0.1, function() if (IsValid(self)) then
	 	local fx = EffectData();
		fx:SetEntity(self.Entity);
		util.Effect("iris_buble",fx,true,true);
	end end);
end

--################# Close the Shield (aka Activate) @aVoN
function ENT:Close()
	self.Entity:SetNoDraw(false);
	local id = "ShieldSound."..self.Entity:EntIndex();
	self.Entity:EmitSound(self.Sounds.Close,90,math.random(98,103));
	if(self.IdleSound) then self.IdleSound:Stop() end;
	self.IdleSound = CreateSound(self.Entity,self.Sounds.Idle);
	local snd = self.IdleSound;
	local e = self.Entity;
	timer.Remove(id);
	timer.Create(id,1.5,1,
		function()
			if(IsValid(e)) then
				snd:PlayEx(90,math.random(98,103));
			end
		end
	);
	self:SetBusy(0.7);
end

--################# Open the Shield (aka Deactivate) @aVoN
function ENT:Open(energy)
	self.Entity:SetNoDraw(true);
	if (energy) then
		self.Entity:EmitSound(self.Sounds.OpenEnergy,90,math.random(98,103));
	else
		self.Entity:EmitSound(self.Sounds.Open,90,math.random(98,103));
	end
	timer.Remove("ShieldSound."..self.Entity:EntIndex());
	if(self.IdleSound) then
		self.IdleSound:FadeOut(0.2);
		self.IdleSound = nil;
	end
	self:SetBusy(0.7);
end

--################# Activate @aVoN
function ENT:Toggle(ignore_energy)
	if(self.NextAction <= CurTime()) then
		local deactivate = false
		if(self.HasRD and ignore_energy) then
			local gate = self:FindGate();
			if IsValid(gate) and gate.IsStargate and not gate:HaveEnergy(true,true) then deactivate = true end
		end
		if(self.IsActivated or deactivate) then
			self.Entity:SetNWBool("StopBuble", true);
			self.Entity:Open(deactivate)
			self.Entity:SetTrigger(false);
			self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD);
			self.Entity:SetSolid(SOLID_NONE);
			self.LastMoveable = self.Phys:IsMoveable();
			if(#StarGate.GetConstrainedEnts(self.Entity,1) == 0) then
				self.Phys:EnableMotion(false); -- Don't enable motion if it's closed or it may fall into the ground
			end
			self.IsActivated = false
			self:SetWire("Activated",false);
		else
			if (not ignore_energy and IsValid(self.GateLink) and self.GateLink.GateSpawnerSpawned and not self:IsComputer()) then return end
			if(self.HasRD) then
				local gate = self:FindGate();
				if IsValid(gate) and gate.IsStargate and not gate:HaveEnergy(true,true) then if (self.Sounds and self.Sounds.Fail) then self.Entity:EmitSound(self.Sounds.Fail,90,math.random(90,110)); end return end
			end
			self.Entity:DrawBuble();
			self.Entity:Close()
			self.Entity:SetCollisionGroup(COLLISION_GROUP_NONE);
			self.Entity:SetSolid(SOLID_VPHYSICS);
			--To kill any prop/player which got "stuck in iris/shield" - (Only works if SetTrigger is true, but SetTrigger also makes bullets hit the shield if disabled so we need to "unset" settrigger after a short period of time)
			self.AllowTouch = CurTime();
			self.Entity:SetTrigger(true);
			local e = self.Entity;
			timer.Simple(0.1,
				function()
					if(IsValid(e)) then e:SetTrigger(false) end;
				end
			);
			self.Phys:EnableMotion(self.LastMoveable);
			self.Phys:Wake();
			self.IsActivated = true;
			self:SetWire("Activated",true);
		end
	end
end

--################# Activate @aVoN
function ENT:TrueActivate(deactivate,wire)
	if(self.NextAction <= CurTime()) then
		if(self.IsActivated and deactivate) then
			self.Entity:SetNWBool("StopBuble", true);
			self.Entity:Open(not wire)
			self.Entity:SetTrigger(false);
			self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD);
			self.Entity:SetSolid(SOLID_NONE);
			self.LastMoveable = self.Phys:IsMoveable();
			if(#StarGate.GetConstrainedEnts(self.Entity,1) == 0) then
				self.Phys:EnableMotion(false); -- Don't enable motion if it's closed or it may fall into the ground
			end
			self.IsActivated = false
			self:SetWire("Activated",false);
		elseif (not self.IsActivated and not deactivate) then
			if (not ignore_energy and IsValid(self.GateLink) and self.GateLink.GateSpawnerSpawned and not self:IsComputer()) then return end
			if(self.HasRD and self.Entity:GetModel() == "models/zup/stargate/sga_shield.mdl") then
				local gate = self:FindGate();
				if IsValid(gate) and gate.IsStargate and not gate:HaveEnergy(true,true) then return end
			end
			self.Entity:DrawBuble();
			self.Entity:Close()
			self.Entity:SetCollisionGroup(COLLISION_GROUP_NONE);
			self.Entity:SetSolid(SOLID_VPHYSICS);
			--To kill any prop/player which got "stuck in iris/shield" - (Only works if SetTrigger is true, but SetTrigger also makes bullets hit the shield if disabled so we need to "unset" settrigger after a short period of time)
			self.AllowTouch = CurTime();
			self.Entity:SetTrigger(true);
			local e = self.Entity;
			timer.Simple(0.1,
				function()
					if(IsValid(e)) then e:SetTrigger(false) end;
				end
			);
			self.Phys:EnableMotion(self.LastMoveable);
			self.Phys:Wake();
			self.IsActivated = true;
			self:SetWire("Activated",true);
		end
	end
end

--################# Touch @aVoN
function ENT:Touch(e)
	if(self.AllowTouch and self.AllowTouch + 0.1 > CurTime()) then
		if(e:IsPlayer() and not e:HasGodMode() or e:IsNPC()) then
			e:SetHealth(1);
			e:TakeDamage(10,self.Entity);
		end
	else
		self.AllowTouch = nil;
	end
end

--################# Wire input @aVoN
function ENT:TriggerInput(k,v)
	if(
		k == "Activate" and
		(
			(not self.IsActivated and v >= 1) or
			(self.IsActivated and v == 0)
		)
	) then
		self:Toggle();
	elseif (k == "Toggle") then
		self:Toggle();
	end
end

function ENT:PreEntityCopy()
	local dupeInfo = {};
	if (IsValid(self.GateLink)) then
		dupeInfo.Gate = self.GateLink:EntIndex();
	end
	duplicator.StoreEntityModifier(self, "Iris", dupeInfo);
	StarGate.WireRD.PreEntityCopy(self)
end

function ENT:PostEntityPaste(Player, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	if (Ent.EntityMods.Iris) then
		if (Ent.EntityMods.Iris.Gate) then
			self.GateLink = CreatedEntities[Ent.EntityMods.Iris.Gate] or NULL;
		end
	end
	StarGate.WireRD.PostEntityPaste(self,Player,Ent,CreatedEntities)
end

function ENT:IsComputer()
	local dist = 1000
	local pos = self:GetPos()
	local ret = false;
	for _,v in pairs(ents.FindByClass("iris_computer")) do
		if(v.LockedIris==self) then
			ret = true;
			break;
		elseif(v.LockedIris==v) then
			local ir_dist = (pos - v:GetPos()):Length()
			if(dist >= ir_dist) then
				ret = true;
				break;
			end
		end
	end
	return ret;
end

function ENT:IrisProtection()
	local ent = self.Entity;
	timer.Create("StargateIrisProtCheck"..self:EntIndex(),15.0,0,function()
		if (IsValid(ent)) then
			if (ent.IsActivated) then
				local dist = 1000
				local pos = ent:GetPos()
				local open = true;
				if (ent:IsComputer()) then open = false end
				if (open) then
					ent:Toggle();
				end
			end
		end
	end);
end

end

if CLIENT then

ENT.RenderGroup = RENDERGROUP_OPAQUE
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("goauld_iris",SGLanguage.GetMessage("stool_giris"));
end

end