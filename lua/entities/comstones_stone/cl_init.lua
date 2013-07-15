include("shared.lua");
ENT.Stone_hud = surface.GetTextureID("VGUI/resources_hud/MCD");
ENT.Category = Language.GetMessage("entity_main_cat");
ENT.PrintName = Language.GetMessage("entity_stone");

function ENT:Draw()
    self.Entity:DrawModel();
	hook.Remove("HUDPaint",tostring(self.Entity).."Stone");
    if(LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance( self.Entity:GetPos() ) < 1024)then
		hook.Add("HUDPaint",tostring(self.Entity).."Stone",function()
		    surface.SetTexture(self.Stone_hud);
	        surface.SetDrawColor(Color( 255, 255, 255, 155 ));
	        surface.DrawTexturedRect(ScrW()/2-3, ScrH()/2-112, 100, 100);

			local name = "---";
			if IsValid(self.Entity) then name = self.Entity:GetNetworkedString("Name", "---"); end

            draw.DrawText("Stone", "header", ScrW()/2+27, ScrH()/2-103, Color(0,255,255,255), 0)
            draw.DrawText("Finger print:", "center2", ScrW()/2+10, ScrH()/2-77, Color(209,238,238,255),0);
			draw.DrawText(name, "center2", ScrW()/2+10, ScrH()/2-57, Color(209,238,238,255),0);

		end);
	end
end

function ENT:OnRemove()
    hook.Remove("HUDPaint",tostring(self.Entity).."Stone");
end