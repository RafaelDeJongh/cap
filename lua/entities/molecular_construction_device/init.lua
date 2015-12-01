/*
	molecular construction device for GarrysMod10
	Copyright (C) 2010  Llapp, AlexALX
*/

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

ENT.Sounds = {
	Idle=Sound("tech/mcd_idle.wav"),
}

local shield_model = "models/micropro/shield_gen.mdl";
-- local server-size table with all needed information 
local MCDEntities = {
	["tollan_disabler"] = {
		["model"] = "models/iziraider/disabler/disabler.mdl",
		["stop"] = 35.2,
		["pos"] = 58.2,
	},
	["cloaking_generator"] = {
		["model"] = shield_model,
		["check"] = "stargate_cloaking",
		["pos"] = 58.2,
	},
	["shield_generator"] = {
		["model"] = shield_model,
		["check"] = "stargate_shield",
		["pos"] = 58.2,
	},
	["jamming_device"] = {
		["model"] = shield_model,
		["check"] = "jamming",
	},
	["zpm_mk3"] = {
		["stop"] = 40.5,
		["pos"] = 62.9,
	},
	["arthur_mantle"] = {
		["type"] = "ent",
		["stop"] = 34.2,
	},
	["telchak"] = {
		["type"] = "ent",
		["stop"] = 34.2,
	},
	["naquadah_generator"] = {
		["check"] = "naq_gen_mks",
		["stop"] = 33,
	},
	["replicator"] = {
		["model"] = "models/pg_props/pg_stargate/pg_replicator.mdl",
	},
	["fnp90"] = {
		["model"] = "models/boba_fett/p90/w_smg_p90.mdl",
		["type"] = "swep",
	},
	["weapon_zat"] = {
		["model"] = "models/w_zat.mdl",
		["type"] = "swep",
		["stop"] = 36,
	},
	["weapon_asura"] = {
		["model"] = "models/micropro/asuragun/w_asugun/w_asugun.mdl",
		["type"] = "swep",
		["stop"] = 38,
	},
	["sg_medkit"] = {
		["model"] = "models/pg_props/pg_weapons/pg_healthkit_w.mdl",
		["type"] = "swep",
		["stop"] = 35.2,
	},
	["naquadah_bottle"] = {},
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
	
	self.EffDColor = Color(247,51,12,0);
	self.EffColor = self.EffDColor;
	self:SetNWVector("EffColor",Vector(self.EffColor.r,self.EffColor.g,self.EffColor.b));
	
	self.Speed = StarGate.CFG:Get("mcd","speed",100)/100;
	self.CheckRights = StarGate.CFG:Get("mcd","check_rights",true);

	if(self.HasWire) then
		self:CreateWireInputs("Alternative Skin","Effect Color [VECTOR]","Class Name [STRING]","Create")
		self:CreateWireOutputs("Active","Creation Class [STRING]","Percent Completed", "Conscruction Complete")
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
	elseif (k=="Effect Color") then
		if (v==Vector()) then 
			self.EffColor = self.EffDColor;
		else 
			self.EffColor = Color(math.Clamp(v.x,0,255),math.Clamp(v.y,0,255),math.Clamp(v.z,0,255)); 
		end
		self:SetNWVector("EffColor",Vector(self.EffColor.r,self.EffColor.g,self.EffColor.b));
		if (IsValid(self.Ent)) then self.Ent:SetColor(self.EffColor); end
	elseif (k=="Class Name") then
		if (v!="") then self.CreateClass = v;
		else self.CreateClass = nil; end
	elseif (k=="Create" and v>0) then
		if (self.CreateClass and IsValid(self.Owner)) then
			self:StartCreate(self.CreateClass,self.Owner);
		end
	end
end

function ENT:SpawnFunction(p,t)
	if (not t.Hit) then return end

	if (IsValid(p)) then
		local PropLimit = GetConVar("CAP_mcd_max"):GetInt()
		if(p:GetCount("CAP_mcd")+1 > PropLimit) then
			p:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"entity_limit_mcd\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
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
	e.Owner = p;
	if (IsValid(p)) then
		p:AddCount("CAP_mcd", e)
	end
	return e;
end

function ENT:Use(ply)
    if(not self.Create and self.Forw)then
		net.Start("MCD")
	    net.WriteEntity(self.Entity);
		local classes = {}
		for k,v in pairs(MCDEntities) do
			if (k=="replicator") then continue end
			local pl = ply
			if (not self.CheckRights) then pl = nil end
			if (not StarGate.NotSpawnable(v.check or k,pl,v.type or "tool",true)) then
				classes[k] = true;
			end
		end
		net.WriteTable(classes)
	    net.Send(ply)
		self.Player = ply;
	end
end

function ENT:Think()
    if(self.Create)then
    	if (not IsValid(self.Ent)) then
    		self.Create = false;
		    self.Entity:SetNWInt("EntProgress",0);
			self.Entity:SetNWInt("Progress",0);
		    self.InitCreate = true;
		    return
    	end
	    if(self.InitCreate)then
		    self.InitCreate = false;
			self.Forw = false;
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
            self.Ent:SetColor(self.EffColor);
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
			self.Entity:SetNWInt("Progress",math.Clamp(self.Progress+(0.02*self.Speed),0,255)); -- 0.02
			local color = self.Ent:GetColor();
			local r,g,b,a = color.r,color.g,color.b,color.a;
			self.Ent:SetRenderMode( RENDERMODE_TRANSALPHA );
	        if(self.Progress < 254)then
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
				local distance = (self.Entity:GetPos() - self.Ent:GetPos()):Length()
				if(distance >= self.Ent._MCDSTOP)then
			        self.Ent:SetPos(self.Entity:GetPos() + self.Entity:GetUp()*self.Ent._MCDUP)
					self.Ent._MCDUP = self.Ent._MCDUP - 0.04;
				elseif (self.Progress==255) then
					self.EntProgress = 255;
					self.Entity:SetNWInt("EntProgress",self.EntProgress);
				end
			    self.Ent:SetParent(self.Entity);
		    end
            if(self.Entity:GetNWInt("EntProgress") == 255)then
	            self.Ent:SetParent(nil);
				self.Entity:SetNWBool("IdleSound",false);
				if (self.Ent._MCDTampered) then
					local e = ents.Create("tampered_zpm");
					e:SetPos(self.Ent:GetPos());
					e:Spawn();
					e:SetAngles(self.Ent:GetAngles());
					e:SetParent(self.Entity);
					if CPPI and IsValid(self.Owner) and e.CPPISetOwner then e:CPPISetOwner(self.Owner) end
					self.Ent:Remove();
					self.Ent = e;
				end	
				if (self.MCD_RealClass!=nil) then
					local e = ents.Create(self.MCD_RealClass);
					e:SetPos(self.Ent:GetPos());
					e:SetModel(self.Ent:GetModel());
					e:Spawn();
					e:SetAngles(self.Ent:GetAngles());
					e:SetParent(self.Entity);
					if CPPI and IsValid(self.Owner) and e.CPPISetOwner then e:CPPISetOwner(self.Owner) end
					self.Ent:Remove();
					self.Ent = e;
				end
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
				self.Ent:SetParent(NULL);
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
		if (self.Create) then
			self.y = self.y or 0;
			if(type(self.y)=="number" and self.y <= 360)then
				self.y = self.y + 0.5;
			else
				self.y = 0;
			end
			--local ang = Angle(self.Entity:GetAngles().Pitch, self.Entity:GetAngles().Yaw + self.y, self.Entity:GetAngles().Roll)
			self.Ent:SetLocalAngles(Angle(0,self.y,0));
			self:ProgressIdle();
		end
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
				self.Ent = nil;
				self.Forw = true;
				if(self.HasWire) then
					self:SetWire("Conscruction Complete", 0)
					self:SetWire("Percent Completed", 0)
					self:SetWire("Active", 0)
					self:SetWire("Creation Class","")
				end
			end
		end);
		local sequence = self.Entity:LookupSequence("idle");
        self.Entity:ResetSequence(sequence);
		if (IsValid(self.Ent)) then
			local class = self.Ent:GetClass();
			if (class=="naquadah_generator") then class = "naq_gen_mks"; end
			undo.Create(class)
			undo.AddEntity(self.Ent)
			undo.SetPlayer(self.Player)
			undo.Finish()
			self.Ent.Create = false;
			self.Ent._MCDUP = nil;
			self.Ent._MCDTampered = nil;
		end
		self.Undone = false;
		--self.Forw = true;
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

function ENT:StartCreate(class,owner,data)
	if (self.Create or not class or not MCDEntities[class]) then return end
	local info = MCDEntities[class];
	local orig_class = class;
	local pl = owner;
	if (not self.CheckRights) then pl = nil end
	if (class!="replicator" and StarGate.NotSpawnable(info.check or class,pl,info.type or "tool")) then return end	
	local realclass = nil
	if (class=="replicator") then realclass = "prop_ragdoll"; class = "prop_physics"; end
	if (class=="fnp90" or class=="weapon_zat" or class=="weapon_asura" or class=="sg_medkit" or class=="weapon_gdo") then realclass = class; class = "prop_physics"; end
    local e = ents.Create(class);
	if (not IsValid(e)) then return end
	self:SetWire("Creation Class",orig_class);
    if (class=="zpm_mk3" and StarGate.CFG:Get("mcd","allow_tzmp",false)) then
    	local rnd = StarGate.CFG:Get("mcd","tzmp_chance",2);
    	if (rnd<1) then rnd = 1 end
    	local rand = math.random(1,rnd);
    	if (rand==1) then
 			e._MCDTampered = true;
 		end
    end
	self.MCD_RealClass = realclass
    self.Undone = true;
    --self.Object = class;
	e._MCDSTOP = info.stop or 34;
	e._MCDUP = info.pos or 57;
	e:SetPos(self.Entity:GetPos() + self.Entity:GetUp()*e._MCDUP);
	e.Owner = owner;
    if(info.model)then
   	    e:SetModel(info.model);
    end
	e:SetParent(self.Entity);
	e:Spawn();
	e:SetAngles(self.Entity:GetAngles());
	if CPPI and IsValid(owner) and e.CPPISetOwner then e:CPPISetOwner(owner) end
	self.Ent = e;
	self.Create = true;
	self.Start = true;
	self.Ent.Create = true;
	self.Entity:SetNWEntity("CreatingEntity",self.Ent);
	self.Entity:SetNWBool("StartEffects",true);
    if(class == "tollan_disabler" or class == "cloaking_generator" or class == "shield_generator" or class == "jamming_device")then
        local togglename;
		data = data or {};
        local size = data.size or 800;
        local immunity = data.immunity;
		if (immunity==nil) then immunity = true end -- if use data.immunity or true it will always return true so...
        local phaseshifting = data.phaseshifting or false;
        local strengh = data.strengh or 0;
        local drawbubble = data.drawbubble;
		if (drawbubble==nil) then drawbubble = true end 
        local passing = data.passing;
		if (passing==nil) then passing = true end 
        local containment = data.containment or false;
		local antiNC = data.antiNC;
		if (antiNC==nil) then antiNC = true end 
        local key = data.key;
        local color = data.color or Vector(0,0,255);
        if(class == "tollan_disabler" or class == "jamming_device")then
		    e:Setup(size,immunity,owner);
	        if(class == "tollan_disabler")then
		        togglename = "ToggleDisabler";
		    else
		        togglename = "ToggleJamming";
		    end
			numpad.Register(togglename,function(owner,e)
				if(not IsValid(e) or e.Create) then return end;
				if(e.IsEnabled) then
					e.IsEnabled = false;
				else
					e.IsEnabled = true;
				end
			end);
	    elseif(class == "cloaking_generator" or class == "shield_generator")then
	        if(class == "cloaking_generator")then
		        togglename = "ToggleCloaking";
				e:SetVar("Owner",owner);
   	    		e:SetSize(size);
   	    		e.ImmuneOwner = immunity;
   	    		e.PhaseShifting = phaseshifting;
		    else
		        togglename = "ToggleShield";
				e:SetVar("Owner",owner);
	            e:SetSize(size);
   	            e.ImmuneOwner = immunity;
   	            e:SetMultiplier(strengh);
	            e:SetShieldColor(color.x/255,color.y/255,color.z/255);
   	            e.DrawBubble = drawbubble;
   	            e.PassingDraw = passing;
  		        e.Containment = containment;
				e.AntiNoclip = antiNC;
		    end
			numpad.Register(togglename,function(owner,e)
				if(not IsValid(e) or e.Create) then return end;
				if(e:Enabled()) then
					e:Status(false);
				else
					e:Status(true);
				end
			end);
	    end
	    if key then numpad.OnDown(owner,key,togglename,e); end
    end

end

net.Receive("MCD",function(len,ply)
	local self = net.ReadEntity()
	if (not IsValid(self) or self.Player!=ply) then return end
	local class = net.ReadString();
	self:TriggerInput("Effect Color",net.ReadVector());
	local data = {};
    if(class == "tollan_disabler" or class == "cloaking_generator" or class == "shield_generator" or class == "jamming_device")then
        data.size = net.ReadInt(16);
        data.immunity = util.tobool(net.ReadBit());
        data.phaseshifting = util.tobool(net.ReadBit());
        data.strengh = net.ReadInt(16);
        data.drawbubble = util.tobool(net.ReadBit());
        data.passing = util.tobool(net.ReadBit());
        data.containment = util.tobool(net.ReadBit());
		data.antiNC = util.tobool(net.ReadBit());
        data.key = net.ReadInt(16);
        data.color = Vector(net.ReadInt(8),net.ReadInt(8),net.ReadInt(8));
	end
	self:StartCreate(class,ply,data);
end);

function ENT:PostEntityPaste(player, Ent,CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local PropLimit = GetConVar("CAP_mcd_max"):GetInt()
	if(IsValid(player) and player:IsPlayer() and player:GetCount("CAP_mcd")+1 > PropLimit) then
		player:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"entity_limit_mcd\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		self.Entity:Remove();
		return
	end
	if (IsValid(player)) then
		player:AddCount("CAP_mcd", self.Entity)
		self.Owner = player;
	end
	StarGate.WireRD.PostEntityPaste(self,player,Ent,CreatedEntities)
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "molecular_construction_device", StarGate.CAP_GmodDuplicator, "Data" )
end