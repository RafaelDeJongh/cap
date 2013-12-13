/*
	Kawoosh hurt entity
	Copyright (C) 2012  by AlexALX
*/

ENT.Type = "point"
ENT.Base = "base_entity"
ENT.PrintName = "Kawoosh"
ENT.Author = "AlexALX"
ENT.Spawnable = false
ENT.AdminSpawnable = false

if SERVER then

--################# HEADER #################
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end
AddCSLuaFile();

ENT.CAP_NotSave = true;
ENT.NotTeleportable = true;
ENT.NoDissolve = true;
ENT.CDSIgnore = true; -- CDS Immunity
function ENT:gcbt_breakactions() end; ENT.hasdamagecase = true; -- GCombat invulnarability!

function ENT:KeyValue( key, value )
	if ( key == "Damage" ) then
		self.Damage = value;
	elseif ( key == "DamageType" ) then
		self.DamageType = value;
	elseif ( key == "DamageRadius" ) then
		self.Radius = value;
	end
end

function ENT:Initialize()
	self.Radius = self.Radius or 0;
	self.Damage = self.Damage or 0;
	self.DamageType = self.DamageType or 0;
end

function ENT:AcceptInput( name, activator, caller, data )
    if (name == "hurt") then
		-- damage
		local dmginfo = DamageInfo()
		dmginfo:SetDamage( self.Damage )
		dmginfo:SetDamageType( self.DamageType )
		dmginfo:SetAttacker( self.Entity )
		dmginfo:SetInflictor( self.Entity )
		dmginfo:SetDamageForce( Vector( 0, 0, 1000 ) )

		local parent = self.Entity:GetParent();

		for _,v in pairs(ents.FindInSphere(self.Entity:GetPos(),self.Radius)) do
			if (IsValid(v)) then
				if(not (parent.Attached[v] or v.GateSpawnerSpawned or v.NoDissolve)) then
					if (constraint.HasConstraints(v)) then
						local entities = StarGate.GetConstrainedEnts(v,2);
						local cont = false;
						if(entities) then
							for c,b in pairs(entities) do
								if(b:IsWorld()) then
									cont = true;
									break;
								end
							end
						end
						if (cont) then continue end
					end
					if(not parent.Attached[v:GetParent()] and not parent.Attached[v:GetDerive()]) then
						v:TakeDamageInfo(dmginfo);
					end
				end
			end
		end
    elseif (name == "kill") then
        self.Entity:Remove();
    end
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.PrintName = SGLanguage.GetMessage("kawoosh_hurt");
language.Add("kawoosh_hurt",SGLanguage.GetMessage("kawoosh_hurt"))
end

if(file.Exists("materials/VGUI/weapons/kawoosh_hurt_killicon.vmt","GAME")) then
	killicon.Add("kawoosh_hurt","VGUI/weapons/kawoosh_hurt_killicon",Color(255,255,255));
end

end