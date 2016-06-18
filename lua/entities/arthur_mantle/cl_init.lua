--[[
	Arthurs Mantle
	Copyright (C) 2010 Madman07
	Secret Code added by AlexALX
]]--

include("shared.lua");

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_main_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_arthurs_mantle");
end

ENT.AFont = "Anquietas"
ENT.SFont = "Stargate Address Glyphs Concept"

local font = {
	font = ENT.AFont,
	size = 35,
	weight = 400,
	antialias = true,
	additive = true,
}
surface.CreateFont("AncientsC", font);

local font = {
	font = "Roboto",
	size = ScreenScale(70),
	weight = 400,
	antialias = true,
	additive = true,
}
surface.CreateFont("MantleErr", font);

local font = {
	font = ENT.SFont,
	size = 35,
	weight = 400,
	antialias = true,
	additive = true,
}
surface.CreateFont("GlyphsC", font);

/*
-- Damn, recoded this myself for fix stupid bugs with flashlight and cloak. I hope now all works fine (c) AlexALX
hook.Add("Think","StarGate.ArthurCloaking.Think",
	function()
		local cloaked_self = LocalPlayer():GetNetworkedBool("ArthurCloaked",false);
		local sodan_self = LocalPlayer():GetNetworkedBool("pCloaked",false);
		for k,p in pairs(player.GetHumans()) do
			local cloaked = p:GetNWBool("ArthurCloaked",NULL); -- If a player hasn't cloaked himself yet, we do not want to override color at all (It conflicted on my server
			local sodan_cloaked = p:GetNWBool("pCloaked",NULL); -- sodan thing
			if(cloaked ~= NULL or sodan_cloaked ~= NULL) then
				if (cloaked==NULL) then cloaked = false end
				if (sodan_cloaked==NULL) then sodan_cloaked = false end
				local weapon = p:GetActiveWeapon();
				local color = p:GetColor();
				local r,g,b,a = color.r,color.g,color.b,color.a;
				local c = false;
				if (cloaked_self and sodan_self) then
					if (cloaked or sodan_cloaked) then a = 255; end
				elseif(cloaked_self) then
					if (cloaked and not sodan_cloaked) then a = 255; elseif (sodan_cloaked) then a = 0; c = true; end
				elseif(sodan_self) then
					if (sodan_cloaked and not cloaked) then a = 255; elseif (cloaked) then a = 0; c = true; end
				else
					if (cloaked or sodan_cloaked) then a = 0; c = true end
				end
				if (c and p.__SGCloakMaterial==nil) then
					p.__SGCloakMaterial = p:GetMaterial();
					p:SetMaterial("models/effects/vol_light001");
				elseif (not c and p.__SGCloakMaterial!=nil) then
					a = 255;
					if (p.__SGCloakMaterial=="models/effects/vol_light001") then
						p:SetMaterial("");
					else
						p:SetMaterial(p.__SGCloakMaterial);
					end
					p.__SGCloakMaterial = nil;
				end
				p:SetRenderMode( RENDERMODE_TRANSALPHA );
				p:SetColor(Color(r,g,b,a)); -- Cloak, lol
				if(IsValid(weapon)) then
					weapon:SetRenderMode( RENDERMODE_TRANSALPHA )
					weapon:SetColor(Color(255,255,255,a)); -- Cloak his weapon too
				end
			elseif(p.__SGCloakMaterial!=nil) then
				local color = p:GetColor();
				local r,g,b = color.r,color.g,color.b;
				local weapon = p:GetActiveWeapon();
				if (p.__SGCloakMaterial=="models/effects/vol_light001") then
					p:SetMaterial("");
				else
					p:SetMaterial(p.__SGCloakMaterial);
				end
				p.__SGCloakMaterial = nil;
				p:SetRenderMode( RENDERMODE_TRANSALPHA );
				p:SetColor(Color(r,g,b,255));
				if(IsValid(weapon)) then
					weapon:SetRenderMode( RENDERMODE_TRANSALPHA )
					weapon:SetColor(Color(255,255,255,255)); -- Cloak his weapon too
				end
			end
		end
	end
);        */

local font = {
	font = ENT.SFont,
	size = ScreenScale(35),
	weight = 400,
	antialias = true,
	additive = true,
}
surface.CreateFont("Glyphs", font);

-- New much better way without overriding alpha on players @ AlexALX
hook.Add("PrePlayerDraw","StarGate.ArthurCloak", function(p)
		if (not IsValid(p)) then return end
		local cloaked_self = LocalPlayer():GetNetworkedBool("ArthurCloaked",false);
		local sodan_self = LocalPlayer():GetNetworkedBool("pCloaked",false);

		local cloaked = p:GetNWBool("ArthurCloaked",NULL); -- If a player hasn't cloaked himself yet, we do not want to override color at all (It conflicted on my server
		local sodan_cloaked = p:GetNWBool("pCloaked",NULL); -- sodan thing
		if(cloaked ~= NULL or sodan_cloaked ~= NULL) then
			if (cloaked==NULL) then cloaked = false end
			if (sodan_cloaked==NULL) then sodan_cloaked = false end
			local cloak = false;
			if(cloaked_self and not sodan_self) then
				if (sodan_cloaked) then cloak = true; end
			elseif(sodan_self and not cloaked_self) then
				if (cloaked) then cloak = true; end
			elseif(not sodan_self and not cloaked_self) then
				if (cloaked or sodan_cloaked) then cloak = true; end
			end
			if cloak then return true end -- cloak
		end
	end
);

local font = {
	font = ENT.AFont,
	size = ScreenScale(35),
	weight = 400,
	antialias = true,
	additive = true,
}
surface.CreateFont("Ancients", font);

-- Stops making players "recognizeable" if they are cloaked (E.g. by looking at them - Before you e.g. saw "Catdaemon - Health 100" if you lookaed at a cloaked player. Now, you dont see anything if he is cloaked
hook.Add("HUDDrawTargetID","StarGate.ArthurCloak", function()
	local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end
	if (!trace.HitNonWorld) then return end

	if (trace.Entity:IsPlayer()) then
		if(not LocalPlayer():GetNetworkedBool("ArthurCloaked",false) and trace.Entity:GetNWBool("ArthurCloaked",false)) then return false end;
	end
end);

local datatable = {}

function ENT:Think()

	local cloak = LocalPlayer():GetNetworkedBool("ArthurCloaked",false);
	if cloak and self:GetSkin()==1 then
		self:SetSkin(0);
	elseif not cloak and self:GetSkin()==0 then
		self:SetSkin(1);
	end

	self.Entity:NextThink(CurTime() + 0.5)
	return true
end

local validfont
local function checkfont(self)
	if (validfont!=nil) then return validfont end
	surface.SetFont( "AncientsC" )
	local w = surface.GetTextSize("SoMe TeXt HerE 12-12 %$");
	surface.SetFont( "GlyphsC" )
	local w2 = surface.GetTextSize("SOMETEXTHERE0123#*xyz");
	if (w==321 and (w2==716 or w2==733 and not system.IsWindows())) then
		validfont = true
	end
	if (self.AFont!=self.TFont) then validfont = false end
	if (self.SFont!=self.GFont) then validfont = false end
	if (validfont==nil) then validfont = false end
	return validfont;
end

local checkdata = false
if (file.Exists("entities/arthur_mantle/cl_data.lua","LUA")) then
	local str = util.Decompress(file.Read("entities/arthur_mantle/cl_data.lua","LUA") or "") or "";
	local str_exp = string.Explode("||\n\n||",str);
	local tbl = {}
	for k=1,table.Count(str_exp) do
		if (str_exp[k] and str_exp[k]!="") then
			local tmp = string.Explode("|\n|",str_exp[k]);
			if (table.Count(tmp)>2) then
				local t = tonumber(util.Decompress(tmp[1]) or "") or 0;
				tbl[t] = {}
				for l=2,table.Count(tmp)-1 do
					table.insert(tbl[t],util.Decompress(tmp[l]) or "");
				end
				if (util.CRC(string.Implode("",tbl[t]))!=tmp[table.Count(tmp)]) then
					tbl[t] = nil
					break;
				end
			end
		end
	end
	if (table.Count(tbl)==9) then
		datatable = tbl;
		checkdata = true;
	end
end

function ENT:Draw()

	self.Entity:DrawModel();

	if LocalPlayer():GetNetworkedBool("ArthurCloaked",false) then

		local pos = self.Entity:GetPos() + self.Entity:GetUp()*50
		for i=0,1 do
			local ang = self.Entity:GetAngles();
			ang:RotateAroundAxis(ang:Up(), 90);
			ang:RotateAroundAxis(ang:Forward(), 90);
			if (i==1) then
				ang:RotateAroundAxis(ang:Right(), 180);
			end

			local Col = Color(math.Rand(200,255),math.Rand(50,75),math.Rand(25,50),math.Rand(150,200));
			if (not checkdata or not checkfont(self)) then
				cam.Start3D2D(pos, ang, 0.05 );
					draw.DrawText(not checkdata and "DATA ERROR" or "FONT ERROR", "MantleErr", 0, 600, Col, TEXT_ALIGN_CENTER );
				cam.End3D2D();
			else
				cam.Start3D2D(pos, ang, 0.05 );
					if (self:GetNWInt("Step",0)==1) then
						draw.DrawText(datatable[1][1], "Ancients", 0, 0, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[1][2], "Ancients", 0, 100, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[1][3], "Ancients", 0, 200, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[1][4], "Ancients", 0, 300, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[1][5], "Ancients", 0, 400, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(self:GetNWString("Phase","error"), "Ancients", 0, 500, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[1][6], "Ancients", 0, 600, Col, TEXT_ALIGN_CENTER );
					elseif (self:GetNWInt("Step",0)==2) then
						draw.DrawText(datatable[2][1], "Ancients", 0, 0, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[2][2], "Ancients", 0, 100, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[2][3], "Ancients", 0, 200, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[2][4], "Ancients", 0, 300, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(self:GetNWString("Phase","error"), "Ancients", 0, 400, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[2][5], "Ancients", 0, 500, Col, TEXT_ALIGN_CENTER );
					elseif (self:GetNWInt("Step",0)==3) then
						draw.DrawText(datatable[3][1], "Ancients", 0, 0, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[3][2], "Ancients", 0, 100, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[3][3], "Ancients", 0, 200, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[3][4], "Ancients", 0, 300, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[3][5], "Ancients", 0, 400, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[3][6], "Ancients", 0, 500, Col, TEXT_ALIGN_CENTER );
					elseif (self:GetNWInt("Step",0)==4) then
						draw.DrawText(datatable[4][1], "Ancients", 0, 0, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[4][2], "Ancients", 0, 100, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[4][3], "Ancients", 0, 200, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[4][4], "Ancients", 0, 300, Col, TEXT_ALIGN_CENTER );
						local adr = self:GetNWString("Scr","ERROR");
						if (adr=="ERROR") then
							draw.DrawText(adr, "MantleErr", 0, 400, Col, TEXT_ALIGN_CENTER );
						else
							draw.DrawText(adr, "Glyphs", 0, 400, Col, TEXT_ALIGN_CENTER );
						end
						draw.DrawText(datatable[4][5], "Ancients", 0, 500, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[4][6], "Ancients", 0, 600, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[4][7], "Ancients", 0, 700, Col, TEXT_ALIGN_CENTER );
					elseif (self:GetNWInt("Step",0)==5) then
						draw.DrawText(datatable[5][1], "Ancients", 0, 0, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[5][2], "Ancients", 0, 100, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[5][3], "Ancients", 0, 200, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[5][4], "Ancients", 0, 300, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[5][5], "Ancients", 0, 400, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[5][6], "Ancients", 0, 500, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[5][7], "Ancients", 0, 600, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[5][8], "Ancients", 0, 700, Col, TEXT_ALIGN_CENTER );
					elseif (self:GetNWInt("Step",0)==6) then
						draw.DrawText(datatable[6][1], "Ancients", 0, 0, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[6][2], "Ancients", 0, 100, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[6][3], "Ancients", 0, 200, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[6][4], "Ancients", 0, 300, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[6][5], "Ancients", 0, 400, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[6][6], "Ancients", 0, 500, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[6][7], "Ancients", 0, 600, Col, TEXT_ALIGN_CENTER );
					elseif (self:GetNWInt("Step",0)==7) then
						draw.DrawText(datatable[7][1], "Ancients", 0, 0, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[7][2], "Ancients", 0, 100, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[7][3], "Ancients", 0, 200, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[7][4], "Ancients", 0, 300, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[7][5], "Ancients", 0, 400, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[7][6], "Ancients", 0, 500, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[7][7], "Ancients", 0, 600, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[7][8], "Ancients", 0, 700, Col, TEXT_ALIGN_CENTER );
					elseif (self:GetNWInt("Step",0)==8) then
						draw.DrawText(datatable[8][1], "Ancients", 0, 0, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[8][2], "Ancients", 0, 100, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[8][3], "Ancients", 0, 200, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[8][4], "Ancients", 0, 300, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[8][5], "Ancients", 0, 400, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[8][6], "Ancients", 0, 500, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[8][7], "Ancients", 0, 600, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[8][8], "Ancients", 0, 700, Col, TEXT_ALIGN_CENTER );
					else
						draw.DrawText(datatable[0][1], "Ancients", 0, 0, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[0][2], "Ancients", 0, 100, Col, TEXT_ALIGN_CENTER );
						draw.DrawText(datatable[0][3], "Ancients", 0, 200, Col, TEXT_ALIGN_CENTER );
						local hi = 300
						if (self:GetNWString("Phase","")=="") then
							draw.DrawText(datatable[0][4]..datatable[0][5], "Ancients", 0, hi, Col, TEXT_ALIGN_CENTER );
						else
							draw.DrawText(datatable[0][4].." Secret code", "Ancients", 0, hi, Col, TEXT_ALIGN_CENTER );
							draw.DrawText("is "..self:GetNWString("Phase","error").." "..datatable[0][5], "Ancients", 0, hi+100, Col, TEXT_ALIGN_CENTER );
						end
						draw.DrawText(datatable[0][6], "Ancients", 0, hi+200, Col, TEXT_ALIGN_CENTER );
						Col = Color(255,math.Rand(20,30),math.Rand(20,30),math.Rand(150,200));
						draw.DrawText(datatable[0][7], "Glyphs", 0, hi+300, Col, TEXT_ALIGN_CENTER );
					end
				cam.End3D2D();
			end
		end

	end

end
       /*
-- HACKY HACKY HACKY HACKY HACKY @aVoN
-- Stops making players "recognizeable" if they are cloaked (E.g. by looking at them - Before you e.g. saw "Catdaemon - Health 100" if you lookaed at a cloaked player. Now, you dont see anything if he is cloaked
if(util._Arthur_TraceLine) then return end;
util._Arthur_TraceLine = util.TraceLine;
function util.TraceLine(...)
	local t = util._Arthur_TraceLine(...);
	if(t and IsValid(t.Entity)) then
		if(t.Entity:IsPlayer()) then
			if(not LocalPlayer():GetNetworkedBool("ArthurCloaked",false) and t.Entity:GetNWBool("ArthurCloaked",false)) then t.Entity = NULL end;
		end
	end
	return t;
end     */