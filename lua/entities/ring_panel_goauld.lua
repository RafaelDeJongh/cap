--[[
	Goauld Panel
	Copyright (C) 2010 Madman07
]]--

ENT.Type 			= "anim"
ENT.Base 			= "ring_panel"
ENT.PrintName		= "Ring Panel (Goauld)"
ENT.Author			= "Madman07, Rafael De Jongh, Catdaemon, aVoN"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Category		= "Stargate Carter Addon Pack: Gates and Rings"

list.Set("CAP.Entity", ENT.PrintName, ENT);

ENT.ButtonPos = {
	[1] = Vector(2.55, -3.3, 12.1),
	[2] = Vector(2.55, 3.3, 12.1),
	[3] = Vector(2.55, -3.3, 9.1),
	[4] = Vector(2.55, 3.3, 9.1),
	[5] = Vector(2.55, -3.3, 6.1),
	DIAL = Vector(2.55, 3.3, 6.1),
}

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
AddCSLuaFile()

ENT.Sounds={
	[1] = Sound("button/ring_button1.mp3"),
	[2] = Sound("button/ring_button2.mp3"),
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:SetModel("models/Madman07/ring_panel/goauld_panel.mdl");
	self.BaseClass.Initialize(self);
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr)
	if ( !tr.Hit ) then return end
	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("ring_panel_goauld");
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

		table.insert(self.DialAdress, 6)
		local str = string.Implode(",",self.DialAdress)
		self.Entity:SetNetworkedString("ADDRESS",str);

		self.Entity:Fire("skin",6);
		timer.Create( self.Entity:EntIndex().."Skin", 0.5, 1, function()
			if (IsValid(self.Entity)) then
				self.Entity:Fire("skin",7);
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
				self.Entity:Fire("skin",7);
				self.CantDial = false;
			end
		end )
		self.Entity:EmitSound(self.Sounds[2]);

	end

end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "ring_panel_goauld", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("stargate_category");
ENT.PrintName = SGLanguage.GetMessage("ring_panel_goauld");
end

ENT.ButtonPos = {
	[1] = Vector(2.55, -3.3, 12.1),
	[2] = Vector(2.55, 3.3, 12.1),
	[3] = Vector(2.55, -3.3, 9.1),
	[4] = Vector(2.55, 3.3, 9.1),
	[5] = Vector(2.55, -3.3, 6.1),
	[6] = Vector(2.55, 3.3, 6.1),
}

ENT.Middle = Vector(2.55, 0, 12.1);

ENT.ButtCount = 6;

end