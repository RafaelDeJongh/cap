--[[
	Ancient Panel
	Copyright (C) 2010 Madman07
]]--

ENT.Type 			= "anim"
ENT.Base 			= "ring_panel"
ENT.PrintName		= "Ring Panel (Ancient)"
ENT.Author			= "Madman07, Boba Fett, Catdaemon, aVoN"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Category		= "Stargate Carter Addon Pack: Gates and Rings"

list.Set("CAP.Entity", ENT.PrintName, ENT);

ENT.ButtonPos = {
	[1] = Vector(1.53, -1.5, 19.38),
	[2] = Vector(1.53, 1.5, 19.38),
	[3] = Vector(1.53, 0, 15.68),
	[4] = Vector(1.53, -1.5, 11.98),
	[5] = Vector(1.53, 1.5, 11.98),
	[6] = Vector(1.53, -2.5, 4.57),
	[7] = Vector(1.53, 0, 4.57),
	[8] = Vector(1.53, 2.5, 4.57),
	DIAL = Vector(1.53, 0, 8.28),
}

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
AddCSLuaFile()

ENT.Sounds={
	[1] = Sound("button/ancient_button1.wav"),
	[2] = Sound("button/ancient_button2.wav"),
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:SetModel("models/Madman07/ring_panel/ancient_panel.mdl");
	self.BaseClass.Initialize(self);
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr)
	if ( !tr.Hit ) then return end
	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("ring_panel_ancient");
	ent:SetPos( tr.HitPos + tr.HitNormal * 50);
	ent:SetAngles(ang);
	ent:Spawn();
	ent:Activate();

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end
	ent:CartersRampsRPanel(tr);

	return ent;
end

-----------------------------------PRESS BUTTON----------------------------------

function ENT:PressButton(button, ply)

	self.CantDial = true;

	if (button == "DIAL") then

		if (table.getn(self.DialAdress) == 0) then
			ply.RingDialEnt = self;
			self:DoCallback(0, "");
		else
			ply.RingDialEnt = self;
			self:DoCallback(50, string.Implode("",self.DialAdress));
		end

		table.insert(self.DialAdress, 9)
		local str = string.Implode(",",self.DialAdress)
		self.Entity:SetNetworkedString("ADDRESS",str);

		self.Entity:Fire("skin",6);
		timer.Create( self.Entity:EntIndex().."Skin", 0.5, 1, function()
			if (IsValid(self.Entity)) then
				self.Entity:Fire("skin",10);
			end
		end )
		self.Entity:EmitSound(self.Sounds[1]);

		timer.Create( self.Entity:EntIndex().."Dial", 2, 1, function()
			if (IsValid(self.Entity)) then
				self.DialAdress = nil;
				self.DialAdress = {};
				self.CantDial = false;
				self.Entity:SetNetworkedString("ADDRESS",string.Implode(",",self.DialAdress));
			end
		end )

		timer.Destroy(self.Entity:EntIndex().."Counting")

	else

		if table.HasValue(self.DialAdress, button ) then return end

		if (table.getn(self.DialAdress) == 0) then
			timer.Create( self.Entity:EntIndex().."Counting", 3, 1, function()
				if (IsValid(self.Entity)) then
					self.DialAdress = nil;
					self.DialAdress = {};
					self.CantDial = false;
					self.Entity:SetNetworkedString("ADDRESS",string.Implode(",",self.DialAdress));
				end
			end )
		else
			if timer.Exists(self.Entity:EntIndex().."Counting") then timer.Destroy(self.Entity:EntIndex().."Counting") end
			timer.Create( self.Entity:EntIndex().."Counting", 3,1, function()
				if (IsValid(self.Entity)) then
					self.DialAdress = nil;
					self.DialAdress = {};
					self.CantDial = false;
					self.Entity:SetNetworkedString("ADDRESS",string.Implode(",",self.DialAdress));
				end
			end )
		end

		table.insert(self.DialAdress, button)

		self.Entity:SetNetworkedString("ADDRESS",string.Implode(",",self.DialAdress));

		if (button > 5) then button = button + 1 end
		self.Entity:Fire("skin",button);
		timer.Create( self.Entity:EntIndex().."Skin", 0.5, 1, function()
			if (IsValid(self.Entity)) then
				self.Entity:Fire("skin",10);
				self.CantDial = false;
			end
		end )
		self.Entity:EmitSound(self.Sounds[2]);

	end

end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "ring_panel_ancient", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("stargate_category");
ENT.PrintName = SGLanguage.GetMessage("ring_panel_ancient");
end

ENT.ButtonPos = {
	[1] = Vector(1.53, -1.5, 19.38),
	[2] = Vector(1.53, 1.5, 19.38),
	[3] = Vector(1.53, 0, 15.68),
	[4] = Vector(1.53, -1.5, 11.98),
	[5] = Vector(1.53, 1.5, 11.98),
	[6] = Vector(1.53, -2.5, 4.57),
	[7] = Vector(1.53, 0, 4.57),
	[8] = Vector(1.53, 2.5, 4.57),
	[9] = Vector(1.53, 0, 8.28),
}

ENT.Middle = Vector(1.53, 0, 11.98);

ENT.ButtCount = 9;

end