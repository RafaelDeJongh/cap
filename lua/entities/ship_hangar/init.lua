--[[
	Ships Hangar
	Copyright (C) 2010 Madman07
]]--

if (not StarGate.CheckModule("ship")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	util.PrecacheModel("models/Iziraider/capbuild/hangar.mdl")
	self.Entity:SetModel("models/Iziraider/capbuild/hangar.mdl");

	self.Entity:SetName("Ships Hangar");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self.Inputs = WireLib.CreateInputs( self.Entity, {"Next Ship", "Prev Ship", "Spawn Ship", "Toggle Doors"});

	self.ShipCount = 0;
	self.ShipClass = {
		"sg_vehicle_f302",
		"puddle_jumper",
		"sg_vehicle_glider",
		"sg_vehicle_gate_glider",
		"sg_vehicle_dart",
	}

	self.Pressed = false;
	self.Range = 1000;
	self.LockedDoor = false;

end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("ship_hangar");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos+Vector(0,0,100));
	ent:Spawn();
	ent:Activate();

	ent:SpawnDoors();
	ent:SpawnButtons();

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	return ent
end

function ENT:SpawnDoors()
	util.PrecacheModel("models/Iziraider/capbuild/hangardoor.mdl")

	local ent = ents.Create("ship_hangar_door");
	ent:SetAngles(self.Entity:GetAngles());
	ent:SetPos(self.Entity:GetPos());
	ent.Parent = self;
	ent.Factor = 1;
	ent:Spawn();
	ent:Activate();
	ent:GetPhysicsObject():Wake();
	constraint.NoCollide( ent, self, 0, 0 );
	self.Door1 = ent;

	local ent2 = ents.Create("ship_hangar_door");
	ent2:SetAngles(self.Entity:GetAngles()+Angle(0,180,0));
	ent2:SetPos(self.Entity:GetPos());
	ent2.Parent = self;
	ent2.Factor = -1;
	ent2:Spawn();
	ent2:Activate();
	ent2:GetPhysicsObject():Wake();
	constraint.NoCollide( ent2, self, 0, 0 );
	self.Door2 = ent2;
end

function ENT:SpawnButtons(entt)

	entt = entt or {};

	local ang = self:GetAngles();

	util.PrecacheModel("models/beer/wiremod/numpad.mdl")

	local ent = entt[1] or ents.Create("ship_hangar_button");
	ent:SetAngles(ang+Angle(35,-90,0));
	ent:SetPos(self:LocalToWorld(Vector(-469.94, -622.5, 48)));
	ent:SetModel("models/beer/wiremod/numpad.mdl");
	ent:Spawn();
	ent:Activate();
	ent:SetColor(Color(0,0,0,0));
	ent:SetRenderMode(RENDERMODE_TRANSALPHA);
	ent.Parent = self;
	ent.ID = 1;
	if (not entt[1]) then constraint.Weld(self,ent,0,0,0,true) end
	self.ButtonL = ent;

	ent = entt[2] or ents.Create("ship_hangar_button");
	ent:SetAngles(ang+Angle(35,-90,0));
	ent:SetPos(self:LocalToWorld(Vector(-457.69, -622.5, 48)));
	ent:SetModel("models/beer/wiremod/numpad.mdl");
	ent:Spawn();
	ent:Activate();
	ent:SetColor(Color(0,0,0,0));
	ent:SetRenderMode(RENDERMODE_TRANSALPHA);
	ent.Parent = self;
	ent.ID = 2;
	if (not entt[2]) then constraint.Weld(self,ent,0,0,0,true) end
	self.ButtonR = ent;

	ent = entt[3] or ents.Create("ship_hangar_button");
	ent:SetAngles(ang+Angle(35,-90,0));
	ent:SetPos(self:LocalToWorld(Vector(-444.71, -622.5, 48)));
	ent:SetModel("models/beer/wiremod/numpad.mdl");
	ent:Spawn();
	ent:Activate();
	ent:SetColor(Color(0,0,0,0));
	ent:SetRenderMode(RENDERMODE_TRANSALPHA);
	ent.Parent = self;
	ent.ID = 3;
	if (not entt[3]) then constraint.Weld(self,ent,0,0,0,true) end
	self.ButtonSP = ent;

	ent = entt[4] or ents.Create("ship_hangar_button");
	ent:SetAngles(ang+Angle(35,-90,0));
	ent:SetPos(self:LocalToWorld(Vector(-422.40, -621.5, 48)));
	ent:SetModel("models/beer/wiremod/numpad.mdl");
	ent:Spawn();
	ent:Activate();
	ent:SetColor(Color(0,0,0,0));
	ent:SetRenderMode(RENDERMODE_TRANSALPHA);
	ent.Parent = self;
	ent.ID = 4;
	if (not entt[4]) then constraint.Weld(self,ent,0,0,0,true) end
	self.ButtonLock = ent;

	ent = entt[5] or ents.Create("ship_hangar_button");
	ent:SetAngles(ang+Angle(0,0,0));
	ent:SetPos(self:LocalToWorld(Vector(77,-459,-42)));
	ent:SetModel("models/props_lab/freightelevatorbutton.mdl");
	ent:Spawn();
	ent:Activate();
	ent.Parent = self;
	ent.ID = 5;
	if (not entt[5]) then constraint.Weld(self,ent,0,0,0,true) end
	self.ButtonT1 = ent;

	ent = entt[6] or ents.Create("ship_hangar_button");
	ent:SetAngles(ang+Angle(0,180,0));
	ent:SetPos(self:LocalToWorld(Vector(-24,-473,-28)));
	ent:SetModel("models/props_lab/freightelevatorbutton.mdl");
	ent:Spawn();
	ent:Activate();
	ent.Parent = self;
	ent.ID = 5;
	if (not entt[6]) then constraint.Weld(self,ent,0,0,0,true) end
	self.ButtonT2 = ent;

	ent = entt[7] or ents.Create("prop_physics");
	ent:SetAngles(ang+Angle(35,-90,0));
	ent:SetPos(self:LocalToWorld(Vector(-430, -621.5, 49)));
	ent:SetModel("models/led2.mdl");
	ent:Spawn();
	ent:Activate();
	ent:SetParent(self);
	ent:SetMaterial("models/debug/debugwhite");
	ent:SetColor(Color( 20, 50, 20, 255));
	if (not entt[7]) then constraint.Weld(self,ent,0,0,0,true) end
	self.LED = ent;
end

function ENT:OnRemove()
	if IsValid(self.Door1) then self.Door1:Remove(); end
	if IsValid(self.Door2) then self.Door2:Remove(); end
	if IsValid(self.ButtonL) then self.ButtonL:Remove(); end
	if IsValid(self.ButtonR) then self.ButtonR:Remove(); end
	if IsValid(self.ButtonSP) then self.ButtonSP:Remove(); end
	if IsValid(self.ButtonLock) then self.ButtonLock:Remove(); end
	if IsValid(self.ButtonT1) then self.ButtonT1:Remove(); end
	if IsValid(self.ButtonT2) then self.ButtonT2:Remove(); end
	if IsValid(self.LED) then self.LED:Remove(); end
end

function ENT:ButtonPressed(id, ply)
	if (id == 1) then
		self.ShipCount = self.ShipCount + 1;
		if (self.ShipCount > 4) then self.ShipCount = 0; end
		self.Entity:Fire("skin",self.ShipCount);
	elseif (id == 2) then
		self.ShipCount = self.ShipCount - 1;
		if (self.ShipCount < 0) then self.ShipCount = 4; end
		self.Entity:Fire("skin",self.ShipCount);
	elseif (id == 3) then
		local e = ents.Create(self.ShipClass[self.ShipCount+1]);
		undo.Create("Ship")
			undo.AddEntity(e)
			undo.SetPlayer(ply)
		undo.Finish()
		e:SetPos(self.Entity:GetPos() + Vector(0,0,30) - self.Entity:GetForward()*400);
		e:SetAngles(Angle(0,self.Entity:GetAngles().Yaw,0));
		e:Spawn();
		e:Activate();
		e:SetWire("Health",e:GetNetworkedInt("health"));
	elseif (id == 4) then
		self.LockedDoor = not self.LockedDoor;
		if self.LockedDoor then self.LED:SetColor(Color(0, 255, 0, 255));
		else self.LED:SetColor( Color(20, 50, 20, 255)); end
	elseif (id == 5) then
		if not self.LockedDoor then
			self.Door1:Toggle();
			self.Door2:Toggle();
		end
	end
end

function ENT:Think(ply)

	local pos = self.Entity:GetPos();

	for _,v in pairs(ents.FindByClass("sg_vehicle_*")) do
		local ship_dist = (pos - v:GetPos()):Length();
		if(ship_dist < self.Range) then
			local health = v:GetNetworkedInt("health");
			health = health + 5;
			if (v:GetClass()=="sg_vehicle_teltac") then
				if (health > 3000) then health = 3000; end
			else
				if (health > 500) then health = 500; end
			end
			v:SetNetworkedInt("health", health);
			v:SetWire("Health",health);
		end
	end

	for _,v in pairs(ents.FindByClass("puddle_jumper")) do
		local ship_dist = (pos - v:GetPos()):Length();
		if(ship_dist < self.Range) then
			local health = v:GetNetworkedInt("health");
			health = health + 5;
			if (health > 500) then health = 500; end
			v:SetNetworkedInt("health", health);
			v:SetWire("Health",health);
		end
	end

	self.Entity:NextThink(CurTime()+1);
	return true
end
function ENT:PreEntityCopy()
	local dupeInfo = {}
	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end
	if WireAddon then
		dupeInfo.WireData = WireLib.BuildDupeInfo( self.Entity )
	end

	if IsValid(self.Door1) then dupeInfo.Door1 = self.Door1:EntIndex(); end
	if IsValid(self.Door2) then dupeInfo.Door2 = self.Door2:EntIndex(); end
	if IsValid(self.ButtonL) then dupeInfo.ButtonL = self.ButtonL:EntIndex(); end
	if IsValid(self.ButtonR) then dupeInfo.ButtonR = self.ButtonR:EntIndex(); end
	if IsValid(self.ButtonSP) then dupeInfo.ButtonSP = self.ButtonSP:EntIndex(); end
	if IsValid(self.ButtonLock) then dupeInfo.ButtonLock = self.ButtonLock:EntIndex(); end
	if IsValid(self.ButtonT1) then dupeInfo.ButtonT1 = self.ButtonT1:EntIndex(); end
	if IsValid(self.ButtonT2) then dupeInfo.ButtonT2 = self.ButtonT2:EntIndex(); end
	if IsValid(self.LED) then dupeInfo.LED = self.LED:EntIndex(); end

	duplicator.StoreEntityModifier(self, "HangarConDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "HangarConDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	local dupeInfo = Ent.EntityMods.HangarConDupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	if(Ent.EntityMods and Ent.EntityMods.HangarConDupeInfo.WireData) then
		WireLib.ApplyDupeInfo( ply, Ent, Ent.EntityMods.HangarConDupeInfo.WireData, function(id) return CreatedEntities[id] end)
	end

	if dupeInfo.Door1 then self.Door1 = CreatedEntities[dupeInfo.Door1]; self.Door1.Parent = self.Entity; self.Door1.Factor = 1; end
	if dupeInfo.Door2 then self.Door2 = CreatedEntities[dupeInfo.Door2]; self.Door2.Parent = self.Entity; self.Door2.Factor = -1; end
	if dupeInfo.ButtonL then self.ButtonL = CreatedEntities[dupeInfo.ButtonL]; end
	if dupeInfo.ButtonR then self.ButtonR = CreatedEntities[dupeInfo.ButtonR]; end
	if dupeInfo.ButtonSP then self.ButtonSP = CreatedEntities[dupeInfo.ButtonSP]; end
	if dupeInfo.ButtonLock then self.ButtonLock = CreatedEntities[dupeInfo.ButtonLock]; end
	if dupeInfo.ButtonT1 then self.ButtonT1 = CreatedEntities[dupeInfo.ButtonT1]; end
	if dupeInfo.ButtonT2 then self.ButtonT2 = CreatedEntities[dupeInfo.ButtonT2]; end
	if dupeInfo.LED then self.LED = CreatedEntities[dupeInfo.LED]; end
	self:SpawnButtons({self.ButtonL,self.ButtonR,self.ButtonSP,self.ButtonLock,self.ButtonT1,self.ButtonT2,self.LED})

	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end

	self.Owner = ply;

end