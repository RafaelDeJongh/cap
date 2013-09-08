--[[
	Ancient Console
	Copyright (C) 2011 Madman07
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

ENT.Sounds = {
	PressOne=Sound("dakara/dakara_control_panel.wav"),
	PressFew=Sound("dakara/dakara_control_panel2.wav"),
}

ENT.Anims = {
	"push1",
	"push2",
	"push3",
	"push4",
	"push5",
	"random",
	"reset",
	"crystalo",
	"crystalc",
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	util.PrecacheModel("models/Iziraider/dakara/console.mdl")
	self.Entity:SetModel("models/Iziraider/dakara/console.mdl");

	self.Entity:SetName("Ancient Control Console");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self.CurrentOption = 0;

	self.OpenCrystal = false;
	self.Busy = false;
	self.AlreadyOpened = false;
	self.AnimRunning = false;

end

-----------------------------------USE----------------------------------

function ENT:Use(ply)
	if(not self.Busy)then
		umsg.Start("AncientPanel",ply)
	    umsg.Entity(self.Entity);
	    umsg.End()
		self.Player = ply;
	end
end

-- function ENT:StartTouch(ent)
	-- if IsValid(ent) then
		-- if (ent:GetModel() == "models/iziraider/artifacts/ancient_pallet.mdl") then
			-- if not self.AlreadyOpened then
				-- self.AlreadyOpened = true;
				-- local dakara = self:FindDakara();
				-- dakara.Inputs = WireLib.CreateInputs( dakara, {"Main", "Secret"});
			-- end
		-- end
	-- end
-- end

-- function ENT:ToggleCrystal()
	-- if self.OpenCrystal then
		-- self.OpenCrystal = false;
		-- self.ModelAnim:Fire("setanimation","crystalc","0")
	-- else
		-- self.OpenCrystal = true;
		-- self.ModelAnim:Fire("setanimation","crystalo","0")
	-- end
-- end

-----------------------------------OTHER CRAP----------------------------------

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS; end

--########## Run the anim that's set in the arguements @RononDex
function ENT:Anim(anim,delay,nosound,sound)
	timer.Create(anim..self:EntIndex(),delay,1,function()
		if IsValid(self) then
			self:NextThink(CurTime());
			if(not(nosound)) then --Set false to allow sound
				self:EmitSound(sound,100,math.random(90,110)); --create sound as a string in the arguements
			end
			self:SetPlaybackRate(1);
			self:ResetSequence(self:LookupSequence(anim)); -- play the sequence
		end
	end);
end

function ENT:Think()
	if self.AnimRunning then --run often only if doors are busy
		self:NextThink(CurTime());
		return true
	end
end

function ENT:Think(ply)

	concommand.Add("AP"..self:EntIndex(),function(ply,cmd,args)

		local power = tonumber(args[1]);

		self.AnimRunning = true;

		self:Anim(self.Anims[1], 0, false, self.Sounds.PressOne);
		self:Anim(self.Anims[2], 1.5, false, self.Sounds.PressOne);
		self:Anim(self.Anims[3], 3, false, self.Sounds.PressOne);
		self:Anim(self.Anims[4], 4.5, false, self.Sounds.PressOne);
		self:Anim(self.Anims[5], 6, false, self.Sounds.PressOne);

		self:Anim(self.Anims[6], 7.5+power/2, false, self.Sounds.PressFew);
		self:Anim(self.Anims[6], 11.5+power/2, false, self.Sounds.PressFew);
		self:Anim(self.Anims[7], 17.5+power/2, false, self.Sounds.PressOne);

		timer.Create("StopAnim"..self:EntIndex(),20+power/2,1,function() self.AnimRunning = false end);

		local dakara = self:FindDakara();
		if (IsValid(dakara)) then
			timer.Create("PrepareDakara"..self:EntIndex(),5+power/2,1,function()
				if (IsValid(dakara)) then dakara:PrepareWeapon(power, tonumber(args[2]), tonumber(args[3]), tonumber(args[4]), tonumber(args[5]), tonumber(args[6])) end
			end);

			timer.Create("DialAllGates"..self:EntIndex(),power/2,1,function()
				if (IsValid(self)) then self:DiallAllGates(dakara); end
			end);
		end

    end);

end

function ENT:DiallAllGates(dakara)
	self.DialGate = dakara:FindGate();
	if IsValid(self.DialGate) then

		self.IncomingGates = dakara:FindAllGate();
		self.DialGate.Target = self.DialGate;

		self.DialGate:AbortDialling();
		for _,v in pairs(self.IncomingGates) do
			v:AbortDialling();
		end

		timer.Create("DialFrom"..self:EntIndex(),2,1,function()
			local action = self.DialGate.Sequence:New();
			action = self.DialGate.Sequence:Dial(false,true,false);
			action = action + self.DialGate.Sequence:OpenGate(true);
			self.DialGate:RunActions(action);
		end);

		timer.Create("DialTo"..self:EntIndex(),2.3,1,function()
			for _,v in pairs(self.IncomingGates) do
				v.Outbound = true; // fix lighting up dhds
				local action = v.Sequence:New();
				action = v.Sequence:Dial(true,true,false);
				action = action + v.Sequence:OpenGate();
				v:RunActions(action);
			end
		end);

		timer.Create("Autoclose"..self:EntIndex(),15,1,function()
			if (IsValid(self.DialGate)) then
				self.DialGate:EmergencyShutdown(); -- different methods or gates wont close, hope it will work
				self.DialGate:AbortDialling();
				self.DialGate:DeactivateStargate(true);
				for _,v in pairs(self.IncomingGates) do
					if IsValid(v) then
						v:EmergencyShutdown();
						v:AbortDialling();
						v:DeactivateStargate(true);
					end
				end
			end
		end);

	end
end

function ENT:FindDakara()
	local gate;
	local dist = 10000000;
	local pos = self.Entity:GetPos();
	for _,v in pairs(ents.FindByClass("dakara_building")) do
		local sg_dist = (pos - v:GetPos()):Length();
		if(dist >= sg_dist) then
			dist = sg_dist;
			gate = v;
		end
	end
	return gate;
end