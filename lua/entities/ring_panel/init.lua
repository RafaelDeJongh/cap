--[[
	Ring Panel
	Copyright (C) 2010 Madman07
]]--

if (not StarGate.CheckModule("extra")) then return end
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Entity:SetUseType(SIMPLE_USE);

	self.DialAdress = {};
	self.CantDial = false;

	self.RingBase = self.Entity;
	self.Range = 500;

	self.Entity:SetNetworkedString("ADDRESS",string.Implode(",",self.DialAdress));

	self.AllowMenu = StarGate.CFG:Get("ring_panel","menu",true);

end

-----------------------------------THINK----------------------------------

function ENT:Think(ply)

	if (IsValid(self.Entity) and IsValid(self.RingBase) and self.RingBase != self.Entity) then

		if (timer.Exists(self.Entity:EntIndex().."Dial") and self.RingBase.Busy) then

			timer.Destroy(self.Entity:EntIndex().."Dial")
			timer.Create( self.Entity:EntIndex().."Dial", 2, 1, function()
				if IsValid(self.Entity) then
					self.DialAdress = nil;
					self.DialAdress = {};
					self.CantDial = false;
					self.Entity:SetNetworkedString("ADDRESS",string.Implode(",",self.DialAdress));
				end
			end )

		end


	end

	self.Entity:NextThink(CurTime()+1);
	return true
end

-----------------------------------FIND RINGS----------------------------------

function ENT:FindRing()
	local ring;
	local dist = self.Range;
	local pos = self.Entity:GetPos();
	for _,v in pairs(ents.FindByClass("ring_base*")) do
		local ring_dist = (pos - v:GetPos()):Length();
		if(dist >= ring_dist) then
			dist = ring_dist;
			ring = v;
		end
	end
	return ring;
end

-----------------------------------USE---------------------------------

function ENT:Use(ply)

	if (IsValid(ply) and ply:IsPlayer()) then

		local e = self:FindRing();
		if(not IsValid(e)) then return end;
		self.RingBase = e;

		if (self.CantDial or e.Busy) then return
		else
			local button = self:GetAimingButton(ply);
			if (button) then self:PressButton(button, ply)
			elseif(self.AllowMenu) then
				umsg.Start("RingTransporterShowWindowCap", ply)
				umsg.End()
				ply.RingDialEnt = self.Entity;
			end
		end
	end

end

-----------------------------------CATDAEMON STUFF----------------------------------

function ENT:DoCallback(range, address)

	if self.RingBase == self.Entity then return end -- well that was a bloody waste of time
	if (type(address) == "number") then address = tostring(address) end

	if not self.RingBase.Busy then
		if (self.RingBase:GetClass() == "ring_base_ancient" and address == "3571") then
			local nearest_ring = self.RingBase:FindNearest("")
			if (nearest_ring == false) then return end
			if nearest_ring:GetClass() == "ring_base_ancient" then
				nearest_ring:StartLaser();
				if timer.Exists(self.Entity:EntIndex().."Dial") then timer.Destroy(self.Entity:EntIndex().."Dial") end
			end
		else
			self.RingBase.SetRange = range;
			self.RingBase:Dial(address)
		end
	end

end

function RingsDiallingCallback(ply,cmd,args)
	if ply.RingDialEnt and ply.RingDialEnt~=NULL then
		if args[1] then
			ply.RingDialEnt:DoCallback(50, args[1])
		else
			ply.RingDialEnt:DoCallback(0, "")
		end
		ply.RingDialEnt:EmitSound(Sound("tech/ring_button1.mp3")); -- "Dial Button" Sound @aVoN
		ply.RingDialEnt=nil
	end
end
concommand.Add("doringsdial",RingsDiallingCallback)

-----------------------------------DUPLICATOR----------------------------------

function ENT:PreEntityCopy()
	local dupeInfo = {}
	if IsValid(self.Entity) then
		dupeInfo.EntityID = self.Entity:EntIndex()
	end
	duplicator.StoreEntityModifier(self, "RingPanelDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "RingPanelDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end

	local dupeInfo = Ent.EntityMods.RingPanelDupeInfo

	if dupeInfo.EntityID then
		self.Entity = CreatedEntities[ dupeInfo.EntityID ]
	end

	self.RingBase = self.Entity;

end

--######################## @Alex, aVoN -- snap gates to cap ramps
function ENT:CartersRampsRPanel(t)
	local e = t.Entity;
	if(not IsValid(e)) then return end;
	local RampOffset = StarGate.RampOffset.RingP;
	local mdl = e:GetModel();
	if(RampOffset[mdl]) then
		if (RampOffset[mdl][2]) then
			self.Entity:SetAngles(e:GetAngles() + RampOffset[mdl][2]);
		else
			self.Entity:SetAngles(e:GetAngles());
		end
		self.Entity:SetPos(e:LocalToWorld(RampOffset[mdl][1]));
		constraint.Weld(e,self.Entity,0,0,0,true);
		-- Is this needed?
		--e.CDSIgnore = true; -- Fixes Combat Damage System destroying Ramps - http://mantis.39051.vs.webtropia.com/view.php?id=45
		--return e;
	end
end