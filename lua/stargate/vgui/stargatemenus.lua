/*
	New stargate vgui menus
	-----------------------
	For Garry's Mod 13
	(c) 2014 by AlexALX
	-----------------------
	Based on old avon menus
	Copyright (C) 2007  aVoN

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

-- local table with all gates
local StarGate_GetAll = {};

local function StarGateRefreshList( len )
	local ent = net.ReadInt(16);
	if (not ent) then return end
	local class = net.ReadString();
	local gg = net.ReadBit()
	if (not StarGate_GetAll[ent]) then
		local info = {}
		info["ent"] = ent;
		info["groupgate"] = gg;
		info["address"] = "";
		info["group"] = "";
		info["name"] = "";
		info["private"] = false;
		info["blocked"] = false;
		info["locale"] = false;
		info["galaxy"] = false;
		info["class"] = class;
		info["pos"] = Vector(0,0,0);
		StarGate_GetAll[ent] = info;
	end
	local type = string.lower(net.ReadString());
	local typ = net.ReadString();
	if (typ=="bool") then
		StarGate_GetAll[ent][type] = util.tobool(net.ReadBit());
	elseif (typ=="vector") then
		StarGate_GetAll[ent][type] = net.ReadVector();
	else
		StarGate_GetAll[ent][type] = net.ReadString();
	end
end
net.Receive( "RefreshGateList", StarGateRefreshList);

local function StarGateRemoveFromList( len )
	local ent = net.ReadInt(16);
	if (not ent) then return end
	StarGate_GetAll[ent] = nil;
end
net.Receive( "RemoveGateFromList" , StarGateRemoveFromList );

local function StarGateRemoveList( len )
	StarGate_GetAll = {};
end
net.Receive( "RemoveGateList" , StarGateRemoveList );

--##################################
--###### msghooks.lua
--###### VGUI/Dial Menu
--##################################

-- Must be here now, and reloading with stargate_reload command, or we have bugs with new address list transfer client-side.

local VGUI
net.Receive("StarGate.VGUI.Menu",function(len)
	local gate = net.ReadEntity();
	if (not IsValid(gate)) then return end
	if(VGUI and VGUI:IsValid()) then
		VGUI:SetVisible(false);
	end
	local type = net.ReadInt(8);
	local groupsystem = gate:GetNetworkedBool("SG_GROUP_SYSTEM");
	if (type<=0) then -- 0 is normal menu, -1 is alternative (without dial)
		local candialg = util.tobool(gate:GetNetworkedInt("CANDIAL_GROUP_MENU"));
		local alternatemenu = (type<0);
		VGUI = vgui.Create("SControlePanel");
		VGUI:SetSettings(gate,groupsystem,alternatemenu,candialg);
		VGUI:SetVisible(true);
	elseif(type==1) then -- 1 is normal dial menu (used in ships/mobile dhd etc)
		local candialg = util.tobool(gate:GetNetworkedInt("CANDIAL_GROUP_DHD"));
		VGUI = vgui.Create("SControlePanelDHD");
		VGUI:SetSettings(gate,groupsystem,candialg);
		VGUI:SetVisible(true);
	elseif(type==2) then -- 2 is for dial menu with feature to override candialg option (for dhds/destiny console etc).
		local candialg = util.tobool(net.ReadBit());
		VGUI = vgui.Create("SControlePanelDHD");
		VGUI:SetSettings(gate,groupsystem,candialg);
		VGUI:SetVisible(true);
	elseif(type==3) then -- 3 is for nox dial
		local candialg = util.tobool(gate:GetNetworkedInt("CANDIAL_GROUP_DHD"));
		VGUI = vgui.Create("SControlePanelDHD");
		VGUI:SetSettings(gate,groupsystem,candialg,true);
		VGUI:SetVisible(true);
	elseif(type==4) then -- 4 is for orlin gate
		local candialg = util.tobool(gate:GetNetworkedInt("CANDIAL_GROUP_MENU"));
		VGUI = vgui.Create("SControlePanelDHD");
		VGUI:SetSettings(gate,groupsystem,candialg,false,true);
		VGUI:SetVisible(true);
	end
end)

-- ################# Reset vgui settings @ AlexALX
concommand.Add("stargate_reset_menu",function(ply)
	local RVGUI = vgui.Create("Panel");
	RVGUI:SetCookieName("StarGate.SControlePanel");
	RVGUI:SetCookie("SG.Size.W",nil);
	RVGUI:SetCookie("SG.Size.H",nil);
	RVGUI:SetCookie("SG.Pos.X",nil);
	RVGUI:SetCookie("SG.Pos.Y",nil);
	RVGUI:SetCookieName("StarGate.SControlePanel_Alt");
	RVGUI:SetCookie("SG.Pos.X",nil);
	RVGUI:SetCookie("SG.Pos.Y",nil);
	RVGUI:SetCookieName("StarGate.SControlePanelDHD");
	RVGUI:SetCookie("SG.Size.W",nil);
	RVGUI:SetCookie("SG.Size.H",nil);
	RVGUI:SetCookie("SG.Pos.X",nil);
	RVGUI:SetCookie("SG.Pos.Y",nil);
	RVGUI:SetCookieName("StarGate.SAddressSelect"); 
	RVGUI:SetCookie("ColumnSort",nil);
	RVGUI:SetCookie("ColumnSortDesc",nil);	
	RVGUI:SetCookie("DHDDial",nil);	
	RVGUI:Remove();
end)

-- ################# Closes the dialling Dialoge @aVoN
usermessage.Hook("StarGate.DialMenuDHDClose",
	function(data)
		if(VGUI and VGUI:IsValid()) then
			VGUI:SetVisible(false);
		end
	end
);

-- ################# Screen clicking code @aVoN
hook.Add("GUIMousePressed","StarGate.DHD.GUIMousePressed_Group",
	function(_,dir)
		--if(IsValid(DHD)) then
			local p = LocalPlayer();
			if (input.IsButtonDown( MOUSE_RIGHT ) or not IsValid(p)) then return end
			local trace = util.QuickTrace(p:GetShootPos(),dir*1024,p);
			if(IsValid(trace.Entity) and trace.Entity.IsDHD and not trace.Entity:GetNetworkedBool("BusyGUI",false)) then
				DHD = trace.Entity;
				if (DHD:GetPos():Distance(p:GetPos()) > 110) then return end
				local btn = DHD:GetCurrentButton(p);
				if(btn and btn != "IRIS") then
					p:ConCommand("_StarGate.DHD.AddSymbol_Group "..DHD:EntIndex().." "..btn);
					-- ######### Add/Remove symbols
					if(btn ~= "DIAL") then
						local chevrons = DHD:GetNWString("ADDRESS",""):upper():TrimExplode(",");
						btn = tostring(btn):upper();
						local add = true;
						for k,v in pairs(chevrons) do
							if(v == btn) then
								chevrons[k] = nil;
								add = false;
							end
							-- Should never be addedto the VGUI
							if(v == "DIAL") then
								chevrons[k] = nil;
							end
						end
						if(add and #chevrons < 9) then
							table.insert(chevrons,btn);
						end
						if (VGUI and VGUI:IsValid()) then VGUI:SetText(table.concat(table.ClearKeys(chevrons))); end
					end
				end
			end
		--end
	end
);

--##################################
--###### scontrolepanel.lua
--##################################

local PANEL = {}
PANEL.Data = {}
PANEL.Images = {
	Valid = "icon16/accept.png",
	Invalid = "icon16/cancel.png",
	Editing = "icon16/table_edit.png",
	Warning = "icon16/error.png",
	Info = "icon16/information.png",
	Shield = "icon16/shield.png",
}
PANEL.Sounds = {
	Warning = Sound("buttons/button2.wav"),
	Info = Sound("buttons/button9.wav"),
}

function PANEL:Init()
	self:SetPos(10,10);
end

--################# Set settings aka init panel @ AlexALX
function PANEL:SetSettings(entity,groupsystem,alternatemenu,candialg)
	if (not IsValid(entity) or not entity.IsStargate) then self:Remove() end
	self.Entity = entity;
	self.GroupSystem = groupsystem;
	self.Alternative = alternatemenu;
	self.CanDialGroups = candialg;
	self.Class = entity:GetClass();
	
	self.AlphaTime = CurTime(); -- For the FadeIn/Out

	if (self.Alternative) then
		self:SetCookieName("StarGate.SControlePanel_Alt");
		self:SetSize(225,210);
		--self:SetMinimumSize(225,210);
	else
		self:SetCookieName("StarGate.SControlePanel");
		self:SetSize(700,210);
		self:SetMinimumSize(700,210);

		self.Data.SizeW = self:GetCookie("SG.Size.W",700);
		self.Data.SizeH = self:GetCookie("SG.Size.H",210);
	end
	self.Data.PosX = self:GetCookie("SG.Pos.X",10);
	self.Data.PosY = self:GetCookie("SG.Pos.Y",10);

	self.VGUI = {
		TitleLabel = vgui.Create("DLabel",self),
		AddressPanel = vgui.Create("SAddressPanel",self),
		AddressLabel = {
			vgui.Create("DLabel",self),
			vgui.Create("DLabel",self), -- Black background/Shadow
		},
		NameTextEntry = vgui.Create("DTextEntry",self),
		NameLabel = vgui.Create("DLabel",self),
		PrivateImage = vgui.Create("DImage",self),
		PrivateCheckbox = vgui.Create("DCheckBoxLabel",self),
	}

	self.blocked_allowed = true;
	if (entity:GetNetworkedInt("SG_BLOCK_ADDRESS")<=0 or entity:GetNetworkedInt("SG_BLOCK_ADDRESS")==1 and self.Class!="stargate_universe" or self.Class=="stargate_supergate") then
		self.blocked_allowed = false;
	end

	if (self.blocked_allowed) then
		self.VGUI.BlockedCheckbox = vgui.Create("DCheckBoxLabel",self);
	end

	local pos = {133,172,160,190};
	if (not self.blocked_allowed) then
		pos[2] = 165;
	end
	if (self.Class=="stargate_supergate") then
		pos = {103,129,130};
	elseif (self.GroupSystem) then
		self.VGUI.LocaleCheckbox = vgui.Create("DCheckBoxLabel",self);
	elseif (self.Class!="stargate_universe") then
		pos = {103,142,130,160};
		if (not self.blocked_allowed) then
			pos[2] = 136;
		end
		self.VGUI.GalaxyCheckbox = vgui.Create("DCheckBoxLabel",self);
	elseif (self.Class=="stargate_universe") then
		pos = {103,136,130,145};
		if (not self.blocked_allowed) then
			pos = {103,129,130};
		end
	end

	if (not self.Alternative) then
		self.VGUI.AddressSelect = vgui.Create("SAddressSelect",self);
		self.VGUI.AddressSelectLabel = {
			vgui.Create("DLabel",self),
			vgui.Create("DLabel",self), -- Black background/Shadow
		}
	end

	-- The topic of the whole frame
	self.VGUI.TitleLabel:SetText(SGLanguage.GetMessage("stargate_vgui"));
	self.VGUI.TitleLabel:SetPos(30,7);
	self.VGUI.TitleLabel:SetWide(200);

	--###### Set Address
	-- The Topic of this section
	for i=1,2 do
		local mul = (i-1);
		self.VGUI.AddressLabel[i]:SetText(SGLanguage.GetMessage("stargate_vgui_settings"));
		self.VGUI.AddressLabel[i]:SetWide(150);
		self.VGUI.AddressLabel[i]:SetPos(30-mul*2,35-mul*2);
		self.VGUI.AddressLabel[i]:SetTextColor(Color(255*mul,255*mul,255*mul,255));
	end

	-- Our AddressPanel (Where we set Addresses with)
	self.VGUI.AddressPanel:SetPos(30,60);
	self.VGUI.AddressPanel.OnAddressSet = function(e,address,group)
		if((self.AlphaTime or 0)+0.3 < CurTime()) then -- Avoids the VGUI sending "SetGateAddress" everytime we open it!
			if (IsValid(e)) then
				e:SetGateAddress(address);
				if (group) then e:SetGateGroup(group); end
			end
			if (self.VGUI.AddressSelect) then
				timer.Remove("_StarGate.RefreshAddressList");
				timer.Create("_StarGate.RefreshAddressList",0.25,1,
					function()
						if(self!=nil and self.VGUI!=nil) then
							self.VGUI.AddressSelect:RefreshList(true);
						end
					end
				);
			end
		end
	end

	-- Name Label
	self.VGUI.NameLabel:SetPos(30,pos[1]);
	self.VGUI.NameLabel:SetText(SGLanguage.GetMessage("stargate_vgui_name"));

	-- Name TextEntry
	self.VGUI.NameTextEntry:SetPos(75,pos[1]);
	self.VGUI.NameTextEntry:SetWide(110);
	self.VGUI.NameTextEntry:SetTooltip(SGLanguage.GetMessage("stargate_vgui_nametip"));
	self.VGUI.NameTextEntry:SetAllowNonAsciiCharacters(true);
	self.VGUI.NameTextEntry.OnTextChanged = function(TextEntry)
		local s = TextEntry:GetValue();
		local e = self.Entity;
		local search = self.VGUI.AddressSelect;
		-- Do this within a timer to avoid constant calling of the concommand as soon as someont types in something
		timer.Remove("_StarGate.SetNameTime");
		timer.Create("_StarGate.SetNameTime",1,1,
			function()
				if(IsValid(e)) then
					e:SetGateName(s);
				end
			end
		);
	end

	--###### Private
	-- The Private Image
	self.VGUI.PrivateImage:SetPos(30,pos[2]); -- 159, 165
	self.VGUI.PrivateImage:SetSize(16,16);
	self.VGUI.PrivateImage:SetImage(self.Images.Shield);

	-- The Private Checkbox
	self.VGUI.PrivateCheckbox:SetPos(75,pos[3]);
	self.VGUI.PrivateCheckbox:SetText(SGLanguage.GetMessage("stargate_vgui_private"));
	self.VGUI.PrivateCheckbox:SetWide(110);
	local tip = SGLanguage.GetMessage("stargate_vgui_privatetip");
	self.VGUI.PrivateCheckbox:SetTooltip(tip);
	self.VGUI.PrivateCheckbox.Label:SetTooltip(tip); -- Workaround/Fix
	self.VGUI.PrivateCheckbox.Button.ConVarChanged = function(CheckBox)
		local b = util.tobool(CheckBox:GetChecked());
		if(IsValid(self.Entity)) then
			self.Entity:SetPrivate(b);
		end
	end

	if (self.Class!="stargate_supergate") then
		if (self.GroupSystem) then
			-- The Local Checkbox
			self.VGUI.LocaleCheckbox:SetPos(75,175);
			self.VGUI.LocaleCheckbox:SetWide(110);
			self.VGUI.LocaleCheckbox:SetText(SGLanguage.GetMessage("stargate_vgui_locale"));
			local tip = SGLanguage.GetMessage("stargate_vgui_localetip");
			self.VGUI.LocaleCheckbox:SetTooltip(tip);
			self.VGUI.LocaleCheckbox.Label:SetTooltip(tip); -- Workaround/Fix
			self.VGUI.LocaleCheckbox.Button.ConVarChanged = function(CheckBox)
				if((self.AlphaTime or 0)+0.3 >= CurTime()) then return end -- Avoids the VGUI sending "SetGateAddress" everytime we open it!
				local b = util.tobool(CheckBox:GetChecked());
				if(IsValid(self.Entity)) then
					self.Entity:SetLocale(b);
					if (self.VGUI.AddressSelect) then
						timer.Remove("_StarGate.RefreshAddressList");
						timer.Create("_StarGate.RefreshAddressList",0.25,1,
							function()
								if(self!=nil and self.VGUI!=nil) then
									self.VGUI.AddressSelect:UpdateLocalStage(b);
									self.VGUI.AddressSelect:RefreshList(true);
								end
							end
						);
					end
				end
			end
		elseif (self.Class!="stargate_universe") then
			self.VGUI.GalaxyCheckbox:SetPos(75,145);
			self.VGUI.GalaxyCheckbox:SetText(SGLanguage.GetMessage("stargate_galaxy_vgui"));
			local tip = SGLanguage.GetMessage("stargate_galaxy_vgui_tip");
			self.VGUI.GalaxyCheckbox:SetTooltip(tip);
			self.VGUI.GalaxyCheckbox:SetWide(110);
			self.VGUI.GalaxyCheckbox.Label:SetTooltip(tip); -- Workaround/Fix
			self.VGUI.GalaxyCheckbox.Button.ConVarChanged = function(CheckBox)
				if((self.AlphaTime or 0)+0.3 >= CurTime()) then return end -- Avoids the VGUI sending "SetGateAddress" everytime we open it!
				local b = util.tobool(CheckBox:GetChecked());
				if(IsValid(self.Entity)) then
					self.Entity:SetGalaxy(b);
					if (self.VGUI.AddressSelect) then
						timer.Remove("_StarGate.RefreshAddressList");
						timer.Create("_StarGate.RefreshAddressList",0.25,1,
							function()
								if(self!=nil and self.VGUI!=nil) then
									self.VGUI.AddressSelect:RefreshList(true);
								end
							end
						);
					end
				end
			end
		end
	end

	if (self.blocked_allowed) then
		-- The Blocked Checkbox
		self.VGUI.BlockedCheckbox:SetPos(75,pos[4]);
		self.VGUI.BlockedCheckbox:SetWide(150);
		self.VGUI.BlockedCheckbox:SetText(SGLanguage.GetMessage("stargate_vgui_blocked"));
		local tip = SGLanguage.GetMessage("stargate_vgui_blockedtip");
		self.VGUI.BlockedCheckbox:SetTooltip(tip);
		self.VGUI.BlockedCheckbox.Label:SetTooltip(tip); -- Workaround/Fix
		self.VGUI.BlockedCheckbox.Button.ConVarChanged = function(CheckBox)
			local b = util.tobool(CheckBox:GetChecked());
			if(IsValid(self.Entity)) then
				self.Entity:SetBlocked(b);
			end
		end
	end

	if (not self.Alternative) then
		--###### Select Address
		-- The topic
		for i=1,2 do
			local mul = (i-1);
			self.VGUI.AddressSelectLabel[i]:SetText(SGLanguage.GetMessage("stargate_vgui_dial"));
			self.VGUI.AddressSelectLabel[i]:SetWide(200);
			self.VGUI.AddressSelectLabel[i]:SetPos(250-mul*2,35-mul*2);
			self.VGUI.AddressSelectLabel[i]:SetTextColor(Color(255*mul,255*mul,255*mul,255));
		end

		-- Our AddressSelect Panel (Where we dial Addresses from)
		self.VGUI.AddressSelect:SetPos(250,60);
		self.VGUI.AddressSelect.OnDial = function(e,address,mode)
			if (IsValid(e)) then
				e:DialGate(address,mode);
			end
			self:SetVisible(false);
		end
		self.VGUI.AddressSelect.OnAbort = function(e)
			if (IsValid(e)) then
				e:AbortDialling();
			end
			self:SetVisible(false);
		end
	end

	self:RegisterHooks();
	self:LoadSettings();
end

--################# Load settings @ AlexALX
function PANEL:LoadSettings()
	if (self.VGUI.AddressSelect) then
		self.VGUI.AddressSelect:SetSettings(self.Entity,self.GroupSystem,self.CanDialGroups);
		self.VGUI.AddressSelect:LoadSettings();
	end
	self.VGUI.AddressPanel:SetSettings(self.Entity,self.GroupSystem);
	self.VGUI.AddressPanel:LoadSettings();
	self.VGUI.NameTextEntry:SetText(self.Entity:GetGateName());
	self.VGUI.PrivateCheckbox:SetValue(self.Entity:GetPrivate());
	if (self.Class!="stargate_supergate") then
		if (self.GroupSystem) then
			self.VGUI.LocaleCheckbox:SetValue(self.Entity:GetLocale());
		elseif (self.Class!="stargate_universe") then
			self.VGUI.GalaxyCheckbox:SetValue(self.Entity:GetGalaxy());
		end
	end
	if (self.blocked_allowed) then
		self.VGUI.BlockedCheckbox:SetValue(self.Entity:GetBlocked());
	end
end

--################# Register Hooks @aVoN, AlexALX
function PANEL:RegisterHooks()
	-- This is necessary: Everytime we set this window visible, we will update the address panel and any other necessary object
	self._SetVisible = self.SetVisible;
	self.SetVisible = function(self,b)
		if(b) then
			if(self.OnOpen) then
				local ret = self:OnOpen();
				if(ret ~= nil) then return ret end;
			end
		else
			if(self.OnClose) then
				local ret = self:OnClose();
				if(ret ~= nil) then return ret end;
			end
		end
		self._SetVisible(self,b);
	end
	self._Think = self.Think;
	self.Think = function(self)
		local x,y = gui.MousePos();
		if(x ~= ScrW()/2 and y ~= ScrH() and x > 1 and y > 1) then -- Prevents some resnapping bugs
			self.Data.MouseX,self.Data.MouseY = x,y;
		end
		if (self.VGUI.AddressSelect) then self.Data.DialType = self.VGUI.AddressSelect:GetDialType(); end
		local x,y = self:GetPos();
		self.Data.PosX, self.Data.PosY = x,y;
		self._Think(self);
	end
	self._PerformLayout = self.PerformLayout;
	self.PerformLayout = function(self,w,h)
		--####### Save Width/Heigth
		if (self.VGUI.AddressSelect) then self.VGUI.AddressSelect:SetSize(w-(250+10),h-(60+10)); end
		self.Data.SizeW, self.Data.SizeH = w,h;
		self._PerformLayout(self,w,h);
	end
	-- for new gmod
	self:MakePopup();
	if (self.Alternative) then
		self:SetSizable(false)
	else
		self:SetSizable(true)
	end
	self:SetDeleteOnClose( false )
	self:SetTitle("")
	self.Logo = vgui.Create("DImage",self);
	self.Logo:SetPos(8,10);
	self.Logo:SetImage("gui/cap_logo");
	self.Logo:SetSize(16,16);
end

--################# Open Hook @aVoN
function PANEL:OnOpen()
	self:SetKeyBoardInputEnabled(true);
	self:SetMouseInputEnabled(true);
	self.AlphaTime = CurTime(); -- For the FadeIn/Out
	self.FadeOut = nil;
	self:SetAlpha(1); -- We will fade in!
	--self.VGUI.AddressSelect:RefreshList(true);
	if(self.Data.MouseX and self.Data.MouseY) then
		gui.SetMousePos(self.Data.MouseX,self.Data.MouseY);
	end
	if (not self.Alternative and self.Data.SizeH!=nil and self.Data.SizeW!=nil) then
		self:SetSize(self.Data.SizeW,self.Data.SizeH);
	end
	if (self.Data.PosX!=nil and self.Data.PosY!=nil) then
		self:SetPos(self.Data.PosX,self.Data.PosY);
	end
	if (self.Data.DialType!=nil and self.VGUI.AddressSelect!=nil) then
		self.VGUI.AddressSelect:SetDialType(self.Data.DialType);
	end
end

--################# Close Hook @aVoN
function PANEL:OnClose()
	self:SetKeyBoardInputEnabled(false);
	self:SetMouseInputEnabled(false);
	self.AlphaTime = CurTime(); -- For the FadeIn/Out
	self.FadeOut = true;
	-- save all data @ AlexALX
	if (not self.Alternative) then
		self:SetCookie("SG.Size.W",self.Data.SizeW);
		self:SetCookie("SG.Size.H",self.Data.SizeH);
	end
	self:SetCookie("SG.Pos.X",self.Data.PosX);
	self:SetCookie("SG.Pos.Y",self.Data.PosY);
	return false; -- Override default fadeout
end

--################# Paint @aVoN
function PANEL:Paint(w,h)
	-- Fade in!
	local alpha = math.Clamp(CurTime() - (self.AlphaTime or 0),0,0.20)*5;
	if(self.FadeOut) then
		alpha = 1-alpha;
		if(alpha == 0) then
			--self:_SetVisible(false);
			self.FadeOut = nil;
			self:Remove();
		end
	end
	draw.RoundedBox(10,0,0,w,h,Color(16,16,16,160*alpha));
	self:SetAlpha(alpha*255);
	return true;
end

vgui.Register("SControlePanel",PANEL,"DFrame");

--local data = PANEL.Data; -- To store the mousepos accross sessions (And sync it with the main Panel)
local PANEL = table.Copy(PANEL);
PANEL.Data = {};

--################# Init @aVoN
function PANEL:Init()
	self:SetPos(10,10); -- No Center because I'm planing making it able to dial a DHD by just clicking with the mouse on it
	--self:Center();
end

--################# Set settings aka init panel @ AlexALX
function PANEL:SetSettings(entity,groupsystem,candialg,nox,orlin)
	self:SetSize(440,160);
	self:SetMinimumSize(440,160);

	self:SetCookieName("StarGate.SControlePanelDHD");

	self.Data.SizeW = self:GetCookie("SG.Size.W",440);
	self.Data.SizeH = self:GetCookie("SG.Size.H",160);
	self.Data.PosX = self:GetCookie("SG.Pos.X",10);
	self.Data.PosY = self:GetCookie("SG.Pos.Y",10);

	self.AlphaTime = CurTime()
	self.LastEntity = nil;
	-- Keyboard/Mouse behaviour
	self.Entity = entity;
	self.GroupSystem = groupsystem;
	self.CanDialGroups = candialg;
	self.Orlin = orlin;
	self.Nox = nox;
	-- VGUI Elements
	self.VGUI = {
		TitleLabel = vgui.Create("DLabel",self),
		AddressSelect = vgui.Create("SAddressSelect",self),
		AddressSelectLabel = {
			vgui.Create("DLabel",self),
			vgui.Create("DLabel",self), -- Black background/Shadow
		},
	}

	if (self.Orlin) then
		self.VGUI.GroupLabel = vgui.Create("DLabel",self);
		self.VGUI.GroupTextEntry = vgui.Create("DMultiChoice",self);
		self.VGUI.GroupStatus = vgui.Create("DLabel",self);
		self.VGUI.StatusImage = vgui.Create("DImage",self);

		-- Group
		self.VGUI.GroupLabel:SetText(SGLanguage.GetMessage("stargate_vgui_group"));
		self.VGUI.GroupStatus:SetText("");

		local grouppos = 145;
		-- The Description above the TextEntry
	 	self.VGUI.GroupLabel:SetPos(grouppos,35);

		-- The Group TextEntry
		self.VGUI.GroupTextEntry:SetPos(grouppos+45,35);
		self.VGUI.GroupTextEntry:SetSize(35,self.VGUI.GroupTextEntry:GetTall());
		self.VGUI.GroupTextEntry:SetTooltip(SGLanguage.GetMessage("stargate_vgui_grptip"));
		--This function restricts the letters you can enter to a valid address
		self.VGUI.GroupTextEntry.TextEntry.OnTextChanged = function(TextEntry)
			local text = TextEntry:GetValue();
			if(text ~= self.LastGroup) then
				local pos = TextEntry:GetCaretPos();
				local len = text:len();
				local letters = text:upper():gsub("[^0-9A-Z@]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
				local text = ""; -- Wipe
				for _,v in pairs(letters) do
					if(not text:find(v)) then
						text = text..v;
					end
				end
				text = text:sub(1,2);
				self.LastGroup = text;
				TextEntry:SetText(text);
				TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
				self:SetStatus(text);
			end
		end

		self.VGUI.GroupTextEntry.OnSelect = function(panel,index,value,data)
			local text = data;
			if(text ~= self.LastGroup) then
				local pos = panel.TextEntry:GetCaretPos();
				local len = text:len();
				local letters = text:upper():gsub("[^0-9A-Z@]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
				text = text:sub(1,2);
				self.LastGroup = text;
				panel.TextEntry:SetText(text);
				panel.TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
				self:SetStatus(text);
			else
				panel.TextEntry:SetText(text);
			end
		end

		self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp1"),"M@");
		self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp2"),"P@");
		self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp3"),"I@");
		self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp8"),"OT");
		self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp4"),"O@");
		if (SG_CUSTOM_GROUPS) then
			for g,d in pairs(SG_CUSTOM_GROUPS) do
				self.VGUI.GroupTextEntry:AddChoice(d[1],g);
			end
		end

		-- Status Label
		self.VGUI.StatusImage:SetPos(grouppos+85,35);
		self.VGUI.StatusImage:SetSize(16,16);
		self.VGUI.GroupStatus:SetPos(grouppos+105,35);
		self.VGUI.GroupStatus:SetWide(200);

		-- Our AddressPanel (Where we set Addresses with)
		self.OnAddressSet = function(e,group)
			if((self.AlphaTime or 0)+0.3 < CurTime()) then -- Avoids the VGUI sending "SetGateAddress" everytime we open it!
				e:SetGateGroup(group);
				timer.Remove("_StarGate.RefreshAddressList");
				timer.Create("_StarGate.RefreshAddressList",0.25,1,
					function()
						if(self!=nil and self.VGUI!=nil) then
							self.VGUI.AddressSelect:RefreshList(true);
						end
					end
				);
			end
		end

	end

	-- The topic of the whole frame
	self.VGUI.TitleLabel:SetText(SGLanguage.GetMessage("stargate_vgui"));
	self.VGUI.TitleLabel:SetPos(30,7);
	self.VGUI.TitleLabel:SetWide(200);
	--###### Select Address
	-- The topic
	for i=1,2 do
		local mul = (i-1);
		self.VGUI.AddressSelectLabel[i]:SetText(SGLanguage.GetMessage("stargate_vgui_dial"));
		self.VGUI.AddressSelectLabel[i]:SetWide(200);
		self.VGUI.AddressSelectLabel[i]:SetPos(10-mul*2,35-mul*2);
		self.VGUI.AddressSelectLabel[i]:SetTextColor(Color(255*mul,255*mul,255*mul,255));
	end
	-- Our AddressSelect Panel (Where we dial Addresses from)
	self.VGUI.AddressSelect:SetPos(10,60);
	self.VGUI.AddressSelect.OnDial = function(e,address,mode)
		if (IsValid(e)) then
			e:DialGate(address,mode,self.Nox);
		end
		self:SetVisible(false);
	end
	self.VGUI.AddressSelect.OnAbort = function(e)
		if (IsValid(e)) then
			e:AbortDialling();
		end
		self:SetVisible(false);
	end
	self.VGUI.AddressSelect.OnTextChanged = function(AddressSelect)
		if(self.OnTextChanged) then self.OnTextChanged(AddressSelect) end;
	end
	-- This is necessary: Everytime we set this window visible, we will update the address panel and any other necessary object
	self:RegisterHooks();
	self:LoadSettings();
end

function PANEL:RegisterHooks()
	-- This is necessary: Everytime we set this window visible, we will update the address panel and any other necessary object
	self._SetVisible = self.SetVisible;
	self.SetVisible = function(self,b)
		if(b) then
			if(self.OnOpen) then
				local ret = self:OnOpen();
				if(ret ~= nil) then return ret end;
			end
		else
			if(self.OnClose) then
				local ret = self:OnClose();
				if(ret ~= nil) then return ret end;
			end
		end
		self._SetVisible(self,b);
	end
	self._Think = self.Think;
	self.Think = function(self)
		local x,y = gui.MousePos();
		if(x ~= ScrW()/2 and y ~= ScrH() and x > 1 and y > 1) then -- Prevents some resnapping bugs
			self.Data.MouseX,self.Data.MouseY = x,y;
		end
		if (self.VGUI.AddressSelect) then self.Data.DialType = self.VGUI.AddressSelect:GetDialType(); end
		local x,y = self:GetPos();
		self.Data.PosX, self.Data.PosY = x,y;
		self._Think(self);
	end
	self._PerformLayout = self.PerformLayout;
	self.PerformLayout = function(self,w,h)
		--####### Save Width/Heigth
		self.VGUI.AddressSelect:SetSize(w-20,h-(60+10));
		self.Data.SizeW, self.Data.SizeH = w,h;
		self._PerformLayout(self);
	end
	-- for new gmod
	self:MakePopup();
	self:SetSizable(true)
	self:SetDeleteOnClose( false )
	self:SetTitle("")
	self.Logo = vgui.Create("DImage",self);
	self.Logo:SetPos(8,10);
	self.Logo:SetImage("gui/cap_logo");
	self.Logo:SetSize(16,16);
end

--################# Sets a value to the address field @aVoN
function PANEL:SetText(text)
	self.VGUI.AddressSelect:SetText(text);
end

function PANEL:SetTextOrlin(text)
	local g = (text or ""):upper();
	self.VGUI.GroupTextEntry.TextEntry:SetText(g);
	self.LastGroup = g;
	self:SetStatus(g,true);
end

--################# Gets an address @aVoN
function PANEL:GetValue()
	return self.VGUI.AddressSelect:GetValue();
end

--################# To what Entity to we belong to? @aVoN
function PANEL:LoadSettings()
	if (self.Orlin) then
		self:SetTextOrlin(self.Entity:GetGateGroup());
	end
	self.VGUI.AddressSelect:SetSettings(self.Entity,self.GroupSystem,self.CanDialGroups,self.Nox or self.Entity:GetClass()=="stargate_orlin");
	self.VGUI.AddressSelect:LoadSettings();
end

--################# Sets the status (Valid/Invalid/Already Exists) @aVoN
function PANEL:SetStatus(g,no_message)
	local g = (g or ""):upper();
	if(g:len() == 2) then
		self.VGUI.StatusImage:SetImage(self.Images.Valid);
		if (not no_message) then surface.PlaySound(self.Sounds["Info"]); end
		if(self.OnAddressSet) then self.OnAddressSet(self.Entity,g:upper()) end; -- SET THE GROUP!
		if (g == "M@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp1"));
		elseif (g == "P@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp2"));
		elseif (g == "I@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp3"));
		elseif (g == "OT") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp8"));
		elseif (g == "O@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp4"));
		elseif (SG_CUSTOM_GROUPS and SG_CUSTOM_GROUPS[g]) then
			self.VGUI.GroupStatus:SetText(SG_CUSTOM_GROUPS[g][1]);
		else
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grpc"));
		end
	else
		-- Typing address!
		self.VGUI.StatusImage:SetImage(self.Images.Editing);
		if (g == "M@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp1"));
		elseif (g == "P@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp2"));
		elseif (g == "I@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp3"));
		elseif (g == "OT") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp8"));
		elseif (g == "O@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp4"));
		elseif (SG_CUSTOM_GROUPS and SG_CUSTOM_GROUPS[g]) then
			self.VGUI.GroupStatus:SetText(SG_CUSTOM_GROUPS[g][1]);
		elseif (g:len() == 2) then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grpc"));
		else
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_edit"));
		end
	end
end

vgui.Register("SControlePanelDHD",PANEL,"DFrame");

--##################################
--###### saddresspanel.lua
--##################################

local PANEL = {};
PANEL.Images = {
	Valid = "icon16/accept.png",
	Invalid = "icon16/cancel.png",
	Editing = "icon16/table_edit.png",
	Warning = "icon16/error.png",
	Info = "icon16/information.png",
}
PANEL.Sounds = {
	Warning = Sound("buttons/button2.wav"),
	Info = Sound("buttons/button9.wav"),
}

function PANEL:Init()
	self:SetSize(200,80);
end

function PANEL:SetSettings(entity,groupsystem)
	-- Create the Address Field
	self.VGUI = {
		AddressLabel = vgui.Create("DLabel",self),
		AddressTextEntry = vgui.Create("DTextEntry",self),
		StatusLabel = vgui.Create("DLabel",self),
		StatusImage = vgui.Create("DImage",self),
		MessageImage = vgui.Create("DImage",self),
		MessageLabel = vgui.Create("DLabel",self),
	}

	self.VGUI.AddressLabel:SetText(SGLanguage.GetMessage("stargate_vgui_address"));
	self.VGUI.StatusLabel:SetText("");
	self.VGUI.MessageLabel:SetText("");
	self.Entity = entity;
	self.Class = entity:GetClass();
	self.GroupSystem = groupsystem;
	self.IsSuper = (self.Class=="stargate_supergate");
	self.IsSGU = (self.Class=="stargate_universe");
	self.GroupAllowed = (not self.IsSuper and self.GroupSystem);
	self.PaintPos = 21;

	if (self.GroupAllowed) then
		self.PaintPos = 51;
		self.VGUI.GroupLabel = vgui.Create("DLabel",self);
		self.VGUI.GroupTextEntry = vgui.Create("DMultiChoice",self);
		self.VGUI.GroupStatus = vgui.Create("DLabel",self);

		if (self.IsSGU) then
			self.VGUI.GroupLabel:SetText(SGLanguage.GetMessage("stargate_vgui_type"));
		else
			self.VGUI.GroupLabel:SetText(SGLanguage.GetMessage("stargate_vgui_group"));
		end
		self.VGUI.GroupStatus:SetText("");
	end

	self.Symbols = "[^0-9A-Z@]";
	if (not self.IsSuper and not self.GroupSystem) then
		self.Symbols = "[^1-9A-Z]";
	end

	--####### Apply Sizes...
	-- The Description above the TextEntry
 	self.VGUI.AddressLabel:SetPos(0,0);

	-- The Address TextEntry
	self.VGUI.AddressTextEntry:SetPos(45,0);
	self.VGUI.AddressTextEntry:SetSize(60,self.VGUI.AddressTextEntry:GetTall());
	if (self.GroupSystem or self.IsSuper) then
		self.VGUI.AddressTextEntry:SetTooltip(SGLanguage.GetMessage("stargate_vgui_adrtip"));
	else
		self.VGUI.AddressTextEntry:SetTooltip(SGLanguage.GetMessage("stargate_galaxy_vgui_adrtip"));
	end
	--This function restricts the letters you can enter to a valid address
	if (self.GroupAllowed) then
		if (self.IsSGU) then
			self.VGUI.AddressTextEntry.OnTextChanged = function(TextEntry)
				local text = TextEntry:GetValue();
				local group = self.VGUI.GroupTextEntry.TextEntry:GetValue();
				if(text ~= self.LastAddress) then
					local pos = TextEntry:GetCaretPos();
					local len = text:len();
					local letters = text:upper():gsub("[^0-9A-Z@]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
					local lettersg = group:upper():gsub("[^0-9A-Z@#]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
					local text = ""; -- Wipe
					local add = true;
					for _,v in pairs(letters) do
						if(#lettersg>=1 and v:find(lettersg[1]) or #lettersg>=2 and v:find(lettersg[2]) or #lettersg==3 and v:find(lettersg[3])) then
							add = false;
						end
						if(not text:find(v) and (#lettersg==0 or add)) then
							text = text..v;
						end
					end
					text = text:sub(1,6);
					self.LastAddress = text;
					TextEntry:SetText(text);
					TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
					self:SetStatusSGU(text,group);
				end
			end
		else
			self.VGUI.AddressTextEntry.OnTextChanged = function(TextEntry)
				local text = TextEntry:GetValue();
				local group = self.VGUI.GroupTextEntry.TextEntry:GetValue();
				if(text ~= self.LastAddress) then
					local pos = TextEntry:GetCaretPos();
					local len = text:len();
					local letters = text:upper():gsub("[^0-9A-Z@]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
					local lettersg = group:upper():gsub("[^0-9A-Z@]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
					local text = ""; -- Wipe
					local add = true;
					for _,v in pairs(letters) do
						if(#lettersg>=1 and v:find(lettersg[1]) or #lettersg>=2 and v:find(lettersg[2])) then
							add = false;
						end
						if(not text:find(v) and (#lettersg==0 or add)) then
							text = text..v;
						end
					end
					text = text:sub(1,6);
					self.LastAddress = text;
					TextEntry:SetText(text);
					TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
					self:SetStatusGroup(text,group);
				end
			end
		end
	else
		self.VGUI.AddressTextEntry.OnTextChanged = function(TextEntry)
			local text = TextEntry:GetValue();
			if(text ~= self.LastAddress) then
				local pos = TextEntry:GetCaretPos();
				local len = text:len();
				local letters = text:upper():gsub(self.Symbols,""):TrimExplode(""); -- Upper, remove invalid chars and split!
				local text = ""; -- Wipe
				for _,v in pairs(letters) do
					if(not text:find(v)) then
						text = text..v;
					end
				end
				text = text:sub(1,6);
				self.LastAddress = text;
				TextEntry:SetText(text);
				TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
				self:SetStatus(text);
			end
		end
	end

	if (self.GroupAllowed) then
		-- The Description above the TextEntry
	 	self.VGUI.GroupLabel:SetPos(0,30);
		if (self.IsSGU) then
			-- The Group TextEntry
			self.VGUI.GroupTextEntry:SetPos(45,30);
			self.VGUI.GroupTextEntry:SetSize(42,self.VGUI.GroupTextEntry:GetTall());
			self.VGUI.GroupTextEntry.TextEntry:SetTooltip(SGLanguage.GetMessage("stargate_vgui_typetip"));
			--This function restricts the letters you can enter to a valid address
			self.VGUI.GroupTextEntry.TextEntry.OnTextChanged = function(TextEntry)
				local text = TextEntry:GetValue();
				local address = self.VGUI.AddressTextEntry:GetValue();
				if(text ~= self.LastGroup) then
					local pos = TextEntry:GetCaretPos();
					local len = text:len();
					local lettersa = address:upper():gsub("[^0-9A-Z@]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
					local letters = text:upper():gsub("[^0-9A-Z@#]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
					local text = ""; -- Wipe
					local add1 = true;
					local add2 = true;
					local add3 = true;
					for _,v in pairs(lettersa) do
						if(#letters>=1 and v:find(letters[1])) then
							add1 = false;
						end
						if(#letters>=2 and v:find(letters[2])) then
							add2 = false;
						end
						if(#letters==3 and v:find(letters[3])) then
							add3 = false;
						end
					end
					if (letters[1]=="#") then add1 = false end
					if (letters[2]=="#") then add2 = false end
					local i = 1
					for _,v in pairs(letters) do
						if((add1 and i==1 or add2 and i==2 or add3 and i==3) and not text:find(v)) then
							text = text..v;
						end
						i = i+1;
					end
					text = text:sub(1,3);
					self.LastGroup = text;
					TextEntry:SetText(text);
					TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
					self:SetStatusSGU(address,text,false,"",true);
				end
			end

			self.VGUI.GroupTextEntry.OnSelect = function(panel,index,value,data)
				local text = data;
				local address = self.VGUI.AddressTextEntry:GetValue();
				if(text ~= self.LastGroup) then
					local pos = panel.TextEntry:GetCaretPos();
					local len = text:len();
					local lettersa = address:upper():gsub("[^0-9A-Z@]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
					local letters = text:upper():gsub("[^0-9A-Z@#]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
					local add1 = true;
					local add2 = true;
					local add3 = true;
					for _,v in pairs(lettersa) do
						if(#letters>=1 and v:find(letters[1])) then
							add1 = false;
						end
						if(#letters>=2 and v:find(letters[2])) then
							add2 = false;
						end
						if(#letters==3 and v:find(letters[3])) then
							add3 = false;
						end
					end
					text = text:sub(1,3);
					self.LastGroup = text;
					panel.TextEntry:SetText(text);
					panel.TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
					if (not add1 and not add2 and not add3) then
						self:SetStatusSGU(address,text,false,text);
					elseif (not add1 and not add2) then
						self:SetStatusSGU(address,text,false,letters[1]..letters[2]);
					elseif (not add1 and not add3) then
						self:SetStatusSGU(address,text,false,letters[1]..letters[3]);
					elseif (not add2 and not add3) then
						self:SetStatusSGU(address,text,false,letters[2]..letters[3]);
					elseif (not add1) then
						self:SetStatusSGU(address,text,false,letters[1]);
					elseif (not add2) then
						self:SetStatusSGU(address,text,false,letters[2]);
					elseif (not add3) then
						self:SetStatusSGU(address,text,false,letters[3]);
					else
						self:SetStatusSGU(address,text,false,"",true);
					end
				else
					panel.TextEntry:SetText(text);
				end
			end

			self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp5"),"U@#");
			self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp6"),"SGI");
			self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp7"),"DST");
			if (SG_CUSTOM_TYPES) then
				for g,d in pairs(SG_CUSTOM_TYPES) do
					self.VGUI.GroupTextEntry:AddChoice(d[1],g);
				end
			end

			self.VGUI.GroupStatus:SetPos(92,30);
			self.VGUI.GroupStatus:SetWide(200);
		else
			-- The Group TextEntry
			self.VGUI.GroupTextEntry:SetPos(45,30);
			self.VGUI.GroupTextEntry:SetSize(35,self.VGUI.GroupTextEntry:GetTall());
			self.VGUI.GroupTextEntry.TextEntry:SetTooltip(SGLanguage.GetMessage("stargate_vgui_grptip"));
			--This function restricts the letters you can enter to a valid address
			self.VGUI.GroupTextEntry.TextEntry.OnTextChanged = function(TextEntry)
				local text = TextEntry:GetValue();
				local address = self.VGUI.AddressTextEntry:GetValue();
				if(text ~= self.LastGroup) then
					local pos = TextEntry:GetCaretPos();
					local len = text:len();
					local lettersa = address:upper():gsub("[^0-9A-Z@]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
					local letters = text:upper():gsub("[^0-9A-Z@]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
					local text = ""; -- Wipe
					local add1 = true;
					local add2 = true;
					for _,v in pairs(lettersa) do
						if(#letters>=1 and v:find(letters[1])) then
							add1 = false;
						end
						if(#letters>=2 and v:find(letters[2])) then
							add2 = false;
						end
					end
					local i = 1
					for _,v in pairs(letters) do
						if((add1 and i==1 or add2 and i==2) and not text:find(v)) then
							text = text..v;
						end
						i = i+1;
					end
					text = text:sub(1,2);
					self.LastGroup = text;
					TextEntry:SetText(text);
					TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
					self:SetStatusGroup(address,text,false,"",true);
				end
			end

			self.VGUI.GroupTextEntry.OnSelect = function(panel,index,value,data)
				local text = data;
				local address = self.VGUI.AddressTextEntry:GetValue();
				if(text ~= self.LastGroup) then
					local pos = panel.TextEntry:GetCaretPos();
					local len = text:len();
					local lettersa = address:upper():gsub("[^0-9A-Z@]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
					local letters = text:upper():gsub("[^0-9A-Z@]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
					local add1 = true;
					local add2 = true;
					for _,v in pairs(lettersa) do
						if(#letters>=1 and v:find(letters[1])) then
							add1 = false;
						end
						if(#letters>=2 and v:find(letters[2])) then
							add2 = false;
						end
					end
					text = text:sub(1,2);
					self.LastGroup = text;
					panel.TextEntry:SetText(text);
					panel.TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
					if (not add1 and not add2) then
						self:SetStatusGroup(address,text,false,text);
					elseif (not add1) then
						self:SetStatusGroup(address,text,false,letters[1]);
					elseif (not add2) then
						self:SetStatusGroup(address,text,false,letters[2]);
					else
						self:SetStatusGroup(address,text,false,"",true);
					end
				else
					panel.TextEntry:SetText(text);
				end
			end

			self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp1"),"M@");
			self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp2"),"P@");
			self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp3"),"I@");
			self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp8"),"OT");
			self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp4"),"O@");
			if (SG_CUSTOM_GROUPS) then
				for g,d in pairs(SG_CUSTOM_GROUPS) do
					self.VGUI.GroupTextEntry:AddChoice(d[1],g);
				end
			end

			self.VGUI.GroupStatus:SetPos(85,30);
			self.VGUI.GroupStatus:SetWide(200);
		end
	end

	-- Status Label
	self.VGUI.StatusImage:SetPos(110,3);
	self.VGUI.StatusImage:SetSize(16,16);
	self.VGUI.StatusLabel:SetPos(130,0);
	self.VGUI.StatusLabel:SetWide(200);

	-- Message (What went wrong?)
	if (self.GroupAllowed) then
		self.VGUI.MessageImage:SetPos(2,52);
		self.VGUI.MessageImage:SetSize(16,16);
		self.VGUI.MessageLabel:SetPos(22,50);
		self.VGUI.MessageLabel:SetWide(200);
	else
		self.VGUI.MessageImage:SetPos(2,23);
		self.VGUI.MessageImage:SetSize(16,16);
		self.VGUI.MessageLabel:SetPos(22,21);
		self.VGUI.MessageLabel:SetWide(200);
	end
	--PANEL_RegisterHooks(self);
end

--################# Draw the fading info box @aVoN
function PANEL:Paint()
	-- The box around our notify message
	if(self.Message) then
		-- Fade in/out
		local alpha = math.Clamp(self.MessageCreated+1-CurTime(),0,1);
		if(self.MessageShow) then alpha = 1-alpha end;
		if(alpha > 0) then
			surface.SetFont("Default");
			local w,h = surface.GetTextSize(self.Message or "");
			draw.RoundedBox(8,0,self.PaintPos,w+25,20,Color(16,16,16,160*alpha));
			self.VGUI.MessageLabel:SetAlpha(255*alpha);
			self.VGUI.MessageImage:SetAlpha(255*alpha);
		end
	end
	return true;
end

--################# Get every valid gates by AlexALX
function PANEL:GetGates()
	local gates = {};
	for _,v in pairs(StarGate_GetAll or {}) do
		if (self.IsSuper and v.class=="stargate_supergate" or not self.IsSuper and v.groupgate) then
			table.insert(gates,v);
		end
	end
	return gates;
end

--################# Setting text on this panel will set the text on the TextEntry instead @aVoN
function PANEL:SetText(s,g)
	local s = (s or ""):upper();
	self.VGUI.AddressTextEntry:SetText(s);
	self.LastAddress = s;
	if (self.GroupAllowed) then
		local g = (g or ""):upper();
		self.VGUI.GroupTextEntry.TextEntry:SetText(g);
		self.LastGroup = g;
		if (self.IsSGU) then
			self:SetStatusSGU(s,g,true);
		else
			self:SetStatusGroup(s,g,true);
		end
	else
		self:SetStatus(s,true);
	end
end

--################# Sets the status (Valid/Invalid/Already Exists) @aVoN
function PANEL:SetStatus(s,no_message)
	local s = (s or ""):upper();
	local len = s:len();
	if(len == 6) then
		local letters = s:TrimExplode("");
		local valid = true;
		local set = true;
		for k,v in pairs(self:GetGates()) do
			local address = v.address;
			if(	address:find(letters[1]) and
				address:find(letters[2]) and
				address:find(letters[3]) and
				address:find(letters[4]) and
				address:find(letters[5]) and
				address:find(letters[6])
			) then
				if(tonumber(v.ent) == self.Entity:EntIndex()) then -- We have entered the same/similar address we had before - So we haven't changed anything
					set = false;
					break;
				else
					valid = false;
					break;
				end
			end
		end
		-- Valid address?
		if(valid) then
			self.VGUI.StatusImage:SetImage(self.Images.Valid);
			self.VGUI.StatusLabel:SetText(SGLanguage.GetMessage("stargate_vgui_valid"));
			if(not no_message) then
				-- Have we set the address or is it the old from before?
				if(set) then
					self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_valid2"),"Info");
				else
					self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_valid3",s),"Info",true);
				end
			end
			if(self.OnAddressSet) then self.OnAddressSet(self.Entity,s:upper()) end; -- SET THE ADDRESS!
		else
			-- INVALID!
			self.VGUI.StatusImage:SetImage(self.Images.Invalid);
			self.VGUI.StatusLabel:SetText(SGLanguage.GetMessage("stargate_vgui_invalid"));
			self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_adrexs"),"Warning");
		end
	elseif(len == 0) then
		-- Cleared this gate's address
		self.VGUI.StatusImage:SetImage("null");
		self.VGUI.StatusLabel:SetText("");
		if(not no_message) then self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_adrclr"),"Info") end;
		if(self.OnAddressSet) then self.OnAddressSet(self.Entity,"") end; -- CLEAR ADDRESS
	else
		-- Typing address!
		self.VGUI.StatusImage:SetImage(self.Images.Editing);
		self.VGUI.StatusLabel:SetText(SGLanguage.GetMessage("stargate_vgui_edit"));
		self:ShowMessage();
	end
	-- Clear any previous message
	if(no_message) then
		-- Instant clear! (Some hacky way w/e)
		self.Message = nil;
		self.MessageShow = false;
		self.VGUI.MessageLabel:SetAlpha(0);
		self.VGUI.MessageImage:SetAlpha(0);
	end
end

function PANEL:SetStatusGroup(s,g,no_message,letters,gs)
	local s = (s or ""):upper();
	local g = (g or ""):upper();
	local l = (letters or ""):upper();
	local len = s:len();
	if(len == 6 and g:len() == 2) then
		local letters = s:TrimExplode("");
		local valid = true;
		local set = true;
		if (l!="") then
			valid = false;
		end
		if (valid) then
			for _,v in pairs(self:GetGates()) do
				local address = v.address;
				local group = v.group;
				if(	address:find(letters[1]) and
					address:find(letters[2]) and
					address:find(letters[3]) and
					address:find(letters[4]) and
					address:find(letters[5]) and
					address:find(letters[6]) and
					(g == group or g:sub(1,1) == group:sub(1,1))
				) then
					if (self.Entity:GetNetworkedInt("SG_ATL_OVERRIDE")<=0 or (v.class=="stargate_atlantis" and self.Entity:GetClass()=="stargate_atlantis" or v.class!="stargate_atlantis" and self.Entity:GetClass()!="stargate_atlantis") or g:sub(1,1) == group:sub(1,1) and g:sub(2,2) != group:sub(2,2)) then
						if(tonumber(v.ent) == self.Entity:EntIndex()) then -- We have entered the same/similar address we had before - So we haven't changed anything
							if (group:find(g)) then
								set = false;
							end
							valid = true;
							break;
						else
							valid = false;
							break;
						end
					end
				end
			end
		end
		-- Valid address?
		if(valid) then
			self.VGUI.StatusImage:SetImage(self.Images.Valid);
			self.VGUI.StatusLabel:SetText(SGLanguage.GetMessage("stargate_vgui_valid"));
			if(not no_message) then
				-- Have we set the address or is it the old from before?
				if(set) then
					if (IsValid(self.Entity) and self.Entity.GetGateGroup and g != self.Entity:GetGateGroup()) then
						self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_valid4"),"Info");
					else
						self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_valid2"),"Info");
					end
				else
					if (gs) then
						self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_valid4b",g),"Info");
					else
						self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_valid3",s),"Info",true);
					end
				end
			end
			if(self.OnAddressSet) then self.OnAddressSet(self.Entity,s:upper(),g:upper()) end; -- SET THE ADDRESS!
			if (g == "M@") then
				self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp1"));
			elseif (g == "P@") then
				self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp2"));
			elseif (g == "I@") then
				self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp3"));
			elseif (g == "OT") then
				self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp8"));
			elseif (g == "O@") then
				self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp4"));
			elseif (SG_CUSTOM_GROUPS and SG_CUSTOM_GROUPS[g]) then
				self.VGUI.GroupStatus:SetText(SG_CUSTOM_GROUPS[g][1]);
			else
				self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grpc"));
			end
		else
			-- INVALID!
			self.VGUI.StatusImage:SetImage(self.Images.Invalid);
			self.VGUI.StatusLabel:SetText(SGLanguage.GetMessage("stargate_vgui_invalid"));
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_invalid"));
			if (l!="" and l:len()==1) then
				self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_symused",l),"Warning");
			elseif (l!="" and l:len()==2) then
				self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_symsused",l),"Warning");
			else
				self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_adrexs"),"Warning");
			end
		end
	elseif(len == 0 and g:len() == 2 and g == self.Entity:GetGateGroup()) then
		-- Cleared this gate's address
		self.VGUI.StatusImage:SetImage("null");
		self.VGUI.StatusLabel:SetText("");
		if(not no_message) then self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_adrclr"),"Info") end;
		if(self.OnAddressSet) then self.OnAddressSet(self.Entity,"",g:upper()) end; -- CLEAR ADDRESS
		if (g == "M@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp1"));
		elseif (g == "P@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp2"));
		elseif (g == "I@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp3"));
		elseif (g == "OT") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp8"));
		elseif (g == "O@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp4"));
		elseif (SG_CUSTOM_GROUPS and SG_CUSTOM_GROUPS[g]) then
			self.VGUI.GroupStatus:SetText(SG_CUSTOM_GROUPS[g][1]);
		else
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grpc"));
		end
	elseif(len == 0 and g:len() == 2 and g != self.Entity:GetGateGroup()) then
		-- Cleared this gate's address
		self.VGUI.StatusImage:SetImage("null");
		self.VGUI.StatusLabel:SetText("");
		if(not no_message) then self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_valid4"),"Info"); end;
		if(self.OnAddressSet) then self.OnAddressSet(self.Entity,"",g:upper()) end; -- CLEAR ADDRESS
		if (g == "M@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp1"));
		elseif (g == "P@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp2"));
		elseif (g == "I@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp3"));
		elseif (g == "OT") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp8"));
		elseif (g == "O@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp4"));
		elseif (SG_CUSTOM_GROUPS and SG_CUSTOM_GROUPS[g]) then
			self.VGUI.GroupStatus:SetText(SG_CUSTOM_GROUPS[g][1]);
		else
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grpc"));
		end
	else
		-- Typing address!
		self.VGUI.StatusImage:SetImage(self.Images.Editing);
		self.VGUI.StatusLabel:SetText(SGLanguage.GetMessage("stargate_vgui_edit"));
		if (g == "M@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp1"));
		elseif (g == "P@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp2"));
		elseif (g == "I@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp3"));
		elseif (g == "OT") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp8"));
		elseif (g == "O@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp4"));
		elseif (SG_CUSTOM_GROUPS and SG_CUSTOM_GROUPS[g]) then
				self.VGUI.GroupStatus:SetText(SG_CUSTOM_GROUPS[g][1]);
		elseif (g:len() == 2) then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grpc"));
		else
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_edit"));
		end
		self:ShowMessage();
	end
	-- Clear any previous message
	if(no_message) then
		-- Instant clear! (Some hacky way w/e)
		self.Message = nil;
		self.MessageShow = false;
		self.VGUI.MessageLabel:SetAlpha(0);
		self.VGUI.MessageImage:SetAlpha(0);
	end
end

function PANEL:IsSharedGroup(group)
	if (group=="U@#" or group=="SGI" or SG_CUSTOM_TYPES and SG_CUSTOM_TYPES[group] and SG_CUSTOM_TYPES[group][2]) then return true end
	return false
end

function PANEL:SetStatusSGU(s,g,no_message,letters,gs)
	local s = (s or ""):upper();
	local g = (g or ""):upper();
	local l = (letters or ""):upper();
	local len = s:len();
	if(len == 6 and g:len() == 3) then
		local letters = s:TrimExplode("");
		local valid = true;
		local valid_type = true;
		local set = true;
		if (l!="") then
			valid = false;
		end
		if (valid) then
			for _,v in pairs(self:GetGates()) do
				local address = v.address;
				local group = v.group;
				if(	address:find(letters[1]) and
					address:find(letters[2]) and
					address:find(letters[3]) and
					address:find(letters[4]) and
					address:find(letters[5]) and
					address:find(letters[6]) and
					group:len()==3 or 
					not self:IsSharedGroup(group) and g == group
				) then
					if(tonumber(v.ent) == self.Entity:EntIndex()) then -- We have entered the same/similar address we had before - So we haven't changed anything
						if (group:find(g)) then
							set = false;
						end
						if (self.Entity:GetGateGroup() == g) then
							break;
						end
					else
						valid = false;
						if (not self:IsSharedGroup(group) and g == group) then
							valid_type = false;
						end
						break;
					end
				end
			end
		end
		-- Valid address?
		if(valid) then
			self.VGUI.StatusImage:SetImage(self.Images.Valid);
			self.VGUI.StatusLabel:SetText(SGLanguage.GetMessage("stargate_vgui_valid"));
			if(not no_message) then
				-- Have we set the address or is it the old from before?
				if(set) then
					if (IsValid(self.Entity) and self.Entity.GetGateGroup and g != self.Entity:GetGateGroup()) then
						self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_valid5"),"Info");
					else
						self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_valid2"),"Info");
					end
				else
					if (gs) then
						self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_valid5b",g),"Info");
					else
						self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_valid3",s),"Info",true);
					end
				end
			end
			if(self.OnAddressSet) then self.OnAddressSet(self.Entity,s:upper(),g:upper()) end; -- SET THE ADDRESS!
			if (g == "U@#") then
				self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp5"));
			elseif (g == "SGI") then
				self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp6"));
			elseif (g == "DST") then
				self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp7"));
			elseif (SG_CUSTOM_TYPES and SG_CUSTOM_TYPES[g]) then
				self.VGUI.GroupStatus:SetText(SG_CUSTOM_TYPES[g][1]);
			else
				self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grpc2"));
			end
		else
			-- INVALID!
			self.VGUI.StatusImage:SetImage(self.Images.Invalid);
			self.VGUI.StatusLabel:SetText(SGLanguage.GetMessage("stargate_vgui_invalid"));
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_invalid"));
			if (l!="" and l:len()==1) then
				self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_symused",l),"Warning");
			elseif (l!="" and l:len()>=2) then
				self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_symsused",l),"Warning");
			else
				if (valid_type) then
					self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_adrexs"),"Warning");
				else
					self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_typexs"),"Warning");
				end
			end
		end
	elseif(len == 0 and g:len() == 3 and g == self.Entity:GetGateGroup()) then
		-- Cleared this gate's address
		self.VGUI.StatusImage:SetImage("null");
		self.VGUI.StatusLabel:SetText("");
		if(not no_message) then self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_adrclr"),"Info") end;
		if(self.OnAddressSet) then self.OnAddressSet(self.Entity,"",g:upper()) end; -- CLEAR ADDRESS
		if (g == "U@#") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp5"));
		elseif (g == "SGI") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp6"));
		elseif (g == "DST") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp7"));
		elseif (SG_CUSTOM_TYPES and SG_CUSTOM_TYPES[g]) then
			self.VGUI.GroupStatus:SetText(SG_CUSTOM_TYPES[g][1]);
		else
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grpc2"));
		end
	elseif(len == 0 and g:len() == 3 and g != self.Entity:GetGateGroup()) then
		local valid = true;
		local set = true;
		for _,v in pairs(self:GetGates()) do
			local group = v.group;
			if(not self:IsSharedGroup(group) and g == group) then
				valid = false;
				break;
			end
		end
		-- Valid address?
		if(valid) then
			-- Cleared this gate's address
			self.VGUI.StatusImage:SetImage("null");
			self.VGUI.StatusLabel:SetText("");
			if(not no_message) then self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_valid5"),"Info"); end;
			if(self.OnAddressSet) then self.OnAddressSet(self.Entity,"",g:upper()) end; -- CLEAR ADDRESS
			if (g == "U@#") then
				self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp5"));
			elseif (g == "SGI") then
				self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp6"));
			elseif (g == "DST") then
				self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp7"));
			elseif (SG_CUSTOM_TYPES and SG_CUSTOM_TYPES[g]) then
				self.VGUI.GroupStatus:SetText(SG_CUSTOM_TYPES[g][1]);
			else
				self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grpc2"));
			end
		else
			-- INVALID!
			self.VGUI.StatusImage:SetImage(self.Images.Invalid);
			self.VGUI.StatusLabel:SetText(SGLanguage.GetMessage("stargate_vgui_invalid"));
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_invalid"));
			self:ShowMessage(SGLanguage.GetMessage("stargate_vgui_typexs"),"Warning");
		end
	else
		-- Typing address!
		self.VGUI.StatusImage:SetImage(self.Images.Editing);
		self.VGUI.StatusLabel:SetText(SGLanguage.GetMessage("stargate_vgui_edit"));
		self:ShowMessage();
		if (g == "U@#") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp5"));
		elseif (g == "SGI") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp6"));
		elseif (g == "DST") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp7"));
		elseif (SG_CUSTOM_TYPES and SG_CUSTOM_TYPES[g]) then
			self.VGUI.GroupStatus:SetText(SG_CUSTOM_TYPES[g][1]);
		elseif (g:len() == 3) then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grpc2"));
		else
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_edit"));
		end
	end
	-- Clear any previous message
	if(no_message) then
		-- Instant clear! (Some hacky way w/e)
		self.Message = nil;
		self.MessageShow = false;
		self.VGUI.MessageLabel:SetAlpha(0);
		self.VGUI.MessageImage:SetAlpha(0);
	end
end

--################# Shows a message, what we did now @aVoN
function PANEL:ShowMessage(s,img,nosound)
	if(not s) then -- Stop the Message
		if(self.MessageShow) then
			self.MessageShow = false;
			self.MessageCreated = CurTime();
		end
		return;
	end
	self.VGUI.MessageImage:SetImage(self.Images[img] or "null");
	if(not nosound) then
		surface.PlaySound(self.Sounds[img]);
	end
	self.VGUI.MessageLabel:SetText(s);
	self.Message = s;
	if(not self.MessageShow) then
		self.MessageShow = true;
		self.MessageCreated = CurTime();
	end
end

function PANEL:LoadSettings()
	self:SetText(self.Entity:GetGateAddress(),self.Entity:GetGateGroup());
end

vgui.Register("SAddressPanel",PANEL,"Panel");

--##################################
--###### saddressselect.lua
--##################################

local PANEL = {};
PANEL.Images = {
	Search = "icon16/application_form_magnify.png",
	Refresh = "icon16/arrow_refresh.png",
	Dial = "icon16/folder_go.png",
	Abort = "icon16/cancel.png",
}
PANEL.Sounds = {
	Info = Sound("buttons/button9.wav"),
	Click = Sound("npc/turret_floor/click1.wav"),
	Warning = Sound("buttons/button2.wav"),
}
PANEL.Data = {
	Addresses = {}, -- Last Dialled Addresses
	AddressesSuper = {}, -- Last Dialled Addresses
	Address = "", -- Last Address in the multichoice
	AddressSuper = "", -- Last Address in the multichoice
	LastSearchText = "", -- The last search text a person entered
}

local additive = false
local size = 500

local sg1 = {
	font = "Stargate Address Glyphs SG1",
	size = 16,
	weight = size,
	antialias = true,
	additive = additive,
}
surface.CreateFont("stargate_address_glyphs_sg1", sg1);

local sgc = {
	font = "Stargate Address Glyphs Concept",
	size = 16,
	weight = size,
	antialias = true,
	additive = additive,
}
surface.CreateFont("stargate_address_glyphs_concept", sgc);

local sgu = {
	font = "Stargate Address Glyphs U",
	size = 38,
	weight = 100,
	antialias = true,
	additive = additive,
}
surface.CreateFont("stargate_address_glyphs_u", sgu);

local sga = {
	font = "Stargate Address Glyphs Atl",
	size = 15,
	weight = 100,
	antialias = true,
	additive = additive,
}
surface.CreateFont("stargate_address_glyphs_a", sga);

local textsizes = {17.8,20,11,8} -- {sg1, atlantis, universe, normal text}, for windows
if not system.IsWindows() then
	textsizes = {18.9,17.5,11.5,9} -- for linux/osx, hope it works
end

local function TextSize(text,type)
	local len = text:len()
	local siz = len*textsizes[type+1];
	return math.ceil(siz);
end

-- Apply glyphs
local function ApplyGlyphs(self, galaxy, small)

	local w,wa,wu,h,ha,hu = 160,172,98,18,18,23;
	if (small) then w,wa,wu,h,ha,hu = 128,137,78,18,18,23; end
	local offset = 5;
	if (galaxy) then offset = 4; end

	local ent = self.Entity;
	local isconpt = self:IsConcept(self.Entity)
	local mlist = self.VGUI.AddressListView:GetLines()
	local universe, atlantis = false, false;
	local block_address = 2;
	local sizeg,sizea = 80,self.VGUI.Width;
	if (IsValid(ent)) then block_address = ent:GetNetworkedInt("SG_BLOCK_ADDRESS"); end
	if (IsValid(ent) and ent:GetClass()=="stargate_universe") then
		self.VGUI.AddressListView:SetDataHeight(hu);
		universe = true;
	elseif (IsValid(ent) and ent:GetClass()=="stargate_atlantis") then
		self.VGUI.AddressListView:SetDataHeight(ha);
		atlantis = true;
	else
		self.VGUI.AddressListView:SetDataHeight(h);
	end

	local glyphs = ent:GetNetworkedInt("SG_VGUI_GLYPHS")

	for i=1, #mlist do
		local ss = self.VGUI.AddressListView:GetLine(i);
		if (glyphs<=0) then
			ss:SetValue(2," "..ss:GetValue(2));
		end
		local blocked = ss.Columns[offset]:GetValue();
		if (not universe and block_address==1) then blocked = false; end
		local energy = ss.Columns[offset+1]:GetValue();
		if (universe) then
			ss.Columns[1]:SetFont("stargate_address_glyphs_u");
		elseif (atlantis) then
			ss.Columns[1]:SetFont("stargate_address_glyphs_a");
		else
			if (isconpt) then
				ss.Columns[1]:SetFont("stargate_address_glyphs_concept");
			else
				ss.Columns[1]:SetFont("stargate_address_glyphs_sg1");
			end
		end
		local col = Color(0,0,0,255);
		if (blocked=="true") then
			col = Color(255,0,0,255);
			ss.Blocked = true;
		elseif (energy=="false") then
			col = Color(192,192,192,255);
			ss.LowEnergy = true;
		else
			ss.Blocked = false;
			ss.LowEnergy = false;
		end
		local type = 0;
		if (atlantis) then type = 1; elseif (universe) then type = 2; end
		local siz = TextSize(ss:GetValue(1),type)
        if (siz>sizeg) then
        	sizeg = siz;
        end
 		siz = TextSize(ss:GetValue(2),3)
        if (siz>sizea) then
        	sizea = siz;
        end
		for c=1,#ss.Columns-1 do
			ss.Columns[c]:SetColor(col);
		end
	end

	if (glyphs==2) then
		self.VGUI.AddressListView.Columns[1]:SetFixedWidth(sizeg);
		self.VGUI.AddressListView.Columns[2]:SetFixedWidth(sizea);
	elseif (glyphs==1) then
		self.VGUI.AddressListView.Columns[1]:SetFixedWidth(sizeg);
		self.VGUI.AddressListView.Columns[2]:SetFixedWidth(0);
	elseif (glyphs<=0) then
		self.VGUI.AddressListView.Columns[1]:SetFixedWidth(0);
		self.VGUI.AddressListView.Columns[2]:SetFixedWidth(sizea);
	end

end

-- for supergate
local function ApplyColor(self)
	local mlist = self.VGUI.AddressListView:GetLines()
	local ent = self.Entity;
	for i=1, #mlist do
		local ss = self.VGUI.AddressListView:GetLine(i);
		local energy = ss.Columns[3]:GetValue();
		local col = Color(0,0,0,255);
		if (energy=="false") then
			col = Color(192,192,192,255);
			ss.LowEnergy = true;
		else
			ss.LowEnergy = false;
		end
		for c=1,#ss.Columns-1 do
			ss.Columns[c]:SetColor(col);
		end
	end
end

function PANEL:Init()
	self:SetSize(400,100);
end

function PANEL:SetSettings(entity,groupsystem,candialg,hidedialmode)
	if (not IsValid(entity) or not entity.IsStargate) then self:Remove() end
	self.VGUI = {
		AddressListView=vgui.Create("DListView",self),
		AddressLabel=vgui.Create("DLabel",self),
		AddressMultiChoice=vgui.Create("DMultiChoice",self),
		DialTypeCheckbox=vgui.Create("DCheckBox",self),
		DialImageButton=vgui.Create("DImageButton",self),
		AbortDialImageButton=vgui.Create("DImageButton",self),
		SearchLabel=vgui.Create("DLabel",self),
		SearchTextEntry=vgui.Create("DTextEntry",self),
		SearchImageButton=vgui.Create("DImageButton",self),
		RefreshImageButton=vgui.Create("DImageButton",self),
	}
	self.Entity = entity;

	self.Class = entity:GetClass();
	self.GroupSystem = groupsystem;
	self.IsSuper = (self.Class=="stargate_supergate");
	self.IsSGU = (self.Class=="stargate_universe");
	self.GroupAllowed = (not self.IsSuper and self.GroupSystem);
	self.CanDialGroups = candialg;
	self.LocalGate = (entity:GetLocale() or not self.CanDialGroups);

	self:SetCookieName("StarGate.SAddressSelect"); -- Just for the checkbox to save the value (it always annoyed me, it losses it after a restart)
	--####### Apply Sizes: Search Fields
	-- The Address List
	self.VGUI.AddressListView:SetPos(0,25);
	self.AddressColumn = 1;
	self.ChoiceSize = 70;
	self.AllowedSymbols = "[^0-9A-Z@]";
	self.AllowedSymbolsTxt = "stargate_vgui_dialadr2";
	self.MaxSymbols = 6;
	self.VguiPos = {15,132,127};
	if (self.GroupAllowed) then
		if (self.LocalGate) then
			self.AddressColumn = 2;
			self.ChoiceSize = 70;
			self.AllowedSymbols = "[^0-9A-Z@]";
			self.AllowedSymbolsTxt = "stargate_vgui_dialadr2";
			self.MaxSymbols = 6;
			self.VguiPos = {15,132,127};
			self.VGUI.AddressListView:AddColumn(SGLanguage.GetMessage("stargate_vgui_glyphs")):SetFixedWidth(128);
			self.VGUI.AddressListView:AddColumn(SGLanguage.GetMessage("stargate_vgui_address2")):SetFixedWidth(60);
			self.VGUI.Width = 60;
			self.VGUI.AddressListView:AddColumn(SGLanguage.GetMessage("stargate_vgui_grouptype")):SetFixedWidth(100);
			self.VGUI.AddressListView:AddColumn(SGLanguage.GetMessage("stargate_vgui_name2"));
		else
			self.AddressColumn = 2;
			self.ChoiceSize = 80;
			self.AllowedSymbols = "[^0-9A-Z@#]";
			self.AllowedSymbolsTxt = "stargate_vgui_dialadr";
			self.MaxSymbols = 9;
			self.VguiPos = {30,142,137};
			self.VGUI.AddressListView:AddColumn(SGLanguage.GetMessage("stargate_vgui_glyphs")):SetFixedWidth(150);
			self.VGUI.AddressListView:AddColumn(SGLanguage.GetMessage("stargate_vgui_address2")):SetFixedWidth(80);
			self.VGUI.Width = 80;
			self.VGUI.AddressListView:AddColumn(SGLanguage.GetMessage("stargate_vgui_grouptype")):SetFixedWidth(100);
			self.VGUI.AddressListView:AddColumn(SGLanguage.GetMessage("stargate_vgui_name2"));
		end
	elseif (self.IsSuper) then
		self.VGUI.AddressListView:AddColumn(SGLanguage.GetMessage("stargate_vgui_address2")):SetFixedWidth(60);
		self.VGUI.AddressListView:AddColumn(SGLanguage.GetMessage("stargate_vgui_name2"));
	else
		self.AddressColumn = 2;
		self.ChoiceSize = 70;
		if (not self.CanDialGroups) then
			self.AllowedSymbolsTxt = "stargate_galaxy_vgui_dialadr2";
			self.MaxSymbols = 6;
		else
			self.AllowedSymbolsTxt = "stargate_galaxy_vgui_dialadr";
			self.MaxSymbols = 9;
		end
		self.VguiPos = {15,172,127};
		self.VGUI.AddressListView:AddColumn(SGLanguage.GetMessage("stargate_vgui_glyphs")):SetFixedWidth(150);
		self.VGUI.AddressListView:AddColumn(SGLanguage.GetMessage("stargate_vgui_address2")):SetFixedWidth(80);
		self.VGUI.Width = 80;
		self.VGUI.AddressListView:AddColumn(SGLanguage.GetMessage("stargate_vgui_name2"));
	end
	//self.VGUI.AddressListView:SortByColumn(1,true);
	//self:SortColumns()
	self.VGUI.AddressListView.OnRowSelected = function(ListView,Row)
		local selected = ListView:GetSelectedLine();
		if (ListView:GetLine(selected).Blocked) then ListView:GetLine(selected):SetSelected(false); self.LastSelected = 0; return end
		local address = ListView:GetLine(selected):GetColumnText(self.AddressColumn):upper():gsub(" ","");
		self.VGUI.AddressMultiChoice.TextEntry:SetText(address);
		if (self.IsSuper) then
			self.Data.AddressSuper = address;
		else
			self.Data.Address = address;
		end
		-- Avoids confusing soundspam on double click
		if(selected ~= self.LastSelected) then
			self.LastSelected = selected;
			surface.PlaySound(self.Sounds.Click);
		end
	end
	self.VGUI.AddressListView.DoDoubleClick = function(ListView,id,List)
		self:DialGate(List:GetColumnText(self.AddressColumn));
	end 
	for k,v in pairs(self.VGUI.AddressListView.Columns) do
		v._DoClick = v.DoClick
		v.DoClick = function() 
			v:_DoClick();
			self:SetCookie("ColumnSort",k);
			self:SetCookie("ColumnSortDesc",v:GetDescending() and 0 or 1);
		end
	end    

	--local w = 40
	--if (SGLanguage.ValidMessage("stargate_vgui_search_width")) then w = SGLanguage.GetMessage("stargate_vgui_search_width") end

	-- The Search Label
	self.VGUI.SearchLabel:SetPos(0,0);
	self.VGUI.SearchLabel:SetSize(40,self.VGUI.SearchLabel:GetTall());
	self.VGUI.SearchLabel:SetText(SGLanguage.GetMessage("stargate_vgui_search"));
	self.VGUI.SearchLabel:SizeToContentsX();
	local w,h = self.VGUI.SearchLabel:GetSize();
	w = w+5;

	-- The Search Field
	self.VGUI.SearchTextEntry:SetPos(w,0);
	self.VGUI.SearchTextEntry:SetSize(140,self.VGUI.SearchTextEntry:GetTall());
	self.VGUI.SearchTextEntry:SetTooltip(SGLanguage.GetMessage("stargate_vgui_srchtip"));
	self.VGUI.SearchTextEntry:SetAllowNonAsciiCharacters(true);
	self.VGUI.SearchTextEntry:SetText(self.Data.LastSearchText);
	-- Starts the Search delayed
	self.VGUI.SearchTextEntry.OnTextChanged = function(TextEntry)
		-- Do the search, but delayed. It's handled in the Think
		self.Data.LastSearchText = TextEntry:GetValue();
		self.Data.LastSearchTyped = CurTime();
	end

	-- The Search Button - It may seem to be obsolete (due to the autosearch), but an address can just be changed
	self.VGUI.SearchImageButton:SetPos(w+142,2);
	self.VGUI.SearchImageButton:SetSize(16,16);
	self.VGUI.SearchImageButton:SetImage(self.Images.Search);
	self.VGUI.SearchImageButton:SetTooltip(SGLanguage.GetMessage("stargate_vgui_search2"));
	self.VGUI.SearchImageButton.DoClick = function(ImageButton)
		-- Immediately do a search (Maybe a stargate has recently changed it's addresse or name?)
		self:RefreshList();
	end

	-- The Refresh Button (Refreshs the list of stargates we have) - Similar to a search, but it will find just recently added stargates
	self.VGUI.RefreshImageButton:SetPos(w+161,2);
	self.VGUI.RefreshImageButton:SetSize(16,16);
	self.VGUI.RefreshImageButton:SetImage(self.Images.Refresh);
	self.VGUI.RefreshImageButton:SetTooltip(SGLanguage.GetMessage("stargate_vgui_refresh"));
	self.VGUI.RefreshImageButton.DoClick = function(ImageButton)
		-- Immediately do a search (Maybe a stargate has recently changed it's addresse or name?)
		self:RefreshList(true);
	end

	--####### Apply Sizes: Address/Dial Fields - Positions set in PerformLayout
	-- The Address Label
	self.VGUI.AddressLabel:SetText(SGLanguage.GetMessage("stargate_vgui_address"));
	self.VGUI.AddressLabel:SizeToContentsX();

	-- The Address TextEntry
	-- DMultiChoice instead of TextEntry and make it save the recent gate addresses being dialled!
	self.VGUI.AddressMultiChoice:SetSize(self.ChoiceSize,self.VGUI.AddressMultiChoice:GetTall());
	self.VGUI.AddressMultiChoice.TextEntry:SetTooltip(SGLanguage.GetMessage(self.AllowedSymbolsTxt));
	-- This function restricts the letters you can enter to a valid address
	if (self.GroupSystem or self.IsSuper) then
		self.VGUI.AddressMultiChoice.TextEntry.OnTextChanged = function(TextEntry)
			local addr = self.Data.Address;
			if (self.IsSuper) then addr = self.Data.AddressSuper; end
			local text = TextEntry:GetValue();
			if(text ~= addr) then
				local pos = TextEntry:GetCaretPos();
				local len = text:len();
				local letters = text:upper():gsub(self.AllowedSymbols,""):TrimExplode(""); -- Upper, remove invalid chars and split!
				local text = ""; -- Wipe
				for _,v in pairs(letters) do
					if(not text:find(v)) then
						text = text..v;
					end
				end
				text = text:sub(1,self.MaxSymbols);
				TextEntry:SetText(text);
				TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
				if(addr ~= text and self.OnTextChanged) then
					self.OnTextChanged(TextEntry);
				end
				if (self.IsSuper) then
					self.Data.AddressSuper = text;
				else
					self.Data.Address = text;
				end
			end
		end
	else
		self.VGUI.AddressMultiChoice.TextEntry.OnTextChanged = function(TextEntry)
			local text = TextEntry:GetValue();
			if(text ~= self.Data.Address) then
				local pos = TextEntry:GetCaretPos();
				local len = text:len();
				local letters = text:upper():gsub("[^1-9A-Z@!]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
				local text = ""; -- Wipe
				for _,v in pairs(letters) do
					if(not text:find(v)) then
						text = text..v;
					end
				end
				-- set address field to 6 char, for @ 7. char and ! for 8.char @Llapp
				for i=1,6 do
				    if(text:sub(i,i) == "@" or text:sub(i,i) == "!")then
					    text = text:sub(1,i-1);
					end
				end
				if(text:sub(8,8) == "!")then text = text:sub(1,8);
				elseif(text:sub(7,7) == "@")then text = text:sub(1,7);
				else text = text:sub(1,6) end;
				if (self.MaxSymbols==6) then text = text:sub(1,6); end -- if can't dial 8-9 chevrons by convars
				--
				TextEntry:SetText(text);
				TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
				if(self.Data.Address ~= text and self.OnTextChanged) then
					self.OnTextChanged(TextEntry);
				end
				self.Data.Address = text;
			end
		end
	end

	-- Add choices (Last 15 dialled addresses)
	if (self.IsSuper) then
		for k,v in pairs(self.Data.AddressesSuper) do
			if (self.LocalGate and v:len()>6) then continue end
			self.VGUI.AddressMultiChoice:AddChoice(v);
		end
	else
		for k,v in pairs(self.Data.Addresses) do
			if (self.LocalGate and v:len()>6) then continue end
			self.VGUI.AddressMultiChoice:AddChoice(v);
		end
	end

	-- The DHD/SGC Dialmode Checkbox
	self.VGUI.DialTypeCheckbox:SetToolTip(SGLanguage.GetMessage("stargate_vgui_dialtip"));
	self.VGUI.DialTypeCheckbox:SetValue(self:GetCookie("DHDDial",false));
	self.VGUI.DialTypeCheckbox.ConVarChanged = function(CheckBox)
		self:SetCookie("DHDDial",CheckBox:GetChecked());
	end

	self.Correct_pos = 0;

	if (hidedialmode) then
		self.Correct_pos = 12;
		self.VGUI.DialTypeCheckbox:SetVisible(false);
	end

	-- The Dial Button
	self.VGUI.DialImageButton:SetSize(16,16);
	self.VGUI.DialImageButton:SetImage(self.Images.Dial);
	self.VGUI.DialImageButton:SetToolTip(SGLanguage.GetMessage("stargate_vgui_dialgt"));
	self.VGUI.DialImageButton.DoClick = function(ImageButton)
		self:DialGate(self.VGUI.AddressMultiChoice.TextEntry:GetValue());
	end

	-- The AbortDial Button
	self.VGUI.AbortDialImageButton:SetSize(16,16);
	self.VGUI.AbortDialImageButton:SetImage(self.Images.Abort);
	self.VGUI.AbortDialImageButton:SetToolTip(SGLanguage.GetMessage("stargate_vgui_dialab"));
	self.VGUI.AbortDialImageButton.DoClick = function(ImageButton)
		if(self.OnAbort) then self.OnAbort(self.Entity) end;
	end

	-- Add the gates to the list
	self.Gates = self:GetGates();
	self:AddGatesToList(self.Data.LastSearchText);
	self:LoadSettings();
end

--################# Sets the Address, entered in the dialbox @aVoN
function PANEL:SetText(text)
	self.VGUI.AddressMultiChoice.TextEntry:SetText(text or "");
end

--################# Gets the value of the addressfield @aVoN
function PANEL:GetValue()
	return self.VGUI.AddressMultiChoice.TextEntry:GetValue() or "";
end

function PANEL:UpdateLocalStage(locale)
	self.LocalGate = (locale or not self.CanDialGroups);
	if (self.LocalGate) then
		self.AddressColumn = 2;
		self.ChoiceSize = 70;
		self.AllowedSymbols = "[^0-9A-Z@#]";
		self.AllowedSymbolsTxt = "stargate_vgui_dialadr2";
		self.MaxSymbols = 6;
		self.VguiPos = {15,132,127};
		self.VGUI.Width = 60;
	else
		self.AddressColumn = 2;
		self.ChoiceSize = 80;
		self.AllowedSymbols = "[^0-9A-Z@#]";
		self.AllowedSymbolsTxt = "stargate_vgui_dialadr";
		self.MaxSymbols = 9;
		self.VguiPos = {30,142,137};
		self.VGUI.Width = 80;
	end
	self.VGUI.AddressMultiChoice.TextEntry:SetTooltip(SGLanguage.GetMessage(self.AllowedSymbolsTxt));
	self.VGUI.AddressMultiChoice:SetSize(self.ChoiceSize,self.VGUI.AddressMultiChoice:GetTall());
	local txt = self:GetValue();
	if (txt:len()>6 and locale) then
		self:SetText(txt:sub(1,6));
	end
	self.VGUI.AddressMultiChoice.Choices = {};
	-- Add choices (Last 15 dialled addresses)
	for k,v in pairs(self.Data.Addresses) do
		if (self.LocalGate and v:len()>6) then continue end
		self.VGUI.AddressMultiChoice:AddChoice(v);
	end
end

--################# Adds the address we selected to the "LastDialled" list and plays a sound. Also calls the Dial function @aVoN
function PANEL:DialGate(address)
	address = (address or ""):upper():gsub(" ","");
	if(address:len() >= 6) then
		surface.PlaySound(self.Sounds.Info);
		-- Shall we add this address to the "already dialled" list?
		if (self.IsSuper) then
			for k,v in pairs(self.Data.AddressesSuper) do
				if(self:Find(v,address,true)) then
					self.Data.AddressesSuper[k] = nil;
				end
			end
		else
			for k,v in pairs(self.Data.Addresses) do
				if(self:Find(v,address,true)) then
					self.Data.Addresses[k] = nil;
				end
			end
		end
		local addresses = {address};
		-- Keep the last 15 dialled addresses in cache...
		if (self.IsSuper) then
			for k,v in pairs(table.ClearKeys(self.Data.AddressesSuper)) do
				if(k < 15) then table.insert(addresses,v) end;
			end
			self.Data.AddressSuper = address;
			self.Data.AddressesSuper = addresses;
		else
			for k,v in pairs(table.ClearKeys(self.Data.Addresses)) do
				if(k < 15) then table.insert(addresses,v) end;
			end
			self.Data.Address = address;
			self.Data.Addresses = addresses;
		end
		-- Clear old choices first!
		self.VGUI.AddressMultiChoice.Choices = {};
		-- Now, add the choices!
		if (self.IsSuper) then
			for _,v in pairs(self.Data.AddressesSuper) do
				self.VGUI.AddressMultiChoice:AddChoice(v);
			end
		else
			for _,v in pairs(self.Data.Addresses) do
				self.VGUI.AddressMultiChoice:AddChoice(v);
			end
		end
		if(self.OnDial) then self.OnDial(self.Entity,address,self.VGUI.DialTypeCheckbox:GetChecked()) end;
	else
		surface.PlaySound(self.Sounds.Warning);
	end
end

--################# Perform the layout @aVoN
function PANEL:PerformLayout(w,h)
	if (self.VGUI==nil or self.VguiPos==nil) then return end
	-- The Address List
	self.VGUI.AddressListView:SetSize(w,h-self.VguiPos[1]);
	-- Fix a bug in the DListView: We will redraw it's Lines to fit to the altered size!
	self.VGUI.AddressListView:DataLayout();
	-- The Address Label
	local lw,lh = self.VGUI.AddressLabel:GetSize();
	self.VGUI.AddressLabel:SetPos(w-self.VguiPos[2]+self.Correct_pos-lw,0);
	-- The Address TextEntry
	self.VGUI.AddressMultiChoice:SetPos(w-self.VguiPos[3]+self.Correct_pos,0);
	self.VGUI.DialTypeCheckbox:SetPos(w-55,3);
	-- The Dial Button
	self.VGUI.DialImageButton:SetPos(w-40,2);
	-- The Abort Button
	self.VGUI.AbortDialImageButton:SetPos(w-20,2);
end

--################# The necessary Entity, this panel comes along with (the gate) @aVoN
function PANEL:LoadSettings()
	--##### Search text
	self.VGUI.SearchTextEntry:SetText(self.Data.LastSearchText or "");
	local caret_pos = math.Clamp(self.VGUI.AddressMultiChoice.TextEntry:GetCaretPos(),0,self.Data.Address:len());
	if (self.IsSuper) then
		caret_pos = math.Clamp(self.VGUI.AddressMultiChoice.TextEntry:GetCaretPos(),0,self.Data.AddressSuper:len());
		self.VGUI.AddressMultiChoice.TextEntry:SetText(self.Data.AddressSuper);
	else
		local txt = self.Data.Address;
		if (txt:len()>6 and self.LocalGate) then
			txt = txt:sub(1,6);
		end
		self.VGUI.AddressMultiChoice.TextEntry:SetText(txt);
	end
	self.VGUI.AddressMultiChoice.TextEntry:SetCaretPos(caret_pos);
	--##### The searchfield has been reset - Update the list
	--self:RefreshList(true);
	-- "SetEntity" normally also means, we are getting "opened". So use this as an event and make the TextEntry focussed (for diallign a gate)
	self.VGUI.AddressMultiChoice.TextEntry:RequestFocus();
end

--################# Get group/type name by AlexALX
function PANEL:GetGroupName(g)
	local name = SGLanguage.GetMessage("stargate_vgui_grpc")
	if (g == "M@") then
		name = SGLanguage.GetMessage("stargate_vgui_grp1");
	elseif (g == "P@") then
		name = SGLanguage.GetMessage("stargate_vgui_grp2");
	elseif (g == "I@") then
		name = SGLanguage.GetMessage("stargate_vgui_grp3");
	elseif (g == "OT") then
		name = SGLanguage.GetMessage("stargate_vgui_grp8");
	elseif (g == "O@") then
		name = SGLanguage.GetMessage("stargate_vgui_grp4");
	elseif (g == "U@#") then
		name = SGLanguage.GetMessage("stargate_vgui_grp5");
	elseif (g == "SGI") then
		name = SGLanguage.GetMessage("stargate_vgui_grp6");
	elseif (g == "DST") then
		name = SGLanguage.GetMessage("stargate_vgui_grp7");
	elseif (SG_CUSTOM_GROUPS and SG_CUSTOM_GROUPS[g]) then
		name = SG_CUSTOM_GROUPS[g][1];
	elseif (SG_CUSTOM_TYPES and SG_CUSTOM_TYPES[g]) then
		name = SG_CUSTOM_TYPES[g][1];
	elseif (g:len()==3) then
		name = SGLanguage.GetMessage("stargate_vgui_grpc2");
	end
	return name;
end

--################# Adds the gates to the AddressList @aVoN
function PANEL:AddGatesToList(s)
	if(s == "") then s = nil end;
	-- Get the last selected gate:
	local line = self.VGUI.AddressListView:GetSelectedLine();
	local last_address;
	if(line) then
		last_address = self.VGUI.AddressListView:GetLine(line):GetColumnText(1);
	end
	-- Clear old view
	self.VGUI.AddressListView:Clear();
	if (self.GroupAllowed) then
		local gates = {}
		for k,v in pairs(self.Gates) do
			-- Never add the gate we are dialling from to this panel
			if(tonumber(v.ent) ~= self.Entity:EntIndex() and not v.private) then
				local address = v.address;
				local group = v.group;
				local locale = v.locale;
				local ent = self.Entity;
				if (self.Entity.IsStargate == true) then
					ent = self.Entity;
				elseif (self.Entity.IsDHD == true) then
					ent = self.Entity:GetParent();
				end
				if(address != "" and group != "" and IsValid(ent) and (not locale and not ent:GetLocale() and not self.LocalGate or (ent:GetGateGroup() == group or v.class=="stargate_universe" and ent:GetClass()=="stargate_universe")) and (address!=ent:GetGateAddress() or group!=ent:GetGateGroup())) then
					local range = (ent:GetPos() - v.pos):Length();
					local c_range = ent:GetNetworkedInt("SGU_FIND_RANDE"); -- GetConVar("stargate_sgu_find_range"):GetInt();
					if (ent:GetGateGroup() != group and (v.class!="stargate_universe" or ent:GetClass()!="stargate_universe") or c_range > 0 and range>c_range and ent:GetGateGroup():len()==3) then
						if (locale or ent:GetLocale()) then	continue end
						if (ent:GetGateGroup():len()==3 and group:len()==3 or ent:GetGateGroup():len()==2 and group:len()==2) then
							address = address..group:sub(1,1);
						else
							address = address..group;
						end
						if (group:len()==2 and ent:GetGateGroup():len()==3) then
							address = address.."#";
						end
					end
					local address2 = string.sub(address:gsub("#","").."#",1,9);
					local name = v.name;
					if(not table.HasValue(gates,address) and (not ent:GetNWBool("Chev9Special") or address2:len()==9) and (not s or (self:Find(address,s) or (name ~= "" and self:Find(name,s))))) then
						if(name == "") then name = "N/A" end;
						local blocked, energy = "false", "true";
						if (v.blocked) then blocked = "true"; end
						if (not ent:CheckEnergy(v,address2:len())) then energy = "false"; end
						self.VGUI.AddressListView:AddLine(address2,address,self:GetGroupName(group),name,blocked,energy);
						table.insert(gates,address);
					end
				end
			end
		end
	elseif(self.IsSuper) then
		for k,v in pairs(self.Gates) do
			-- Never add the gate we are dialling from to this panel
			if(tonumber(v.ent) ~= self.Entity:EntIndex() and not v.private) then
			    local address = v.address;
				local ent = self.Entity;
				if (self.Entity.IsStargate == true) then
					ent = self.Entity;
				elseif (self.Entity.IsDHD == true) then
					ent = self.Entity:GetParent();
				end
				if(address ~= "" and IsValid(ent)) then
					local name = v.name;
					if(not s or (self:Find(address,s) or (name ~= "" and self:Find(name,s)))) then
						if(name == "") then name = "N/A" end;
						local energy = "true";
						if (not ent:CheckEnergy(v,address:len()+1)) then energy = "false"; end
						self.VGUI.AddressListView:AddLine(address,name,energy);
					end
				end
			end
		end
	else
		local g = self.Entity;
		for k,v in pairs(self.Gates) do
			-- Never add the gate we are dialling from to this panel
			if(tonumber(v.ent) ~= self.Entity:EntIndex() and not v.private) then
			    local address = v.address;
				if(address ~= "") then
					if(IsValid(g))then
						local range = (g:GetPos() - v.pos):Length();
						local c_range = g:GetNetworkedInt("SGU_FIND_RANDE"); -- GetConVar("stargate_sgu_find_range"):GetInt();
					    if(v.galaxy or g:GetGalaxy() or
						   v.class=="stargate_universe" and g:GetClass()=="stargate_universe" and
						   c_range > 0 and range>c_range)then
						    address = address.."@";
					    end
					    if(v.class == "stargate_atlantis" and g:GetClass() == "stargate_atlantis" and #address == 7 and g:GetGalaxy() and v.galaxy)then
							address = string.Explode("@",tostring(address));
							address = address[1];
						end
						if(#address == 7 and g:GetGalaxy() and v.galaxy and ((v.class ~= "stargate_atlantis" and g:GetClass() ~= "stargate_atlantis") and
						   (v.class ~= "stargate_universe" and g:GetClass() ~= "stargate_universe")))then
							address = string.Explode("@",tostring(address));
							address = address[1];
						end
						if((v.class == "stargate_universe" and g:GetClass() ~= "stargate_universe") or --#address == 7 and
						   (v.class ~= "stargate_universe" and g:GetClass() == "stargate_universe"))then
							address = string.Explode("@",tostring(address));
							address = address[1].."@!";
						end
					end
					local name = v.name;
					local ent = self.Entity;
					if (IsValid(self.Entity) and self.Entity.IsDHD == true) then
						ent = self.Entity:GetParent();
					end
					if(IsValid(ent) and (not s or (self:Find(address,s) or (name ~= "" and self:Find(name,s))))) then
						if(name == "") then name = "N/A" end;
						local address2 = string.sub(address:gsub("#","").."#",1,9);
						if (self.CanDialGroups or address:len()==6) then
							local blocked, energy = "false", "true";
							if (IsValid(g) and v.blocked) then blocked = "true"; end
							if (not ent:CheckEnergy(v,address2:len())) then energy = "false"; end
							self.VGUI.AddressListView:AddLine(address2,address,name,blocked,energy);
						end
					end
				end
			end
		end
	end
	if (self.IsSuper) then
		ApplyColor(self);
	else
		ApplyGlyphs(self, not self.GroupSystem);
	end
	if(last_address) then
		for _,v in pairs(self.VGUI.AddressListView.Lines) do
			if(v:GetColumnText(1) == last_address) then
				v:SetSelected(true);
				break;
			end
		end
	end
	
	self:SortColumns()
	
end

function PANEL:SortColumns()
	local desc = self:GetCookie("ColumnSortDesc",1)==1 and true or false
	local col = tonumber(self:GetCookie("ColumnSort",1))
	self.VGUI.AddressListView:SortByColumn(col,desc);
	-- fix for column click
	for k,v in pairs(self.VGUI.AddressListView.Columns) do
		if (k==col) then
			v:SetDescending( not desc )
			break
		end
	end
end

--################# If DHD is concept added by AlexALX
function PANEL:IsConcept(ent)
	if(not IsValid(self.Entity)) then return false end;
	if (self.Entity:GetNetworkedInt("Point_of_Origin",0)==1) then
		return true;
	elseif (self.Entity:GetNetworkedInt("Point_of_Origin",0)>=2) then
		return false;
	end
	for _,v in pairs(self:FindDHD()) do
		if(v:IsValid() and v:GetClass() == "dhd_concept") then
			return true;
		end
	end
	if (table.Count(self:FindDHD())==0) then return true end
	return false;
end

--################# Find's all DHD's which may call this gate @aVoN
function PANEL:FindDHD()
	if (not IsValid(self.Entity)) then return end
	local pos = self.Entity:GetPos();
	local dhd = {};
	local DHDRange = StarGate.CFG:Get("dhd","range",1000);
	for _,v in pairs(ents.FindByClass("dhd_*")) do
		if (v.IsGroupDHD) then
			local e_pos = v:GetPos();
			local dist = (e_pos - pos):Length(); -- Distance from DHD to this stargate
			if(dist <= DHDRange) then
				-- Check, if this DHD really belongs to this gate
				local add = true;
				for _,gate in pairs(self:GetGates()) do
					if(gate.ent ~= self.Entity:EntIndex() and (gate.pos - e_pos):Length() < dist) then
						add = false;
						break;
					end
				end
				if(add) then
					table.insert(dhd,v);
				end
			end
		end
	end
	return dhd;
end

--################# Refreshs the list of the panel
function PANEL:RefreshList(update)
	if(update) then
		self.Gates = self:GetGates();
	end
	self:AddGatesToList(self.VGUI.SearchTextEntry:GetValue());
end

--################# Finds needle (n) in haystack (h). Setting letters to true will search for the occurance of all letters (no matter in what order they are) @aVoN
function PANEL:Find(h,n,letters)
	local h = h:upper();
	local n = n:upper();
	if(letters) then
		local letters = n:gsub("[^0-9A-Z@]",""):TrimExplode(""); -- Removes illegal chars, because "letters" is only used for addresses in here
		for _,v in pairs(letters) do
			if(not h:find(v)) then return false end;
		end
		return true;
	else
		local words = n:gsub("[%s]+"," "):TrimExplode(" "); -- Remove any space character (maybe multiple) with only one
		for _,v in pairs(words) do
			if(not h:find(v)) then return false end;
		end
		return true;
	end
end

--################# Get every valid gates by AlexALX
function PANEL:GetGates()
	local gates = {};
	for _,v in pairs(StarGate_GetAll or {}) do
		if (self.IsSuper and v.class=="stargate_supergate" or not self.IsSuper and v.groupgate) then
			table.insert(gates,v);
		end
	end
	return gates;
end

--################# Think @aVoN
function PANEL:Think()
	-- Do the search, but delayed
	if(self.Data.LastSearchTyped and CurTime() - self.Data.LastSearchTyped > 0.5) then
		self.Gates = self:GetGates(); -- First, refresh stargates!
		self:AddGatesToList(self.Data.LastSearchText);
		self.Data.LastSearchTyped = nil;
		self.LastSelected = nil;
	end
end

--################# Get DialType checkbox status by AlexALX
function PANEL:GetDialType()
	return self.VGUI.DialTypeCheckbox:GetChecked();
end

--################# Get DialType checkbox status by AlexALX
function PANEL:SetDialType(set)
	self.VGUI.DialTypeCheckbox:SetChecked(set);
	if (set) then
		self.VGUI.DialTypeCheckbox:SetValue(1);
	else
		self.VGUI.DialTypeCheckbox:SetValue(0);
	end
end

vgui.Register("SAddressSelect",PANEL,"Panel");