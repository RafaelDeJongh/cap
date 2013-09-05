--[[
	Sodan Obelisk
	Copyright (C) 2010 Madman07
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

ENT.Sounds={
	[1] = Sound("button/ancient_button1.wav"),
	[2] = Sound("button/ancient_button2.wav"),
	Transport = Sound("tech/sodan_oblisk.wav"),
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	self.Entity:SetModel("models/ZsDaniel/ancient-obelisk/obelisk.mdl");

	self.Entity:SetName("Sodan Obelisk");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self.Range = 600;
	self.CantDial = false;
	self.DialAdress = {};
	self.Password = ""

	self.Entity:SetNetworkedString("pass","")
	self.Entity:SetNetworkedString("ADDRESS",string.Implode(",",self.DialAdress));

end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local PropLimit = GetConVar("CAP_sod_obelisk_max"):GetInt()
	if(ply:GetCount("CAP_sod_obelisk")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Sodan Obelisk limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("sodan_obelisk");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();

	ent.Owner = ply;

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	ply:AddCount("CAP_sod_obelisk", ent)
	return ent
end

-----------------------------------USE----------------------------------

function ENT:Use(ply)
	if (IsValid(ply) and ply:IsPlayer()) then
		if self.Paired and IsValid(self.Target) then

			local button = self:GetAimingButton(ply);
			if (button) then
				if button == "PASS" then
					if ply == self.Owner then
						self.Entity:EmitSound(self.Sounds[2]);
						umsg.Start("ObeliskShowPassWindow",ply)
						umsg.Entity(self.Entity);
						umsg.End()
						ply.ObeliskNameEnt=self
					end
				else
					self:PressButton(button, ply)
				end
			end

		end
	end
end

-----------------------------------BUTTON----------------------------------

function ENT:PressButton(button, ply)

	self.CantDial = true;

	if table.HasValue(self.DialAdress, button ) then return end

	table.insert(self.DialAdress, button)
	self.Entity:SetNetworkedString("ADDRESS",string.Implode(",",self.DialAdress));

	local adr = string.Implode("",self.DialAdress)

	if (adr == self.Password) then

		self.Entity:EmitSound(self.Sounds[2]);

		timer.Create( self.Entity:EntIndex().."Dial", 2, 1, function()
			if (IsValid(self)) then
				self.DialAdress = nil;
				self.DialAdress = {};
				self.CantDial = false;
				self.Entity:SetNetworkedString("ADDRESS",string.Implode(",",self.DialAdress));
			end
		end )

		timer.Destroy(self.Entity:EntIndex().."Counting")

		self.Entity:Teleport();

	else

		if (table.getn(self.DialAdress) == 0) then
			timer.Create( self.Entity:EntIndex().."Counting", 3, 1, function()
				if (IsValid(self)) then
					self.DialAdress = nil;
					self.DialAdress = {};
					self.CantDial = false;
					self.Entity:SetNetworkedString("ADDRESS",string.Implode(",",self.DialAdress));
				end
			end )
		else
			if timer.Exists(self.Entity:EntIndex().."Counting") then timer.Destroy(self.Entity:EntIndex().."Counting") end
			timer.Create( self.Entity:EntIndex().."Counting", 3,1, function()
				if (IsValid(self)) then
					self.DialAdress = nil;
					self.DialAdress = {};
					self.CantDial = false;
					self.Entity:SetNetworkedString("ADDRESS",string.Implode(",",self.DialAdress));
				end
			end )
		end

		timer.Create( self.Entity:EntIndex().."Skin", 0.5, 1, function()
			self.CantDial = false;
		end )

		self.Entity:EmitSound(self.Sounds[1]);

	end

end

-----------------------------------PAIR----------------------------------

function ENT:Touch(ent)
	if (ent:GetClass() == "sodan_obelisk") then
		if not self.Paired then
			local fx = EffectData();
				fx:SetEntity(self.Entity);
			util.Effect("propspawn",fx);
			self.Target = ent;
			self.Paired = true;
		end
	end
end

-----------------------------------PASS----------------------------------

function SetObeliskPassword(ply,cmd,args)
	if ply.ObeliskNameEnt and ply.ObeliskNameEnt~=NULL then
		if args[1] then
			ply.ObeliskNameEnt.Password=args[1]
			ply.ObeliskNameEnt:SetNetworkedString("pass",args[1])
			if ply.ObeliskNameEnt.Paired and IsValid(ply.ObeliskNameEnt.Target) then
				ply.ObeliskNameEnt.Target.Password=args[1]
				ply.ObeliskNameEnt.Target:SetNetworkedString("pass",args[1])
			end
		end
		ply.ObeliskNameEnt=nil
	end
end
concommand.Add("setobeliskpass",SetObeliskPassword)

-----------------------------------TELEPORT----------------------------------

function ENT:Teleport()

	if IsValid(self.Entity) and IsValid(self.Target) then

		local pos = self.Entity:GetPos();

		local oldpos = Vector(0,0,5);
		local newpos = Vector(0,0,5);

		self.Entity:EmitSound(self.Sounds.Transport,100,math.random(90,110));
		self.Target:EmitSound(self.Sounds.Transport,100,math.random(90,110));

		local deltayaw = self.Entity:GetAngles().Yaw - self.Target:GetAngles().Yaw

		for _,v in pairs(ents.FindByClass("player*")) do
			if IsValid(v) and v:IsPlayer() then

				local dist = (pos - v:GetPos()):Length();
				if (dist < self.Range) then

					oldpos = self.Entity:WorldToLocal(v:GetPos()) + Vector(0,0,5);
					newpos = self.Target:LocalToWorld(oldpos);

					timer.Create("Transport"..v:EntIndex(), 0.5, 1, function()
						if (IsValid(v)) then
							v:SetPos(newpos);
							v:SetEyeAngles(v:GetAimVector():Angle() - Angle(0,deltayaw,0));
							local fx3 = EffectData();
								fx3:SetOrigin(v:GetShootPos()+v:GetAimVector()*10);
								fx3:SetEntity(v);
							util.Effect("arthur_cloak",fx3,true);
						end
					end)

					local fx = EffectData();
						fx:SetOrigin(v:GetShootPos()+v:GetAimVector()*10);
						fx:SetEntity(v);
					util.Effect("arthur_cloak",fx,true);

					local fx2 = EffectData();
						fx2:SetEntity(v);
					util.Effect("arthur_cloak_light",fx2,true);

				end

			end

		end
	end
end

function ENT:OnRemove()

	if timer.Exists(self.Entity:EntIndex().."Dial") then timer.Destroy(self.Entity:EntIndex().."CloseGates") end
	if timer.Exists("Transport*") then timer.Destroy("Transport*") end
	if timer.Exists(self.Entity:EntIndex().."Counting") then timer.Destroy(self.Entity:EntIndex().."TeleportEffect") end
	if timer.Exists(self.Entity:EntIndex().."Skin") then timer.Destroy(self.Entity:EntIndex().."DialGates") end

	if IsValid(self.Entity) then self.Entity:Remove() end
end

-----------------------------------DUPLICATOR----------------------------------

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end

	dupeInfo.Password = self.Password;
	dupeInfo.Target = self.Target;
	dupeInfo.Paired = self.Paired;

	duplicator.StoreEntityModifier(self, "SodanTrDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "SodanTrDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local PropLimit = GetConVar("CAP_sod_obelisk_max"):GetInt();
	if(ply:GetCount("CAP_sod_obelisk")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Sodan Obelisk limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		self.Entity:Remove();
		return
	end

	local dupeInfo = Ent.EntityMods.SodanTrDupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	self.Password = dupeInfo.Password;
	self.Target = dupeInfo.Target;
	self.Paired = dupeInfo.Paired;

	if (self.Paired and IsValid(self.Target)) then
		self.Target.Target = self;
		self.Target.Paired = true;
	end

	self.Entity:SetNetworkedString("pass",self.Password)

	self.Owner = ply;
	ply:AddCount("CAP_sod_obelisk", self.Entity)

end