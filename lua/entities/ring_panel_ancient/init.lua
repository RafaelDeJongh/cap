--[[
	Ancient Panel
	Copyright (C) 2010 Madman07
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

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