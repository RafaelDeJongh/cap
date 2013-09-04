/*
	ZPM Hub for GarrysMod10
	Copyright (C) 2010  Llapp
*/

include("shared.lua");
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("zpmhub",SGLanguage.GetMessage("stool_atlantis_hub"));
end

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

ENT.Zpm_hud = surface.GetTextureID("VGUI/resources_hud/sga_hub");

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

local font = {
	font = "Arial",
	size = 14,
	weight = 500,
	antialias = true,
	additive = false,
}
surface.CreateFont("zpmheader", font);

function ENT:Draw()
	if(self.Entity:GetNetworkedBool("DrawText"))then
		self.DAmt=math.Clamp(self.DAmt+0.1,0,1)
	else
		self.DAmt=math.Clamp(self.DAmt-0.05,0,1)
	end
	self.Entity:DrawModel()
	if(not StarGate.VisualsMisc("cl_draw_huds",true)) then hook.Remove("HUDPaint",tostring(self.Entity).."SGAH"); return end;
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

	hook.Remove("HUDPaint",tostring(self.Entity).."SGAH");
    if(LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance( self.Entity:GetPos() ) < 1024)then
		hook.Add("HUDPaint",tostring(self.Entity).."SGAH",function()
		    local w = 0;
            local h = 260;
		    surface.SetTexture(self.Zpm_hud);
	        surface.SetDrawColor(Color( 255, 255, 255, 255 ));
	        surface.DrawTexturedRect(ScrW() / 2 - 42 + w, ScrH() / 2 - 50 - h, 360, 360);

	        surface.SetFont("center2")
	        surface.SetFont("header")
	        surface.SetFont("zpmheader")
            surface.SetFont("center");

    	    draw.DrawText("SGA HUB", "header", ScrW() / 2 + 58 + w, ScrH() / 2 +41 - h, Color(0,255,255,255),0);
            draw.DrawText("Status", "center2", ScrW() / 2 + 40 + w, ScrH() / 2 +65 - h, Color(209,238,238,255),0);
		    draw.DrawText("Energy", "center2", ScrW() / 2 + 40 + w, ScrH() / 2 +115 - h, Color(209,238,238,255),0);
		    draw.DrawText("Capacity", "center2", ScrW() / 2 + 40 + w, ScrH() / 2 +165 - h, Color(209,238,238,255),0);

			draw.DrawText("Capacities", "zpmheader", ScrW() / 2 + 180 + w, ScrH() / 2 +45 - h, Color(209,238,238,255),0);
			draw.DrawText("ZPM 1", "center", ScrW() / 2 + 180 + w, ScrH() / 2 +65 - h, Color(209,238,238,255),0);
		    draw.DrawText("ZPM 2", "center", ScrW() / 2 + 180 + w, ScrH() / 2 +115 - h, Color(209,238,238,255),0);
		    draw.DrawText("ZPM 3", "center", ScrW() / 2 + 180 + w, ScrH() / 2 +165 - h, Color(209,238,238,255),0);

			if(IsValid(self.Entity))then
	            add = self.Entity:GetNWString("add");
	            perc = self.Entity:GetNWString("perc");
	            eng = self.Entity:GetNWString("eng");
				zpm1 = self.Entity:GetNWString("zpm1");
	            zpm2 = self.Entity:GetNWString("zpm2");
	            zpm3 = self.Entity:GetNWString("zpm3");
	        end

            surface.SetFont("center");

            local color = Color(0,255,0,255);
            if(add == "Inactive")then
                color = Color(255,0,0,255);
            end
            if(tonumber(perc)>0)then perc = string.format("%f",perc) end;
			if(tonumber(zpm1)>0 and zpm1 != nil)then zpm1 = string.format("%G",zpm1) end;
			if(tonumber(zpm2)>0 and zpm2 != nil)then zpm2 = string.format("%G",zpm2) end;
			if(tonumber(zpm3)>0 and zpm3 != nil)then zpm3 = string.format("%G",zpm3) end;

	        draw.SimpleText(add, "center", ScrW() / 2 + 40 + w, ScrH() / 2 +85 - h, color,0);
	        draw.SimpleText(tostring(eng), "center", ScrW() / 2 + 40 + w, ScrH() / 2 +135 - h, Color(255,255,255,255),0);
	        draw.SimpleText(tostring(perc).."%", "center", ScrW() / 2 + 40 + w, ScrH() / 2 +185 - h, Color(255,255,255,255),0);

			draw.SimpleText(tostring(zpm1).."%", "center", ScrW() / 2 + 180 + w, ScrH() / 2 +85 - h, Color(255,255,255,255),0);
			draw.SimpleText(tostring(zpm2).."%", "center", ScrW() / 2 + 180 + w, ScrH() / 2 +135 - h, Color(255,255,255,255),0);
			draw.SimpleText(tostring(zpm3).."%", "center", ScrW() / 2 + 180 + w, ScrH() / 2 +185 - h, Color(255,255,255,255),0);
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
    hook.Remove("HUDPaint",tostring(self.Entity).."SGAH");
end