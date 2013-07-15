--Idea and originally code by PiX06 - Recoded,shrinked,fixed and optimized (:D) by aVoN
--http://forums.facepunchstudios.com/showthread.php?p=6341522

-- FIXME: Rewrite every single line below and add a stool so it's not required to use wire

if (not StarGate.CheckModule("devices")) then return end

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");
--include("entities/event_horizon/modules/teleport.lua"); -- FIXME: Move all teleportation code of the eventhorizon to /stargate/server/teleport.lua. Then create a teleportation class

local snd = Sound("tech/asgard_teleport.mp3");

--################### Init @PiX06,aVoN
function ENT:Initialize()
	self.Entity:SetModel("models/Boba_Fett/props/asgard_console/asgard_console.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Origin = Vector(0,0,0);
	self.Destination = Vector(0,0,0);
	self.TeleportEverything = false;
	self.Exceptions = {}; -- Used internal
	self:AddResource("energy",1);
	self:CreateWireInputs("Origin [VECTOR]","Origin X","Origin Y","Origin Z","Dest [VECTOR]","Dest X","Dest Y","Dest Z","Teleport Everything","Send","Retrieve");
	self:CreateWireOutputs("Teleport Distance","Targets at Origin","Targets at Destination");
	self.Disallowed = {};
	for _,v in pairs(StarGate.CFG:Get("teleporter","classnames",""):TrimExplode(",")) do
		self.Disallowed[v:lower()] = true;
	end
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:Wake();
	end
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("transporter");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply;

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end
	ent.Owner = ply;

	return ent
end

--################### Update some vars @aVoN
function ENT:Think()
	if (not IsValid(self)) then return end
	local orig,dest = 0,0;
	local dist = 0;
	if(self.Origin ~= self.Destination) then
		orig = table.Count(self:FindObjects(self.Origin,true));
		dest = table.Count(self:FindObjects(self.Destination,true));
		dist = self.Destination:Distance(self.Origin);
	end
	self:SetWire("Targets at Origin",orig);
	self:SetWire("Targets at Destination",dest);
	self:SetWire("Teleport Distance",dist);
	--self:SetOverlayText("Asgard Transporter\nTeleport Distance: "..dist);
	self.Entity:NextThink(CurTime()+0.5);
	return true;
end

-- Tiny helper function
local function TableValuesToKeys(tab)
	local ret = {};
	for _,v in pairs(tab) do
		ret[v] = v;
	end
	return ret;
end

--################### Is the entity we want to teleport valid? @aVoN
function ENT:ValidForTeleport(e)
	local phys = e:GetPhysicsObject();
	if(not IsValid(phys) or e.GateSpawnerProtected or e==game.GetWorld() or IsValid(e:GetParent())) then return false end;
	if(e:IsWeapon() and type(e:GetParent()) == "Player") then return end;
	local class = e:GetClass():lower();
	local mdl = e:GetModel() or "";
	if(not (self.Disallowed[class] or class:find("func_") or mdl:find("*") or class=="prop_door_rotating")) then return true end;
	return false;
end

--################### Get valid objects for teleport @aVoN
function ENT:FindObjects(pos,quick)
	local objects = {};
	for _,e in pairs(ents.FindInSphere(pos,130)) do
		if(e:IsValid()) then
			-- Only players?
			if(e:IsPlayer() or e:IsNPC()) then
				objects[e] = e
			-- Everything?
			elseif(self.TeleportEverything and not self.Exceptions[e]) then
				local class = e:GetClass();
				local mdl = e:GetModel() or "";
				-- Validity checked
				if(self:ValidForTeleport(e)) then
					-- Is this stuff in whatever kind constrained to other stuff? And is this "other stuff" frozen? If yes, do not allow teleportation.
					-- If no, allow teleportation but the whole stuff!
					-- FIXME: Use the stargate teleportation code. Look at the top of the file
					local allow = true;
					if(not quick) then
						local entities = StarGate.GetConstrainedEnts(e);
						if(#entities < 50) then -- So much to teleport? NAH! (Maybe later with the stargate teleport stuff)
							for k,v in pairs(entities) do
								if(self.Exceptions[v] or v == self.Entity) then allow = false break end;
								local phys = v:GetPhysicsObject();
								if(phys:IsValid() and v ~= e) then
									-- One part is frozen: So the whole contraption can't get teleported
									if(not phys:IsMoveable()) then allow = false break end;
								else
									entities[k] = nil;
								end
							end
							-- Add the whole (small) contration.
							if(allow) then
								for _,v in pairs(entities) do
									if(self:ValidForTeleport(v)) then objects[v] = v end;
								end
							end
						else
							allow = false;
						end
					end
					if(allow) then objects[e] = e end;
				end
			end
		end
	end
	return objects;
end

--################### Wire input has been triggered @aVoN
function ENT:TriggerInput(k,v)
	local b = util.tobool(v);
	if(k == "Origin") then
		self.Origin = v;
	elseif(k == "Origin X") then
		self.Origin.X = v;
	elseif(k == "Origin Y") then
		self.Origin.Y = v;
	elseif(k == "Origin Z") then
		self.Origin.Z = v;
	elseif(k == "Dest X") then
		self.Destination.X = v;
	elseif(k == "Dest Y") then
		self.Destination.Y = v;
	elseif(k == "Dest Z") then
		self.Destination.Z = v;
	elseif(k == "Dest") then
		self.Destination = v;
	elseif(k == "Send") then
		if(b) then
			self:Teleport(self.Origin,self.Destination);
		end
	elseif(k == "Retrieve") then
		if(b) then
			self:Teleport(self.Destination,self.Origin);
		end
	elseif(k == "Teleport Everything") then
		self.TeleportEverything = b;
		self:SetWire("Teleport Everything",b);
	end
end

--################### Do teleport @aVoN
-- Helper function. Out here because it's called by a timer. And we do not want to create new function objects everytime we teleport - This fights an issue with GarbageCollection
local function DoTeleportTimer(e,pos,r,g,b,a,rm)
	local isplayer = e:IsPlayer();
	local mtype;
	if(isplayer) then
		-- Set him noclip for a second. Otherwise he probably gets stuck "on the destination" and GMod seems to have an inbuild mechanism to
		-- teleport him "back" to the old positon. So he never moved.
		mtype = e:GetMoveType();
		e:SetMoveType(MOVETYPE_NOCLIP);
	end
	e:SetPos(pos);
	e:SetColor(Color(r,g,b,a));
	e:SetRenderMode(rm);
	if(isplayer) then e:SetMoveType(mtype) end;
end

function ENT:Teleport(from,to)
	local time = CurTime();
	if((self.Next or 0) > time) then return end;
	-- first check for jammming devices, we can telepor from and to only if jaiming is offline (madman07)
	local radius = 1024; -- max range of jamming, we will adjust it later
	local jaiming_online = false;
	for _,v in pairs(ents.FindInSphere(from,  radius)) do
		if IsValid(v) then
			if v.IsEnabled then
				local dist = from:Distance(v:GetPos());
				if (dist < v.Size) then  -- ow jaiming, we cant do anything
					if v.Immunity and v.Owner == self.Owner then local a; -- but we are the owner so we know codes :D it does nothign, so create some value...
					else jaiming_online = true end
				end
			end
		end
	end
	for _,v in pairs(ents.FindInSphere(to,  radius)) do
		if IsValid(v) then
			if v.IsEnabled then
				local dist = to:Distance(v:GetPos());
				if (dist < v.Size) then -- ow jaiming, we cant do anything
					if v.Immunity and v.Owner == self.Owner then local a; -- but we are the owner so we know codes :D it does nothign, so create some value...
					else jaiming_online = true end
				end
			end
		end
	end
	if not jaiming_online then
		-- Prepare teleport
		self.Exceptions = TableValuesToKeys(StarGate.GetConstrainedEnts(self.Entity)); -- Not allowed because constrained to this teleporter
		local entities = self:FindObjects(from);
		local num = table.Count(entities);
		if(num == 0) then return end;
		local needed_energy = num*100;
		local energy = self:GetResource("energy",needed_energy);
		if(energy < needed_energy) then return end;
		self:ConsumeResource("energy",needed_energy);
		self.Next = time + 1;

		-- This here is the actual teleport
		sound.Play(snd,from,100,100);
		sound.Play(snd,to,100,100);
		local diff = to - from;
		for _,v in pairs(entities) do
			local start = v:GetPos();
			local dest = diff + start; dest.z = dest.z + 1; -- Offset so you never get stuck in ground
			-- Effects for teleport. That's what you actually see. But you seriously should see me coding this shit all around because a teleporter IS NOT ONLY THE EFFECT - idiot!
			local color = v:GetColor();
			local rendmode = v:GetRenderMode();
			v:SetRenderMode( RENDERMODE_TRANSALPHA );
			v:SetColor(Color(color.r,color.g,color.b,0));
			local fx = EffectData();
			fx:SetEntity(v);
			fx:SetOrigin(start);
			fx:SetScale(1); -- "Suck in" - a.k.a. "beam me up". Suck it!
			util.Effect("teleport_effect",fx,true,true);
			fx:SetOrigin(dest);
			fx:SetScale(0); -- "Spit out" - a.k.a. "beam me down". Don't spit bitch
			-- Note to myself: Why am I so damn sarcastic and vogue?
			util.Effect("teleport_effect",fx,true,true);
			timer.Simple(0.8,function() DoTeleportTimer(v,dest,color.r,color.g,color.b,color.a,rendmode) end);
		end
	end
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end