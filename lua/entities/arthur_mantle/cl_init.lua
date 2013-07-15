include('shared.lua');
ENT.Category = Language.GetMessage("entity_main_cat");
ENT.PrintName = Language.GetMessage("entity_arthurs_mantle");

local font = {
	font = "Anquietas",
	size = ScreenScale(35),
	weight = 400,
	antialias = true,
	additive = true,
}
surface.CreateFont("Ancients", font);

local font = {
	font = "Stargate Address Glyphs Concept",
	size = ScreenScale(35),
	weight = 400,
	antialias = true,
	additive = true,
}
surface.CreateFont("Glyphs", font);

function ENT:Think()

	local cloaked_self = LocalPlayer():GetNetworkedBool("ArthurCloaked",false);
	for _,p in pairs(player.GetAll()) do
		local cloaked = p:GetNetworkedBool("ArthurCloaked",NULL); -- If a player hasn't cloaked himself yet, we do not want to override color at all (It conflicted on my server
		local sodan_cloaked = p:GetNWBool("pCloaked",NULL); -- sodan thing
		if(cloaked ~= NULL) then
			local weapon = p:GetActiveWeapon();
			local color = p:GetColor();
			local r,g,b,a = color.r,color.g,color.b,color.a;
			if cloaked_self then
				if cloaked then a = 255;
				elseif sodan_cloaked then a = 255 end
			else
				if cloaked then
					a = 0;
					p.__HasBeenCloaked = true;
				elseif (a == 0 and p.__HasBeenCloaked) then -- If he is uncloaked but still at 0 alpha, make him visible back again (Failsafe) - But do this only, if WE have cloaked him
					a = 255;
					p.__HasBeenCloaked = false;
				end
			end
			p:SetRenderMode( RENDERMODE_TRANSALPHA );
			p:SetColor(Color(r,g,b,a)); -- Cloak, lol
			if(IsValid(weapon)) then
				weapon:SetColor(Color(255,255,255,a)); -- Cloak his weapon too
			end
		end
	end
end

function ENT:Draw()

	self.Entity:DrawModel();

	local players = self.Entity:GetNWString("CloackedPlayers"):TrimExplode(",");

	if table.HasValue(players, tostring(  LocalPlayer():EntIndex()  )  ) then

		local pos = self.Entity:GetPos() + self.Entity:GetUp()*50
		local ang = self.Entity:GetAngles();
		ang:RotateAroundAxis(ang:Up(), 90);
		ang:RotateAroundAxis(ang:Forward(), 90);

		local Col = Color(math.Rand(200,255),math.Rand(50,75),math.Rand(25,50),math.Rand(150,200))

		cam.Start3D2D(pos, ang, 0.05 );
			draw.DrawText("It's an Arthus Mantle, it was created", "Ancients", 0, 0, Col, TEXT_ALIGN_CENTER );
			draw.DrawText("by by Merlin, also known as Merudin", "Ancients", 0, 100, Col, TEXT_ALIGN_CENTER );
			draw.DrawText("and by Madman 07. Use that to hide", "Ancients", 0, 200, Col, TEXT_ALIGN_CENTER );
			draw.DrawText("your work before ancients. Take", "Ancients", 0, 300, Col, TEXT_ALIGN_CENTER );
			draw.DrawText("and remebmer that gate address.", "Ancients", 0, 400, Col, TEXT_ALIGN_CENTER );
		cam.End3D2D();

		Col = Color(255,math.Rand(20,30),math.Rand(20,30),math.Rand(150,200))

		cam.Start3D2D(pos, ang, 0.05 );
			draw.DrawText("GYEBND#", "Glyphs", 0, 500, Col, TEXT_ALIGN_CENTER );
		cam.End3D2D();

		local ang = self.Entity:GetAngles();
		ang:RotateAroundAxis(ang:Up(), 90);
		ang:RotateAroundAxis(ang:Forward(), 90);
		ang:RotateAroundAxis(ang:Right(), 180);

		Col = Color(math.Rand(200,255),math.Rand(50,75),math.Rand(25,50),math.Rand(150,200))

		cam.Start3D2D(pos, ang, 0.05 );
			draw.DrawText("It's an Arthus Mantle, it was created", "Ancients", 0, 0, Col, TEXT_ALIGN_CENTER );
			draw.DrawText("by by Merlin, also known as Merudin", "Ancients", 0, 100, Col, TEXT_ALIGN_CENTER );
			draw.DrawText("and by Madman 07. Use that to hide", "Ancients", 0, 200, Col, TEXT_ALIGN_CENTER );
			draw.DrawText("your work before ancients. Take", "Ancients", 0, 300, Col, TEXT_ALIGN_CENTER );
			draw.DrawText("and remebmer that gate address.", "Ancients", 0, 400, Col, TEXT_ALIGN_CENTER );
		cam.End3D2D();

		Col = Color(255,math.Rand(20,30),math.Rand(20,30),math.Rand(150,200))

		cam.Start3D2D(pos, ang, 0.05 );
			draw.DrawText("GYEBND#", "Glyphs", 0, 500, Col, TEXT_ALIGN_CENTER );
		cam.End3D2D();

	end

end

-- HACKY HACKY HACKY HACKY HACKY @aVoN
-- Stops making players "recognizeable" if they are cloaked (E.g. by looking at them - Before you e.g. saw "Catdaemon - Health 100" if you lookaed at a cloaked player. Now, you dont see anything if he is cloaked
if(util.__TraceLine) then return end;
util.__TraceLine = util.TraceLine;
function util.TraceLine(...)
	local t = util.__TraceLine(...);
	if(t and IsValid(t.Entity)) then
		if(t.Entity:IsPlayer()) then
			if(not LocalPlayer():GetNetworkedBool("ArthurCloaked",false) and t.Entity:GetNWBool("ArthurCloaked",false)) then t.Entity = NULL end;
		end
	end
	return t;
end
