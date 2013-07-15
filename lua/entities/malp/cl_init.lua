include("shared.lua")
ENT.Category = Language.GetMessage("entity_main_cat");
ENT.PrintName = Language.GetMessage("entity_malp");
local MAXDIST = 5000
local KBD = StarGate.KeyBoard:New("MALP")
--Navigation
KBD:SetDefaultKey("FWD","W")
KBD:SetDefaultKey("LEFT","A")
KBD:SetDefaultKey("RIGHT","D")
KBD:SetDefaultKey("BACK","S")
KBD:SetDefaultKey("VIEW","1")

KBD:SetDefaultKey("CAMUP","UPARROW")
KBD:SetDefaultKey("CAMDOWN","DOWNARROW")
KBD:SetDefaultKey("CAMLEFT","LEFTARROW")
KBD:SetDefaultKey("CAMRIGHT","RIGHTARROW")
KBD:SetDefaultKey("RESETCAM","R")

function ENT:Draw() self:DrawModel() end

function ENT:Initialize()

	self.KBD = self.KBD or KBD:CreateInstance(self)

end


local function SetData(um)
	local p = LocalPlayer()
	p.SignalLost = um:ReadBool()
	gravity = um:ReadShort()
	habitat = um:ReadShort()
	atmosphere = um:ReadShort()
	temp = um:ReadShort()
end
usermessage.Hook("MALPData", SetData)

function ENT:Think()

	local p = LocalPlayer()
	local control = p:GetNetworkedBool("ControllingMALP",false)

	if(control) then
		self.KBD:SetActive(true)
	else
		self.KBD:SetActive(false)
	end
end


--[[ The following is taken from MadJawa's malp code,
but edited to work with mine. It is not a complete copy and paste
but most credit should go to Madjawa
]]--
--################# Renders the fullscreen MALP view @MadJawa, RononDex
local mat = StarGate.MaterialCopy("MalpBlur","pp/blurscreen");
local TEXTURES = {
	Overlay = surface.GetTextureID("VGUI/malp/malpoverlay"),
	Input = surface.GetTextureID("VGUI/malp/malpoverlayinput"),
	Square = surface.GetTextureID("VGUI/malp/malpoverlaysquare"),
	Dots = surface.GetTextureID("VGUI/malp/malpoverlaydots"),
	Signal = {
		surface.GetTextureID("VGUI/malp/malpoverlaysignal0"),
		surface.GetTextureID("VGUI/malp/malpoverlaysignal1"),
	}
}
local FONT = "MALP_Font";
local fnt = {
	font = "Old Republic",
	size = math.ceil(0.023*ScrH() + 3.85),
	weight = 500,
	antialias = true,
	additive = true,
}
surface.CreateFont(FONT, fnt)

local function RenderMALPHud()
	local p = LocalPlayer();
	local malp = p:GetNWEntity("MALP")
	local pos = p:GetPos()
	local time = CurTime();
	local w,h = ScrW(),ScrH();
	local fpv = p:GetNWBool("FirstPerson")
	if (fpv) then
		if(IsValid(malp)) then
			local dist = (pos-malp:GetPos()):Length()

			-- this is the distance at which we start losing the signal
			local badDist = 5000-350;

			if (dist > badDist) then
				if(p.SignalLost) then
					-- FIXME: make a better effect (tv static or something)
					local n = dist-badDist;

					mat:SetFloat( "$blur", (n/20)*(math.sin(time)+3));
					render.UpdateScreenEffectTexture();
					surface.SetMaterial(mat);
					surface.SetDrawColor(255, 255, 255, 255);
					surface.DrawTexturedRect(0, 0, w, h);

					surface.SetDrawColor(0, 0, 0, math.Clamp(n*3/4, 0, 255));
					surface.DrawRect(-1, -1, w+1, h+1);
				end
			end


			-- drawing various MALP HUD parts
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetTexture(TEXTURES.Overlay)
			surface.DrawTexturedRect(0, 0, w, h);

			-- multiplicator used to scale the MALP HUD to all resolutions
			local widthMul, heightMul = w/1280, h/1024;
			local width, height = 512*widthMul, 256*heightMul;

			surface.SetDrawColor(255, 255, 255, math.abs(math.sin(3*time)*255))
			surface.SetTexture(TEXTURES.Input)
			surface.DrawTexturedRect(0, h-height, width, height);

			surface.SetDrawColor(255, 255, 255, math.Clamp(4*math.sin(2*time)*255, 0, 255))
			surface.SetTexture(TEXTURES.Square)
			surface.DrawTexturedRect(0, h-height, width, height);

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetTexture(TEXTURES.Dots)
			surface.DrawTexturedRect(0, h-height, width, height);

			local alpha, signal = 255, 2;
			if (dist > MAXDIST) then
				if(p.SignalLost) then
					alpha = math.abs(math.sin(2*time)*255);
					signal = 1;
				end
			end

			-- drawing Signal Lost or Uplinked depending on the distance
			surface.SetDrawColor(255, 255, 255, alpha)
			surface.SetTexture(TEXTURES.Signal[signal])
			surface.DrawTexturedRect(w/2-(512*widthMul/2), h-(128*heightMul), 512*widthMul, 128*heightMul);


			-- If SB isn't installed, it'll show default values. I think it's better than having nothing in the corner

			local habitable = habit or 1;
			local mgravity = gravity or 1;
			local pressure = atmosphere or 1;
			local temperature = temp or 288;

			if(habitable == 1) then habitable = "Yes"; else habitable = "No"; end

			-- too far: don't show the informations
			if(dist > MAXDIST) then
				if(p.SignalLost) then -- Too far away and no active gate connecting the signals
					habitable = "-";
					mgravity = "-";
					pressure = "-";
					temperature = "-";
				end
			end

			draw.SimpleText("Habitable: "..habitable,FONT, 955*widthMul, 862*heightMul, color_white);
			draw.SimpleText("Gravity: "..mgravity.." G",FONT, 955*widthMul, 891*heightMul, color_white);
			draw.SimpleText("Pressure: "..pressure.." Bar",FONT, 955*widthMul, 920*heightMul, color_white);
			draw.SimpleText("Temperature: "..temperature.." K",FONT, 955*widthMul, 949*heightMul, color_white);
		end
	end
end
hook.Add("HUDPaint", "RenderMALPHud", RenderMALPHud);