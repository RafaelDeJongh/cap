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