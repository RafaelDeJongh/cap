local matScreen = Material("Madman07/GDO/screen");
local RTTexture = GetRenderTarget("GDO_Screen", 256, 128);

local bg = surface.GetTextureID("Madman07/GDO/screen_bg");
local font = {
	font = "Quiver",
	size = 70,
	weight = 1000,
	antialias = true,
	additive = false,
}
surface.CreateFont("Quiver", font);

function SWEP:RenderScreen()

    local NewRT = RTTexture;
    local oldW = ScrW();
    local oldH = ScrH();
	local ply = LocalPlayer();
	local col = self.ColorDisplay;

	matScreen:SetTexture( "$basetexture", NewRT);

    local OldRT = render.GetRenderTarget();
    render.SetRenderTarget(NewRT);
    render.SetViewPort( 0, 0, 256, 128);

    cam.Start2D();

		render.Clear( 50, 50, 100, 0 );

	    surface.SetDrawColor( 255, 255, 255, 255 );
        surface.SetTexture( bg );
        surface.DrawTexturedRect( 0, 0, 256, 128);

		surface.SetFont( "Quiver" )

		local gdo_answer = self:GetNetworkedString("gdo_textdisplay", "")

		local w, h = surface.GetTextSize(gdo_answer)
		local x = (256-w)/2;
		local y = (128-h)/2;

		surface.SetTextColor( 0, 0, 0, 255 )
		surface.SetTextPos(x+3, y+3)
		surface.DrawText(gdo_answer)

		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos(x, y)
		surface.DrawText(gdo_answer)

    cam.End2D();

    render.SetRenderTarget(OldRT);
    render.SetViewPort( 0, 0, oldW, oldH )

end