--[[
	Ori Panel
	Copyright (C) 2010 Madman07
]]--

ENT.Type 			= "anim"
ENT.Base 			= "ring_panel"
ENT.PrintName		= "Ring Panel (Ori)"
ENT.Author			= "Madman07, Boba Fett, Catdaemon, aVoN"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Category		= "Stargate Carter Addon Pack: Gates and Rings"

list.Set("CAP.Entity", ENT.PrintName, ENT);

ENT.ButtonPos = {
	[1] = Vector(1.40, -9.97, 3.31),
	[2] = Vector(1.36, -8.98, 5.82),
	[3] = Vector(1.38, -7.46, 7.76),
	[4] = Vector(1.42, -5.17, 9.24),
	[5] = Vector(1.46, -2.95, 10.12),
	DIAL = Vector(2.15, 0.09, 2.25),
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
	self.Entity:SetModel("models/ZsDaniel/ori-ringpanel/panel.mdl");
	self.BaseClass.Initialize(self);
	self.SkinCountaa = 1;
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr)
	if ( !tr.Hit ) then return end
	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("ring_panel_ori");
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
			self.Entity:Fire("skin",6);
		else
			ply.RingDialEnt = self;
			self:DoCallback(50, string.Implode("",self.DialAdress));
			self.Entity:Fire("skin",7);
		end

		table.insert(self.DialAdress, 9)
		local str = string.Implode(",",self.DialAdress)
		self.Entity:SetNetworkedString("ADDRESS",str);

		timer.Create( self.Entity:EntIndex().."Skin", 0.5, 1, function()
			if (IsValid(self.Entity)) then
				self.Entity:Fire("skin",8);
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

		self.Entity:Fire("skin",button);
		timer.Create( self.Entity:EntIndex().."Skin", 0.5, 1, function()
			if (IsValid(self.Entity)) then
				self.Entity:Fire("skin",8);
				self.CantDial = false;
			end
		end )
		self.Entity:EmitSound(self.Sounds[2]);

	end

end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "ring_panel_ori", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("stargate_category");
ENT.PrintName = SGLanguage.GetMessage("ring_panel_ori");
end

ENT.ButtonPos = {
	[1] = Vector(1.40, -9.97, 3.31),
	[2] = Vector(1.36, -8.98, 5.82),
	[3] = Vector(1.38, -7.46, 7.76),
	[4] = Vector(1.42, -5.17, 9.24),
	[5] = Vector(1.46, -2.95, 10.12),
	[6] = Vector(2.15, 0.09, 2.25),
}

ENT.Middle = Vector(2.15, 0.09, 2.25);

ENT.ButtCount = 6;

end