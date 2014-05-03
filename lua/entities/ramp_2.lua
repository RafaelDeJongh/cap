/*   Copyright 2010 by Llapp   */
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Ramp"
ENT.Author = "Llapp"
ENT.Category = "Stargate Carter Addon Pack"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.IsRamp = true

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
AddCSLuaFile();

function ENT:Initialize()
	self.Entity:PhysicsInit( SOLID_VPHYSICS ) ;
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS );
	self.Entity:SetSolid( SOLID_VPHYSICS );
	self.Entity:SetSkin(1);
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:Wake();
		phys:SetMass(5000);
	end
	self.Gate=nil;
end

function ENT:SpawnFunction(p,t)
	if(not t.Hit) then return end;
	local e = ents.Create("ramp_2");
	e:SetPos(t.HitPos+Vector(0,0,90));
	e:DrawShadow(true);
	e:Spawn();
	return e;
end

function ENT:Think()
    if(self.Gate!=nil)then
        self:SkinChanger();
	end
    self:GateFinder();
	self:NextThink(CurTime()+0.5);
end

function ENT:SkinChanger()
    if(self.Gate!=nil)then
        if(not self.Gate.NewActive)then
	        self.Entity:SetSkin(1);
        elseif(self.Gate.NewActive and not self.Gate.IsOpen)then
	        self.Entity:SetSkin(0);
	    elseif(self.Gate.NewActive and self.Gate.IsOpen and not self.Gate.Outbound)then
	        self.Entity:SetSkin(3);
	    elseif(self.Gate.NewActive and self.Gate.IsOpen and self.Gate.Outbound)then
	        self.Entity:SetSkin(2);
	    end
	end
end

function ENT:GateFinder()
	for _,v in pairs(StarGate.GetConstrainedEnts(self.Entity,2) or {}) do
		if(IsValid(v) and v:GetClass():find("stargate_*") and v:GetClass()!="stargate_dhd") then
		    self.Gate = v;
		--else
		--    self.Gate = nil;
		end
	end
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable("anim_ramps",ply,"tool") ) then self.Entity:Remove(); return end
	if (IsValid(ply)) then
		local PropLimit = GetConVar("sbox_maxanim_ramps"):GetInt()
		if(ply:GetCount("CAP_anim_ramps")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"stool_ramp_anim_limit\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			self.Entity:Remove();
			return
		end
		ply:AddCount("CAP_anim_ramps", self.Entity)
	end
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "ramp_2", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("ramp",SGLanguage.GetMessage("ramp_kill"));
end

end