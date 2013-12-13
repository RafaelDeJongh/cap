/*
	ZPM MK III for GarrysMod 10
	Copyright (C) 2010 Llapp
*/

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim" --gmodentity
ENT.PrintName = "Zero Point Module"
ENT.Author = "Llapp, Boba Fett, Progsys"
ENT.WireDebugName = "ZPM MK III"
ENT.Category = "Stargate Carter Addon Pack"

ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.IsZPM = true

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("energy")) then return end

AddCSLuaFile();

function ENT:Initialize()
	self.Entity:SetModel("models/pg_props/pg_zpm/pg_zpm.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:EnableMotion(false);
		phys:SetMass(10);
	end
	--self:AddResource("ZPMs",1);
	--self:SupplyResource("ZPMs",1);
	--self:AddResource("ZPMO",10000000);
	self:AddResource("energy",StarGate.CFG:Get("zpm_mk3","energy_capacity",1000000));
	self:SupplyResource("energy",StarGate.CFG:Get("zpm_mk3","energy_capacity",1000000))
	self.MaxEnergy = StarGate.CFG:Get("zpm_mk3","capacity",88000000);
	self.Energy = StarGate.CFG:Get("zpm_mk3","capacity",88000000);
	self:CreateWireOutputs("Active","ZPM %","ZPM Energy");
	self:Skin(2);
	self.empty = false;
	self.Connected = false;
	self.Flow = 0;
	self.isZPM = 1;
end

function ENT:SpawnFunction(p,t)
	if (not t.Hit) then return end
	local e = ents.Create("zpm_mk3");
	e:SetPos(t.HitPos+Vector(0,0,0));
	e:DrawShadow(true);
	e:SetVar("Owner",p)
	e:Spawn();
	e:Activate();
	local ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360
	e:SetAngles(ang);
	self.Zpm = e;
	return e;
end

function ENT:Skin(a)
    if(a==1)then
		self.Entity:SetSkin(1);
		self.Entity:SetNetworkedInt("zpmyellowlightalpha",155);
	elseif(a==2)then
        self.Entity:SetSkin(0);
		self.Entity:SetNWInt("zpmyellowlightalpha",1);
	end
end

function ENT:Think()
    if(self.empty or not self.HasResourceDistribution)then return end;
	if(self.Entity:SetNetworkedEntity("ZPM",self.Zpm)==NULL)then
	    self.Entity:SetNetworkedEntity("ZPM",self.Zpm)
	end

	local energy = self:GetResource("energy");

	if (self.Flow == 0) then
		/*local entTable = RD.GetEntityTable(self);
		local netTable = RD.GetNetTable(entTable["network"]);
		local entities = netTable["entities"]; */
		local entities = StarGate.WireRD.GetEntListTable(self);

		if (entities != nil) then
			zpms = 0;
			local zpmsarray = {};
			for k, v in pairs(entities) do
				if IsValid(v) then
					if (v.isZPM != NULL) then
						zpms = zpms+1;
						zpmsarray[zpms] = v;
					end
				end
			end

			local nw_capacity = self:GetNetworkCapacity("energy");
			local rate = (nw_capacity-energy)/zpms;

			for k, v in pairs(zpmsarray) do
				v.Flow = rate;
			end
		end
	end

	local active = 1;
	--local my_capacity = self:GetUnitCapacity("energy");
    --local nw_capacity = self:GetNetworkCapacity("energy");
	--if(my_capacity ~= nw_capacity)then
	if (StarGate.WireRD.Connected(self.Entity)) then
		if(not self.Connected) then
			self:Skin(1);
			self.Connected = true;
		end
	else
		if(self.Connected) then
			self:Skin(2);
			self.Connected = false;
		end
	end
	if(self.Energy > 0)then
   	    local my_capacity = self:GetUnitCapacity("energy");
        local nw_capacity = self:GetNetworkCapacity("energy");
        percent = (self.Energy/self.MaxEnergy)*100;
   	    if(energy < nw_capacity)then
       	    --local rate = (my_capacity+nw_capacity)/2;
       	    local rate = self.Flow;
   	        rate = math.Clamp(rate,0,self.Energy);
   	        rate = math.Clamp(rate,0,nw_capacity-energy);
            self:SupplyResource("energy",rate);
            self.Energy = self.Energy-rate;
        end
	else
	    percent = 0;
		self.Energy = 0;
		active = 0;
		self.empty = true;
		self:Skin(2);
		--if (self.HasRD) then StarGate.WireRD.OnRemove(self,true) end;
		self:AddResource("energy",0);
		self.Connected = false;
	end

	self.Flow = 0;

    self:SetWire("Active",active);
    self:SetWire("ZPM Energy",math.floor(self.Energy));
    self:SetWire("ZPM %",percent);
	self:Output(percent,self.Energy);
	self.Entity:NextThink(CurTime()+0.01);
	return true;
end

function ENT:Output(perc,eng)
	local add = "Disconnected";
	if(self.Connected)then add = "Connected" end;
	if (self.Energy<=0) then add = "Depleted" end;
	self.Entity:SetNWString("add",add);
	self.Entity:SetNWString("perc",perc);
	self.Entity:SetNWString("eng",math.floor(eng));
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("zpm_mk3",SGLanguage.GetMessage("stool_zpm_mk3"));
end

if (StarGate==nil or StarGate.MaterialFromVMT==nil) then return end

local font = {
	font = "Arial",
	size = 16,
	weight = 500,
	antialias = true,
	additive = false,
}
surface.CreateFont("center2", font);
local font = {
	font = "Arial",
	size = 12,
	weight = 500,
	antialias = true,
	additive = false,
}
surface.CreateFont("header", font);
local font = {
	font = "Arial",
	size = 15,
	weight = 500,
	antialias = true,
	additive = true,
}
surface.CreateFont("center", font);

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

ENT.Zpm_hud = surface.GetTextureID("VGUI/resources_hud/zpm");

function ENT:Initialize()
	self.Entity:SetNetworkedString("add","Disconnected");
	self.Entity:SetNWString("perc",0);
	self.Entity:SetNWString("eng",0);
end

function ENT:Draw()
    self.Entity:DrawModel();
	hook.Remove("HUDPaint",tostring(self.Entity).."ZMK");
	if(not StarGate.VisualsMisc("cl_draw_huds",true)) then return end;
    if(LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance( self.Entity:GetPos() ) < 1024)then
		hook.Add("HUDPaint",tostring(self.Entity).."ZMK",function()
		    local w = 0;
            local h = 260;
		    surface.SetTexture(self.Zpm_hud);
	        surface.SetDrawColor(Color( 255, 255, 255, 255 ));
	        surface.DrawTexturedRect(ScrW() / 2 + 6 + w, ScrH() / 2 - 50 - h, 180, 360);

            surface.SetFont("center2");
            surface.SetFont("header");

		    draw.DrawText("ZPM MK 3", "header", ScrW() / 2 + 58 + w, ScrH() / 2 +41 - h, Color(0,255,255,255),0);
    	    if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
            	draw.DrawText(SGLanguage.GetMessage("hud_status"), "center2", ScrW() / 2 + 40 + w, ScrH() / 2 +65 - h, Color(209,238,238,255),0);
		    	draw.DrawText(SGLanguage.GetMessage("hud_energy"), "center2", ScrW() / 2 + 40 + w, ScrH() / 2 +115 - h, Color(209,238,238,255),0);
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
	render.SetMaterial(self.ZpmSprite);
	local alpha = self.Entity:GetNWInt("zpmyellowlightalpha");
	local col = Color(255,165,0,alpha);
	for i=1,5 do
	    local size = 9;
		if(i==3)then
		    size = 8;
		elseif(i==4)then
		    size = 7;
		elseif(i==5)then
		    size = 6;
		end
	    render.DrawSprite(self.Entity:LocalToWorld(self.SpritePositions[i]),size,size,col);
	end
end

function ENT:OnRemove()
    hook.Remove("HUDPaint",tostring(self.Entity).."ZMK");
end

end