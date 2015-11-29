-- jumperhud.lua

local PANEL = {};
PANEL.Fonts = {};
local w = ScrW()*0.99;
local h = (w/4096)*512*(3/4);
local x = ScrW()/4*0;
local y = ScrH()/4*3.5;
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
	w = ScrW()*0.99;
	h = (w/4096)*512*(3/4);
	font.size = (w/1024)*30
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
	
	local multiply = 0;
	if(ScrH()==768 and ScrW()==1024) then
		multiply = 5;
	elseif(ScrW()==1920 and ScrH()==1080) then
		multiply = -15;
	elseif(ScrW()==1600 and ScrH()==900) then
		multiply = -10;
	end
	
	surface.SetFont("CenterHud")
	surface.SetTextPos(ScrW()/4*1.92,65-multiply)
	surface.SetTextColor(Ecolor)
	surface.DrawText("Engine")

	surface.SetTextPos(ScrW()/4*1.57,30-multiply)
	surface.SetTextColor(Ccolor)
	surface.DrawText("Cloak")

	surface.SetTextPos(ScrW()/4*2.27,30-multiply)
	surface.SetTextColor(Wcolor)
	surface.DrawText("Weapons")

	surface.SetTextPos(ScrW()/4*1.92,25-multiply)
	surface.SetTextColor(Scolour)
	surface.DrawText("Shield")

	surface.SetFont("JumperFont")
	surface.SetTextPos(ScrW()/4*0.6,35-multiply)
	surface.SetTextColor(WHITE)
	if not self.Data.Health then return end
	surface.DrawText("Hull: "..(math.Round(self.Data.Health/5)).."%")

	surface.SetFont("JumperFont")
	surface.SetTextPos(ScrW()/4*2.95,35-multiply)
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

-- jumperlsd.lua

local PANEL = {};
local LSD = surface.GetTextureID("Markjaw/LSD/dot");

function PANEL:Init()

	self:SetSize(ScrW(),ScrH())
	self:SetPos(0,0)
	self:SetVisible(false)
	self.GroupSystem = false;

end

local dot = surface.GetTextureID("Markjaw/LSD/dot");
local x,y;
local sX,sY;
local gX,gY;
local vX,vY;
local s = "";
local gate = "";
function PANEL:Paint()
	local Jumper = LocalPlayer():GetNetworkedEntity("jumper",NULL);
	local Pilot = LocalPlayer():GetNetworkedEntity("JPilot",NULL);
	local viewpoint = Jumper:GetPos()+Jumper:GetForward()*75+Jumper:GetUp()*25
	for k,v in pairs(ents.FindInCone(viewpoint,Jumper:GetForward(),10000,60)) do
		local pos = (Jumper:GetPos() - v:GetPos()):Length()
		if(v:IsNPC() or v:IsPlayer()) then
			if(not(LocalPlayer()==v)) then
				local vpos = v:GetPos()+Vector(0,0,20);
				local screen = vpos:ToScreen();
				for k,v in pairs(screen) do
					if k=="x" then
						x = v;
					elseif k=="y" then
						y = v;
					end
				end
				if(v:IsPlayer()) then
					s = v:GetName();
				elseif(v:IsNPC()) then
					s = v:GetClass();
					s = string.Replace(s,"npc_","");
					s = string.upper(s);
				end

				surface.SetTexture(dot);

				if (pos<10000) then
					surface.DrawTexturedRect(x-16, y-16, 32, 32);
					surface.SetFont("Default");
					surface.SetTextPos(x+20,y-20);
					surface.SetTextColor(Color(255,0,0,255));
					surface.DrawText(s);
					surface.SetTextPos(x+20,y);
					surface.DrawText(v:Health().."%");

				end
			end
		elseif(v.IsStargate) then
			local spos = v:GetPos();
			local toScreen = spos:ToScreen();
			for k,v in pairs(toScreen) do
				if k=="x" then
					sX = v;
				elseif k=="y" then
					sY = v;
				end
			end
			gate = v.PrintName or v:GetClass();
			if(pos<2500) then
				surface.SetFont("Default");
				surface.SetTextPos(sX+60,sY-60-(pos/75));
				surface.SetTextColor(Color(255,0,0,255));
				surface.DrawText(gate);
				surface.SetTextPos(sX+60,sY-45-(pos/75));
				surface.DrawText(SGLanguage.GetMessage("stargate_vgui_name").." "..v:GetGateName());
				surface.SetTextPos(sX+60,sY-30-(pos/75));
				surface.DrawText(SGLanguage.GetMessage("stargate_vgui_address").." "..v:GetGateAddress());
				local posy = 15;
				if (self.GroupSystem and not v.IsSupergate) then
					posy = 0;
					surface.SetTextPos(sX+60,sY-15-(pos/75));
					if (v:GetClass()=="stargate_universe") then
						surface.DrawText(SGLanguage.GetMessage("stargate_vgui_type").." "..v:GetGateGroup());
					else
						surface.DrawText(SGLanguage.GetMessage("stargate_vgui_group").." "..v:GetGateGroup());
					end
				end
				if(v:GetDialledAddress()!="") then
					surface.SetTextPos(sX+60,sY-posy-(pos/75));
					if (v:GetDialledAddress():find("?")) then
						surface.DrawText(SGLanguage.GetMessage("jumper_hud_dial").." "..string.rep("*",v:GetDialledAddress():len()));
					else
						surface.DrawText(SGLanguage.GetMessage("jumper_hud_dial").." "..v:GetDialledAddress());
					end
				end
			else
				local gpos = v:GetPos();
				local tScreen = gpos:ToScreen();
				for k,v in pairs(tScreen) do
					if k=="x" then
						gX = v;
					elseif k=="y" then
						gY = v;
					end
				end
				draw.WordBox(4,gX,gY,gate,"Default", Color(0,0,255,127.5),Color(255,0,0,255) )
			end
		/*elseif(v.IsSGVehicle) then
			if(pos>1000) then
				local vpos = v:GetPos();
				local vScreen = vpos:ToScreen();
				for k,v in pairs(vScreen) do
					if k=="x" then
						vX = v;
					elseif k=="y" then
						vY = v;
					end
				end
				draw.WordBox(4,vX,vY,v.Vehicle.." (HP: "..v:GetNetworkedInt("health",0)..")","Default", Color(0,0,255,127.5),Color(255,0,0,255) )
			end*/
		end
	end
	return true;
end


--################# Activate Panel @aVoN
function PANEL:Activate()
	if(not self.Active) then
		self.GroupSystem = util.tobool(StarGate.GroupSystem or 0);
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
vgui.Register("JumperLSD",PANEL,"Panel");