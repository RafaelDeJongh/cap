if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Base = "base_gmodentity"
ENT.Type = "anim"

ENT.PrintName = "Naquadah Generator Mk2"
ENT.Author = "RononDex"
ENT.Category = "Stargate Carter Addon Pack"
ENT.AutomaticFrameAdvance = true

ENT.Spawnable = false
ENT.AdminSpawnable = false

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("energy")) then return end
AddCSLuaFile()

function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("naq_gen_mk2")
	e:SetPos(tr.HitPos + Vector(0,0,60))
	e:SetUseType(SIMPLE_USE);
	e:Spawn()
	e:Activate()
	e:SetVar("Owner",pl)
	e.Owner = pl
	return e
end

function ENT:Initialize()

	self:SetModel("models/MarkJaw/naquadah_generator.mdl")
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)

	//self:AddResource("Naquadah",500000)
	//self:SupplyResource("Naquadah",500000)
	self.Naquadah = StarGate.CFG:Get("naq_gen_mk2","naquadah",500000);
	self.MaxEnergy = StarGate.CFG:Get("naq_gen_mk2","naquadah",500000);
	self:AddResource("energy",StarGate.CFG:Get("naq_gen_mk2","energy",75000));
	self.Generate = StarGate.CFG:Get("naq_gen_mk2","generate",2000);
	self.GenMulti = StarGate.CFG:Get("naq_gen_mk2","multiplier",25);
	self.AllowNuke = StarGate.CFG:Get("naq_gen_mk2","nuke_explode",true);
	self:CreateWireInputs("ON/OFF","Disable Use");
	self:CreateWireOutputs("Active","Naquadah","Naquadah %","Countdown","Energy")

	self.health=100
	self.Countdown=5
	self.ActiveTime=0
	self.Detonation=60
	self.Exploded = false;
	self.depleted = false;

	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:SetMass(1000)
		phys:Wake()
	end
	self.Entity:SetUseType(SIMPLE_USE);
end

function ENT:Think()

	if(not self.HasResourceDistribution) then return end;

	if(self.Active) then
		//self.ActiveTime = math.Approach(self.ActiveTime,60,1)
		if(self.Naquadah>0 and self:GetResource("energy")<self:GetNetworkCapacity("energy")) then
			self.Detonation=self.Detonation-1
			//self.ActiveTime=math.Clamp(self.ActiveTime+1,1,60);
			local rnd = math.Round(self.Generate*math.Rand(0.95,1.05)); -- just for better visual consume
			if (self:GetResource("energy")+rnd*self.GenMulti>self:GetNetworkCapacity("energy")) then
				local en = self:GetNetworkCapacity("energy")-self:GetResource("energy");
				self:SupplyResource("energy",self.GenMulti)
				rnd = math.Round(en/self.GenMulti)
			else
				self:SupplyResource("energy",rnd*self.GenMulti)
			end
			if (self.Naquadah-rnd<0) then
				self.Naquadah = 0;
			else
				self.Naquadah = self.Naquadah-rnd;
			end
		elseif (self.Naquadah>0 and self:GetResource("energy")>=self:GetNetworkCapacity("energy") and not self.Overloaded and self.Detonation>5) then
			//self.ActiveTime=math.Clamp(self.ActiveTime-1,1,54);
			self.Detonation=math.Clamp(self.Detonation+1,6,60);
		end

		if(self.Naquadah <= 0) then
			self.depleted = true;
			if (not self.Overloaded) then
				self.Active=false
				self.ActiveTime=0
				//self.Detonation=-1
				self:SetSkin(0)
			end
		end

		if(self.depleted) then
			--if (self.HasRD) then StarGate.WireRD.OnRemove(self,true) end;
			self:AddResource("energy",0);
			self:SetWire("Active",0);
			self:SetWire("Naquadah",0);
			self:SetWire("Naquadah %",0);
			self:SetWire("Energy",0);
			self:SetWire("Countdown",-1)
			self.Energy = 0;
			self:SetSkin(0)
		else
			local percent = (self.Naquadah/self.MaxEnergy)*100;
			self:SetWire("Active",self.Active)
			self:SetWire("Naquadah",math.floor(self.Naquadah))
			self:SetWire("Naquadah %",percent);
			self:SetWire("Countdown",self.Detonation)
			self:SetWire("Energy",self:GetResource("energy"));
		end
	elseif(not self.depleted) then
		self:SetWire("Active",0)
		self:SetWire("Energy",self:GetResource("energy"));
		self:SetWire("Countdown",self.Detonation)
		self.Detonation=math.Clamp(self.Detonation+3,6,60);
		//self:SupplyResource("energy",0)
		//self:ConsumeResource("Naquadah",0)
	end

	if (not self.depleted) then
		if(self.Countdown<=0) then
			if self.Exploded == false then
				self.Exploded = true;
				self:Bang()
			end
		end
		if(self.Detonation<6 and not self.Exploded) then
			self.Overloaded=true
			if(self:GetSkin()<2) then
				self:SetSkin(2)
			end
			if (self.Owner) then
				self.Owner:PrintMessage(HUD_PRINTCENTER,"Naquadah Generator overloads in: "..self.Countdown)
			end
			self.Countdown=self.Countdown-1
		end
	end

	--local my_capacity = self:GetUnitCapacity("energy");
    --local nw_capacity = self:GetNetworkCapacity("energy");
	--if(my_capacity ~= nw_capacity)then
	if (StarGate.WireRD.Connected(self.Entity)) then
		self.Connected = true;
	else
		self.Connected = false;
	end
	percent = (self.Naquadah/self.MaxEnergy)*100;
	self:Output(percent,self.Naquadah);
	self:NextThink(CurTime()+1)
	return true
end

function ENT:Output(perc,eng)
	local add = "Disconnected";
	if(self.Connected)then add = "Connected" end;
	if (self.Naquadah<=0) then add = "Depleted" end;
	self.Entity:SetNetworkedString("add",add);
	self.Entity:SetNWString("perc",perc);
	self.Entity:SetNWString("eng",eng);
end

function ENT:Use(p) --####### Activate or deactivate @RononDex
	if (self:GetWire("Disable Use")>0) then return end
	if (self.depleted) then return end
	if(not(self.Active)) then
		self.Active=true
		self:SetSkin(1)
		//self.Detonation=10
	else
		if(not(self.Overloaded)) then
			self.Active=false
			self.ActiveTime=0
			//self.Detonation=60
			self:SetSkin(0)
		else
			p:ChatPrint("System's aren't responding! Explosion is imminent")
		end
	end
end

function ENT:TriggerInput(k,v)
	if (self.depleted) then return end;
	if(k=="ON/OFF") then
		if((v or 0) >= 1) then
			if(not(self.Active)) then
				self.Active=true
				self:SetSkin(1)
				//self.Detonation=60
			else
				if(not(self.Overloaded)) then
					self.Active=false
					self.ActiveTime=0
					//self.Detonation=60
					self:SetSkin(0)
				end
			end
		end
	end
end

function ENT:Bang()
	if (self.AllowNuke and not self.depleted) then
		local e = ents.Create("sat_blast_wave")
		e:SetPos(self:GetPos()+self:GetUp()*15)
		e:Spawn()
		e:Activate()
	else
		local fx = EffectData()
		fx:SetOrigin(self:GetPos())
		util.Effect("Explosion",fx)
	end
	self:Remove()
end

function ENT:OnTakeDamage(dmg)

	self.health = self.health-(dmg:GetDamage()/10)

	if self.health<1 and self.Exploded == false then
		self.Exploded = true;
		self:Bang();
	end
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable("naq_gen_mks",ply,"tool")) then self.Entity:Remove(); return end
	if (IsValid(ply)) then
		if(ply:GetCount("naq_gen_mks")+1>GetConVar("sbox_maxnaq_gen_mks"):GetInt()) then
			ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"stool_naq_gen_mks_limit\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			self.Entity:Remove();
			return
		end
		ply:AddCount("naq_gen_mks", self.Entity)
		self.Owner = ply;
	end
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "naq_gen_mk2", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("naq_gen_mk2",SGLanguage.GetMessage("naq_gen_mk2"));
end

ENT.Zpm_hud = surface.GetTextureID("VGUI/resources_hud/mk2");

function ENT:Initialize()
	self.Entity:SetNetworkedString("add","Disconnected");
	self.Entity:SetNWString("perc",0);
	self.Entity:SetNWString("eng",0);
end

function ENT:Draw()
	self.Entity:DrawModel();
	hook.Remove("HUDPaint",tostring(self.Entity).."MK2");
	local ent = self.Entity
	if(not StarGate.VisualsMisc("cl_draw_huds",true)) then return end;
    if(LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance( self.Entity:GetPos() ) < 1024)then
		hook.Add("HUDPaint",tostring(self.Entity).."MK2",function()
		
			if(not IsValid(ent))then
				hook.Remove("HUDPaint",tostring(ent).."MK2")
				return
			end
		
		    local w = 0;
            local h = 260;
		    surface.SetTexture(self.Zpm_hud);
	        surface.SetDrawColor(Color( 255, 255, 255, 255 ));
	        surface.DrawTexturedRect(ScrW() / 2 + 6 + w, ScrH() / 2 - 50 - h, 180, 360);

	        surface.SetFont("center2")
	        surface.SetFont("header")

            draw.DrawText("NGEN MK2", "header", ScrW() / 2 + 54 + w, ScrH() / 2 +41 - h, Color(0,255,255,255), 0)
    	    if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
            	draw.DrawText(SGLanguage.GetMessage("hud_status"), "center2", ScrW() / 2 + 40 + w, ScrH() / 2 +65 - h, Color(209,238,238,255),0);
		    	draw.DrawText(SGLanguage.GetMessage("hud_naquadah"), "center2", ScrW() / 2 + 40 + w, ScrH() / 2 +115 - h, Color(209,238,238,255),0);
		    	draw.DrawText(SGLanguage.GetMessage("hud_capacity"), "center2", ScrW() / 2 + 40 + w, ScrH() / 2 +165 - h, Color(209,238,238,255),0);
		    end
			
			if(IsValid(self.Entity))then
	            add = self.Entity:GetNetworkedString("add");
	            perc = self.Entity:GetNWString("perc");
	            eng = self.Entity:GetNWString("eng");
	        end

            surface.SetFont("center")

            local color = Color(0,255,0,255);
            if(add == "Disconnected" or add == "Depleted")then
                color = Color(255,0,0,255);
            end
            if(tonumber(perc)>0)then
                perc = string.format("%f",perc);
	        end

            if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
	        	draw.SimpleText(SGLanguage.GetMessage("hud_sts_"..add:lower()), "center", ScrW() / 2 + 40 + w, ScrH() / 2 +85 - h, color,0);
	        end
	        draw.SimpleText(tostring(eng), "center", ScrW() / 2 + 40 + w, ScrH() / 2 +135 - h, Color(255,255,255,255),0)
	        draw.SimpleText(tostring(perc).."%", "center", ScrW() / 2 + 40 + w, ScrH() / 2 +185 - h, Color(255,255,255,255),0)
		end);
	end
end

function ENT:OnRemove()
    hook.Remove("HUDPaint",tostring(self.Entity).."MK2");
end

end