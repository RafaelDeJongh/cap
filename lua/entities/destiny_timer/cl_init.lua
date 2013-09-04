include('shared.lua');
local font = {
	font = "Anquietas",
	size = 70,
	weight = 400,
	antialias = true,
	additive = true,
}
surface.CreateFont("AncientsT", font);

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_main_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_dest_timer");
end

function ENT:Draw()

	self.Entity:DrawModel();

	local pos = self.Entity:GetPos() + self.Entity:GetUp()*2.5 - self.Entity:GetForward()*2;
	local ang = self.Entity:GetAngles();
	ang:RotateAroundAxis(ang:Up(), -90);
	ang:RotateAroundAxis(ang:Up(), 180);

	local Time = self.Entity:GetNetworkedInt("time",0);

	local Col = Color(200,230,255,255);
	if (Time < 11) then Col = Color(225,50,50,255) end;

	local TimeStr = string.ToMinutesSeconds(Time);
	surface.SetFont("AncientsT");

	cam.Start3D2D(pos, ang, 0.07 );
		draw.DrawText(TimeStr, "Ancients", 0, 0, Col, TEXT_ALIGN_CENTER );
	cam.End3D2D();

end