/*
	molecular construction device for GarrysMod10
	Copyright (C) 2010  Llapp
*/

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

ENT.Sounds = {
	Idle=Sound("tech/mcd_idle.wav"),
}

function ENT:Initialize()
	self.Entity:SetModel("models/MarkJaw/mcd/mcd.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid())then
		phys:EnableMotion(false);
		phys:SetMass(2000);
	end
	self.Create = false;
	self.InitCreate = true;
	self.Entity:SetNetworkedInt("EntProgress",0);
	self.EntProgress = 0;
	self.Progress = 0;
	self.Entity:SetNWInt("Progress",0);
	self.Undone = false;
	self.StartEffect = 0;
	self.Forw = true;
	self.molecular = 0;
	self.Mul = 0;
	self.Start = false;
	self.Player = nil;
	self.AdvanceTimer = 0;
	self.AtlSkin = false;
	self:SetUseType(SIMPLE_USE)

	if(self.HasWire) then
		self:CreateWireInputs("Alternative Skin")
		self:CreateWireOutputs("Active","Percent Completed", "Conscruction Complete")
	end
end

function ENT:TriggerInput(k,v)
	if (k=="Alternative Skin") then
		if (v>=1) then
			self.AtlSkin = true
    		if(self.Create)then
		        self.Entity:SetMaterial("MarkJaw/mcd/mcd_on_atl.vmt");
		  	else
		        self.Entity:SetMaterial("MarkJaw/mcd/mcd_atl.vmt");
		  	end
		else
			self.AtlSkin = false
    		if(self.Create)then
		        self.Entity:SetMaterial("MarkJaw/mcd/mcd_on.vmt");
		  	else
		        self.Entity:SetMaterial("MarkJaw/mcd/mcd.vmt");
		  	end
		end
	end
end

function ENT:SpawnFunction(p,t)
	if (not t.Hit) then return end

	if (IsValid(p)) then
		local PropLimit = GetConVar("CAP_mcd_max"):GetInt()
		if(p:GetCount("CAP_mcd")+1 > PropLimit) then
			p:SendLua("GAMEMODE:AddNotify(\"Gate Overloader limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			return
		end
	end

	local ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+90) % 360;
	local pos = t.HitPos+Vector(0,0,0);
	local e = ents.Create("molecular_construction_device");
	e:SetPos(pos);
	e:SetAngles(ang);
	e:DrawShadow(true);
	e:SetVar("Owner",p)
	e:Spawn();
	e:Activate();
	if (IsValid(p)) then
		p:AddCount("CAP_mcd", e)
	end
	return e;
end

function ENT:Use(ply)
    if(not self.Create)then
		umsg.Start("MolecularConstructionDevice",ply)
	    umsg.Entity(self.Entity);
	    umsg.End()
		self.Player = ply;
	end
end

function ENT:Think()
    if(self.Create)then
	    if(self.InitCreate)then
		    self.InitCreate = false;
		    if (self.AtlSkin) then
	        	self.Entity:SetMaterial("MarkJaw/mcd/mcd_on_atl.vmt");
		    else
	        	self.Entity:SetMaterial("MarkJaw/mcd/mcd_on.vmt");
	        end
			self.Entity:SetNWBool("IdleSound",true);
			local color = self.Ent:GetColor();
			local r,g,b,a = color.r,color.g,color.b,color.a;
			self.ColorR = r;
			self.ColorG = g;
			self.ColorB = b;
			self.Material = self.Ent:GetMaterial();
            self.Ent:SetColor(Color(247,51,12,0));
            self.Ent:SetParent(self.Entity);
            self.Ent:SetSolid(SOLID_NONE);
            self.Ent:DrawShadow(false);
			self.Ent:SetMaterial("Llapp/mcd_sheet.vmt"); --models/props_combine/portalball001_sheet    Llapp/mcd_sheet.vmt
			util.PrecacheSound("tech/mcd_spawn.wav");
		    self.Entity:EmitSound( "tech/mcd_spawn.wav", 100, 77 );
			if(self.HasWire) then
				self:SetWire("Active", 1)
			end
		else
		    self.EntProgress = self.Entity:GetNetworkedInt("EntProgress");
			self.Progress = self.Entity:GetNWInt("Progress");
			self.Progress = string.Explode(".",tostring(self.Progress))
			if(self.Progress[2] != nil)then
			    self.Progress = tonumber(self.Progress[1].."."..math.floor(self.Progress[2]))
			else
			    self.Progress = tonumber(self.Progress[1])
			end
			self.Entity:SetNWInt("Progress",self.Progress+0.02); -- 0.02
			local color = self.Ent:GetColor();
			local r,g,b,a = color.r,color.g,color.b,color.a;
			self.Ent:SetRenderMode( RENDERMODE_TRANSALPHA );
	        if(self.Progress < 255)then
			    if(self.EntProgress == self.Progress)then
				    if(self.Progress <= 175)then
                        self.Ent:SetColor(Color(r,g,b,a + 1));
					elseif(self.Progress >= 175 and self.Progress <= 254)then
					end
			    	self.Entity:SetNWInt("EntProgress",self.EntProgress+1);
			    end
	        end
			if(self.Progress >= 240)then
			    self.Entity:SetNWBool("StartEffects",false);
			    self.Start = false;
			end
			if(self.Progress >= 240.8)then
		        self.Ent:SetParent(nil);
				local distance = (self.Entity:GetPos() + self.Ent:GetPos()):Length()
				if(distance >= 32)then
			        self.Ent:SetPos(self.Ent:GetPos() - Vector(0,0,0.04))
				end
			    self.Ent:SetParent(self.Entity);
		    end
            if(self.Entity:GetNWInt("EntProgress") == 255)then
	            self.Ent:SetParent(nil);
				local effectdata = EffectData()
				effectdata:SetOrigin(self.Ent:GetPos())
			    util.Effect( "mcd_spawn", effectdata )
				util.PrecacheSound("tech/mcd_spawn.wav")
		        self.Entity:EmitSound( "tech/asgard_teleport.mp3", 100, 75 )
				timer.Simple(0.3,function()
				    if(self.Ent:IsValid())then
					    self.Ent:SetColor(Color(self.ColorR,self.ColorG,self.ColorB,255));
				        self.Ent:SetMaterial(self.Material);
					end
				end);
		        self.Ent:SetSolid(SOLID_VPHYSICS);
		        local phys = self.Ent:GetPhysicsObject();
	            if(phys:IsValid())then
		            phys:EnableMotion(true);
			        phys:Wake();
	            end
		        self.Create = false;
		        self.Entity:SetNWInt("EntProgress",0);
				self.Entity:SetNWInt("Progress",0);
		        self.Ent:DrawShadow(true);
		        self.InitCreate = true;
			end
		end
		if(self.Progress <= 240)then
		    local percent = (self.Progress/240)*100;
			self.AdvanceTimer = self.AdvanceTimer + 1;
			if(self.AdvanceTimer == 50 or percent == 100)then
			    self.Entity:SetNWInt("Advance",percent);
			    if(self.HasWire) then
					self:SetWire("Percent Completed", percent)
				end
				self.AdvanceTimer = 0;
			end
		end
		--##############################################################################
		y = y or 0;
		if(type(y)=="number" and y <= 360)then
		    y = y + 0.5;
		else
		    y = 0;
		end
		local ang = Angle(self.Entity:GetAngles().Pitch, self.Entity:GetAngles().Yaw + y, self.Entity:GetAngles().Roll)
        self.Ent:SetAngles(ang);
		self:ProgressIdle();
        --##############################################################################
	elseif(not self.Create and self.Undone)then
	    timer.Simple(6,function()
		    if(IsValid(self.Entity))then
		    	if (self.AtlSkin) then
		       		self.Entity:SetMaterial("MarkJaw/mcd/mcd_atl.vmt");
		    	else
		       		self.Entity:SetMaterial("MarkJaw/mcd/mcd.vmt");
		        end
				self.Entity:SetNWInt("Advance",0);
				self.Entity:SetNWBool("IdleSound",false);
				if(self.HasWire) then
					self:SetWire("Conscruction Complete", 0)
					self:SetWire("Percent Completed", 0)
					self:SetWire("Active", 0)
				end
			end
		end);
		local sequence = self.Entity:LookupSequence("idle");
        self.Entity:ResetSequence(sequence);
	    undo.Create(self.Object)
        undo.AddEntity(self.Ent)
        undo.SetPlayer(self.Player)
        undo.Finish()
        self.Ent.Create = false;
		self.Undone = false;
		self.Forw = true;
		self.AdvanceTimer = 0;
		if(self.HasWire) then
			self:SetWire("Conscruction Complete", 1)
		end
	end
	self.Entity:NextThink(CurTime()+0.01);
	return true;
end

function ENT:ProgressIdle()
	-- Damn you, sounds playing forever with this code
	/*sec = sec or 0
	sec = sec + 1
    if(sec==118)then --155, 77
		self.Entity:EmitSound(self.Sounds.Idle, 60, 100 )
        sec=0;
	end   */
	--self.IdleSound = self.IdleSound or CreateSound(self.Entity,self.Sounds.Idle);

end

util.AddNetworkString("MCD")

net.Receive("MCD",function(len,ply)
	local self = net.ReadEntity()
	if (not IsValid(self) or self.Player!=ply or self.Create) then return end

    local entities = {"tollan_disabler","cloaking_generator","shield_generator","jamming_device","tampered_zpm","zpm_mk3"}
    local class = net.ReadString()
    if (class=="zpm_mk3" and StarGate.CFG:Get("MCD","allow_tzmp",false)) then
    	local rnd = StarGate.CFG:Get("MCD","tzmp_chance",2);
    	if (rnd<1) then rnd = 1 end
    	local rand = math.random(1,rnd);
    	if (rand==1) then
 			class = "tampered_zpm";
 		end
    end
    local e = ents.Create(class);
    self.Undone = true;
    self.Object = class;
	e:SetPos(self.Entity:GetPos() + self.Entity:GetUp()*57);
	if(class == entities[1] or class == entities[2] or class == entities[3])then
		e:SetPos(self.Entity:GetPos() + self.Entity:GetUp()*58.2);
		e.Owner = self.Player;
	elseif(class == entities[5] or class == entities[6] or class == entities[7])then
		e:SetPos(self.Entity:GetPos() + self.Entity:GetUp()*62.9);
	end
	local model = net.ReadString()
    if(model != "")then
   	    e:SetModel(model);
    end
	e:SetParent(self.Entity);
	e:Spawn();
	e:SetAngles(self.Entity:GetAngles());
	self.Ent = e;
	self.Create = true;
	self.Start = true;
	self.Ent.Create = true;
	self.Entity:SetNWEntity("CreatingEntity",self.Ent);
	self.Entity:SetNWBool("StartEffects",true);
    if(class == entities[1] or class == entities[2] or class == entities[3] or class == entities[4])then
        local togglename;
        local size = net.ReadInt(16);
        local immunity = net.ReadBit();
        local phaseshifting = net.ReadBit();
        local strengh = net.ReadInt(16);
        local drawbubble = net.ReadBit();
        local passing = net.ReadBit();
        local containment = net.ReadBit();
        local key = net.ReadInt(16);
        local r,g,b = net.ReadInt(8),net.ReadInt(8),net.ReadInt(8);
        if(class == entities[1] or class == entities[4])then
		    e.Size = size;
   	        e.Immunity = util.tobool(immunity);
	        if(class == entities[1])then
		        togglename = "ToggleDisabler";
		    elseif(class == entities[4])then
		        togglename = "ToggleJamming";
		    end
			numpad.Register(togglename,function(ply,e)
				if(not IsValid(e) or e.Create) then return end;
				if(e.IsEnabled) then
					e.IsEnabled = false;
				else
					e.IsEnabled = true;
				end
			end);
	    elseif(class == entities[2] or class == entities[3])then
	        if(class == entities[2])then
		        togglename = "ToggleCloaking";
				e:SetVar("Owner",self.Player);
   	    		e.Size = size;
   	    		e.ImmuneOwner = util.tobool(immunity);
   	    		e.PhaseShifting = util.tobool(phaseshifting);
		    elseif(class == entities[3])then
		        togglename = "ToggleShield";
				e:SetVar("Owner",self.Player);
	            e.Size = tonumber(size);
   	            e.ImmuneOwner = util.tobool(immunity);
   	            e:SetMultiplier(strengh);
	            e:SetShieldColor(r/255,g/255,b/255);
   	            e.DrawBubble = util.tobool(drawbubble);
   	            e.PassingDraw = util.tobool(passing);
  		        e.Containment = util.tobool(containment);
		    end
			numpad.Register(togglename,function(ply,e)
				if(not IsValid(e) or e.Create) then return end;
				if(e:Enabled()) then
					e:Status(false);
				else
					e:Status(true);
				end
			end);
	    end
	    numpad.OnDown(self.Player,key,togglename,e);
    end

end);

function ENT:PostEntityPaste(player, Ent,CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local PropLimit = GetConVar("CAP_mcd_max"):GetInt()
	if(IsValid(player) and player:IsPlayer() and player:GetCount("CAP_mcd")+1 > PropLimit) then
		player:SendLua("GAMEMODE:AddNotify(\"MCD limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		self.Entity:Remove();
		return
	end
	player:AddCount("CAP_mcd", self.Entity)
	StarGate.WireRD.PostEntityPaste(self,player,Ent,CreatedEntities)
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "molecular_construction_device", StarGate.CAP_GmodDuplicator, "Data" )
end