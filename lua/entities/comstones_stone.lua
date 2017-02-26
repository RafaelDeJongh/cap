--[[
	Comunication Device
	Copyright (C) 2011 Madman07
]]--

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Stone"
ENT.Author = "cooldudetb, Madman07, Rafael De Jongh"
ENT.Category = "Stargate Carter Addon Pack"

list.Set("CAP.Entity", ENT.PrintName, ENT);
ENT.WireDebugName = "Communication Stone"

if CLIENT then

ENT.Stone_hud = surface.GetTextureID("VGUI/resources_hud/MCD");
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_main_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_stone");
end

function ENT:Draw()
    self.Entity:DrawModel();
	hook.Remove("HUDPaint",tostring(self.Entity).."Stone");
    if(LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance( self.Entity:GetPos() ) < 1024)then
		hook.Add("HUDPaint",tostring(self.Entity).."Stone",function()
		    surface.SetTexture(self.Stone_hud);
	        surface.SetDrawColor(Color( 255, 255, 255, 155 ));
	        surface.DrawTexturedRect(ScrW()/2-3, ScrH()/2-112, 100, 100);

			local name = "---";
			if IsValid(self.Entity) then name = self.Entity:GetNetworkedString("Name", "---"); end

            draw.DrawText("Stone", "header", ScrW()/2+27, ScrH()/2-103, Color(0,255,255,255), 0)
            draw.DrawText("Finger print:", "center2", ScrW()/2+10, ScrH()/2-77, Color(209,238,238,255),0);
			draw.DrawText(name, "center2", ScrW()/2+10, ScrH()/2-57, Color(209,238,238,255),0);

		end);
	end
end

function ENT:OnRemove()
    hook.Remove("HUDPaint",tostring(self.Entity).."Stone");
end

end

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end

AddCSLuaFile();

function ENT:Initialize()
	self.Entity:SetModel("models/Madman07/com_device/stone.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self.Tablet = NULL;
	self.Ply = NULL;
	self.PairedStone = NULL;
	self.Connected = false;
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("comstones_stone");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	return ent
end

function ENT:Use(ply)
	if(IsValid(ply) and ply:IsPlayer()) then
		if (self.Ply == ply) then
			self.Ply = NULL;
			self.Entity:SetNetworkedString("Name", "---");
			if IsValid(self.Tablet) then self.Tablet:Disconnect(self); end
		else
			self.Ply = ply;
			self.Entity:SetNWString("Name", ply:GetName());
			if IsValid(self.Tablet) then self.Tablet:Connect(self); end
		end

	end
end

-----------------------------------DUPLICATOR----------------------------------

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end

	duplicator.StoreEntityModifier(self, "StoneDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "StoneDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local dupeInfo = Ent.EntityMods.StoneDupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "comstones_stone", StarGate.CAP_GmodDuplicator, "Data" )
end

end