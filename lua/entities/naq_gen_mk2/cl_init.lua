include("shared.lua");
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
	if(not StarGate.VisualsMisc("cl_draw_huds",true)) then return end;
    if(LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance( self.Entity:GetPos() ) < 1024)then
		hook.Add("HUDPaint",tostring(self.Entity).."MK2",function()
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