if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
local base_size=100 -- the size of the ring tube

-- stuff in here cannnot be teleported
local protected_entities = {
	ramp = true,
	func_door = true,
	func_door_rotating = true,
	func_movelinear = true,
	func_rot_button= true,
	func_rotating = true,
	prop_door_rotating=true
	-- ring_* and stargate_* protected too
}

local playersonly = CreateConVar( "rings_players_only", "0" )

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()

	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)

	util.PrecacheModel(self.RingModel); -- prevent gmod freeze on ori ring activation

	self.Rings={}

	self.EndPos=Vector(0,0,0)
	self.Ready=0
	self.Other=self.Entity
	self.Master=false
	self.Busy=false
	self.Ents={}
	self.Effect=false
	self.WaitTime=0
	self.WireRange=1024
	self.Entity:SetUseType(SIMPLE_USE)
	self.Address=nil
	self.Laser = false;
	self.Anims = false;

	self.Disallowed = {};
	for _,v in pairs(StarGate.CFG:Get("ring","classnames",""):TrimExplode(",")) do
		self.Disallowed[v:lower()] = true;
	end

	-- Wire support to the ring base using stargate lib - @aVoN
	self:CreateWireInputs("Dial Closest","Dial Address [STRING]","Set Range","UnUsable");
	self:CreateWireOutputs("Usable","Active");
end

function ENT:KeyValue(key,value)
	if key=="name" then
		self.Address=value
		self.Entity:SetNetworkedString("address",value)
	end
end

--################# Stops rings if you remove the dialling ring-transporter while it was dialling @aVoN
function ENT:OnRemove()
	if(IsValid(self.Other) and self.Other.Busy) then
		self.Other.Other = NULL;
		if (IsValid(self.Other)) then
			self.Other:ReadyChecks();
		end
	end
	if self.Laser then
		self.Laser = false;
		if (IsValid(self.LaserBeam)) then
			self.LaserBeam:RemoveLaser();
		end
	end
end

function ENT:Use(ply)
	--if self.Address then return end -- Allow address changing!
	umsg.Start("RingTransporterShowNameWindowCap",ply)
	umsg.Entity(self.Entity);
	umsg.End()
	ply.RingNameEnt=self
end

function RingsNamingCallback(ply,cmd,args)
	if ply.RingNameEnt and ply.RingNameEnt~=NULL then
		if args[1] then
			local adr = args[1]:gsub("[^0-9]","");
			-- No multiple rings please!
			for _,v in pairs(ents.FindByClass("ring_base_*")) do
				if(v.Address == adr and v.Entity != ply.RingNameEnt) then
					ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"ring_error\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
					return;
				end
			end
			ply.RingNameEnt.Address=adr
			ply.RingNameEnt:SetNetworkedString("address",adr)
			ply.RingNameEnt:SetEntityModifier("Address",adr);
		end
		ply.RingNameEnt=nil
	end
end
concommand.Add("setringname",RingsNamingCallback)

function ENT:SetRingAddress(address)
	if not IsValid(self.Entity) then return end
	local adr = address:gsub("[^0-9]","");
	-- No multiple rings please!
	for _,v in pairs(ents.FindByClass("ring_base_*")) do
		if(v.Address == adr and v.Entity != self.Entity) then
			return;
		end
	end
	self.Address=adr
	self.Entity:SetNetworkedString("address",adr)
	self.Entity:SetEntityModifier("Address",adr);
end

function ENT:ReportReachedPos(ent) -- this'll be called when a ring gets to its position
		self.Ready=self.Ready+1
end

function ENT:FindNearest(address)
if address=="" or not address then
	local dist=999999999999999 -- lolwut
	local nEnt=self.Entity
	local rings=ents.FindByClass("ring_base_*")
		for i=1,table.getn(rings) do
			if (rings[i]~=self.Entity and rings[i].IsRings and (rings[i].Laser == false)) then
				local nDist=(self.Entity:GetPos()-rings[i]:GetPos()):Length()
					 if nDist<dist then
						 dist=nDist
						 nEnt=rings[i]
					 end
			end
		end
	return nEnt
else
	local rings=ents.FindByClass("ring_base_*")
	for _,ent in pairs(rings) do
		if (ent.IsRings and (ent.Address==address) and (ent.Laser == false)) then
			return ent

		end
	end
	return false
end

end

local function CheckedEntRemove(ent)
	if IsValid(ent) then
		ent:Remove()
	end
end

function ENT:ReturnRings()
	self.Entity:EmitSound("tech/ring_transporter3.wav", 100, 100)
		local times = {0.2,0.7,1.0,1.2,1.4};
		for k,v in pairs(self.Rings) do
			timer.Simple(times[k],function() if IsValid(v) then v:ReturnPos() end end)
			timer.Simple(3,function() CheckedEntRemove(v) end)
		end
		timer.Simple(3,function()
			if IsValid(self.Entity) then
				self.Busy=false
				self:SetWire("Active",false);
				self:Anim(true);
			end
		end)
	self.Ents={}
end

--################# Get's an entities bone's for suckup (taken from my teleportation module) @aVoN
function ENT:GetBones(e)
	-- And as well, get the bones of an object
	local bones = {};
	if(e:IsVehicle() or e:GetClass() == "prop_ragdoll") then
		for i=0,e:GetPhysicsObjectCount()-1 do
			local bone = e:GetPhysicsObjectNum(i);
			if(bone:IsValid()) then
				table.insert(bones,{
					Entity=bone,
				});
			end
		end
	end
	return bones;
end

function ENT:DoTeleport()
	local entz=ents.FindInSphere(self.Entity:LocalToWorld(self.EndPos),80)
	for _,ent in pairs(entz) do
		-- stargate_* and ring_* protect by AlexALX
		-- fixed by mad
		-- No, by AlexALX ;) xD
		local class = ent:GetClass();
		if not self.Disallowed[class] and not string.find(class,"stargate_") and not string.find(class,"ring_") and not protected_entities[class] and ent~=game.GetWorld() and not self.Other.Ents[ent] and not self.Ents[ent] and not ent.NotTeleportable and not ent:GetParent():IsValid() and not ent.GateSpawnerProtected then
			if playersonly:GetBool() and not ent:IsPlayer() then else
				if ent:GetPhysicsObject():IsValid() then
					self.Ents[ent]=true
					local allow = hook.Call("StarGate.Rings.TeleportEnt",nil,ent,self);
					if (allow==false) then continue end
					if (constraint.HasConstraints(ent)) then
						local entities = StarGate.GetConstrainedEnts(ent,2);
						local cont = false;
						if(entities) then
							for c,b in pairs(entities) do
								if(b:IsWorld()) then
									cont = true;
									break;
								end
							end
						end
						if (cont) then continue end
					end
					local offset=ent:GetPos()-self.Entity:LocalToWorld(self.EndPos)
					local destination=self.Other:LocalToWorld(self.Other.EndPos)+offset

					-- Fix for stuck in ground/ramps by AlexALX
					local trace={}
					trace.start=destination;
					trace.endpos=destination+Vector(0,0,-5);
					trace.filter = {self.Entity,self.Rings[1],self.Rings[2],self.Rings[3],self.Rings[4],self.Rings[5],ent}
					table.Add(trace.filter, player.GetAll() )
					local traceRes=util.TraceLine( trace )

					if (traceRes.Hit) then
						destination = traceRes.HitPos+Vector(0,0,4);
					end

					-- ragdoll fix by AlexALX
					local Bones = self:GetBones(ent)
					for _,bone in pairs(Bones) do
						if(bone.Entity:IsValid()) then
							local bone_offset=bone.Entity:GetPos()-self.Entity:LocalToWorld(self.EndPos)
							local bone_destination=self.Other:LocalToWorld(self.Other.EndPos)+bone_offset

							local trace={}
							trace.start=bone_destination;
							trace.endpos=bone_destination+Vector(0,0,-5);
							trace.filter = {self.Entity,self.Rings[1],self.Rings[2],self.Rings[3],self.Rings[4],self.Rings[5],ent}
							table.Add(trace.filter, player.GetAll() )
							local traceRes=util.TraceLine( trace )

							if (traceRes.Hit) then
								bone_destination = traceRes.HitPos+Vector(0,0,10);
							end

							bone.Entity:SetPos(bone_destination);
							bone.Entity:ApplyForceCenter(Vector(0,0,0))
						end
					end
					ent:SetPos(destination)
					if ent:GetClass()=="player" then
						umsg.Start("RingTransporterTele", ent)
							umsg.Bool(false)
						umsg.End()
					end
				end
			end
		end
	end
	-- let's have a delay before returning the rings
	timer.Simple(0.1,function() if IsValid(self) then self:ReturnRings() end end)
	self.Ready=0
end

function ENT:ReadyChecks()
	if self and IsValid(self.Entity) then
		-- Receiving end is not valid anymore - Retreive the rings!
		if(not IsValid(self.Other)) then
			if(self.Ready == 5) then
				timer.Simple(0.3,function() if IsValid(self.Entity) then self:ReturnRings(); end end)
				return;
			end
			timer.Simple(0.2,function() if IsValid(self.Entity) then self:ReadyChecks() end end);
			return;
		end
		 if self.Other.Ready==5 and self.Ready==5 then
			timer.Simple(0.3,function() if IsValid(self.Entity) then self.Entity:DoTeleport() end end)
			timer.Simple(0.3,function() if IsValid(self.Other) then self.Other:DoTeleport() end end)

	local entz=constraint.GetAllConstrainedEntities(self.Entity)
	for _,ent in pairs(entz) do
		self.Ents[ent]=true
	end

	local entz=constraint.GetAllConstrainedEntities(self.Other)
	for _,ent in pairs(entz) do
		self.Other.Ents[ent]=true
	end
			local effectdata = EffectData()
				effectdata:SetOrigin( self.Entity:LocalToWorld(self.EndPos) )
				effectdata:SetMagnitude(1)
			util.Effect( "transportcore", effectdata )

			local effectdata = EffectData()
				effectdata:SetOrigin( self.Other:LocalToWorld(self.Other.EndPos) )
				effectdata:SetMagnitude(1)
			util.Effect( "transportcore", effectdata )

			if (self.Other:GetClass() == "ring_base_ori") then
				for i=1,5 do
					self.Other.Rings[i]:ChangeMaterial();
				end
			end
			if (self.Entity:GetClass() == "ring_base_ori") then
				for i=1,5 do
					self.Rings[i]:ChangeMaterial();
				end
			end


			local entz=ents.FindInSphere(self.Entity:LocalToWorld(self.EndPos),80)
			for _,ent in pairs(entz) do
				if ent:GetClass()=="player" then
					umsg.Start("RingTransporterTele", ent)
						umsg.Bool(true)
					umsg.End()
				end
			end
		else
			if self.WaitTime<CurTime() then
				self:ReturnRings()
				if (IsValid(self.Other)) then
					self.Other:ReturnRings()
				end
				return
			end
			timer.Simple(0.2,function() if IsValid(self.Entity) then self:ReadyChecks() end end) -- and again and again and again and *
		end
	end
end

function ENT:DoRings()
	self.Busy=true
	self.Entity:EmitSound("tech/ring_transporter2.wav", 100, 100)
	self:Anim(false);

	local dir = 1;
	-- Addtion by aVoN: Use "FindRange" everytime we are facing down and the angle is below 45° (pi/4)
	if(self.Entity:GetUp():DotProduct(Vector(0,0,-1)) > 1/math.sqrt(2)) then
		--self.SetRange = 1024;
		dir = -1;
	end

	for i=1,5 do
		self.Rings[i]=ents.Create("ring_ring")
		self.Rings[i].GateSpawnerSpawned = self.GateSpawnerSpawned
		self.Rings[i]:SetModel(self.RingModel)
		if (dir==-1) then
			self.Rings[i]:SetPos(self.Entity:GetPos()+Vector(0,0,15))
		else
			self.Rings[i]:SetPos(self.Entity:GetPos()+Vector(0,0,-5))
		end
		self.Rings[i].Dir = dir;
		self.Rings[i]:SetAngles(self.Entity:GetAngles())
		self.Rings[i]:SetParent(self.Entity)
		self.Rings[i]:Spawn()
		constraint.NoCollide( self.Rings[i], self, 0, 0 );
		self.Entity:DeleteOnRemove(self.Rings[i])
	end

	for k,v in pairs(self.Rings) do
		if (IsValid(v)) then
			for k2,v2 in pairs(self.Rings) do
				if (IsValid(v2)) then
					constraint.NoCollide( v, v2, 0, 0 );
				end
			end
			if (IsValid(self.Ramp)) then
				constraint.NoCollide( v, self.Ramp, 0, 0 );
			end
			constraint.NoCollide( v, game.GetWorld(), 0, 0 );
			local entz=constraint.GetAllConstrainedEntities(self.Entity)
			for _,ent in pairs(entz) do
				constraint.NoCollide( v, ent, 0, 0 );
			end
		end
	end

	local num=20

	self.Ready=0
	-- find the end position
	local trace={}
		-- Instead of using a mask to avoid "stuff in the ring's way", Catdaemon, I start the traceline a bit later
		trace.start=self.Entity:GetPos()+self.Entity:GetUp()*110;
		trace.endpos=self.Entity:GetPos()+self.Entity:GetUp()*self.WireRange
		trace.filter = {self.Entity,self.Rings[1],self.Rings[2],self.Rings[3],self.Rings[4],self.Rings[5]}
		table.Add(trace.filter, player.GetAll() )
		--trace.mask=MASK_NPCWORLDSTATIC -- Disabled by avon - it fucking sucks!
	local traceRes=util.TraceLine( trace )
	-- move the rings and set the teleport position
	if (traceRes.HitWorld or traceRes.HitPos:Distance(self.Entity:GetPos())<999 and traceRes.HitPos:Distance(self.Entity:GetPos())>100) and dir==-1 then
		local times = {3.6,3.5,3.0,2.5,2.0};
		for k,v in pairs(self.Rings) do
			local pos=traceRes.HitPos-(self.Entity:GetUp()*110)+(self.Entity:GetUp()*num)*(k-self.OriFix)
			timer.Simple(times[k],function() if IsValid(v) then v:GotoPos(self.Entity:WorldToLocal(pos)) end end)
		end
		local pos=traceRes.HitPos-(self.Entity:GetUp()*50)
		self.EndPos=self.Entity:WorldToLocal(pos)
	else
		local times = {3.7,3.5,3.0,2.5,2.0};
		for k,v in pairs(self.Rings) do
			local pos=self.Entity:GetPos()+(self.Entity:GetUp()*num)*(k+self.OriFix)
			timer.Simple(times[k],function() if IsValid(v) then v:GotoPos(self.Entity:WorldToLocal(pos)) end end)
		end
		local pos=self.Entity:GetPos()+(self.Entity:GetUp()*50)+(self.Entity:GetUp()*self.OriFix*25)
		self.EndPos=self.Entity:WorldToLocal(pos)
	end
	self:SetWire("Active",true);
end

function ENT:StartSequence(address)
	self.WaitTime=CurTime()+10
	-- find another ring transporter
	local nearest=self.Entity:FindNearest(address)
	if not nearest or nearest.Busy then
		self.Entity:EmitSound( "common/warning.wav", 100, 70 )
		return
	end
	if nearest==self.Entity then return end -- don't want to teleport to ourselves now do we
	self.Other=nearest
	--self.Other.SetRange=self.SetRange
	self.Master=true
	nearest.Other=self.Entity
	nearest.Master=false
	self.Entity:ReadyChecks() -- go to the next stage

	-- set their rings going
	self.Entity:DoRings()
	self.Other:DoRings()
end

-- #############################################################
-- Wire port, first done by Meeces, implemented by Catdaemon, and now rewritten by aVoN
-- #############################################################



-- ################### This uses my Wire class @aVoN
function ENT:Think()
	self:SetWire("Usable",not self.Busy);

	if self.Anims then
		self:NextThink(CurTime());
		return true
	end
end

-- ################### Slightly improved wireinput version @aVoN
function ENT:TriggerInput(name,value)
	local b = util.tobool(value);
    if(name == "Dial Closest") then
		if(b and not self.Busy) then
			self:Dial("");
		end
	elseif(name == "Dial Address") then
		if(not self.Busy and value!="") then
			self:Dial(value);
		end
	elseif(name == "Set Range") then
		if(b and not self.Busy) then
			self.WireRange=value;
		end
	elseif(name == "UnUsable") then
		self.Busy = b;
		self:SetNWBool("Busy",b)
	end
end

--################# Dials @aVoN
function ENT:Dial(address)
	if (self.Busy) then return end
	if (address!="") then
		local adr = address:gsub("[^0-9]","");
		if (adr!="") then
			self.Entity:StartSequence(adr);
		else
			self.Entity:StartSequence(" ");	-- fail
		end
	else
		self.Entity:StartSequence(address);
	end
end

-- Easter Egg ;]

function ENT:StopLaser()
	self.Laser = false;
	self.Busy = false;
	if IsValid(self.LaserBeam)  then self.LaserBeam:Remove() end
end

function ENT:StartLaser()

	self.Busy = true;
	self.Laser = true;

	local energyBeam = ents.Create("energy_laser");
	energyBeam.Owner = self.Entity;
	energyBeam:SetPos(StarGate.GetEntityCentre(self.Entity));
	energyBeam:Spawn();
	energyBeam:Activate();
	energyBeam:SetOwner(self.Entity);
	energyBeam:Setup(self.Entity, "ONeill", true);
	self.LaserBeam = energyBeam

	local ringbaseshutdown = self.Entity; -- Haha, i have to make some limits ;p
	timer.Create( self.Entity:EntIndex().."LaserBeam", 30, 1, function()
		if IsValid(ringbaseshutdown) then ringbaseshutdown:StopLaser() end
	end )

end

-- ################### This function originally has been added to the ring_panel. But my "ring caller" swep sets Player.RingDialEnt to the actual ring_base rather than the ring_panel entity so we need it here again to avoid lua errors @aVoN
function ENT:DoCallback(range,address)
	local ranger;
	if(range == "1") then
		ranger=1024;
	end
	if(not self.Busy) then
		--self.SetRange = tonumber(ranger or 50);
		self:Dial(address);
	end
end

--##################################
--#### Duplicator Entity Modifiers (for the rings)
--##################################

--################# Sets a new value to one modifier @aVoN
function ENT:SetEntityModifier(k,v)
	self.Duplicator = self.Duplicator or {};
	self.Duplicator[k] = v;
	duplicator.StoreEntityModifier(self.Entity,"RingBase",self.Duplicator);
end

-- FIXME: Maybe a recode? The PostEntityPaste etc functions are already used by Wire/RD2 so I do not want to override them.
function ENT.DuplicatorEntityModifier(_,e,data)
	if(data) then
		for k,v in pairs(data) do
			if(k == "Address") then
				local allow = true;
				for _,ring in pairs(ents.FindByClass("ring_base")) do
					if(ring.Address == v) then allow = false break end;
				end
				if(allow) then
					e:SetNetworkedString("address",v);
					e.Address = v;
				end
			end
			e:SetEntityModifier(k,v);
		end
	end
end
duplicator.RegisterEntityModifier("RingBase",ENT.DuplicatorEntityModifier);

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

--######################## @AlexALX, aVoN -- snap gates to cap ramps
function ENT:CartersRampsRing(t)
	local e = t.Entity;
	if(not IsValid(e)) then return end;
	local RampOffset = StarGate.RampOffset.Ring;
	local mdl = e:GetModel();
	if(RampOffset[mdl]) then
		if (RampOffset[mdl][2]) then
			self.Entity:SetAngles(e:GetAngles() + RampOffset[mdl][2]);
		else
			self.Entity:SetAngles(e:GetAngles());
		end
		self.Entity:SetPos(e:LocalToWorld(RampOffset[mdl][1]));
		self.Ramp = e;
		constraint.Weld(e,self.Entity,0,0,0,true);
		-- Is this needed?
		--e.CDSIgnore = true; -- Fixes Combat Damage System destroying Ramps - http://mantis.39051.vs.webtropia.com/view.php?id=45
		--return e;
	end
end

--######################## Check if gate in ramp (for gatespawner) by AlexALX
function ENT:CheckRamp()
	for _,e in pairs(ents.FindInSphere(self.Entity:GetPos(),20)) do
		if (StarGate.Ramps.Ring[e:GetModel()]) then
			constraint.Weld(self.Entity,e,0,0,0,true);
			break;
		end
	end
end

-----------------------------------ANIM----------------------------------

function ENT:Anim(up)
	if not self.Anims then
		if up then
			local seq = self.Entity:LookupSequence("up");
			self.Entity:ResetSequence(seq);
			self.Anims = true;
			timer.Create("Anim"..self:EntIndex(),1,1,function()
				self.Anims = false;
			end);
		else
			local seq = self.Entity:LookupSequence("down");
			self.Entity:ResetSequence(seq);
			self.Anims = true;
			timer.Create("Anim"..self:EntIndex(),1,1,function()
				self.Anims = false;
			end);
		end
	end
end