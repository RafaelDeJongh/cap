/*
	Stargate Orlin for GarrysMod10
	Copyright (C) 2010  Llapp,Assassin21,aVoN
*/

--################# HEADER #################
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
--################# Include
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");
include("modules/dialling.lua");
--################# Defines
-- Models
ENT.Models = {
	Base="models/Iziraider/minigate/minigate.mdl",
}
-- Sounds
ENT.Sounds = {
	Gate=Sound("Stargate Orlin.wav"),
	Ring=Sound("stargate/universe/gate_roll.mp3"),
	Open=Sound("stargate/universe/gate_open.mp3"),
	Travel=Sound("stargate/gate_travel.mp3"),
	Close=Sound("stargate/universe/gate_close.mp3"),
	ChevronDHD=Sound("stargate/universe/chevron.mp3"),
	Inbound=Sound("stargate/universe/chevron.mp3");
	Lock=Sound("stargate/universe/chevron_lock.mp3"),
	LockDHD=Sound("stargate/universe/chevron.mp3"),
	Chevron={Sound("stargate/universe/chevron.mp3"),Sound("stargate/universe/chevron2.mp3")},
	Fail=Sound("stargate/dial_fail.mp3"),
	Flicker=Sound("stargate/orlin/gateflicker.wav"),
	OnButtonLock=Sound("stargate/stargate/dhd/dhd_usual_dial.wav"),
}
--################# SENT CODE ###############

--################# Init @assassin21,aVoN,Llapp
function ENT:Initialize()
	util.PrecacheModel(self.Models.Base);
	self.Entity:SetModel(self.Models.Base);
	--self.Entity:SetMaterial("Llapp/minigate/minigate")
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.BaseClass.Initialize(self); -- BaseClass Initialize call
	self.DeactivateGate = false;
	self.EHOpen = false;
	self.GateActive = false;
	self.Jamming = false;
	self.Entity:SetNetworkedInt("timer",0);
    self.Entity:SetNWInt("closetimer",0);
	self.Entity:SetNWInt("deactivetimer",0);
	self:IdleSound()
	self.Entity:SetSkin(0)
end

--#################  Called when stargate_group_system changed
function ENT:ChangeSystemType(groupsystem,reload)
	self:GateWireInputs(groupsystem);
	self:GateWireOutputs(groupsystem);
	if (groupsystem) then
		self:SetWire("Dialing Mode",-1);
		self:SetChevrons(0,0);
		self.WireCharters = "A-Z0-9@#";
	else
		self:SetWire("Dialing Mode",-1);
		self:SetChevrons(0,0);
		self.WireCharters = "A-Z1-9@#!";
	end
	if (reload) then
		StarGate.ReloadSystem(groupsystem);
	end
end

function ENT:GateWireInputs(groupsystem)
	self:CreateWireInputs("Dial Address","Dial String [STRING]","Dial Mode","Start String Dial","Close","Transmit [STRING]","Set Point of Origin","Disable Menu");
end

function ENT:GateWireOutputs(groupsystem)
	self:CreateWireOutputs("Active","Open","Chevron","Chevron Locked","Earth Point of Origin","Dialing Address [STRING]","Dialing Mode","Received [STRING]");
end

function ENT:WireOrigin()
	self:SetWire("Earth Point of Origin",self:IsConceptDHD());
end

--################# @Llapp
function ENT:SpawnFunction(p,t)
	if (not t.Hit) then return end
	local ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;
	local pos = t.HitPos+Vector(0,0,57);
	local e = ents.Create("ramp");
	e:SetModel("models/ZsDaniel/minigate-ramp/ramp.mdl");
	e:SetPos(pos);
	e:DrawShadow(true);
	e:Spawn();
	e:Activate();
	e:SetAngles(ang);
	self.Ramp = e;
	local phys = e:GetPhysicsObject();
	if(phys and phys:IsValid())then
		phys:EnableMotion(false);
	end
	local e = ents.Create("stargate_orlin");
	e:SetPos(pos);
	e:DrawShadow(true);
	e:Spawn();
	e:Activate();
	e:SetPrivate(true);
	e:SetGateName("Stargate Orlin");
	e:SetGateGroup("M@");
	--e:SetGateAddress("ORLIN0")
	e:SetAngles(ang);
	e:SetWire("Dialing Mode",-1);
	constraint.NoCollide(self.Ramp,e,0,0);
	--timer.Simple(0.5,function()
	    constraint.Weld(self.Ramp,e,0,0,0,true);
	--end);
	local phys = e:GetPhysicsObject();
	if(phys and phys:IsValid())then
		phys:EnableMotion(true);
	end
	return e;
end

--################# @Llapp, sound file by Assassin21
function ENT:GateSound()
	self.ActiveSound = util.PrecacheSound(self.Sounds.Gate);
    self.ActiveSound = CreateSound(self.Entity, Sound(self.Sounds.Gate));
    self.ActiveSound:Play();
	self.ActiveSound:ChangeVolume(100,0.1);
end

--################# @Llapp
function ENT:IdleSound()
	self.IdleSound = util.PrecacheSound("stargate/supergate/chevron.mp3");
    self.IdleSound = CreateSound(self.Entity, Sound("stargate/supergate/chevron.mp3"));

end

--################# @Llapp
function ENT:Sparks()
	local pos = Vector(3.7, 0, 45);
	local rand = math.random(1,7);
	if(rand==1)then
        pos = Vector(3.7, 0, 45);
	elseif(rand==2)then
        pos = Vector(3.7, 36.5, 26.5);
	elseif(rand==3)then
        pos = Vector(3.7, 43, -14);
	elseif(rand==4)then
        pos = Vector(3.7, 20.6, -40.5);
	elseif(rand==5)then
        pos = Vector(3.7, -20, -40.5);
	elseif(rand==6)then
        pos = Vector(3.7, -43, -14.5);
	elseif(rand==7)then
        pos = Vector(3.7, -36.5, 26.1);
	end
	local rang = math.random(-45,45);
	self.SparkEnt:SetPos(self.Entity:LocalToWorld(pos));
	self.SparkEnt:SetAngles(self.Entity:GetAngles()+Angle(rang,rang,0));
	self.SparkEnt:Fire("SparkOnce", "", 0);
    self.SparkEnt:Fire("StartSpark", "", 0);
end

--################# @Llapp
function ENT:LowThink()
    local tim = CurTime();
    if(self.Entity.IsOpen)then
		if(self.Entity:GetNetworkedInt("timer")==0)then
		    self.Entity:SetNWInt("timer",math.Round(tim)+50);
			self.Entity:SetNWInt("closetimer",math.Round(tim)+60);
			self.DeactivateGate = true;
			self.GateActive = true;
			self:JammingGates(true);
		end
        if(tim >= self.Entity:GetNWInt("closetimer"))then
		    self:JammingGates(false);
		    self.Entity:AbortDialling();
		end
	else
	    if(self.DeactivateGate == true)then
		    if(self.Entity:GetNWInt("deactivetimer")==0)then
		        self.Entity:SetNWInt("deactivetimer",math.Round(tim)+60);
				self.Entity:SetNWInt("timer",0);
		        self.Entity:SetNWInt("closetimer",0);
				self:JammingGates(true);
				timer.Simple(0.2,function()
			        self.Entity:EmitSound(self.Sounds.Fail,90,math.random(130,150));
				end)
			end
			if(tim >= self.Entity:GetNWInt("deactivetimer"))then
		        self.DeactivateGate = false;
		        self.Entity:SetNWInt("deactivetimer",0);
		        self.Entity:EmitSound("weapons/staff_engage.mp3",90,math.random(230,250));
				self:JammingGates(false);
	        end
		end
		if(self.GateActive == true)then
	        local ran = math.random(0,1);
		    if(ran == 1)then
	            self:Sparks();
			    timer.Simple(0.1, function()
			    	if (IsValid(self.SparkEnt)) then
		            	self.SparkEnt:Fire("StopSpark", "", 0);
		            end
			    end);
		    end
	        timer.Simple(5,function()
	            self.GateActive = false;
	        end);
	    end
	end
end

--################# @Llapp
function ENT:Think()
	if (not IsValid(self)) then return false end;

    local tim = CurTime();
	local number = 0;
    if(self.Entity.Active) then
	    if(not self.Entity.IsOpen)then
            number = 20;
		elseif(tim < self.Entity:GetNWInt("timer") and self.Entity.IsOpen)then
	        number = 100;
	        if(self.EHOpen == false)then
	            timer.Simple(2,function() self.EHOpen = true; end);
		    end
		elseif(tim >= self.Entity:GetNWInt("timer") and self.Entity.IsOpen)then
            number = 10;
	    end
	    self.Entity:SetNWBool("smoke",true);
		self.Entity:SetSkin(1);
		for i=1,7 do
            self.Entity:SetNWBool("chevron"..i,true);
		end
        for i=1,7 do
		    if(math.random(1,number)==number)then
		        for i=1,7 do
                    self.Entity:SetNWBool("chevron"..i,false);
		        end
			    if(IsValid(self.Entity.Target) and IsValid(self.Entity.Target.EventHorizon) and IsValid(self.Entity) and IsValid(self.Entity.EventHorizon) and self.EHOpen)then
					self.EventHorizon:SetMaterial("sgorlin/effect_shock.vmt");
					self.EventHorizon.Unstable = true;
					self.EventHorizon:BufferEmpty();
					if(self.Target.Entity:GetClass() == "stargate_universe") then
					    self.Target.EventHorizon:SetMaterial("sgu/effect_shock.vmt");
					elseif(self.Target.Entity:GetClass() == "stargate_infinity") then
					  	self.Target.EventHorizon:SetColor(Color(255,255,255,math.random(55,165)));
					  	self.Target.EventHorizon:SetNWBool("Flicker",true);
					else
						self.Target.EventHorizon:SetMaterial("sgorlin/effect_shock.vmt");
					end
					self.Target.EventHorizon.Unstable = true;
					self.Target.EventHorizon:BufferEmpty();
		            self.Entity.Target:EmitSound(self.Sounds.Flicker,90,math.random(97,103));
					--self.Flicker = util.PrecacheSound(self.Sounds.Flicker);
                   -- self.Flicker = CreateSound(self.Entity, Sound(self.Sounds.Flicker));
					--self.Flicker:PlayEx(1, 200)
                    --self.Flicker:Play();
	                --self.Flicker:ChangeVolume(100);
					--self.Flicker = util.PrecacheSound(self.Sounds.Flicker);
                    --self.Flicker = CreateSound(self.Entity.Target, Sound(self.Sounds.Flicker));
					--self.Flicker:PlayEx(1, 200)
                    --self.Flicker:Play();
	                --self.Flicker:ChangeVolume(100);
					--self.Entity:EmitSound("stargate/orlin/gate_flicker.mp3",90,math.random(110,120));
					--self.Entity.Target:EmitSound("stargate/orlin/gate_flicker.mp3",90,math.random(110,120));
		        end
		        self:Sparks();
		        timer.Simple(0.1, function()
		        	if (not IsValid(self.Entity)) then return end
				    self.Entity:SetSkin(0);
	                for i=1,7 do
	                    if(IsValid(self.Entity))then
                            self.Entity:SetNWBool("chevron"..i,true);
		                    self.SparkEnt:Fire("StopSpark", "", 0);
		                end
	                end
					timer.Simple(0.2,function()
		                if(IsValid(self.Target) and IsValid(self.Target.EventHorizon) and IsValid(self.Entity) and IsValid(self.Entity.EventHorizon) and self.EHOpen)then
				            --self.Entity.EventHorizon:SetColor(255,255,255,255);
			                --self.Entity.Target.EventHorizon:SetColor(255,255,255,255);
							self.EventHorizon:SetMaterial("sgorlin/effect_02.vmt");
							self.EventHorizon.Unstable = false;
							if(self.Target.Entity:GetClass() == "stargate_universe")then
								self.Target.EventHorizon:SetMaterial("sgu/effect_02.vmt");
							elseif(self.Target.Entity:GetClass() == "stargate_infinity")then
								self.Target.EventHorizon:SetColor(Color(255,255,255,255));
								self.Target.EventHorizon:SetNWBool("Flicker",false);
							else
								self.Target.EventHorizon:SetMaterial("sgorlin/effect_02.vmt");
							end
							self.Target.EventHorizon.Unstable = false;
    		            end
		            end);
	            end);
		    end
	    end
	else
	    self.EHOpen = false;
	    if(self.ActiveSound!=nil)then
	        self.ActiveSound:Stop();
		end
        self.Entity:SetNWBool("smoke",false);
		for i=1,7 do
		    self.Entity:SetSkin(0);
            self.Entity:SetNWBool("chevron"..i,false);
			self.SparkEnt:Fire("StopSpark", "", 0);

		end
	end
	self:LowThink();
end

--################# @Llapp
function ENT:JammingGates(bool)
    if(bool==true)then
	    if(self.Jamming == false)then
		    self.Jamming = true;
            for i=1,2 do
                local gate = nil;
                if(i==1)then
                    gate = self.Entity
                elseif(i==2)then
			        if(IsValid(self.Entity.Target))then
                        gate = self.Entity.Target;
				    else
				        return false;
				    end
                end
                function DummyFunction(...)
                    return false;
                end
                gate.backups = {}
                gate.backups.AcceptInput = gate.AcceptInput;
                gate.AcceptInput = DummyFunction;
                --gate.backups.Use = gate.Use;
                gate.backups.EmergencyShutdown = gate.EmergencyShutdown;
                gate.EmergencyShutdown = DummyFunction;
                gate.backups.DeactivateStargate = gate.DeactivateStargate;
                gate.DeactivateStargate = DummyFunction;
                gate.backups.Close = gate.Close;
                gate.Close = DummyFunction;
                gate.backups.ActivateStargate = gate.ActivateStargate;
                gate.ActivateStargate = DummyFunction;
                gate.backups.Open = gate.Open;
                gate.Open = DummyFunction;
                gate.backups.auto_close = gate.auto_close;
                gate.auto_close = false;
                gate.jammed = true;
			end
        end
	else
	    if(self.Jamming == true)then
	        for i=1,2 do
			    self.Jamming = false;
		        local gate = nil;
                if(i==1)then
                    gate = self.Entity;
                elseif(i==2)then
                    if(IsValid(self.Entity.Target))then
                        gate = self.Entity.Target;
				    else
				        return false;
				    end
                end
		        gate.AcceptInput = gate.backups.AcceptInput;
                --gate.Use = gate.backups.Use;
                gate.EmergencyShutdown = gate.backups.EmergencyShutdown;
                gate.DeactivateStargate = gate.backups.DeactivateStargate;
                gate.Close = gate.backups.Close;
                gate.ActivateStargate = gate.backups.ActivateStargate;
                gate.Open = gate.backups.Open;
                gate.auto_close = gate.backups.auto_close;
                gate.jammed = false;
			end
		end
	end
end

--################# @Llapp,aVoN
function ENT:OnRemove()
	StarGate.StopUpdateGateTemperatures(self);
	if timer.Exists("LowPriorityThink"..self:EntIndex()) then timer.Remove("LowPriorityThink"..self:EntIndex()) end
	if timer.Exists("ConvarsThink"..self:EntIndex()) then timer.Remove("ConvarsThink"..self:EntIndex()) end
    self:JammingGates(false);
	self:Close();
	self:StopActions();
	self:DHDDisable(0);
	if(IsValid(self.Entity.Target)) then
		if(self.Entity.IsOpen) then
			self.Entity.Target:DeactivateStargate(true);
		elseif(self.Entity.Dialling) then
			self.Entity.Target:EmergencyShutdown(true);
		end
	end
	if(IsValid(self.Ramp))then
	    self.Ramp:Remove();
	end
	if (self.HasRD) then StarGate.WireRD.OnRemove(self) end;
	self:RemoveGateFromList();
end

function ENT:Shutdown() end -- Not needed but added for example. It is called at the end of ENT:Close or ENT.Sequence:DialFail

function ENT:Open()
	local e = ents.Create("event_horizon");
	e:SetPos(self.Entity:GetPos());
	e:SetAngles(self.Entity:GetAngles());
	e:SetParent(self.Entity);
	-- Set another sound to the gate (must be done before spawning it)
	if(self.Sounds and self.Sounds.Open) then
		e.Sounds.Open = self.Sounds.Open;
	end
   	e:Spawn();
	e:Activate();
	if(self.Outbound) then e:SetTarget(self.Target) end;  -- We tell the Eventhorizon the GATE (not the EH of the gate) where to find the EH of this gate
	if(IsValid(self.EventHorizon)) then self.EventHorizon:Remove() end; -- WORKAROUND for the EH-Stay bug: New EH's will definitely override the old!
	self.EventHorizon = e;
	constraint.NoCollide( e, self.Entity, 0, 0 );
end

function ENT:DialGate(address,mode)
	local allow_override_dial = false;
	-- Someone dials in. Are we getting dialled slowly? If yes, allow dialling out (and abort the dial-in)
	if(not self.Outbound and not self.Active and IsValid(self.Target)) then
		allow_override_dial = false;
	end
	 -- We can't dial again while we already dial!
	if(not allow_override_dial and (self.Dialling or self.IsOpen)) then return end;
	if(not mode) then mode = true end;

	-- I hope this fixes issues the EH staying open
	if(IsValid(self.EventHorizon)) then
		if(self.IsOpen or self.Dialling) then return end; -- We are opened or dialling - Do not allow additional dialling.
		self.EventHorizon:Remove(); -- Remove the EH. We neither are dialling, nor we are opened so it's a bug and the EH stood. Remove it now immediately!
	end
	-- Do we override this dial-in?
	if(allow_override_dial) then
		self.Target:AbortDialling();
	end
	self:SetAddress(address);
	self:SetDialMode(false,true); -- mode
	self:StartDialling();
end

--#################  Use - Open the Dial Menu @aVoN
function ENT:Use(p)
	if self.Jamming then return end;
	if(IsValid(p) and p:IsPlayer()) then
		if(hook.Call("StarGate.Player.CanDialGate",GAMEMODE,p,self.Entity) == false) then return end; -- Not allowed to dial!
		local dialog = "StarGate.OpenDialMenuDHDGate_Group";
		if(hook.Call("StarGate.Player.CanModifyGate",GAMEMODE,p,self.Entity) == false) then
			dialog = "StarGate.OpenDialMenuDHD_Group"; -- He is not allowed to modify stuff, so show him the normal dialling dialoge!
		elseif(self.GateSpawnerProtected) then -- It's a protected gate. Can this user change it?
			local allowed = hook.Call("StarGate.Player.CanModifyProtectedGate",GAMEMODE,p,self.Entity);
			if(allowed == nil) then allowed = (p:IsAdmin() or game.SinglePlayer()) end;
			if(not allowed) then
				dialog = "StarGate.OpenDialMenuDHD_Group";
			end
		end
		if (not GetConVar("stargate_group_system"):GetBool()) then
			dialog = "StarGate.OpenDialMenuDHD_Galaxy";
		end
		umsg.Start(dialog,p);
		umsg.Entity(self.Entity);
		umsg.End();
		self.LastUse = time;
	end
end

--################# DialFail sequence @aVoN
function ENT.Sequence:DialFail(instant_stop,play_sound)
	local action = self:New();
	local delay = 1.5;
	if(instant_stop) then delay = 0 end;
	action:Add({f=self.SetStatus,v={self,false,true,true},d=0}); -- We need to keep in "dialling" mode to get around with conflicts
	action:Add({f=self.SetShutdown,v={self,true},d=0});
	if(self.Entity.Active or play_sound) then
		action:Add({f=self.EmitSound,v={self.Entity,self.Sounds.Fail,90,math.random(130,150)},d=0});-- Fail sound
	end
	action:Add({f=self.DHDDisable,v={self,1.5,true},d=delay});-- Shutdown EVERY DHD
	action:Add({f=self.ActivateRing,v={self,false},d=0}); -- Deactivate ring (if existant);
	-- Stop all chevrons (if active only!)
	if(self.Entity.Active or play_sound) then
		for i=1,9 do
			action:Add({f=self.ActivateChevron,v={self,i,false},d=0});
		end
	end
	if(self.Shutdown) then
		action:Add({f=self.Shutdown,v={self},d=0});
	end
	action:Add({f=self.SetWire,v={self,"Dialing Address",""},d=0}); -- Wire
	action:Add({f=self.SetStatus,v={self,false,false},d=0.8}); -- Make the Wire-Value of "-7" = dial-fail stay longer so people's script work along with the sound
	action:Add({f=self.SetWire,v={self,"Chevron",0},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Chevron Locked",0},d=0}); -- Wire
	action:Add({f=self.SetShutdown,v={self,false},d=0});
	return action;
end