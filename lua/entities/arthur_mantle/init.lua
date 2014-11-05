--[[
	Arthurs Mantle
	Copyright (C) 2010 Madman07
	Secret Code added by AlexALX
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

AddCSLuaFile("cl_data.lua")

ENT.Sounds={
	Enter=Sound("tech/mantle_exit_enter.wav"),
	Exit=Sound("tech/mantle_exit_enter.wav"),
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	self.Entity:SetModel("models/MarkJaw/merlin_device.mdl");

	self.Entity:SetName("Arthurs Mantle");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Entity:SetUseType(SIMPLE_USE);

	self.Entity:Fire("skin",1);

	self.Entity:SetNetworkedEntity("Arthur",self.Entity);

	self:CreateWireInputs("Secret Code [STRING]");

	self.Code = "";
	self:SetNWString("Phase","");
	self.Step = 0;
	self.OldCode = "";
	self:SetNWInt("Step",self.Step);

	local tbl = scripted_ents.Get("stargate_base");
	if (tbl and tbl.ScrAddress) then
		self:SetNWString("Scr",tbl.ScrAddress);
	end
end

function ENT:RandomPhase()
	local max = math.random(8,14)
	local chr = "1234567890ABCDEGHIJKLMNOPQRSTVWXYZ"
    local ret = ""
    local exclude = ""
    while(ret:len() < max) do
        local ll = math.random(1,chr:len())
        local r = chr:sub( ll, ll )
        local match = "[^"..ret..exclude.."%z]"
        if !r:match(match) then continue end
        ret = ret .. r
    end
    return ret
end

function ENT:RandomNumber(max)
	local chr = "1234567890"
    local ret = ""
    local exclude = ""
    while(ret:len() < max) do
        local ll = math.random(1,chr:len())
        local r = chr:sub( ll, ll )
        local match = "[^"..ret..exclude.."%z]"
        if !r:match(match) then continue end
        ret = ret .. r
    end
    return tonumber(ret)
end

function ENT:RandomAct()
	local chr = "+-*"
    local ret = ""
    local exclude = ""
    while(ret:len() < 1) do
        local ll = math.random(1,chr:len())
        local r = chr:sub( ll, ll )
        local match = "[^"..ret..exclude.."%z]"
        if !r:match(match) then continue end
        ret = ret .. r
    end
    return ret
end

function ENT:RandomTask()
	local str = "";
	local result = 0;
	local act,num,num2 = self:RandomAct(),self:RandomNumber(math.random(2,4)),self:RandomNumber(math.random(2,4));
	str = tostring(num)..act..tostring(num2).."=?";
	if (act=="+") then
		result = num+num2;
	elseif (act=="-") then
		result = num-num2;
	else
		result = num*num2;
	end
	return str,tostring(result);
end

function ENT:TriggerInput(k,v)
	if (k=="Secret Code") then
		if (v:upper()==self.Code and self.Code!="") then
			if (self.Step==0) then
				local str,res = self:RandomTask();
				self.OldCode = self.Code;
				self.Code = res;
				self:SetNWString("Phase",str);
				self.Step = 1;
				self:SetNWInt("Step",self.Step);
			elseif (self.Step==1) then
				local str,act = self:RandomPhase(),self:RandomAct();
				if (act=="+") then
					self.Code = str.." "..act.." "..self.Code.." "..act.." "..self.OldCode;
					self:SetNWString("Phase",str.." "..act.." RESULT "..act.." OLDCODE");
				elseif (act=="-") then
					self.Code = self.OldCode.." "..act.." "..self.Code.." "..act.." "..str;
					self:SetNWString("Phase","OLDCODE "..act.." RESULT "..act.." "..str);
				else
					self.Code = self.OldCode.." "..act.." "..self.Code.." "..act.." "..str.." "..act.." "..self.OldCode;
					self:SetNWString("Phase","OLDCODE "..act.." RESULT "..act.." "..str.." "..act.." OLDCODE");
				end
				self.Step = 2;
				self:SetNWInt("Step",self.Step);
			elseif (self.Step==2) then
				self.Code = "";
				self.Step = 3;
				self:SetNWInt("Step",self.Step);
			end
		elseif(self.Step==3 and self.Code=="" and v:lower():find("page")) then
			local page = v:lower();
			if (page=="page1") then
				self:SetNWInt("Step",3);
			elseif (page=="page2") then
				self:SetNWInt("Step",4);
			elseif (page=="page3") then
				self:SetNWInt("Step",5);
			elseif (page=="page4") then
				self:SetNWInt("Step",6);
			elseif (page=="page5") then
				self:SetNWInt("Step",7);
			elseif (page=="page6") then
				self:SetNWInt("Step",8);
			else
				self.Code = self:RandomPhase();
				self.OldCode = "";
				self:SetNWString("Phase",self.Code);
				self.Step = 0;
				self:SetNWInt("Step",self.Step);
			end
		else
			self.Code = self:RandomPhase();
			self.OldCode = "";
			self:SetNWString("Phase",self.Code);
			self.Step = 0;
			self:SetNWInt("Step",self.Step);
		end
	end
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if (!tr.Hit) then return end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("arthur_mantle");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply;

	local phys = ent:GetPhysicsObject();
	if IsValid(phys) then
		phys:EnableMotion(false);
	end

	return ent;
end

-----------------------------------USE----------------------------------

function ENT:Use(ply)

	if IsValid(ply) then
		if (ply:GetNetworkedBool("ArthurCloaked", false)) then -- uncloack

			ply:SetNetworkedBool("ArthurCloaked",false);

			ply:SetCollisionGroup(COLLISION_GROUP_PLAYER);
			ply:SetNoTarget(false)
			self.Entity:EmitSound(self.Sounds.Enter,90,math.random(97,103));
			--self.Entity:Fire("skin",1);

			local fx = EffectData();
				fx:SetOrigin(ply:GetShootPos()+ply:GetAimVector()*10);
				fx:SetEntity(ply);
			util.Effect("arthur_cloak",fx,true,true);

			local fx2 = EffectData();
				fx2:SetEntity(ply);
			util.Effect("arthur_cloak_light",fx2,true,true);

			local fx3 = EffectData();
				fx3:SetEntity(self.Entity);
			util.Effect("arthur_cloak_light",fx3,true,true);

		else -- cloack

			ply:SetNetworkedBool("ArthurCloaked",true);

			ply:SetCollisionGroup(COLLISION_GROUP_WORLD);
			ply:SetNoTarget(true)
			self.Entity:EmitSound(self.Sounds.Enter,90,math.random(97,103));
			--self.Entity:Fire("skin",0);

			local fx = EffectData();
				fx:SetOrigin(ply:GetShootPos()+ply:GetAimVector()*10);
				fx:SetEntity(ply);
			util.Effect("arthur_cloak",fx,true,true);

			local fx2 = EffectData();
				fx2:SetEntity(ply);
			util.Effect("arthur_cloak_light",fx2,true,true);

			local fx3 = EffectData();
				fx3:SetEntity(self.Entity);
			util.Effect("arthur_cloak_light",fx3,true,true);

		end

	end

end

local function playerDies( victim, weapon, killer )
	if (victim:GetNetworkedBool("ArthurCloaked", false)) then
		victim:SetNetworkedBool("ArthurCloaked",false);
		timer.Simple(0.1,function()
			if (IsValid(p)) then
				victim:SetNWBool("ArthurCloaked",nil);
			end
		end)
		victim:SetNoTarget(false);
	end
end
hook.Add( "PlayerDeath", "StarGate.Arthur", playerDies )
hook.Add( "PlayerSilentDeath", "StarGate.Arthur", playerDies )

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

-----------------------------------DUPLICATOR----------------------------------

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end

	duplicator.StoreEntityModifier(self, "MantleDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "MantleDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local dupeInfo = Ent.EntityMods.MantleDupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	self.Owner = ply;
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "arthur_mantle", StarGate.CAP_GmodDuplicator, "Data" )
end

-- function Arthur_SpawnedProp(ply, model, ent)
	-- local shut = self.Entity:GetNetworkedEntity("Arthur");
	-- if table.HasValue(shut.CloackedPlayers, ply:EntIndex()) then
		-- ent:SetCollisionGroup(COLLISION_GROUP_WORLD);
		-- table.insert(shut.CloackedProps, ent:EntIndex());
	-- end
-- end
-- hook.Add("PlayerSpawnedProp", "Arthur_SpawnedProp", Arthur_SpawnedProp)

-- function Arthur_SpawnedSENT(ply, ent)
	-- local shut = self.Entity:GetNWEntity("Arthur");
	-- if table.HasValue(shut.CloackedPlayers, ply:EntIndex()) then
		-- ent:SetCollisionGroup(COLLISION_GROUP_WORLD);
		-- table.insert(shut.CloackedProps, ent:EntIndex());
	-- end
-- end
-- hook.Add( "PlayerSpawnedSENT", "Arthur_SpawnedSENT", Arthur_SpawnedSENT );