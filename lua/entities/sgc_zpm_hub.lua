/*
	SGC ZPM Device for GarrysMod 10
	Copyright (C) 2010 Llapp, cooldudetb, model by micropro
*/

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim" --gmodentity
ENT.PrintName = "SGC Hub Mk2"
ENT.Author = "Llapp, cooldudetb, Boba Fett"
ENT.Category = "Stargate Carter Addon Pack"
ENT.WireDebugName = "SGC Hub Mk2"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if (Environments) then
	ENT.IsNode = false
else
	ENT.IsNode = true
end

ENT.ZPMHub = true

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("energy")) then return end
AddCSLuaFile();

ENT.Sounds = {
	PowerUp=Sound("zpmhub/zpm_power_up.wav"),
	SlideIn=Sound("zpmhub/zpm_hub_slide_in.wav"),
	SlideOut=Sound("zpmhub/zpm_hub_slide_out.wav"),
	Idle=Sound("zpmhub/zpm_hub_idle.wav"),
}

function ENT:Initialize()
	self.Entity:SetModel("models/micropro/zpmslot/zpm_slot.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:EnableMotion(false);
		phys:SetMass(1000);
	end
	self:CreateWireInputs("Deactivate ZPM","Eject ZPM","Disable Use","Disable Sound");
	self:CreateWireOutputs("Active","ZPM Hub %","ZPM Hub Energy");

	self.CanEject = true;

	self.HaveRD3 = false;
	if (CAF and CAF.GetAddon("Resource Distribution")) then self.HaveRD3 = true end

	if self.HaveRD3 then -- Make us a node!
		self.netid = CAF.GetAddon("Resource Distribution").CreateNetwork(self);
		self:SetNetworkedInt( "netid", self.netid );
		self.range = 2048;
		self:SetNetworkedInt( "range", self.range );

		self.RDEnt = CAF.GetAddon("Resource Distribution");
	elseif ( RES_DISTRIB == 2 ) then
		self:AddResource("energy",1)
	end

	self.ZPM = {On=false,Ent=nil,IsValid=false,Dir=1,Dist=1,Eject=0,Type="ZPH",SoundIn=0,SoundOut=0};
	self.Position = {R=0,F=0};
	self.Active = false;

	self.IdleSound = self.IdleSound or CreateSound(self.Entity,self.Sounds.Idle);
	self.IdleS = false;

	self:Skins();
end

function ENT:SpawnFunction(p,t)
	if (not t.Hit) then return end
	local ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+90) % 360;
	local pos = t.HitPos+Vector(0,0,0);
	local e = ents.Create("sgc_zpm_hub");
	e:SetPos(pos);
	e:SetAngles(ang);
	e:DrawShadow(true);
	e:SetVar("Owner",p);
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:UseZPM()
	if (self.ZPM.Dist == 1) then
		self.ZPM.Eject = self.ZPM.Eject+1;
		timer.Simple(0.1,function()
			if(IsValid(self.Entity) and self.ZPM.Eject >= 1)then
				self.ZPM.Eject = self.ZPM.Eject-1;
			end
		end);
	else
		self.ZPM.Dir = 1;
	end
end

function ENT:Touch(ent)
	local pos = self.Entity:GetPos();
	local ang = self.Entity:GetAngles();
	if (self.CanEject == true and ent.IsZPM and ent ~= self.ZPM.Ent) then
		if (not self.ZPM.IsValid and self.ZPM.Eject == 0) then
			self.ZPM.Ent = ent;
			self.ZPM.Dist = 1;
			self.ZPM.Dir = 1;
			self.ZPM.Type = "ZPH";
			self.ZPM.IsValid = true;
			ent:SetUseType(SIMPLE_USE);
			ent.Use = function()
				local constr = constraint.FindConstraint(self,"Weld");
				if (constr and IsValid(constr.Entity[1].Entity)) then
					if (constr.Entity[1].Entity:GetWire("Disable Use")>0) then return end
					constr.Entity[1].Entity:UseZPM();
				end
			end
			constraint.RemoveAll(ent);
			ent:SetPos(pos + self.Entity:GetRight()*(self.Position.R) + self.Entity:GetUp()*(29.1+10) + self.Entity:GetForward()*(self.Position.F));
			ent:SetAngles(ang);
			constraint.Weld(self.Entity,ent,0,0,0,true);
		end
	end
end

function ENT:TriggerInput(variable, value)
	if (variable == "Deactivate ZPM") then
		self.ZPM.Dir = value;
	elseif (variable == "Eject ZPM") then
		self.ZPM.Eject = value;
	elseif (variable == "Disable Sound") then
		if(value>0) then
			self.IdleSound:Stop()
		else
			if (self.Active) then
				self.IdleSound:ChangePitch(85,0);
				self.IdleSound:SetSoundLevel(70);
				self.IdleSound:PlayEx(1,86);
			end
		end
	end
end

function ENT:Skins()
	if(self.Active) then
		self.Entity:SetSkin(2);
    else
		self.Entity:SetSkin(1);
	end
end

function ENT:Think()
	if self.HaveRD3 then
		local nettable = CAF.GetAddon("Resource Distribution").GetNetTable(self.netid)
		if table.Count(nettable) > 0 then
			local entities = nettable.entities
			if table.Count(entities) > 0 then
				for k, ent in pairs(entities) do
					if ent and IsValid(ent) then
						local pos = ent:GetPos()
						if pos:Distance(self:GetPos()) > self.range then
							self:HubUnlink(ent)
							self:EmitSound("physics/metal/metal_computer_impact_bullet"..math.random(1,3)..".wav", 500)
							ent:EmitSound("physics/metal/metal_computer_impact_bullet"..math.random(1,3)..".wav", 500)
						end
					end
				end
			end
			local cons = nettable.cons
			if table.Count(cons) > 0 then
				for k, v in pairs(cons) do
					local tab = CAF.GetAddon("Resource Distribution").GetNetTable(v)
					if tab and table.Count(tab) > 0 then
						local ent = tab.nodeent
						if ent and IsValid(ent) then
							local pos = ent:GetPos()
							local range = pos:Distance(self:GetPos())
							if range > self.range and range > ent.range then
								CAF.GetAddon("Resource Distribution").UnlinkNodes(self.netid, ent.netid)
								self:EmitSound("physics/metal/metal_computer_impact_bullet"..math.random(1,3)..".wav", 500)
								ent:EmitSound("physics/metal/metal_computer_impact_bullet"..math.random(1,3)..".wav", 500)
							end
						end
					end
				end
			end
		end
	end

	local zpmi = {En=0,Per=0,Max=0}

	self.Active = false;

	local ZPH = 0;
	local percent = 0;

	self.ZPM.IsValid = (self.ZPM.Ent and self.ZPM.Ent:IsValid());
	if (self.ZPM.IsValid) then
		self.ZPM.On = ((self.ZPM.Ent.Connected and not self.ZPM.Ent.Empty) or self.ZPM.Ent.enabled == true);
		if self.ZPM.On then
			if (self.ZPM.Type == "ZPH") then
				zpmi.En = self.ZPM.Ent.Energy;
				zpmi.Max = self.ZPM.Ent.MaxEnergy;
			else
				zpmi.En = self.ZPM.Ent:GetResource(self.ZPM.Type);
				zpmi.Max = self.ZPM.Ent.MaxEnergy;
			end
			zpmi.Per = (zpmi.En/zpmi.Max)*100;
			if(zpmi.Per <= 0)then
				zpmi.Per = 0;
			end
			ZPH = ZPH+zpmi.En;
			percent = percent+zpmi.Max;
		end
		local v = self.ZPM
		self.ZPM.Ok = (not util.tobool(v.Dist)) and ( v.Ent.Connected or v.Ent.empty )
		local constr = constraint.FindConstraint(self.ZPM.Ent,"Weld");
		if (self.ZPM.Dist == 1 and (self.ZPM.Eject == 1 or not constr or constr.Entity[1].Entity ~= self.Entity)) then
			self:EjectZPM();
		elseif (self.ZPM.Dist == 0 and self.ZPM.On) then
			self.Active = true;
		end
	end

	self:ZPMsMovement();

	self:SoundIdle(self.Active);
	self:Skins();

	self:SoundSetup();

    self:SetWire("Active",self.Active);

	if percent > 0 then
		percent = (ZPH/percent)*100;
	else
		percent = 0;
	end
	if (self.ZPM.IsValid == false) then
		percent = 0;
	end

	if (self:GetWire("Disable Sound",0)<1) then
		if (self.IdleS) then
			self.IdleSound:ChangePitch(85,0);
			self.IdleSound:SetSoundLevel(70);
			self.IdleSound:PlayEx(1,86);
		else
			self.IdleSound:Stop()
		end
	end

	if IsValid(self.ZPM.Ent) and self.ZPM.Dist == 0 then
		self:SetWire("ZPM Hub %",self.ZPM.Ok and percent or -1);
	else
		self:SetWire("ZPM Hub %",-1);
	end

	timer.Simple(0.1,function()
	    if(IsValid(self.Entity))then
		    self.Entity:SetNetworkedInt("Percents",percent);
		end
	end);
    self:SetWire("Active",self.Active);
    self:SetWire("ZPM Hub Energy",math.floor(ZPH));
	self:Output(percent,ZPH);

	self.Entity:SetNetworkedEntity("ZPM",self.ZPM.Ent);

	self.Entity:NextThink(CurTime()+0.01);
	return true;
end

function ENT:Output(perc,eng)
	local add = "Inactive";
	if(self.Active)then add = "Active" end;
	self.Entity:SetNWString("add",add);
	self.Entity:SetNWString("perc",perc);
	self.Entity:SetNWString("eng",math.floor(eng));
end

function ENT:ZPMsMovement()
	local pos = self.Entity:GetPos();
	local ang = self.Entity:GetAngles();
	local spd = 0.015;
	if (self.ZPM.IsValid and self.ZPM.Dist ~= self.ZPM.Dir) then
		if (self.ZPM.Dist < 0) then
			self.ZPM.Dist = 0;
		elseif (self.ZPM.Dist> 1) then
			self.ZPM.Dist = 1;
		end

		if (self.ZPM.Dir < self.ZPM.Dist) then
			self.ZPM.Dist = self.ZPM.Dist-spd;
			if(self.ZPM.SoundIn==1) then
				self.Entity:EmitSound(self.Sounds.SlideIn,60,100);
				self.ZPM.SoundIn = 2;
			end
			if(self.ZPM.SoundOut==2) then
				self.ZPM.SoundOut = 0;
			end
		elseif (self.ZPM.Dir > self.ZPM.Dist) then
			self.ZPM.Dist = self.ZPM.Dist+spd;
			if(self.ZPM.SoundOut==1) then
				self.Entity:EmitSound(self.Sounds.SlideOut,60,100);
				self.ZPM.SoundOut = 2;
			end
			if(self.ZPM.SoundIn==2) then
				self.ZPM.SoundIn = 0;
			end
		end
		constraint.RemoveAll(self.ZPM.Ent);
		self.ZPM.Ent:SetAngles(self.Entity:GetAngles());
		self.ZPM.Ent:SetPos(pos + self.Entity:GetRight()*(self.Position.R) + self.Entity:GetUp()*(29.1+10*self.ZPM.Dist) + self.Entity:GetForward()*(self.Position.F));
		constraint.Weld(self.Entity,self.ZPM.Ent,0,0,math.floor(self.ZPM.Dist)*5000,true);
		if (self.ZPM.Dir == 0 and self.ZPM.Dist == 0) then
			self:HubLink(self.ZPM.Ent);
		elseif (self.ZPM.Dir == 1) then
			self:HubUnlink(self.ZPM.Ent);
		end
	end
end

function ENT:SoundSetup()
	if(self.ZPM.Dir == 0) then
		if(self.ZPM.SoundIn==0) then
			self.ZPM.SoundIn = 1;
		end
	elseif(self.ZPM.Dir == 1) then
		if(self.ZPM.SoundOut==0) then
			self.ZPM.SoundOut = 1;
		end
	end
end

function ENT:SoundIdle(idle)
    if(idle) then
        self.IdleS = true;
	else
	    self.IdleS = false;
	end
end

function ENT:HubLink(ent)
	if self.HaveRD3 then
		CAF.GetAddon("Resource Distribution").Link(ent,self.netid);
	elseif Environments then
		ent:Link(self.node);
		if (self.node) then
			self.node:Link(ent);
		end
	elseif ( RES_DISTRIB == 2 ) then
		Dev_Link(ent,self, nil, nil, nil, nil, nil);
	end
end
function ENT:HubUnlink(ent)
	if self.HaveRD3 then
		CAF.GetAddon("Resource Distribution").Unlink(ent);
	elseif Environments then
		ent:Unlink();
	elseif ( RES_DISTRIB == 2 ) then
		Dev_Unlink_All(ent);
	end
end

 function ENT:Use()
	if (self:GetWire("Disable Use")>0) then return end
    local val = false;
    if((self.ZPM.IsValid and self.ZPM.Dist == 1)) then
		val = true;
	end

	if (val)then
		timer.Simple(1,function()
			if (IsValid(self.Entity)) then
				self.ZPM.Dir = 0;
  			end
		end);
	else
		timer.Simple(1,function()
			if (IsValid(self.Entity)) then
				self.ZPM.Dir = 1;
			end
		end);
	end
end


function ENT:SetCustomNodeName(name)
end

function ENT:EjectZPM()
	if (self.ZPM.Ent) then
		self.ZPM.Ent.Use = function() end;
		self:HubUnlink(self.ZPM.Ent);
		local phys = self.ZPM.Ent:GetPhysicsObject();
		if(phys:IsValid()) then
			constraint.RemoveAll(self.ZPM.Ent);
		end
		local mul = 3.2;
		self.CanEject = false;
		timer.Simple(1,function()
			if(IsValid(self.Entity))then
				self.CanEject = true;
			end
		end);
		local pos = self.Entity:GetPos();
		self.ZPM.Ent:SetPos(pos + self.Entity:GetRight()*(self.Position.R*mul) + self.Entity:GetUp()*(29.1+12) + self.Entity:GetForward()*(self.Position.F*mul));
	end
	self.ZPM.Ent = nil;
	self.ZPM.IsValid = false;
	self.ZPM.On = false;
end

function ENT:Repair()
end

function ENT:SetRange(range)
end

function ENT:OnRemove()
	StarGate.WireRD.OnRemove(self);
	if (self.ZPM.IsValid) then
		self:EjectZPM();
	end

	self.IdleSound:Stop()
end

function ENT:PreEntityCopy()
	local dupeInfo = {};
	dupeInfo.ZPM = self.ZPM;
	if (IsValid(self.ZPM.Ent)) then
		dupeInfo.ZPMid = self.ZPM.Ent:EntIndex();
	else
		dupeInfo.ZPMid = -1;
	end
	duplicator.StoreEntityModifier(self, "ZPMs", dupeInfo);
	StarGate.WireRD.PreEntityCopy(self)
end

function ENT:PostEntityPaste(Player, Ent, CreatedEntities)
	self.ZPM = Ent.EntityMods.ZPMs.ZPM;
	if (Ent.EntityMods.ZPMs.ZPMid!=-1) then
		self.ZPM.Ent = CreatedEntities[Ent.EntityMods.ZPMs.ZPMid]
		self.ZPM.Ent:SetUseType(SIMPLE_USE);
		self.ZPM.Ent.Use = function()
			local constr = constraint.FindConstraint(self,"Weld");
			if (constr and IsValid(constr.Entity[1].Entity)) then
				constr.Entity[1].Entity:UseZPM(i);
			end
		end
	end
	StarGate.WireRD.PostEntityPaste(self,Player,Ent,CreatedEntities)
end

if (Environments) then
		ENT.Link = function(self, ent, delay)
			if self.node and IsValid(self.node) then
				self:Unlink()
				if (IsValid(self.ZPM.Ent) and self.ZPM.Dist == 0 and self.ZPM.Ent.node and IsValid(self.ZPM.Ent.node)) then
					self.ZPM.Ent:Unlink()
				end
			end
			if ent and ent:IsValid() then
				if (IsValid(self.ZPM.Ent) and self.ZPM.Dist == 0) then
					self.ZPM.Ent:Link(ent)
					ent:Link(self.ZPM.Ent)
				end
				self.node = ent

				if delay then
					timer.Simple(0.1, function()
						umsg.Start("Env_SetNodeOnEnt")
							umsg.Short(self:EntIndex())
							umsg.Short(ent:EntIndex())
						umsg.End()
					end)
				else
					umsg.Start("Env_SetNodeOnEnt")
						umsg.Short(self:EntIndex())
						umsg.Short(ent:EntIndex())
					umsg.End()
				end
				--self:SetNWEntity("node", ent)
			end
		end
	ENT.Unlink = function(self)
		if self.node then
			if (IsValid(self.ZPM.Ent) and self.ZPM.Dist == 0 and self.ZPM.Ent.node and IsValid(self.ZPM.Ent.node)) then
				self.ZPM.Ent:Unlink()
			end
			self.node:Unlink(self)
			self.node = nil
			umsg.Start("Env_SetNodeOnEnt")
				umsg.Short(self:EntIndex())
				umsg.Short(0)
			umsg.End()
		end
	end
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("sgc_zpm_hub",SGLanguage.GetMessage("stool_sgc_hub"));
end

if (StarGate==nil or StarGate.MaterialFromVMT==nil) then return end

ENT.ZpmSprite = StarGate.MaterialFromVMT(
	"ZpmSprite",
	[["Sprite"
	{
		"$spriteorientation" "vp_parallel"
		"$spriteorigin" "[ 0.50 0.50 ]"
		"$basetexture" "sprites/glow04"
		"$spriterendermode" 5
	}]]
);

ENT.SpritePositions = {
	Vector(0,0,5),
	Vector(0,0,3),
	Vector(0,0,0),
	Vector(0,0,-3),
	Vector(0,0,-5),
}

ENT.Zpm_hud = surface.GetTextureID("VGUI/resources_hud/sgc_hub");

function ENT:Initialize()
	self.DAmt=0
	self.Entity:SetNetworkedString("add","Inactive");
	self.Entity:SetNWString("perc",0);
	self.Entity:SetNWString("eng",0);
	self.Entity:SetNWString("zpm1",0);
	self.Entity:SetNWString("zpm2",0);
	self.Entity:SetNWString("zpm3",0);
	local mul = 0.93;
	self.Positions = {{R=0,F=-13*mul},{R=-11.2*mul,F=6.5*mul},{R=11.2*mul,F=6.5*mul}};
end

function ENT:Think()
	self.Entity:NextThink(CurTime()+0.001);
	return true;
end

function ENT:Draw()
	if(self.Entity:GetNetworkedBool("DrawText"))then
		self.DAmt=math.Clamp(self.DAmt+0.1,0,1)
	else
		self.DAmt=math.Clamp(self.DAmt-0.05,0,1)
	end
	self.Entity:DrawModel()
	if(not StarGate.VisualsMisc("cl_draw_huds",true)) then hook.Remove("HUDPaint",tostring(self.Entity).."SGCH"); return end;
	local ang=EyeAngles()
    ang.y = ang.y;
	ang:RotateAroundAxis(ang:Right(),	90)
	ang:RotateAroundAxis(ang:Up(),		-90)

    local pos = self.Entity:GetPos() + self.Entity:GetRight()*(self.Positions[1].R) + self.Entity:GetUp()*(62) + self.Entity:GetForward()*(self.Positions[1].F);
    local str="ZPM 1"
    surface.SetFont("SandboxLabel")
    local w,h=surface.GetTextSize(str)
   	cam.Start3D2D(pos, ang, 0.02 )
	    surface.SetDrawColor( 0, 0, 0, 0 )
	    surface.DrawRect(0-w/1, 0, w, h)
    	draw.DrawText(str, "SandboxLabel", 0, 0, Color(255,255,255,255*self.DAmt), TEXT_ALIGN_CENTER )
    cam.End3D2D()

	local pos = self.Entity:GetPos() + self.Entity:GetRight()*(self.Positions[2].R) + self.Entity:GetUp()*(62) + self.Entity:GetForward()*(self.Positions[2].F);
	local str="ZPM 2"
    surface.SetFont("SandboxLabel")
    local w,h=surface.GetTextSize(str)
   	cam.Start3D2D(pos, ang, 0.02 )
	    surface.SetDrawColor( 0, 0, 0, 0 )
	    surface.DrawRect(0-w/1, 0, w, h)
    	draw.DrawText(str, "SandboxLabel", 0, 0, Color(255,255,255,255*self.DAmt), TEXT_ALIGN_CENTER )
    cam.End3D2D()

	local pos = self.Entity:GetPos() + self.Entity:GetRight()*(self.Positions[3].R) + self.Entity:GetUp()*(62) + self.Entity:GetForward()*(self.Positions[3].F);
	local str="ZPM 3"
    surface.SetFont("SandboxLabel")
    local w,h=surface.GetTextSize(str)
   	cam.Start3D2D(pos, ang, 0.02 )
	    surface.SetDrawColor( 0, 0, 0, 0 )
	    surface.DrawRect(0-w/1, 0, w, h)
    	draw.DrawText(str, "SandboxLabel", 0, 0, Color(255,255,255,255*self.DAmt), TEXT_ALIGN_CENTER )
    cam.End3D2D()

	hook.Remove("HUDPaint",tostring(self.Entity).."SGCH");
    if(LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance( self.Entity:GetPos() ) < 1024)then
		hook.Add("HUDPaint",tostring(self.Entity).."SGCH",function()
		    local w = 0;
            local h = 260;
		    surface.SetTexture(self.Zpm_hud);
	        surface.SetDrawColor(Color( 255, 255, 255, 255 ));
	        surface.DrawTexturedRect(ScrW() / 2 + 6 + w, ScrH() / 2 - 50 - h, 180, 360);

	        surface.SetFont("center2")
	        surface.SetFont("header")

    	    draw.DrawText("SGC HUB", "header", ScrW() / 2 + 58 + w, ScrH() / 2 +41 - h, Color(0,255,255,255),0);
    	    if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
            	draw.DrawText(SGLanguage.GetMessage("hud_status"), "center2", ScrW() / 2 + 40 + w, ScrH() / 2 +65 - h, Color(209,238,238,255),0);
		    	draw.DrawText(SGLanguage.GetMessage("hud_energy"), "center2", ScrW() / 2 + 40 + w, ScrH() / 2 +115 - h, Color(209,238,238,255),0);
		    	draw.DrawText(SGLanguage.GetMessage("hud_capacity"), "center2", ScrW() / 2 + 40 + w, ScrH() / 2 +165 - h, Color(209,238,238,255),0);
		    end

			if(IsValid(self.Entity))then
	            add = self.Entity:GetNWString("add");
	            perc = self.Entity:GetNWString("perc");
	            eng = self.Entity:GetNWString("eng");
	        end

            surface.SetFont("center");

            local color = Color(0,255,0,255);
            if(add == "Inactive")then
                color = Color(255,0,0,255);
            end
            if(tonumber(perc)>0)then perc = string.format("%f",perc) end;
            if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
	        	draw.SimpleText(SGLanguage.GetMessage("hud_sts_"..add:lower()), "center", ScrW() / 2 + 40 + w, ScrH() / 2 +85 - h, color,0);
	        end
	        draw.SimpleText(tostring(eng), "center", ScrW() / 2 + 40 + w, ScrH() / 2 +135 - h, Color(255,255,255,255),0);
	        draw.SimpleText(tostring(perc).."%", "center", ScrW() / 2 + 40 + w, ScrH() / 2 +185 - h, Color(255,255,255,255),0);
		end);
	end

	render.SetMaterial(self.ZpmSprite);
	local alpha1 = self.Entity:GetNWInt("zpm1yellowlightalpha");
	local col1 = Color(255,165,0,alpha1);

	if(self.Entity:GetNetworkedEntity("ZPMA")==NULL)then return end;
	for i=1,5 do
	    render.DrawSprite(self.Entity:GetNetworkedEntity("ZPMA"):LocalToWorld(self.SpritePositions[i]),10,10,col1);
	end

	local alpha = self.Entity:GetNWInt("zpm2yellowlightalpha");
	local col = Color(255,165,0,alpha);
	if(self.Entity:GetNetworkedEntity("ZPMB")==NULL)then return end;
	for i=1,5 do
	    render.DrawSprite(self.Entity:GetNetworkedEntity("ZPMB"):LocalToWorld(self.SpritePositions[i]),10,10,col);
	end

	local alpha = self.Entity:GetNWInt("zpm3yellowlightalpha");
	local col = Color(255,165,0,alpha);
	if(self.Entity:GetNetworkedEntity("ZPMC")==NULL)then return end;
	for i=1,5 do
	    render.DrawSprite(self.Entity:GetNetworkedEntity("ZPMC"):LocalToWorld(self.SpritePositions[i]),10,10,col);
	end
end

function ENT:OnRemove()
    hook.Remove("HUDPaint",tostring(self.Entity).."SGCH");
end

end