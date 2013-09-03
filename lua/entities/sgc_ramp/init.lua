/*   Copyright (C) 2010 by Llapp   */

if (not StarGate.CheckModule("extra")) then return end
include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

ENT.CDSIgnore = true;

function ENT:Initialize()
	if (WireAddon) then
   		self.Inputs = WireLib.CreateInputs( self.Entity, {"Activation Alarm", "Smoke"});
    end
	self.Entity:SetModel("models/Zup/ramps/sgc_ramp.mdl") ;
	self.Entity:PhysicsInit( SOLID_VPHYSICS ) ;
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS );
	self.Entity:SetSolid( SOLID_VPHYSICS );
	self.Entity:SetNetworkedBool("sgc_smoke",false);
	local phys = self.Entity:GetPhysicsObject();
	if (phys:IsValid()) then
	    phys:EnableMotion(false)
		phys:EnableGravity(true);
		phys:SetMass(1000);
		phys:Wake();
	end
	self.Entity:SetNWBool("sgc_smoke",false);
	self.irisclose = true;
	self.snd = "alarm/SGC_alarm.wav";
	self.nalarm = false;
	self.WireSmoke = 0;
	self.WireNormalAlarm = 0;
end

function ENT:SpawnFunction(p,t)
	if (!t.HitWorld) then return end;
	e = ents.Create("sgc_ramp") ;
	e:SetPos(t.HitPos + Vector(0,0,148));
	ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;
	e:SetAngles(ang);
	e:DrawShadow(true);
	self.Ramp = e;
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:TriggerInput(variable, value)
	if (variable == "Activation Alarm") then
	    self.WireNormalAlarm = value;
	elseif (variable == "Smoke") then
	    self.WireSmoke = value;
	end
end

function ENT:OnRemove()
    if (self.Entity and self.Entity:IsValid()) then
	    self.Entity:Remove();
        self.Entity:SetNWBool("sgc_smoke",false);
		timer.Stop("sgcs");
		timer.Destroy("sgcs");
	end
end

function ENT:SmokeThink()
    if(IsValid(self.Gate) and self.WireSmoke>=0)then
        if(self.Gate.IsOpen or self.Gate.NewActive or self.WireSmoke>0)then
    	    self.Entity:SetNWBool("sgc_smoke",true);
	    else
	        timer.Simple(3,function()
	    	    if(IsValid(self.Entity))then
		            self.Entity:SetNWBool("sgc_smoke",false);
		        end
		    end);
	    end
	else
	    self.Entity:SetNWBool("sgc_smoke",false);
	end
end

function ENT:Think()
    self:GateFinder();
    self:SmokeThink()
	self:LowThink()
	self:NextThink(CurTime()+0.1);
	return true;
end

function ENT:GateFinder()
	for _,v in pairs(StarGate.GetConstrainedEnts(self.Entity,2) or {}) do
		if(IsValid(v) and v:GetClass():find("stargate_*")) then
		    self.Gate = v;
		end
	end
end

function ENT:LowThink()
    if(IsValid(self.Gate))then
    	if((self.Gate.Active and self.WireNormalAlarm==1 or self.WireNormalAlarm>1) and self.nalarm==false)then
	        local snd = self.snd;
	        local parsedsound = snd:Trim();
	   	    util.PrecacheSound(parsedsound);
	        self.NormalAlarm = parsedsound;
	        self.SND = CreateSound(self.Entity, Sound(self.NormalAlarm));
	    	self:AlarmSound(true)
	    	self.nalarm = true;
	    elseif((self.WireNormalAlarm<=0 or not self.Gate.Active and self.WireNormalAlarm<=1) and self.nalarm==true)then
	        self:AlarmSound(false)
	    	self.nalarm = false;
	    end
	end
end

function ENT:AlarmSound(alarm)
    if(alarm)then
        self.SND:Play();
		self.SND:ChangeVolume(100,0.1);
    else
        self.SND:Stop();
    end
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable("anim_ramps",ply,"tool") ) then self.Entity:Remove(); return end
	local PropLimit = GetConVar("sbox_maxanim_ramps"):GetInt()
	if(ply:GetCount("CAP_anim_ramps")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Anim ramps limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		self.Entity:Remove();
		return
	end
	ply:AddCount("CAP_anim_ramps", self.Entity)
end