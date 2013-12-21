--[[
	Telchak Healing device
	Copyright (C) 2010 Madman07
]]--

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Telchak healing device"
ENT.Author			= "Madman07, Boba Fett"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= "Only for Ancients."
ENT.Category		= "Stargate Carter Addon Pack"

list.Set("CAP.Entity", ENT.PrintName, ENT);

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end

AddCSLuaFile()

ENT.Sounds = {
	Heal = Sound("tech/telchak_loop.wav")
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	self.Entity:SetModel("models/Madman07/telchak/telchak.mdl");

	self.Entity:SetName("Telchak Healing device");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Entity:SetUseType(SIMPLE_USE);

	self.Active = false;
	self.Entity:SetNetworkedBool("healing", false);

	self.SickPlayers = {}

	timer.Create(self.Entity:EntIndex().."LowHelath", 0.05, 0, function() -- yay do it more often than usual think
		for _,v in pairs(self.SickPlayers) do
			if (IsValid(v) and v:IsPlayer()) then

				local health = v:Health();
				if (health > math.Rand(20,60)) then v:SetHealth(health - 2);
				else

					local new_t = {};
					for _,x in pairs(self.SickPlayers) do
						if(x ~= v) then
							table.insert(new_t,x);
						end
					end
					self.SickPlayers = new_t;
					v:SetNWBool("Telchak_Heal", false);

				end

			end
		end
	end )

end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr)
	if ( !tr.Hit ) then return end
	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("telchak");
	ent:SetPos(tr.HitPos);
	ent:SetAngles(ang);
	ent:Spawn();
	ent:Activate();

	ent.Owner = ply;
	return ent
end


function ENT:OnRemove()
	if self.LoopSound then
		self.LoopSound:Stop();
		self.LoopSound = nil;
	end
	if IsValid(self.Light) then
		self.Light:Fire("TurnOn","","0");
		self.Light:Remove();
		self.Light = nil;
	end
	self.Entity:SetNWBool("healing", false);
	if timer.Exists(self.Entity:EntIndex().."LowHelath") then timer.Destroy(self.Entity:EntIndex().."LowHelath") end
end

-----------------------------------THINK----------------------------------

function ENT:Think(ply)
	if self.Active then

		for _,v in pairs(ents.FindInSphere(self.Entity:GetPos(), 300)) do
			if (IsValid(v) and not table.HasValue(self.SickPlayers, v)) then

				local len = (v:GetPos() - self.Entity:GetPos()):Length();
				if v:IsPlayer() and not v:HasGodMode() then

					if (len < 300) then

						v:SetNWBool("Telchak_Heal", true);

						local health = v:Health();

						if (not v:Alive() and health > math.Rand(10, 30)) then
							local pos = v:GetPos();
							v:Spawn();
							v:SetPos(pos);
						end

						if (health > math.Rand(190, 200)) then
							if not table.HasValue(self.SickPlayers, v) then table.insert(self.SickPlayers, v) end
						else
							v:SetMaxHealth(200);
							v:SetHealth(health + (300-len)/200);
						end

					end

				elseif v:IsNPC() then

					if (len < math.Rand(400, 200)) then
						v:AddEntityRelationship(self.Owner, 1, 999 );
					end

				end

			end
		end

	end

	self.Entity:NextThink(CurTime()+0.5);
	return true
end

-----------------------------------USE---------------------------------

function ENT:Use(ply)

	if (IsValid(ply) and ply:IsPlayer()) then
		if not self.Active then

			self.LoopSound = CreateSound(self.Entity, self.Sounds.Heal)
			if self.LoopSound then
				self.LoopSound:Play()
			end

			self.Entity:SetNWBool("healing", true);
			self.Active = true;
			local dynlight = ents.Create( "light_dynamic" );
			dynlight:SetPos( self.Entity:GetPos() + self.Entity:GetUp()*10 );
			dynlight:SetKeyValue( "_light", 255 .. " " .. 255 .. " " .. 255 .. " " .. 255 );
			dynlight:SetKeyValue( "style", 0 );
			dynlight:SetKeyValue( "distance", 5 );
			dynlight:SetKeyValue( "brightness", 10 );
			dynlight:SetParent( self.Entity );
			dynlight:Spawn();
			self.Light = dynlight;
			self.Entity:SetMaterial("Madman07/telchak/telchak_on"); -- I broke something and i need to use that not beautifull way

		else

			if self.LoopSound then
				self.LoopSound:FadeOut(2);
			end

			self.Entity:SetNWBool("healing", false);
			self.Active = false;
			if IsValid(self.Light) then
				self.Light:Fire("TurnOn","","0");
				self.Light:Remove();
				self.Light = nil;
			end
			self.Entity:SetMaterial("");
		end
	end

end

-- Small fix by AlexALX & Llapp
local function playerDies( victim, weapon, killer )
	if (victim:GetNetworkedBool("Telchak_Heal", false)) then
		victim:SetNetworkedBool("Telchak_Heal", false);
	end
end
hook.Add( "PlayerDeath", "StarGate.Telchak", playerDies )
hook.Add( "PlayerSilentDeath", "StarGate.Telchak", playerDies )

-----------------------------------DUPLICATOR----------------------------------

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end

	dupeInfo.Active = self.Active;

	duplicator.StoreEntityModifier(self, "TelchakDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "TelchakDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end

	local dupeInfo = Ent.EntityMods.TelchakDupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]

		self.Active = dupeInfo.Active;
		self.Entity:SetNWBool("healing", self.Active);
		self.Owner = ply;
	end
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "telchak", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

ENT.RenderGroup = RENDERGROUP_OPAQUE
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_main_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_telchak");
end

ENT.TelchakSprite = Material("effects/multi_purpose_noz");
ENT.Col = Color(255,255,255,50);

function ENT:Initialize()
	self.Healing = false;
end

function ENT:Think()
	self.Healing = self.Entity:GetNetworkedBool("healing",false);
end

function ENT:Draw()
	self.Entity:DrawModel();

	if self.Healing then
		render.SetMaterial(self.TelchakSprite);
		local endpos = self.Entity:GetPos() + self.Entity:GetUp()*10;
		if StarGate.LOSVector(EyePos(), endpos, LocalPlayer(), 15) then
			render.DrawSprite(endpos,75,75,self.Col);
		end
	end
end

local function BlindPlayer()
	if (not IsValid(LocalPlayer())) then return end
	local health = LocalPlayer():Health();
	local used = LocalPlayer():GetNWBool("Telchak_Heal", false);
	if (health > 150 and used) then
		if (health>200) then health = 200 end
		DrawMotionBlur( 0.2, (-150+health)/50, 0.05)

		local tab = {}
		tab[ "$pp_colour_addr" ] = 0
		tab[ "$pp_colour_addg" ] = 0
		tab[ "$pp_colour_addb" ] = 0
		tab[ "$pp_colour_brightness" ] = (-150+health)/150
		tab[ "$pp_colour_contrast" ] = (-150+health)/150+1
		tab[ "$pp_colour_colour" ] = 1
		tab[ "$pp_colour_mulr" ] = 1
		tab[ "$pp_colour_mulg" ] = 1
		tab[ "$pp_colour_mulb" ] = 1

		DrawColorModify( tab )

	end
end
hook.Add( "RenderScreenspaceEffects", "BlindPlayer", BlindPlayer )

end