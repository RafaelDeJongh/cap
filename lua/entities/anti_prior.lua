--[[############################################################################################################
	Anti Prior Device
	Copyright (C) 2010 assassin21
############################################################################################################]]

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Anti Prior Device"
ENT.WireDebugName = "Anti Prior Device"
ENT.Author = "assassin21, Boba Fett"
ENT.Instructions= ""
ENT.Contact = "zoellner21@gmail.com"
ENT.Category = "Stargate Carter Addon Pack"

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

list.Set("CAP.Entity", ENT.PrintName, ENT);

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
	ENT.Category = SGLanguage.GetMessage("entity_main_cat");
	ENT.PrintName = SGLanguage.GetMessage("entity_antiprior");
end

end

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end

AddCSLuaFile()

--##############################Init @ assassin21

function ENT:Initialize()

	self.Entity:SetModel("models/Madman07/anti_priest/anti_priest.mdl");

	self.Entity:SetName("Anti Prior Device");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Entity:SetUseType(SIMPLE_USE);

	self.IsOn = false;
	self.Radius = 800; --math.random(600, 800); sorry disable this, because added hook, lazy to make it with radius...
	if WireAddon then
		self:CreateWireInputs("Activate","Immunity Mode");
		self:CreateWireOutputs("Activated");
	end

	self.Immunity = 0;

end

--###############################Spawn @ assassin21

function ENT:SpawnFunction( ply, tr )
	if (!tr.Hit) then return end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("anti_prior");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply;

	local phys = ent:GetPhysicsObject();
	if IsValid(phys) then phys:EnableMotion(false); end

	return ent;
end

--##############################Use @ assassin21

function ENT:Use()
	if self.IsOn==false then
		self.IsOn=true;
		self:SetWire("Activated",1);
	else
		self.IsOn=false;
		self:SetWire("Activated",0);
	end
end


--################################Wire @ assassin21

function ENT:TriggerInput(variable, value)
	if (variable == "Activate") then
		self.IsOn = util.tobool(value)
		if (self.IsOn) then
			self:SetWire("Activated",1);
		else
			self:SetWire("Activated",0);
		end
	elseif(variable=="Immunity Mode") then
		self.Immunity = math.Clamp(value,-1,1);
		self:SetNWInt("Immunity",self.Immunity);
	end
end

--################################Think @ assassin21

function ENT:Think()
	if self.IsOn==true then
		local e = ents.FindInSphere(self:GetPos(), self.Radius);
			for _,v in pairs(e) do
				if v:IsPlayer() and v:GetMoveType() == MOVETYPE_NOCLIP then
					if (self.Immunity<0 or v != self.Owner) and not v:HasGodMode() then
						local allow = hook.Call("StarGate.AntiPrior.Noclip",nil,v,self);
						if (allow==false) then continue end
						v:SetMoveType(MOVETYPE_WALK)
					end
				end
			end
	end

	if self.IsOn==true then
		self.Entity:Fire("skin",1);
	else
		self.Entity:Fire("skin",0);
	end

	self.Entity:NextThink(CurTime() + 0.5)
	return true
end

-----------------------------------DUPLICATOR----------------------------------

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end
	if WireAddon then
		dupeInfo.WireData = WireLib.BuildDupeInfo( self.Entity )
	end

	dupeInfo.IsOn = self.IsOn;
	dupeInfo.Radius = self.Radius;

	duplicator.StoreEntityModifier(self, "AntiProriDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "AntiProriDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local dupeInfo = Ent.EntityMods.AntiProriDupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	if(Ent.EntityMods and Ent.EntityMods.AntiProriDupeInfo.WireData) then
		WireLib.ApplyDupeInfo( ply, Ent, Ent.EntityMods.AntiProriDupeInfo.WireData, function(id) return CreatedEntities[id] end)
	end

	self.IsOn = dupeInfo.IsOn;
	self.Radius = dupeInfo.Radius;

	self.Owner = ply;
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "anti_prior", StarGate.CAP_GmodDuplicator, "Data" )
end

-- shared hook not help for fix animation glitch it seems, so now again only server-side
hook.Add("PlayerNoClip", "AntiPrior.DisableNoclip", function(ply,noclip)
	if (noclip) then
		if (not IsValid(ply) or ply.HasGodMode and ply:HasGodMode()) then return end
		for k,v in pairs(ents.FindInSphere(ply:GetPos(),800)) do
			if (v:GetClass()=="anti_prior" and v.IsOn and (v.Immunity<0 or ply!=v.Owner) and not ply:HasGodMode()) then
				local allow = hook.Call("StarGate.AntiPrior.Noclip",nil,ply,v);
				if (allow==false) then continue end
				return false;
			end
		end
	end
end )

end

properties.Add( "AntiPrior.Immunity",
{
	MenuLabel	=	SGLanguage.GetMessage("antiprior_c_t"),
	Order		=	-170,
	MenuIcon	=	"icon16/plugin_link.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || ent:GetClass()!="anti_prior") then return false end
						if ( !gamemode.Call( "CanProperty", ply, "antipriormodify", ent ) ) then return false end
						return true

					end,

	MenuOpen = function( self, option, ent, tr )
		local submenu = option:AddSubMenu()
		local val = ent:GetNWInt("Immunity",0);
		local option = submenu:AddOption( SGLanguage.GetMessage("antiprior_c_1"), function() self:SetImmunity( ent, 0 ) end )
		if ( val == 0 ) then option:SetChecked( true ) end
		local option = submenu:AddOption( SGLanguage.GetMessage("antiprior_c_2"), function() self:SetImmunity( ent, 1 ) end )
		if ( val == 1 ) then option:SetChecked( true ) end
		local option = submenu:AddOption( SGLanguage.GetMessage("antiprior_c_3"), function() self:SetImmunity( ent, -1 ) end )
		if ( val == -1 ) then option:SetChecked( true ) end
	end,

	SetImmunity		=	function( self, ent, i )

						self:MsgStart()
							net.WriteEntity( ent )
							net.WriteInt(i,8)
						self:MsgEnd()

					end,

	Receive		=	function( self, length, player )

						local ent = net.ReadEntity()
						if ( !self:Filter( ent, player ) ) then return false end

						ent:TriggerInput("Immunity Mode",net.ReadInt(8));
					end

});