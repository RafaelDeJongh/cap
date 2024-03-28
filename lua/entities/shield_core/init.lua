--[[
	Shield Core
	Copyright (C) 2011 Madman07
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Sounds={
	Engage=Sound("shields/shield_engage.mp3"),
	Disengage=Sound("shields/shield_disengage.mp3"),
	Fail={Sound("buttons/button19.wav"),Sound("buttons/combine_button2.wav")},
	Open=Sound("shields/shield_core.wav"),
};

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	self.Entity:SetModel("models/Madman07/destiny_emmiter/destiny_emmiter.mdl");

	self.Entity:SetName("Shield Core");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self.Immunity = false;
	self.Strength = 0;
	self.Mod = "models/Madman07/shields/sphere.mdl";
	self.Anim = false;
	self.ThinkTime = CurTime()+0.5;
	self.MenuData = "0 0 0 0 5";

	self.Entity:SetNetworkedBool("Kill", false);
	self.Entity:SetNetworkedVector("Size", Vector(100,100,100));
	self.Entity:SetNetworkedAngle("Ang", Angle(0,0,0));
	self.Entity:SetNetworkedVector("Pos", Vector(0,0,0));
	self.Entity:SetNetworkedVector("Col", Vector(170,189,255));
	self.Entity:SetNetworkedString("Mod", self.Mod);
	self.Entity:SetNetworkedString("MenuData", self.MenuData);

	self.StrengthMultiplier = {1,1,1}; -- The first argument is the strength multiplier, the second is the regeneration multiplier. The third value is the "raw" value n, set by SetMultiplier(n) This will get set by the TOOL
	self.Strength = 100; -- Start with 100% Strength by default
	self.EngageEnergy = StarGate.CFG:Get("shield","engage_energy",500); -- This energy will be needed to engage the shield. You will get it back, when the shield collapses
	self.ConsumeMultiplier = StarGate.CFG:Get("shield","consume_multiplier",1)*100; -- As higher this is, as more energy it will take when enabled
	self.RestoreMultiplier = StarGate.CFG:Get("shield","restore_multiplier",1); -- How fast can it restore it's health?
	self.StrengthConfigMultiplier = StarGate.CFG:Get("shield","strength_multiplier",1); -- Doing this value higher will make the shiels stronger (look at the config)

	self.RestoreThresold = StarGate.CFG:Get("shield","restore_thresold",15); -- Which powerlevel has the shield to reach again until it works again?
	self:AddResource("energy",1);
	self:CreateWireInputs("Activate");
	self:CreateWireOutputs("Active","Strength");
	self:SetWire("Strength",self.Strength);

	self.Pressed = false;

	self:SetNetworkedBool("HUD_Enable", 0);
	self:SetNetworkedInt("HUD_Percent", self.Strength);

	self.RegTime = 0;
	self.Depleted = false;

	self.PlyOldEyeAngle = Angle(0,0,0);

	concommand.Add("SC_Apply"..self:EntIndex(),function(ply,cmd,args)
		self.Player:SetViewEntity(self.Player);
		--self.Player:SnapEyeAngles(self.PlyOldEyeAngle);

		self.Busy = false;
		self.Entity:SetNetworkedBool("Kill", true);
		if IsValid(self.Camera) then self.Camera:Remove() end
		if IsValid(self.Shield) then self.Shield:Remove() end

		local a = ents.Create("shield_core_buble");
		a:SetModel("models/hunter/blocks/cube025x025x025.mdl");
		a:SetPos(self:LocalToWorld(self.Pos));
		a:SetAngles(self:GetAngles()+self.Ang);
		a.Parent = self;
		if CPPI and IsValid(self.Owner) and a.CPPISetOwner then a:CPPISetOwner(self.Owner) end
		a:SetNetworkedVector("Col",self.Entity:GetNetworkedVector("Col",Vector(100,100,100)));

		a:Spawn();
		a:Activate();

		constraint.Weld(self.Entity,a,0,0,0,true)
		a:SetCollisionScale(self.Mod, self.SSize/512);
		constraint.Weld(self.Entity,a,0,0,0,true)
		self.Shield = a;

		self:SetMultiplier(tonumber(args[1]));
		self.Immunity = util.tobool(tonumber(args[2]));
		self.Draw = util.tobool(tonumber(args[3]));
		self.Atlantis = util.tobool(tonumber(args[4])) and self.HasResourceDistribution; -- this is working only with power attached, so it need RS

  		numpad.OnDown(self.Owner, tonumber(args[5]), "Toggle_Shield_Core", self.Entity);

		self.MenuData = args[1].." "..args[2].." "..args[3].." "..args[4].." "..args[5];
		self.Entity:SetNetworkedString("MenuData", self.MenuData);

		// for tracelines
		self.Shield:SetNetworkedBool("Immunity",self.Immunity);
		self.Shield:SetNetworkedEntity("Own",self.Owner);

    end);

	concommand.Add("SC_Close"..self:EntIndex(),function(ply,cmd,args)
		self.Player:SetViewEntity(self.Player);
		--self.Player:SnapEyeAngles(self.PlyOldEyeAngle);

		self.Entity:SetNetworkedBool("Kill", true);
		if IsValid(self.Camera) then self.Camera:Remove() end

		if (not self.Anim) then
			self.Busy = false;
			local seq = self:LookupSequence("Close");
			self:ResetSequence(seq);
			self.Anim = true;
			if timer.Exists("Anim"..self:EntIndex()) then timer.Destroy("Anim"..self:EntIndex()); end
			timer.Create( "Anim"..self:EntIndex(), 10, 0, function()
				self.Anim = false;
				self.Entity:SetModel("models/Madman07/destiny_emmiter/destiny_emmiter.mdl");
			end);
		end
    end);

	concommand.Add("SC_Size"..self:EntIndex(),function(ply,cmd,args)
		self.Entity:SetNetworkedVector("Size", Vector(tonumber(args[1]),tonumber(args[2]),tonumber(args[3])));
		self.SSize = Vector(tonumber(args[1]),tonumber(args[2]),tonumber(args[3]));
    end);

	concommand.Add("SC_Angle"..self:EntIndex(),function(ply,cmd,args)
		self.Entity:SetNetworkedAngle("Ang", Angle(tonumber(args[1]),tonumber(args[2]),tonumber(args[3])));
		self.Ang = Angle(tonumber(args[1]),tonumber(args[2]),tonumber(args[3]));
    end);

	concommand.Add("SC_Pos"..self:EntIndex(),function(ply,cmd,args)
		self.Entity:SetNetworkedVector("Pos", Vector(tonumber(args[1]),tonumber(args[2]),tonumber(args[3])));
		self.Pos = Vector(tonumber(args[1]),tonumber(args[2]),tonumber(args[3]))
    end);

	concommand.Add("SC_Visual_Model"..self:EntIndex(),function(ply,cmd,args)
		if (args[1] == "1") then 	 self.Mod = "models/Madman07/shields/sphere.mdl";
		elseif (args[1] == "2") then self.Mod = "models/Madman07/shields/box.mdl";
		elseif (args[1] == "3") then self.Mod = "models/Madman07/shields/atlantis.mdl"; end
		self.Entity:SetNetworkedString("Mod", self.Mod);
    end);

	concommand.Add("SC_Visual_Col"..self:EntIndex(),function(ply,cmd,args)
		self.Col = Vector(tonumber(args[1]),tonumber(args[2]),tonumber(args[3]));
		self.Entity:SetNetworkedVector("Col", self.Col);
    end);
	
	self:SpawnButton()

end

function ENT:SpawnFunction( ply, tr )
	if (!tr.Hit) then return end

	local PropLimit = GetConVar("CAP_shieldcore_max"):GetInt()
	if(ply:GetCount("CAP_shieldcore")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"entity_limit_shield_core\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+135) % 360;

	local ent = ents.Create("shield_core");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply;

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	ply:AddCount("CAP_shieldcore", ent)
	return ent;
end

function ENT:SpawnButton()
	local button = ents.Create("shield_core_button");
	button:SetParent(self);
	button:SetRenderMode(RENDERMODE_TRANSALPHA);
	button.Parent = self;
	button:SetPos(self:GetPos()-self:GetForward()*0.2+self:GetRight()*40+self:GetUp()*20)
	button:SetAngles(self:GetAngles()+Angle(0,0,0))
	button:SetColor(Color(0,0,0,0))
	button:DrawShadow(false)
	button:Spawn();
	button:Activate();
	self.Button = button	
	if CPPI and IsValid(p) and button.CPPISetOwner then button:CPPISetOwner(p) end
end

function ENT:OnRemove()
	StarGate.WireRD.OnRemove(self);
	if IsValid(self.Shield) then self.Shield:Remove() end
	if timer.Exists("Anim"..self:EntIndex()) then timer.Destroy("Anim"..self:EntIndex()); end
	if IsValid(self.Entity) then self.Entity:Remove(); end
	if IsValid(self.Camera) then self.Camera:Remove(); end
	if IsValid(self.Player) then self.Player:SetViewEntity(self.Player); end
end

function ENT:Use(ply)
	if(not self.Busy and ply == self.Owner and not self.Pressed)then
		self:Status(false, true); -- shutdown old shield, close emmiter

		if (not IsValid(self.Camera)) then
			self.Camera = ents.Create("prop_physics");
		end
		self.Camera:SetModel("models/sandeno/naquadah_bottle.mdl");
		self.Camera:SetColor(Color(0,0,0,0));
		self.Camera:SetRenderMode(RENDERMODE_TRANSALPHA);
		local pos = self:LocalToWorld(Vector(750,750,500));
		self.Camera:SetPos(pos);
		local ang = (self:GetPos()-pos):Angle();
		self.Camera:SetAngles(ang);
		self.Camera:Spawn();
		self.Camera:Activate();
		if CPPI and IsValid(self.Owner) and self.Camera.CPPISetOwner then self.Camera:CPPISetOwner(self.Owner) end

		local phys = self.Camera:GetPhysicsObject()
		if IsValid(phys) then phys:EnableMotion(false) end
		constraint.Weld(self.Entity,self.Camera,0,0,0,true)

		self.PlyOldEyeAngle = ply:EyeAngles();
		ply:SetViewEntity(self.Camera);
		--ply:SnapEyeAngles(Angle(0,180,0));

		self.Entity:SetNetworkedBool("Kill", false);

		umsg.Start("ShieldCorePanel",ply)
	    umsg.Entity(self.Entity);
	    umsg.End()
		self.Player = ply;
		ply.ShieldCore = self;

		local fx = EffectData();
			fx:SetEntity(self.Entity);
		util.Effect("shield_core_preview",fx,true,true);

		//self.Entity:SetNetworkedVector("Col", Vector(170,189,255)); // shield dont want to accept colors after menu creation, lets fix it here
	end
end

function ENT:EmmiterAnimation(open)
	self.Anim = true;
	self:SetNetworkedBool("ShouldClip", true);
	if timer.Exists("Anim"..self:EntIndex()) then timer.Destroy("Anim"..self:EntIndex()); end
	if open then
		self.Entity:SetModel("models/Madman07/destiny_emmiter/destiny_emmiter_anim.mdl");
		local seq = self:LookupSequence("Open");
		self:ResetSequence(seq);
		timer.Create( "Anim"..self:EntIndex(), 7, 1, function()
			self.Anim = false;
			self:SetNetworkedBool("ShouldClip", false);
		end);
	else
		local seq = self:LookupSequence("Close");
		self:ResetSequence(seq);
		timer.Create( "Anim"..self:EntIndex(), 7, 1, function()
			self.Anim = false;
			self:SetNetworkedBool("ShouldClip", false);
			self.Entity:SetModel("models/Madman07/destiny_emmiter/destiny_emmiter.mdl");
		end);
	end
	timer.Create( "Sound"..self:EntIndex(), 0.4, 1, function() if (IsValid(self)) then self:EmitSound(self.Sounds.Open,100,100); end end);
end

function ENT:Status(status,nosound)
	if not IsValid(self.Shield) then return end

	if not self.Pressed then
		self.Pressed = true;
		timer.Create( "Press", 7, 0, function() self.Pressed = false end);

		if (self.Depleted and status) then
			self:EmmiterAnimation(false); -- Close emmiter - shield inactive
			self.Depleted = nil;
			self.Shield.Depleted = nil;
			return
		end
		if (status and not self.Shield.Enabled) then
			local energy = self:GetResource("energy",self.EngageEnergy);
			self.ConsumeAmmount = math.ceil(((self.Shield.Radius)^2*math.pi*4)/200000); -- Instead of doing this calculation very second, do it here
			self.ExtraConsume = math.exp(math.Clamp(self.StrengthMultiplier[3]*1.3,0.2,600));
			if((not self.Depleted or (self.Strength >= self.RestoreThresold)) and self.Strength > 0 and energy >= self.EngageEnergy) then
				-- Taking the enagage energy, you will get back later (when turning off the shield)
				self:ConsumeResource("energy",self.EngageEnergy);
				--Enable shield
				self.Shield:Status(true);
				if(not nosound) then
					self:EmitSound(self.Sounds.Engage,90,math.random(90,110));
				end
				self:EmmiterAnimation(true); -- Open emmiter - shield active
				self:SetWire("Active",1);
				self:SetSkin(1);
				return
			end
		elseif(not status and self.Shield.Enabled) then
			-- Give back the energy, we took when it was enagaged
			self:SupplyResource("energy",self.EngageEnergy);
			-- Disable Shield
			self.Shield:Status(false);
			if(not nosound and not self.Depleted) then
				self:EmitSound(self.Sounds.Disengage,90,math.random(90,110));
			end
			self:SetSkin(0);
			self:EmmiterAnimation(false); -- Close emmiter - shield inactive
			self:SetWire("Active",0);
			return
		end

		-- Fail animation
		self:EmitSound(self.Sounds.Fail[1],90,math.random(90,110));
		self:EmitSound(self.Sounds.Fail[2],90,math.random(90,110));
	end
end

function ENT:Think(ply)

	if (self.ThinkTime < CurTime() and IsValid(self.Shield)) then

		self.Shield:SetPos(self:LocalToWorld(self.Pos));
		self.Shield:SetAngles(self:GetAngles()+self.Ang);

		self.ThinkTime = CurTime()+0.5
		local enabled = self.Shield.Enabled;
		if self.Atlantis then	-- infinite strength if we have power
			self:ShowOutput(enabled, true);
			local energy = self:GetResource("energy");
			if(energy <= 1000) then -- minimal energy for making it work
				self:Status(false);
				return
			end
		else
			if (CurTime() > self.RegTime) then self:Regenerate(enabled); end
			self:ShowOutput(enabled);
			if (self.Strength < 1 and not self.Depleted) then
				self.Depleted = true;
				self.Shield.Depleted = true;
				self.Shield:SetNetworkedBool("depleted",true);
				self.Shield:Status(false);
				self:SetWire("Active",0);
			end
			if(self.Depleted) then
				-- Reenable shielt - It was depleted before (But alter the Thresold, so people wont have it up so fast again or need to wait ages)
				if(self.Strength >= math.Clamp(self.RestoreThresold/self.StrengthMultiplier[2],3,40)) then
					self.Depleted = nil;
					self.Shield.Depleted = nil;
					self:EmitSound(self.Sounds.Engage,90,math.random(90,110));

					--Engage Shield!
					self.Shield:Status(true);
					self.Shield:SetNetworkedBool("depleted",false); -- For the traceline class - Clientside
					self:SetWire("Active",1);
				end
			elseif(enabled and self.HasResourceDistribution and self.ConsumeMultiplier ~= 0) then
				-- Consume energy
				local energy = self:GetResource("energy");

				-- Make the shield consume more power depending on it's strength
				local take_energy = (self.ConsumeAmmount or 1)*(self.ExtraConsume or 1)*self.ConsumeMultiplier
				self:ConsumeResource("energy",math.Clamp(take_energy,1,energy));
				if(energy <= take_energy) then -- no energy - shut down it
					self:Status(false);
					return
				end
			end

		end
	end

	if self.Anim then
		self:NextThink(CurTime());
		return true
	else
		self:NextThink(CurTime()+0.5);
		return true
	end
end

function ENT:ShowOutput(enabled, atl)
	local add = 0;
	if(enabled) then
		add = 1;
	end
	if(self.Depleted) then
		add = 2;
	end
	self:SetNetworkedInt("HUD_Enable", add);
	if atl then
		self:SetNetworkedInt("HUD_Percent", 100);
		self:SetWire("Strength",100);
	else
		self:SetNetworkedInt("HUD_Percent", self.Strength);
		self:SetWire("Strength",math.floor(self.Strength));
	end
end

--################# Set's the strengthg multiplier which is necessary for the shields regeneration time and strength @aVoN
function ENT:SetMultiplier(n)
	local n = math.Clamp(n or 0,-5,5); -- Backwarts compatibility and idiot-proof
	if(n > 0) then
		n = 1 + n;
		self.StrengthMultiplier[1] = n
		self.StrengthMultiplier[2] = n^1.5
	else
		n = 1/(1 - n);
		self.StrengthMultiplier[1] = n^1.5;
		self.StrengthMultiplier[2] = n;
	end
	self.Strength = math.Clamp((self.StrengthMultiplier[3]/n)*self.Strength,0,100); -- This avoids cheating
	self.StrengthMultiplier[3] = n;
end

--################# Shield got hit - Take strength @aVoN
function ENT:Hit(strength,normal,pos)
	-- Calculate strenght-taking multiplier: Are we a shield, which is not moving? If so, we are many times stronger than a shield of a ship which is moving.
	local divisor = 1;
	if(self.Entity:GetVelocity():Length() < 5) then
		divisor = StarGate.CFG:Get("shield","stationary_shield_multiplier",10);
	end

	-- Take strength if not atlantis, otherwise take energy
	if self.Atlantis then
		-- Consume energy
		local energy = self:GetResource("energy");

		-- Make the shield consume more power depending on hit strength
		local take_energy = math.Clamp(200*math.Clamp(strength,1,40)/(self.StrengthMultiplier[1]*self.StrengthConfigMultiplier*divisor),1,10000)*StarGate.CFG:Get("shield_core","atlantis_hit",50);
		self:ConsumeResource("energy",math.Clamp(take_energy,1,energy));
	else
		self.Strength = math.Clamp(self.Strength-2*math.Clamp(strength,1,20)/(self.StrengthMultiplier[1]*self.StrengthConfigMultiplier*divisor),0,100);
	end

	self.RegTime = CurTime()+2.5;

	if(StarGate.CFG:Get("shield","apply_force",false)) then
		-- Make us bounce around
		local phys = self:GetPhysicsObject();
		phys:ApplyForceOffset(-1*normal*strength*100*phys:GetMass()/self.StrengthMultiplier[1],pos);
	end
end

--################# Reset it's strength @aVoN
function ENT:Regenerate(enabled)
	if(self.Strength < 100) then
		local multiplier = 1;
		-- Disabled shields can regenrate 2 times faster!
		if(not (enabled or self.Depleted)) then
			multiplier = multiplier*2.5;
		end
		-- Consume energy when restoring the strength
		if(StarGate.HasResourceDistribution) then
			local energy = self:GetResource("energy");
			local speed = math.Clamp(energy/5000,1,4); -- Can make up to 4 times faster to regenerate with enough power connected (ZPMs, resource Caches etc)
			multiplier = math.floor(multiplier*speed);
			local take_energy = multiplier*20
			if(take_energy > energy) then return end;
			self:ConsumeResource("energy",take_energy);
		else
			-- For those without lifesupport: Make the shield regenerate a bit faster (Due to request)
			multiplier = multiplier*2;
		end
		multiplier = multiplier*(self.RestoreMultiplier/self.StrengthMultiplier[2]); -- Multiplier from the config and with the StrengthMultiplier
		self.Strength = math.Clamp(self.Strength+multiplier,0,100);
	end
end

--################# Wire input @aVoN
function ENT:TriggerInput(k,v)
	if(k=="Activate") then
		if((v or 0) >= 1) then
			self:Status(true);
		else
			self:Status(false);
		end
	end
end

numpad.Register("Toggle_Shield_Core",
	function(p,e)
		if not IsValid(e) then return end;
		if not IsValid(e.Shield) then return end;
		if(e.Shield.Enabled) then
			e:Status(false);
		else
			e:Status(true);
		end
	end
);


function ENT:PreEntityCopy()
	local dupeInfo = {}
	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end
	/*
	if WireAddon then
		dupeInfo.WireData = WireLib.BuildDupeInfo( self.Entity )
	end*/

	dupeInfo.SSize = self.SSize;
	dupeInfo.Ang = self.Ang;
	dupeInfo.Pos = self.Pos;
	dupeInfo.Col = self.Col;
	dupeInfo.Mod = self.Mod;
	dupeInfo.MenuData = self.MenuData;

	duplicator.StoreEntityModifier(self, "SCDupeInfo", dupeInfo)
	StarGate.WireRD.PreEntityCopy(self)
end
duplicator.RegisterEntityModifier( "SCDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	if (IsValid(ply)) then
		local PropLimit = GetConVar("CAP_shieldcore_max"):GetInt();
		if(ply:GetCount("CAP_shieldcore")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"entity_limit_shield_core\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			self.Entity:Remove();
			return
		end
	end

	local dupeInfo = Ent.EntityMods.SCDupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end
    /*
	if(Ent.EntityMods and Ent.EntityMods.SCDupeInfo.WireData) then
		WireLib.ApplyDupeInfo( ply, Ent, Ent.EntityMods.SCDupeInfo.WireData, function(id) return CreatedEntities[id] end)
	end  */

	self.Entity:SetNetworkedVector("Size", dupeInfo.SSize);
	self.Entity:SetNetworkedAngle("Ang", dupeInfo.Ang);
	self.Entity:SetNetworkedVector("Pos", dupeInfo.Pos);
	self.Entity:SetNetworkedVector("Col", dupeInfo.Col);
	self.Entity:SetNetworkedString("Mod", dupeInfo.Mod);
	self.Entity:SetNetworkedString("MenuData", dupeInfo.MenuData);

	self.SSize = dupeInfo.SSize;
	self.Ang = dupeInfo.Ang;
	self.Pos = dupeInfo.Pos;
	self.Col = dupeInfo.Col;
	self.Mod = dupeInfo.Mod;
	self.MenuData = dupeInfo.MenuData;

	if (IsValid(ply)) then
		self.Owner = ply;
		ply:AddCount("CAP_shieldcore", self.Entity)
	end
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)

end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "shield_core", StarGate.CAP_GmodDuplicator, "Data" )
end