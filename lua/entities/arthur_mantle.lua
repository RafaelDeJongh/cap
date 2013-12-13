--[[
	Arthurs Mantle
	Copyright (C) 2010 Madman07
]]--

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Arthurs Mantle"
ENT.WireDebugName = "Arthurs Mantle"
ENT.Author = "Madman07, Boba Fett"
ENT.Instructions= ""
ENT.Contact = "madman097@gmail.com"
ENT.Category = "Stargate Carter Addon Pack"

list.Set("CAP.Entity", ENT.PrintName, ENT);

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end

AddCSLuaFile()

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

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_main_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_arthurs_mantle");
end

local font = {
	font = "Anquietas",
	size = ScreenScale(35),
	weight = 400,
	antialias = true,
	additive = true,
}
surface.CreateFont("Ancients", font);

local font = {
	font = "Stargate Address Glyphs Concept",
	size = ScreenScale(35),
	weight = 400,
	antialias = true,
	additive = true,
}
surface.CreateFont("Glyphs", font);

-- Damn, recoded this myself for fix stupid bugs with flashlight and cloak. I hope now all works fine (c) AlexALX
hook.Add("Think","StarGate.ArthurCloaking.Think",
	function()
		local cloaked_self = LocalPlayer():GetNetworkedBool("ArthurCloaked",false);
		local sodan_self = LocalPlayer():GetNetworkedBool("pCloaked",false);
		for k,p in pairs(player.GetHumans()) do
			local cloaked = p:GetNWBool("ArthurCloaked",NULL); -- If a player hasn't cloaked himself yet, we do not want to override color at all (It conflicted on my server
			local sodan_cloaked = p:GetNWBool("pCloaked",NULL); -- sodan thing
			if(cloaked ~= NULL or sodan_cloaked ~= NULL) then
				if (cloaked==NULL) then cloaked = false end
				if (sodan_cloaked==NULL) then sodan_cloaked = false end
				local weapon = p:GetActiveWeapon();
				local color = p:GetColor();
				local r,g,b,a = color.r,color.g,color.b,color.a;
				local c = false;
				if (cloaked_self and sodan_self) then
					if (cloaked or sodan_cloaked) then a = 255; end
				elseif(cloaked_self) then
					if (cloaked and not sodan_cloaked) then a = 255; elseif (sodan_cloaked) then a = 0; c = true; end
				elseif(sodan_self) then
					if (sodan_cloaked and not cloaked) then a = 255; elseif (cloaked) then a = 0; c = true; end
				else
					if (cloaked or sodan_cloaked) then a = 0; c = true end
				end
				if (c and p.__SGCloakMaterial==nil) then
					p.__SGCloakMaterial = p:GetMaterial();
					p:SetMaterial("models/effects/vol_light001");
				elseif (not c and p.__SGCloakMaterial!=nil) then
					a = 255;
					if (p.__SGCloakMaterial=="models/effects/vol_light001") then
						p:SetMaterial("");
					else
						p:SetMaterial(p.__SGCloakMaterial);
					end
					p.__SGCloakMaterial = nil;
				end
				p:SetRenderMode( RENDERMODE_TRANSALPHA );
				p:SetColor(Color(r,g,b,a)); -- Cloak, lol
				if(IsValid(weapon)) then
					weapon:SetRenderMode( RENDERMODE_TRANSALPHA )
					weapon:SetColor(Color(255,255,255,a)); -- Cloak his weapon too
				end
			elseif(p.__SGCloakMaterial!=nil) then
				local color = p:GetColor();
				local r,g,b = color.r,color.g,color.b;
				local weapon = p:GetActiveWeapon();
				if (p.__SGCloakMaterial=="models/effects/vol_light001") then
					p:SetMaterial("");
				else
					p:SetMaterial(p.__SGCloakMaterial);
				end
				p.__SGCloakMaterial = nil;
				p:SetRenderMode( RENDERMODE_TRANSALPHA );
				p:SetColor(Color(r,g,b,255));
				if(IsValid(weapon)) then
					weapon:SetRenderMode( RENDERMODE_TRANSALPHA )
					weapon:SetColor(Color(255,255,255,255)); -- Cloak his weapon too
				end
			end
		end
	end
);

function ENT:Think()

	local cloak = LocalPlayer():GetNetworkedBool("ArthurCloaked",false);
	if cloak and self:GetSkin()==1 then
		self:SetSkin(0);
	elseif not cloak and self:GetSkin()==0 then
		self:SetSkin(1);
	end

	self.Entity:NextThink(CurTime() + 0.5)
	return true
end

function ENT:Draw()

	self.Entity:DrawModel();

	if LocalPlayer():GetNetworkedBool("ArthurCloaked",false) then

		local pos = self.Entity:GetPos() + self.Entity:GetUp()*50
		local ang = self.Entity:GetAngles();
		ang:RotateAroundAxis(ang:Up(), 90);
		ang:RotateAroundAxis(ang:Forward(), 90);

		local Col = Color(math.Rand(200,255),math.Rand(50,75),math.Rand(25,50),math.Rand(150,200))

		cam.Start3D2D(pos, ang, 0.05 );
			draw.DrawText("It's an Arthus Mantle, it was created", "Ancients", 0, 0, Col, TEXT_ALIGN_CENTER );
			draw.DrawText("by by Merlin, also known as Merudin", "Ancients", 0, 100, Col, TEXT_ALIGN_CENTER );
			draw.DrawText("and by Madman 07. Use that to hide", "Ancients", 0, 200, Col, TEXT_ALIGN_CENTER );
			draw.DrawText("your work before ancients. Take", "Ancients", 0, 300, Col, TEXT_ALIGN_CENTER );
			draw.DrawText("and remebmer that gate address.", "Ancients", 0, 400, Col, TEXT_ALIGN_CENTER );
		cam.End3D2D();

		Col = Color(255,math.Rand(20,30),math.Rand(20,30),math.Rand(150,200))

		cam.Start3D2D(pos, ang, 0.05 );
			draw.DrawText("GYEBND#", "Glyphs", 0, 500, Col, TEXT_ALIGN_CENTER );
		cam.End3D2D();

		local ang = self.Entity:GetAngles();
		ang:RotateAroundAxis(ang:Up(), 90);
		ang:RotateAroundAxis(ang:Forward(), 90);
		ang:RotateAroundAxis(ang:Right(), 180);

		Col = Color(math.Rand(200,255),math.Rand(50,75),math.Rand(25,50),math.Rand(150,200))

		cam.Start3D2D(pos, ang, 0.05 );
			draw.DrawText("It's an Arthus Mantle, it was created", "Ancients", 0, 0, Col, TEXT_ALIGN_CENTER );
			draw.DrawText("by by Merlin, also known as Merudin", "Ancients", 0, 100, Col, TEXT_ALIGN_CENTER );
			draw.DrawText("and by Madman 07. Use that to hide", "Ancients", 0, 200, Col, TEXT_ALIGN_CENTER );
			draw.DrawText("your work before ancients. Take", "Ancients", 0, 300, Col, TEXT_ALIGN_CENTER );
			draw.DrawText("and remebmer that gate address.", "Ancients", 0, 400, Col, TEXT_ALIGN_CENTER );
		cam.End3D2D();

		Col = Color(255,math.Rand(20,30),math.Rand(20,30),math.Rand(150,200))

		cam.Start3D2D(pos, ang, 0.05 );
			draw.DrawText("GYEBND#", "Glyphs", 0, 500, Col, TEXT_ALIGN_CENTER );
		cam.End3D2D();

	end

end

-- HACKY HACKY HACKY HACKY HACKY @aVoN
-- Stops making players "recognizeable" if they are cloaked (E.g. by looking at them - Before you e.g. saw "Catdaemon - Health 100" if you lookaed at a cloaked player. Now, you dont see anything if he is cloaked
if(util._Arthur_TraceLine) then return end;
util._Arthur_TraceLine = util.TraceLine;
function util.TraceLine(...)
	local t = util._Arthur_TraceLine(...);
	if(t and IsValid(t.Entity)) then
		if(t.Entity:IsPlayer()) then
			if(not LocalPlayer():GetNetworkedBool("ArthurCloaked",false) and t.Entity:GetNWBool("ArthurCloaked",false)) then t.Entity = NULL end;
		end
	end
	return t;
end

end