--[[
	Destiny Timer
	Copyright (C) 2010 Madman07
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Sounds = {
	Start = Sound("destiny/timer_start.wav"),
	Stop = Sound("destiny/timer_stop.wav"),
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	util.PrecacheModel("models/Iziraider/destinytimer/timer.mdl");
	self.Entity:SetModel("models/Iziraider/destinytimer/timer.mdl");

	self.Entity:SetName("Destiny Timer");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Entity:SetUseType(SIMPLE_USE);

	if (WireAddon) then
		self.Inputs = WireLib.CreateInputs( self.Entity, {"Count","Reset","Minutes","Seconds"});
		self.Outputs = WireLib.CreateOutputs( self.Entity, {"End", "Close Stargate","Minutes","Seconds"});
	end

	self.Count = true;
	self.Minutes = 0;
	self.Seconds = 0;
	self.MiliSeconds = 0;

	self.WireCount = 0;
	self.WireMinutes = 0;
	self.WireSeconds = 0;
	self.WireReset = 0;

	Wire_TriggerOutput(self.Entity, "End", 0);
	Wire_TriggerOutput(self.Entity, "Close Stargate", 0);

end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if (!tr.Hit) then return end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("destiny_timer");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	return ent;
end

-----------------------------------WIRE----------------------------------

function ENT:TriggerInput(variable, value)
	if (variable == "Count") then
		if (self.WireCount == 0 and self.Count) then
			self.WireCount = value;
			self:EmitSound(self.Sounds.Start,500,math.random(90,110));
		end
	elseif (variable == "Reset") then self.WireReset = value;
	elseif (variable == "Minutes") then self.WireMinutes = math.Clamp(value, 0, 59);
	elseif (variable == "Seconds") then self.WireSeconds = math.Clamp(value, 0, 59);
	end
end

-----------------------------------THINK----------------------------------

function ENT:Think(ply)

	local NextThink = CurTime()+0.1;

	if (self.WireReset == 1) then
		self.WireReset = 0;
		self.Seconds = self.WireSeconds;
		self.Minutes = self.WireMinutes;
		self.MiliSeconds = 0;
		self.Count = true;
		self.WireCount = 0;

		Wire_TriggerOutput(self.Entity, "End", 0);
		Wire_TriggerOutput(self.Entity, "Seconds", self.Seconds);
		Wire_TriggerOutput(self.Entity, "Minutes", self.Minutes);

		local time = self.Minutes*60 + self.Seconds;
		self.Entity:SetNetworkedInt("time",time)
	end

	if (self.WireCount == 0 and self.Count) then
		if (self.Minutes == 0 and self.Seconds == 0) then
			self.Seconds = self.WireSeconds;
			self.Minutes = self.WireMinutes;

			Wire_TriggerOutput(self.Entity, "Seconds", self.Seconds);
			Wire_TriggerOutput(self.Entity, "Minutes", self.Minutes);

			local time = self.Minutes*60 + self.Seconds;
			self.Entity:SetNWInt("time",time)
		end
	end

	if (self.WireCount == 1 and self.Count) then
		self.MiliSeconds = self.MiliSeconds - 1;
		if (self.MiliSeconds == -1) then
			self.Seconds = self.Seconds - 1;

			Wire_TriggerOutput(self.Entity, "Seconds", self.Seconds);
			Wire_TriggerOutput(self.Entity, "Minutes", self.Minutes);

			local time = self.Minutes*60 + self.Seconds;
			self.Entity:SetNWInt("time",time)

			if (self.Seconds == -1) then
				self.Minutes = self.Minutes - 1;
				if (self.Minutes == -1) then
					self.Seconds = 0;
					self.Minutes = 0;
					self.MiliSeconds = 0;
					self.WireCount = 0;
					self.Count = false;

					Wire_TriggerOutput(self.Entity, "End", 1);
					Wire_TriggerOutput(self.Entity, "Close Stargate", 1);
					Wire_TriggerOutput(self.Entity, "Seconds", 0);
					Wire_TriggerOutput(self.Entity, "Minutes", 0);
					timer.Simple(0.1, function() Wire_TriggerOutput(self.Entity, "Close Stargate", 0); end);

					self.Entity:SetNWInt("time",0)
					self:EmitSound(self.Sounds.Stop,500,math.random(90,110));
				else
					self.Seconds = 59;
					self.MiliSeconds = 9;
				end
			else
				self.MiliSeconds = 9;
			end
		end
	end

	self.Entity:NextThink(NextThink)
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

	dupeInfo.Minutes = self.Minutes;
	dupeInfo.Seconds = self.Seconds;
	dupeInfo.MiliSeconds = self.MiliSeconds;

	duplicator.StoreEntityModifier(self, "TimerDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "TimerDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local dupeInfo = Ent.EntityMods.TimerDupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	if(Ent.EntityMods and Ent.EntityMods.TimerDupeInfo.WireData) then
		WireLib.ApplyDupeInfo( ply, Ent, Ent.EntityMods.TimerDupeInfo.WireData, function(id) return CreatedEntities[id] end)
	end

	self.Minutes = dupeInfo.Minutes;
	self.Seconds = dupeInfo.Seconds;
	self.MiliSeconds = dupeInfo.MiliSeconds;

	local time = self.Minutes*60 + self.Seconds;
	self.Entity:SetNWInt("time",time)

	self.Owner = ply;
end