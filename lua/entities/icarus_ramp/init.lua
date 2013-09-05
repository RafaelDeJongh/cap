/*   Copyright 2012 by AlexALX   */

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

ENT.CDSIgnore = true;

function ENT:Initialize()
	if (WireAddon) then
   		self.Inputs = WireLib.CreateInputs( self.Entity, {"Activation Alarm","Smoke Mode","Lightning Mode","Make Lightning"});
    end
	self.Entity:SetModel("models/zsdaniel/icarus_ramp/icarus_ramp.mdl") ;
	self.Entity:PhysicsInit( SOLID_VPHYSICS ) ;
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS );
	self.Entity:SetSolid( SOLID_VPHYSICS );
	self.Entity:SetNetworkedBool("icarus_smoke",false);
	local phys = self.Entity:GetPhysicsObject();
	if (phys:IsValid()) then
	    phys:EnableMotion(false)
		phys:EnableGravity(true);
		phys:SetMass(1000);
		phys:Wake();
	end
	self.Entity:SetNWBool("icarus_smoke",false);
	self.irisclose = true;
	self.snd = "alarm/SGC_alarm.wav";
	self.nalarm = false;
	self.WireNormalAlarm = 0;
	self.FullEffects = false;
	self.WireSmoke = 0;
	self.WireLight = 0;
end

function ENT:SpawnFunction(p,t)
	if (!t.HitWorld) then return end;
	e = ents.Create("icarus_ramp") ;
	e:SetPos(t.HitPos + Vector(0,0,41));
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
	elseif (variable == "Smoke Mode") then
	    self.WireSmoke = value;
	elseif (variable == "Lightning Mode") then
	    self.WireLight = value;
	elseif (variable == "Make Lightning") then
		if (value==1 or value>3) then
	    	if (math.random(0,1)==1) then
				self:ActivateBeam(true);
	    	else
				self:ActivateBeam();
	    	end
	    elseif(value==2) then
			self:ActivateBeam();
	    elseif(value==3) then
			self:ActivateBeam(true);
	    end
	end
end

function ENT:OnRemove()
    if (self.Entity and self.Entity:IsValid()) then
	    self.Entity:Remove();
        self.Entity:SetNWBool("icarus_smoke",false);
	end
end

function ENT:EffectThink()
    if(IsValid(self.Gate) and self.WireLight>=0)then
        if(self.Gate.NewActive and (self.Gate.__LastChevron==8 and not self.Gate.__ChevronLocked or self.Gate.__LastChevron==9 or self.Gate.__LastChevron==-9 or self.WireLight==1 and (self.Gate.__ChevronLocked or self.Gate.__LastChevron<-6)) or self.WireLight>=2)then
			if (math.random(0,1)==1) then
				self:CreateBeam();
				if (math.random(0,1)==1) then
					timer.Simple(0.25,function()
						if (IsValid(self)) then
							self:CreateBeam();
						end
					end);
				end
			end
			if (self.FullEffects and math.random(0,1)==1) then
				timer.Simple(0.5,function()
					if (IsValid(self)) then
						self:CreateBeam();
					end
				end);
			end

			if (self.Gate.IsOpen and math.random(0,1)==1) then
				timer.Simple(0.75,function()
					if (IsValid(self)) then
						self:CreateBeam();
					end
				end);
			end

			if (math.random(0,3)==1) then
				timer.Simple(3.0,function()
					if (IsValid(self)) then
						self:CreateBeam();
					end
				end);
			end

			if (not self.FullEffects) then
				timer.Simple(1.5,function() if IsValid(self) then
					if (self.WireSmoke>=0) then
	    	    		self.Entity:SetNWBool("icarus_smoke",true);
	    	    	end
	    	    	self.FullEffects = true;
	    	  	end end);
    	  	else
    	  		if (self.WireSmoke>=2) then
    	  			self.Entity:SetNWBool("icarus_smoke",true);
    	  		elseif (self.WireSmoke<0) then
    	  			self.Entity:SetNWBool("icarus_smoke",false);
    	  		end
    	  	end
	    else
	    	if (self.Gate.NewActive and self.WireSmoke==1) then
				timer.Simple(1.0,function() if IsValid(self) then
    	    		self.Entity:SetNWBool("icarus_smoke",true);
    	  		end end);
	    	else
	    		if (self.WireSmoke>=2) then
	            	self.Entity:SetNWBool("icarus_smoke",true);
	    		else
	            	self.Entity:SetNWBool("icarus_smoke",false);
	            end
	  		end
	  		self.FullEffects = false;
	    end
	else
		self.FullEffects = false;
   		if (self.WireSmoke>=2) then
           	self.Entity:SetNWBool("icarus_smoke",true);
   		else
           	self.Entity:SetNWBool("icarus_smoke",false);
        end
	end
end

function ENT:Think()
    self:GateFinder();
    self:EffectThink()
	self:LowThink()
	self:NextThink(CurTime()+0.1);
	return true;
end

function ENT:ActivateBeam(right)
	local rnd_forw = math.random(-180,-200)
	local rnd_forw2 = math.random(-185,-195)

	local rnd_right = math.random(50,115)

	-- ugly, but havn't ideas how do this better
	local up,rm,dw = -225,12,-210;
	if (rnd_right>=110 and rnd_right<=115) then
		up,rm,dw = -205,15,-190;
	elseif (rnd_right>=105 and rnd_right<110) then
		up,rm,dw = -210,13,-200;
	elseif (rnd_right>=100 and rnd_right<105) then
		up,rm,dw = -215,10,-200;
	elseif (rnd_right>=95 and rnd_right<100) then
		up,rm,dw = -220,12,-205;
	elseif (rnd_right>=90 and rnd_right<95) then
		up,rm,dw = -225,11,-210;
	elseif (rnd_right>=85 and rnd_right<90) then
		up,rm,dw = -230,9,-210;
	elseif (rnd_right>=80 and rnd_right<85) then
		up,rm,dw = -235,8,-212;
	elseif (rnd_right>=75 and rnd_right<80) then
		up,rm,dw = -238,10,-217;
	elseif (rnd_right>=70 and rnd_right<75) then
		up,rm,dw = -242,10,-218;
	elseif (rnd_right>=60 and rnd_right<70) then
		up,rm,dw = -243,9,-220;
	elseif (rnd_right>=50 and rnd_right<60) then
		up,rm,dw = -247,7,-225;
	end

	local startpos = self.Entity:GetPos() + self.Entity:GetForward()*(rnd_forw) + self.Entity:GetRight()*(rnd_right) - self.Entity:GetUp()*(up)
	local endpos = self.Entity:GetPos() + self.Entity:GetForward()*(rnd_forw2) + self.Entity:GetRight()*(rnd_right-rm) - self.Entity:GetUp()*(dw)
	if (right) then
		startpos = self.Entity:GetPos() + self.Entity:GetForward()*(rnd_forw) + self.Entity:GetRight()*(rnd_right*(-1)) - self.Entity:GetUp()*(up)
		endpos = self.Entity:GetPos() + self.Entity:GetForward()*(rnd_forw2) + self.Entity:GetRight()*(rnd_right*(-1)-rm*(-1)) - self.Entity:GetUp()*(dw)
	end

	local fx = EffectData()
	fx:SetOrigin(startpos)
    fx:SetStart(endpos)
	util.Effect("icarus_zap", fx)
end

function ENT:CreateBeam()
	local rnd = math.random(0,4);
	if (rnd>=0 and rnd<=1) then
		self:ActivateBeam();
	elseif (rnd==2) then
		self:ActivateBeam();
		self:ActivateBeam(true);
	else
		self:ActivateBeam(true);
	end
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
    	if (self.Gate.NewActive or self.Gate.IsOpen or self.WireLight>=2) then
			self.Entity:SetSkin(1);
    	else
			self.Entity:SetSkin(0);
    	end
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
	if (IsValid(ply)) then
		if(ply:GetCount("CAP_anim_ramps")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(\"Anim ramps limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			self.Entity:Remove();
			return
		end
		ply:AddCount("CAP_anim_ramps", self.Entity)
	end
end