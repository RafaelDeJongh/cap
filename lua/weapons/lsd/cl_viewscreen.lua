if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
local matScreen = Material("Markjaw/LSD/screen");
local RTTexture = GetRenderTarget("LSD_Screen", 512, 1024);

local dot = surface.GetTextureID("Markjaw/LSD/dot");
local bg = surface.GetTextureID("Markjaw/LSD/screen_bg");

function SWEP:RenderScreen()
    local NewRT = RTTexture;
    local oldW = ScrW();
    local oldH = ScrH();
	local ply = LocalPlayer();

	matScreen:SetTexture( "$basetexture", NewRT);

    local OldRT = render.GetRenderTarget();
    render.SetRenderTarget(NewRT);
    render.SetViewPort( 0, 0, 512, 0);

    cam.Start2D();

		render.Clear( 50, 50, 100, 0 );

	    surface.SetDrawColor( 255, 255, 255, 255 );
        surface.SetTexture( bg );
        surface.DrawTexturedRect( 0, 0, 512, 1024);

		surface.SetTexture(dot);

		for k, v in pairs(ents.GetAll()) do
			if v:IsNPC() or v:IsPlayer() then
				local ang = ply:GetAngles();
				local pos = ply:GetPos() - v:GetPos();
				pos:Rotate(Angle(0, -1*ang.Yaw, 0));
				local x1 = 256 + pos.y/5;
				local y1 = 512 + 0.3*pos.x;
				if (math.abs(pos.z)<200) then
					surface.DrawTexturedRect(x1-16, y1-24, 32, 48);
				end
			end
		end

    cam.End2D();

    render.SetRenderTarget(OldRT);
    render.SetViewPort( 0, 0, oldW, oldH )

end