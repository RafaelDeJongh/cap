if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end

AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");
include("shared.lua");

-- stuff in here cannnot be teleported
local protected_entities = {
	ramp = true,
	func_door = true,
	func_door_rotating = true,
	func_movelinear = true,
	func_rot_button= true,
	func_rotating = true,
	prop_door_rotating=true,
	atlantis_transporter=true,
	atlantis_transporter_doors=true,
	-- ring_* and stargate_* protected too
}

function ENT:SpawnFunction(p,tr)
	if (not tr.Hit) then return end
	local e = ents.Create("atlantis_transporter");
	e:SetPos(tr.HitPos+Vector(0,0,7));
	e:SetAngles(Angle(0,p:EyeAngles().Y-180,0));
	e:Spawn();
	e:Activate();
	e:CreateDoors()
	return e;
end

util.AddNetworkString("UpdateAtlTP");

ENT.Sound = Sound("tech/atlantis_transport.wav")

function ENT:Initialize()

	self.Entity:SetModel("models/Tiny/ATL_Transporter/atl_transporter.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);

	self:CreateWireInputs("Teleport","Destination [STRING]","Toggle Doors","Lock Doors","Lock Console","Should be closed","Disable auto-open","Disable auto-close","Disable Dial Menu","Disable Edit Menu");
	self:CreateWireOutputs("Active","Doors Opened");

	self.TName = "";
	self.TPrivate = false;
	self.Destination = "";
	self.NextAnim = CurTime();
	self.Target = nil;
	self.DisMenu = false;
	self.DisEditMenu = false;
	self.OnlyClosed = false;
	self.NoAutoOpen = false;
	self.NoAutoClose = false;
	self.ShouldClose = false;
	self.DoorsLocked = false;
	self.ConsoleLocked = false;
	self.Fail = false;
	self.Busy = false;
	self.Ents={}
	self.EntsTP={}

	self.Disallowed = {};
	for _,v in pairs(StarGate.CFG:Get("atlantis_transporter","classnames",""):TrimExplode(",")) do
		self.Disallowed[v:lower()] = true;
	end

	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid())then
		phys:EnableMotion(false);
		phys:SetMass(500);
	end
	self.Phys = phys;
end

function ENT:ToggleDoors()
	if IsValid(self.Doors[1]) then
		self.Doors[1]:Toggle()
	end
	if IsValid(self.Doors[2]) then
		self.Doors[2]:Toggle()
	end
end

function ENT:IsDoorsOpen()
	if IsValid(self.Doors[1]) then
		return self.Doors[1].Open
	else
		return false
	end
end

function ENT:IsDoorsBusy()
	if IsValid(self.Doors[1]) then
		return not self.Doors[1].CanDoAnim
	else
		return false
	end
end

function ENT:OnRemove()
	if (IsValid(self.Doors[1])) then self.Doors[1]:Remove() end
	if (IsValid(self.Doors[2])) then self.Doors[2]:Remove() end
	net.Start("UpdateAtlTP")
	net.WriteInt(self:EntIndex(),16)
	net.WriteInt(0,4)
	net.Broadcast()
end

function ENT:CreateDoors(spawner,protect)

	local d = ents.Create("atlantis_transporter_doors");
	local e = self.Entity
	d:SetPos(e:GetPos()+e:GetForward()*(-0.5)+e:GetUp()*(-3)+e:GetRight()*(-1));
	d:SetAngles(e:GetAngles()+Angle(0,90,0));
	d:Spawn();
	d:Activate();
	d:DrawShadow(false)
	d.BaseTP = self;
	local d2 = ents.Create("atlantis_transporter_doors");
	d2:SetPos(e:GetPos()+e:GetForward()*(-0.5)+e:GetUp()*(-3)+e:GetRight()*(-1));
	d2:SetAngles(e:GetAngles()+Angle(0,270,0));
	d2:Spawn();
	d2:Activate();
	d2:DrawShadow(false)
	d2.BaseTP = self;
	d2.Sound = false;
	--constraint.NoCollide(e,d,0,0);
	--constraint.NoCollide(d,game.GetWorld(),0,0);
	constraint.Weld(d,e,0,0,0,true)  -- i don't want use weld here
	constraint.Weld(d2,e,0,0,0,true)  -- i don't want use weld here
	constraint.NoCollide(d,d2,0,0,0,true)
	self.Doors={d,d2}
	self.DoorPhys = {self.Doors[1]:GetPhysicsObject(),self.Doors[2]:GetPhysicsObject()}
	if(IsValid(self.DoorPhys[1]))then
		self.DoorPhys[1]:EnableMotion(false);
		self.DoorPhys[1]:SetMass(100);
	end
	if(IsValid(self.DoorPhys[2]))then
		self.DoorPhys[2]:EnableMotion(false);
		self.DoorPhys[2]:SetMass(100);
	end

	local d = ents.Create("cap_doors_contr");
	local e = self.Entity
	d:SetModel("models/Boba_Fett/props/buttons/atlantis_button.mdl");
	d:SetPos(e:GetPos()+e:GetRight()*(-37)+e:GetUp()*45+e:GetForward()*(3));
	d:SetAngles(e:GetAngles()+Angle(90,0,0));
	d:SetParent(self.Entity);
	d:Spawn();
	d:Activate();
	if (spawner) then
		d.GateSpawnerSpawned = true;
		d:SetNetworkedBool("GateSpawnerSpawned",true);
		d.GateSpawnerProtected = protect;
		d:SetNetworkedBool("GateSpawnerProtected",protect);
	end
	d.Atlantis = true
	d.AtlTP = self;
	d.AtlDoor = self.Doors;
	constraint.NoCollide(e,d,0,0);
	--constraint.NoCollide(d,game.GetWorld(),0,0);
	--constraint.Weld(d,e,0,0,0,true)
	self.Button1=d

	local d = ents.Create("cap_doors_contr");
	local e = self.Entity
	d:SetModel("models/Boba_Fett/props/buttons/atlantis_button.mdl");
	d:SetPos(e:GetPos()+e:GetRight()*(37)+e:GetUp()*55+e:GetForward()*(-4));
	d:SetAngles(e:GetAngles()+Angle(90,0,180));
	d:SetParent(self.Entity);
	d:Spawn();
	d:Activate();
	if (spawner) then
		d.GateSpawnerSpawned = true;
		d:SetNetworkedBool("GateSpawnerSpawned",true);
		d.GateSpawnerProtected = protect;
		d:SetNetworkedBool("GateSpawnerProtected",protect);
	end
	d.Atlantis = true
	d.AtlTP = self;
	d.AtlDoor = self.Doors;
	constraint.NoCollide(e,d,0,0);
	--constraint.NoCollide(d,game.GetWorld(),0,0);
	--constraint.Weld(d,e,0,0,0,true)
	self.Button2=d
end

function ENT:SetAtlName(name,wire,ply)
	if not IsValid(self.Entity) then return end
	name = name or "";
	name = name:Trim();
	if (name!="") then
		-- No multiple rings please!
		for _,v in pairs(ents.FindByClass("atlantis_transporter")) do
			if(v.TName == name and v.Entity != self.Entity) then
				if (not wire) then ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"atl_tp_error\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )"); end
				return;
			end
		end
	end
	self.TName=name;
	net.Start("UpdateAtlTP")
	net.WriteInt(self:EntIndex(),16)
	net.WriteInt(1,4)
	net.WriteString(name)
	net.Broadcast()
end

function ENT:SetAtlPrivate(private)
	if not IsValid(self.Entity) then return end
	private = util.tobool(private);
	self.TPrivate = private;
	net.Start("UpdateAtlTP")
	net.WriteInt(self:EntIndex(),16)
	net.WriteInt(2,4)
	net.WriteBit(private)
	net.Broadcast()
end

function ENT:OnReloaded()
	timer.Simple(0.1,function()
		if (IsValid(self)) then
			net.Start("UpdateAtlTP")
			net.WriteInt(self:EntIndex(),16)
			net.WriteInt(3,4)
			net.WriteString(self.TName)
			net.WriteBit(self.TPrivate)
			net.Broadcast()
		end
	end)
end

function ENT:TriggerInput(k,v)
	if k == "Teleport" then
		if(v>0) then
			self:Teleport();
		end
	elseif k == "Destination" then
		self.Destination = v;
	elseif k == "Toggle Doors" and v>0 then
		self:ToggleDoors();
	elseif k == "Disable Dial Menu" then
		self.DisMenu = v>0;
	elseif k == "Disable Edit Menu" then
		self.DisEditMenu = v>0;
	elseif k == "Should be closed" then
		self.OnlyClosed = v>0;
	elseif k == "Disable auto-open" then
		self.NoAutoOpen = v>0;
	elseif k == "Disable auto-close" then
		self.NoAutoClose = v>0;
	elseif k == "Lock Doors" then
		self.DoorsLocked = v>0;
		if (v>0) then
			if (self:IsDoorsOpen()) then
				self:ToggleDoors();
			end
		end
	elseif k == "Lock Console" then
		self.ConsoleLocked = v>0;
	end
end

util.AddNetworkString("atlantis_transport");

function ENT:GetAimingConsole(p)
	local e = self.Entity;
	local c = {Vector(-73.10,0.87,62.89)};
	local t = p:GetEyeTrace();
	local cv = self.Entity:WorldToLocal(t.HitPos)
	local btn = false;
	local lastd = 5;
	if (p:GetAimVector():DotProduct((p:GetPos()-e:GetPos()):GetNormalized())<0) then return false end
	for k,v in pairs(c) do
		da = (cv - c[k]):Length()
		if(da < 15) then
			btn = true; break;
		end
	end
	return btn;
end

function ENT:Use(ply)
	if (self.Busy) then return end
	if (self:GetAimingConsole(ply)) then
		if (self.Open and not self.DisMenu and not self.ConsoleLocked and (not self:IsDoorsOpen() or not self.OnlyClosed) and not self:IsDoorsBusy()) then
			umsg.Start("AtlantisTransporterShowWindow", ply)
			umsg.Entity(self)
			umsg.End()
		end
		return
	end
	if (self.DisEditMenu) then return end
	umsg.Start("AtlantisTransporterEditWindow", ply)
	umsg.Entity(self)
	umsg.String(self.TName)
	umsg.Bool(self.TPrivate)
	umsg.End()
end

net.Receive("atlantis_transport",function(len,ply)
	local self = net.ReadEntity();
	if (not IsValid(self)) then return end
	if (util.tobool(net.ReadBit())) then
		self.Destination = net.ReadString();
		self:Teleport();
	else
		self:SetAtlName(net.ReadString(),false,ply);
		self:SetAtlPrivate(net.ReadBit());
	end
end)

function ENT:Think()
	local player = self:FindPlayer();
	if self.NextAnim < CurTime() then
		if player and (not self:IsDoorsOpen() or not self.OnlyClosed) and not self.ConsoleLocked and not self.Busy then
			if not self.Open then
				local seq = self:LookupSequence("open");
				self:ResetSequence(seq);
				self.Open = true;
				self.NextAnim = CurTime() + 1;
			end
		else
			if self.Open then
				local seq = self:LookupSequence("close");
				self:ResetSequence(seq)
				self.Open = false;
				self.NextAnim = CurTime() + 1;
			end
		end
	end

	if (not player and self.ShouldClose) then
		timer.Remove("AtlTP.ShouldClose"..self:EntIndex());
		timer.Create("AtlTP.ShouldClose"..self:EntIndex(),3.0,1,function()
			if (IsValid(self)) then
				local player = self:FindPlayer();
				if (not player) then
					self:ToggleDoors();
				else
					self.ShouldClose = true;
				end
			end
		end);
		self.ShouldClose = false;
	end

	-- fix for physics
	if (IsValid(self.Phys) and IsValid(self.DoorPhys[1]) and IsValid(self.DoorPhys[2])) then
        local mot,dmot = self.Phys:IsMotionEnabled(),self.DoorPhys[1]:IsMotionEnabled();

		if (not mot and dmot) then
			self.DoorPhys[1]:EnableMotion(false);
			self.DoorPhys[2]:EnableMotion(false);
		elseif (mot and not dmot) then
			self.DoorPhys[1]:EnableMotion(true);
			self.DoorPhys[2]:EnableMotion(true);
		end

		--self.DoorPhys:SetPos(self.Doors:GetPos());
		--self.DoorPhys:SetAngles(self.Doors:GetAngles());
	end

	if (self.DoorsLocked and self:IsDoorsOpen()) then
		self:ToggleDoors();
	end

	self:NextThink(CurTime()+0.1);
	return true;
end

function ENT:FindTransporter(name)
	if name=="" or not name then
		local dist=999999999999999 -- lolwut
		local nEnt
		local rings=ents.FindByClass("atlantis_transporter")
			for i=1,table.getn(rings) do
				if (rings[i]~=self.Entity and not rings[i].TPrivate) then
					local nDist=(self.Entity:GetPos()-rings[i]:GetPos()):Length()
						 if nDist<dist then
							 dist=nDist
							 nEnt=rings[i]
						 end
				end
			end
		return nEnt
	else
		local entt = ents.FindByClass("atlantis_transporter")
		for _,e in pairs(entt) do
			if IsValid(e) and e!=self and e.TName!="" then
				if e.TName == name then
					return e;
				end
			end
		end
		return
	end
end

function ENT:CanTeleport(ent)
	local class = ent:GetClass();
	if((ent:GetModel() or ""):find("*")) then return false end; -- Do not cloak brushes (like athmospheres in spacebuild)
	if not self.Disallowed[class] and not string.find(class,"stargate_") and not string.find(class,"ring_") and not protected_entities[class] and ent~=game.GetWorld() and not self.Ents[ent] and not ent.NotTeleportable and not ent:GetParent():IsValid() and not ent.GateSpawnerProtected then
		return true;
	end
	return false;
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

function ENT:DoTeleport(target)

	local min = self:GetPos() + self:GetRight() * 50;
	local max = self:GetPos() + self:GetForward() * -70 + self:GetUp() * 120 + self:GetRight() * -40;

	if (IsValid(self.Target)) then
		self.Target.Fail = true;
		for _,v in pairs(ents.FindInBox(min,max)) do
			if IsValid(v) and not self.Target.EntsTP[v] then
				local rotation_matrix = MMatrix.RotationMatrix(self.Target:GetUp(),0);
				local pos = self.Target:LocalToWorld(rotation_matrix*self:WorldToLocal(v:GetPos()))
				if v:IsPlayer() then
					local allow = hook.Call("StarGate.AtlantisTransporter.TeleportEnt",nil,v,self);
					if (allow==false) then self.Ents[v]=true; continue end
					local ang = v:GetAimVector():Angle();
					local ang2 = self.Target:GetAngles().y-self:GetAngles().y;
					-- fix by AlexALX
					v:SetPos(pos+Vector(0,0,4));
					if (not v:IsNPC()) then
						umsg.Start("AtlantisTransporterTele", v);
							umsg.Bool(false);
						umsg.End();
						v:SetEyeAngles(ang + Angle(0,ang2,0));
					else
						v:SetAngles(ang + Angle(0,ang2,0));
					end
					self.EntsTP[v] = true;
					self.Target.Fail = false;
				elseif (self:CanTeleport(v) and IsValid(v:GetPhysicsObject()) or v:IsNPC()) then
					self.Ents[v]=true;
					local allow = hook.Call("StarGate.AtlantisTransporter.TeleportEnt",nil,v,self);
					if (allow==false) then continue end
					if (constraint.HasConstraints(v)) then
						local entities = StarGate.GetConstrainedEnts(v,2);
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
					local ang = v:GetAngles();
					local ang2 = self.Target:GetAngles().y-self:GetAngles().y;
					local ent = v;
					-- ragdoll fix by AlexALX
					local Bones = self:GetBones(ent)
					for _,bone in pairs(Bones) do
						if(bone.Entity:IsValid()) then
							local rotation_matrix = MMatrix.RotationMatrix(self.Target:GetUp(),0);
							local bone_pos = self.Target:LocalToWorld(rotation_matrix*self:WorldToLocal(bone.Entity:GetPos()))
							local bone_ang = bone.Entity:GetAngles();

							bone.Entity:SetPos(bone_pos);
							bone.Entity:SetAngles(bone_ang + Angle(0,ang2,0));
							bone.Entity:ApplyForceCenter(Vector(0,0,0))
						end
					end
					ent:SetPos(pos)
					ent:SetAngles(ang + Angle(0,ang2,0));
					self.EntsTP[v] = true;
					if (v:IsNPC()) then
						self.Target.Fail = false;
					end
				end
			end
		end
	end

	if (IsValid(self.Target)) then
		local effectdata = EffectData()
			effectdata:SetOrigin( self.Entity:LocalToWorld(self.Entity:OBBCenter()-Vector(0,0,20)))
			effectdata:SetMagnitude(0)
		util.Effect( "transportcore", effectdata )
	end

	self.Ents = {};
	self:SetWire("Active",1);

	if (IsValid(self.Target)) then
		timer.Simple(0.1, function() if IsValid(self) then self:EmitSound(self.Sound,100,100); end end);
	end

	if (IsValid(self.Target) and target and not self.Fail and not self.NoAutoOpen) then
		timer.Simple(1.6, function() if IsValid(self) then self:ToggleDoors(); if (not self.NoAutoClose) then self.ShouldClose = true; end end end);
	end
	timer.Simple(1.6, function() if IsValid(self) then self.Busy = false; self.Fail = false; self:SetWire("Active",0); end end);

end

function ENT:Teleport()

	if (self:IsDoorsOpen() and self.OnlyClosed or self.Busy or self:IsDoorsBusy()) then return end

	self.Target = self:FindTransporter(self.Destination);
	if (not IsValid(self.Target) or self.Target:IsDoorsBusy() or self.Target.Busy) then self.Entity:EmitSound( "common/warning.wav", 100, 70 ); return end

    self.Target.Target = self.Entity;
	self.Busy = true;
	self.Target.Busy = true;
	self.ShouldClose = false;

	local dly = 1.3

	if (self:IsDoorsOpen()) then
		self:ToggleDoors();
		dly = 2.2
	end

	if (self.Target:IsDoorsOpen()) then
		self.Target:ToggleDoors();
		dly = 2.2
	end


	self.EntsTP = {};
	self.Target.EntsTP = {};

	local entz=constraint.GetAllConstrainedEntities(self.Entity)
	for _,ent in pairs(entz) do
		self.Ents[ent] = true;
	end

	local entz=constraint.GetAllConstrainedEntities(self.Target)
	for _,ent in pairs(entz) do
		self.Target.Ents[ent] = true;
	end

	local target = self.Target;
	timer.Simple(dly,function()
		if (IsValid(self)) then
			self:DoTeleport();
		end
		if (IsValid(target)) then
			target:DoTeleport(true);
		end
	end);
end


function ENT:FindPlayer()

	local min = self:GetPos() + self:GetRight() * 50
	local max = self:GetPos() + self:GetForward() * -70 + self:GetUp() * 120 + self:GetRight() * -40

	for _,v in pairs(ents.FindInBox(min,max)) do
		if IsValid(v) then
			if v:IsPlayer() or v:IsNPC() then
				return true;
			end
		end
	end
	return false;
end

function ENT:PreEntityCopy()
	local dupeInfo = {};

	if (IsValid(self.Doors[1]) and IsValid(self.Doors[2])) then
		dupeInfo.Doors = {self.Doors[1]:EntIndex(),self.Doors[2]:EntIndex()};
	end

	if (IsValid(self.Button1)) then
		dupeInfo.Button1 = self.Button1:EntIndex();
	end

	if (IsValid(self.Button2)) then
		dupeInfo.Button2 = self.Button2:EntIndex();
	end

	dupeInfo.Name = self.TName;
	dupeInfo.Private = self.TPrivate;

	duplicator.StoreEntityModifier(self, "AtlantisTPDupeInfo", dupeInfo)
	StarGate.WireRD.PreEntityCopy(self)
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	local dupeInfo = Ent.EntityMods.AtlantisTPDupeInfo

	if (dupeInfo.Doors and dupeInfo.Doors[1] and dupeInfo.Doors[2]) then
		self.Doors = {CreatedEntities[dupeInfo.Doors[1]],CreatedEntities[dupeInfo.Doors[2]]};
		self.Doors[1]:DrawShadow(false);
		self.Doors[1].BaseTP = self;
		self.Doors[2]:DrawShadow(false);
		self.Doors[2].BaseTP = self;
		self.DoorPhys = {self.Doors[1]:GetPhysicsObject(),self.Doors[2]:GetPhysicsObject()};
		if(IsValid(self.DoorPhys[1]))then
			--self.DoorPhys:EnableMotion(true);
			self.DoorPhys[1]:SetMass(100);
		end
		if(IsValid(self.DoorPhys[2]))then
			--self.DoorPhys:EnableMotion(true);
			self.DoorPhys[2]:SetMass(100);
		end
	end

	if (dupeInfo.Button1) then
		self.Button1 = CreatedEntities[dupeInfo.Button1];
		self.Button1.Atlantis = true;
		self.Button1.AtlTP = self;
		self.Button1.AtlDoor = self.Doors;
		self.Button1:SetParent(self);
	end

	if (dupeInfo.Button2) then
		self.Button2 = CreatedEntities[dupeInfo.Button2];
		self.Button2.Atlantis = true;
		self.Button2.AtlTP = self;
		self.Button2.AtlDoor = self.Doors;
		self.Button2:SetParent(self);
	end

	self.TName = dupeInfo.Name or "";
	self:SetNetworkedString("TName",self.TName);

	self.TPrivate = dupeInfo.Private or false;

	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	self:OnReloaded();
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "atlantis_transporter", StarGate.CAP_GmodDuplicator, "Data" )
end

function ENT:WireGetAddresses()
	local list = {}
	local entt = ents.FindByClass("atlantis_transporter")
	for _,e in pairs(entt) do
		if IsValid(e) and e!=self and e.TName!="" and not e.TPrivate then
			table.insert(list,e.TName);
		end
	end
	return list;
end