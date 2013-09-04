/*
	ZPM Hub for GarrysMod10
	Copyright (C) 2010  Llapp
*/

include("shared.lua");
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
            draw.DrawText("Status", "center2", ScrW() / 2 + 40 + w, ScrH() / 2 +65 - h, Color(209,238,238,255),0);
		    draw.DrawText("Energy", "center2", ScrW() / 2 + 40 + w, ScrH() / 2 +115 - h, Color(209,238,238,255),0);
		    draw.DrawText("Capacity", "center2", ScrW() / 2 + 40 + w, ScrH() / 2 +165 - h, Color(209,238,238,255),0);

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
	        draw.SimpleText(add, "center", ScrW() / 2 + 40 + w, ScrH() / 2 +85 - h, color,0);
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