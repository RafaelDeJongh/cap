local PANEL = {};
PANEL.Fonts = {};
local w = ScrW()*0.99;
local h = (w/4096)*512*(3/4);
local x = ScrW()/4*0;
local y = ScrH()/4*3.5
local HUD = surface.GetTextureID("VGUI/HUD/puddle_jumper/J_hud")
local GREEN = Color(0,255,0,255);
local RED = Color(255,0,0,255);
local WHITE = Color(255,255,255,255);
local num = 3.5;

local font = {
	font = "Default",
	size = (w/1024)*30,
	weight = 400,
	antialias = true,
	additive = false,
}
surface.CreateFont("JumperFont", font);
local font = {
	font = "Default",
	size = (w/1024)*20,
	weight = 400,
	antialias = true,
	additive = false,
}
surface.CreateFont("CenterHud", font);

function PANEL:Init()

	self.Data = {
		CanShoot = true,
		CanShield = true,
		CantCloak = false,
		Cloaked = false,
		Engine = true,
		Health = 500,
		Drones = 0,
	};

	self:SetSize(w,h)
	self:SetPos(x,y)
	self:SetVisible(false)

end

function PANEL:Think()

	local p = LocalPlayer();
	local alpha = 255;
	local Jumper = p:GetNetworkedEntity("jumper",NULL);
	if(not IsValid(Jumper)) then alpha = 0 end; -- Should never happen!
	num = math.Approach(num,alpha,10);
	self:SetAlpha(num);
	if(num == 0) then self:Deactivate() end;
	if(alpha == 0) then return end; -- Do not update. Just fade out

end

function PANEL:Paint()

	if not self.Active then return end;

	surface.SetTexture(HUD) -- Print the texture to the screen
	surface.SetDrawColor(255,255,255,255) -- Colour of the HUD
	surface.DrawTexturedRect(0,0,w,h) -- Position, Size

	local Ccolor = GREEN -- Cloak Status Colour
	local Wcolor = GREEN -- Weapon Status Colour
	local Scolour = GREEN -- Shield Status Colour
	local Ecolor = GREEN -- Engine Status Colour

	if(self.Data.CantCloak) then Ccolor = RED end -- Cloak damaged
	if(not(self.Data.CanShoot)) then Wcolor = RED end --Weapons damaged
	if(not(self.Data.CanShield)) then
		if(not(self.Data.Cloaked)) then
			Scolour = RED
		end
	end
	if not self.Data.Engine then Ecolor = RED end; -- Engine Damaged

	surface.SetFont("CenterHud")
	surface.SetTextPos(ScrW()/4*1.92,65)
	surface.SetTextColor(Ecolor)
	surface.DrawText("Engine")

	surface.SetTextPos(ScrW()/4*1.57,30)
	surface.SetTextColor(Ccolor)
	surface.DrawText("Cloak")

	surface.SetTextPos(ScrW()/4*2.27,30)
	surface.SetTextColor(Wcolor)
	surface.DrawText("Weapons")

	surface.SetTextPos(ScrW()/4*1.92,25)
	surface.SetTextColor(Scolour)
	surface.DrawText("Shield")

	surface.SetFont("JumperFont")
	surface.SetTextPos(ScrW()/4*0.6,35)
	surface.SetTextColor(WHITE)
	if not self.Data.Health then return end
	surface.DrawText("Hull: "..(math.Round(self.Data.Health/5)).."%")

	surface.SetFont("JumperFont")
	surface.SetTextPos(ScrW()/4*2.95,35)
	surface.SetTextColor(WHITE)
	surface.DrawText(self.Data.Drones.."/"..(6 - self.Data.Drones))

	return true;

end

--################# Activate Panel @aVoN
function PANEL:Activate()
	if(not self.Active) then
		self:SetVisible(true); -- Calling SetVisible all the time causes heavy CPU Load
		self.Active = true;
	end
end

--################# Deactivate Panel @aVoN
function PANEL:Deactivate()
	if(self.Active) then
		self:SetVisible(false); -- Calling SetVisible all the time causes heavy CPU Load
		self.Active = nil;
	end
end
vgui.Register("JumperHUD",PANEL,"Panel");