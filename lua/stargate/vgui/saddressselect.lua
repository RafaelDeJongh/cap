/*
	Stargate for GarrysMod10
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
net.Receive( "RefreshGateListSelect", StarGateRefreshList);

local function StarGateRemoveFromList( len )
	local ent = net.ReadInt(16);
	if (not ent) then return end
	StarGate_GetAll[ent] = nil;
end
net.Receive( "RemoveGateFromListSelect" , StarGateRemoveFromList );

local Panel_Images = {
	Search = "icon16/application_form_magnify.png",
	Refresh = "icon16/arrow_refresh.png",
	Dial = "icon16/folder_go.png",
	Abort = "icon16/cancel.png",
}

local PANEL = {};

PANEL.Sounds = {
	Info = Sound("buttons/button9.wav"),
	Click = Sound("npc/turret_floor/click1.wav"),
	Warning = Sound("buttons/button2.wav"),
}
PANEL.Data = {
	Addresses = {}, -- Last Dialled Addresses
	Address = "", -- Last Address in the multichoice
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

local function TextSize(text,type)
	local len = text:len()
	local siz = len*17.8 -- sg1
	if (type==1) then -- atlantis
		siz = len*20;
	elseif(type==2) then -- universe
		siz = len*11;
	elseif(type==3) then -- normal text
		siz = len*8
	end
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

--################# Register Hooks AlexALX
local function PANEL_RegisterHooks(self)
	-- for smaller font from gmod10
	for k,v in pairs(self.VGUI) do
		if (k=="SearchTextEntry" or k=="Width" or k=="AddressMultiChoice" or k=="AddressListView") then continue end
		if (v.SetFont) then
			v:SetFont("OldDefaultSmall");
		end
		if (v.Label and v.Label.SetFont) then
			v.Label:SetFont("OldDefaultSmall");
		end
	end
end

--################# Init @aVoN
function PANEL:Init()
	self:SetSize(400,100);
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
	self.Entity = NULL;
	self:SetCookieName("StarGate.SAddressSelect"); -- Just for the checkbox to save the value (it always annoyed me, it losses it after a restart)
	--####### Apply Sizes: Search Fields
	-- The Address List
	self.VGUI.AddressListView:SetPos(0,25);
	self.VGUI.AddressListView:AddColumn(Language.GetMessage("stargate_vgui_address2")):SetFixedWidth(60);
	self.VGUI.AddressListView:AddColumn(Language.GetMessage("stargate_vgui_name2"));
	self.VGUI.AddressListView:SortByColumn(1,true);
	self.VGUI.AddressListView.OnRowSelected = function(ListView,Row)
		local selected = ListView:GetSelectedLine();
		local address = ListView:GetLine(selected):GetColumnText(1):upper():gsub(" ","");
		self.VGUI.AddressMultiChoice.TextEntry:SetText(address);
		self.Data.Address = address;
		-- Avoids confusing soundspam on double click
		if(selected ~= self.LastSelected) then
			self.LastSelected = selected;
			surface.PlaySound(self.Sounds.Click);
		end
	end
	self.VGUI.AddressListView.DoDoubleClick = function(ListView,id,List)
		self:DialGate(List:GetColumnText(1));
	end

	local w = 40
	if (Language.ValidMessage("stargate_vgui_search_width")) then w = Language.GetMessage("stargate_vgui_search_width") end

	-- The Search Label
	self.VGUI.SearchLabel:SetPos(0,0);
	self.VGUI.SearchLabel:SetSize(w,self.VGUI.SearchLabel:GetTall());
	self.VGUI.SearchLabel:SetText(Language.GetMessage("stargate_vgui_search"));

	-- The Search Field
	self.VGUI.SearchTextEntry:SetPos(w,0);
	self.VGUI.SearchTextEntry:SetSize(140,self.VGUI.SearchTextEntry:GetTall());
	self.VGUI.SearchTextEntry:SetTooltip(Language.GetMessage("stargate_vgui_srchtip"));
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
	self.VGUI.SearchImageButton:SetImage(Panel_Images.Search);
	self.VGUI.SearchImageButton:SetTooltip(Language.GetMessage("stargate_vgui_search2"));
	self.VGUI.SearchImageButton.DoClick = function(ImageButton)
		-- Immediately do a search (Maybe a stargate has recently changed it's addresse or name?)
		self:RefreshList();
	end

	-- The Refresh Button (Refreshs the list of stargates we have) - Similar to a search, but it will find just recently added stargates
	self.VGUI.RefreshImageButton:SetPos(w+161,2);
	self.VGUI.RefreshImageButton:SetSize(16,16);
	self.VGUI.RefreshImageButton:SetImage(Panel_Images.Refresh);
	self.VGUI.RefreshImageButton:SetTooltip(Language.GetMessage("stargate_vgui_refresh"));
	self.VGUI.RefreshImageButton.DoClick = function(ImageButton)
		-- Immediately do a search (Maybe a stargate has recently changed it's addresse or name?)
		self:RefreshList(true);
	end

	--####### Apply Sizes: Address/Dial Fields - Positions set in PerformLayout
	-- The Address Label
	self.VGUI.AddressLabel:SetText(Language.GetMessage("stargate_vgui_address"));

	-- The Address TextEntry
	-- DMultiChoice instead of TextEntry and make it save the recent gate addresses being dialled!
	self.VGUI.AddressMultiChoice:SetSize(70,self.VGUI.AddressMultiChoice:GetTall());
	self.VGUI.AddressMultiChoice.TextEntry:SetTooltip(Language.GetMessage("stargate_vgui_dialadr2"));
	-- This function restricts the letters you can enter to a valid address
	self.VGUI.AddressMultiChoice.TextEntry.OnTextChanged = function(TextEntry)
		local text = TextEntry:GetValue();
		if(text ~= self.Data.Address) then
			local pos = TextEntry:GetCaretPos();
			local len = text:len();
			local letters = text:upper():gsub("[^0-9A-Z@]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
			local text = ""; -- Wipe
			for _,v in pairs(letters) do
				if(not text:find(v)) then
					text = text..v;
				end
			end
			text = text:sub(1,6);
			TextEntry:SetText(text);
			TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
			if(self.Data.Address ~= text and self.OnTextChanged) then
				self.OnTextChanged(TextEntry);
			end
			self.Data.Address = text;
		end
	end

	-- Add choices (Last 15 dialled addresses)
	for _,v in pairs(self.Data.Addresses) do
		self.VGUI.AddressMultiChoice:AddChoice(v);
	end

	-- The DHD/SGC Dialmode Checkbox
	self.VGUI.DialTypeCheckbox:SetToolTip(Language.GetMessage("stargate_vgui_dialtip"));
	self.VGUI.DialTypeCheckbox:SetValue(self:GetCookie("DHDDial",false));
	self.VGUI.DialTypeCheckbox.ConVarChanged = function(CheckBox)
		self:SetCookie("DHDDial",CheckBox:GetChecked());
	end

	-- The Dial Button
	self.VGUI.DialImageButton:SetSize(16,16);
	self.VGUI.DialImageButton:SetImage(Panel_Images.Dial);
	self.VGUI.DialImageButton:SetToolTip(Language.GetMessage("stargate_vgui_dialgt"));
	self.VGUI.DialImageButton.DoClick = function(ImageButton)
		self:DialGate(self.VGUI.AddressMultiChoice.TextEntry:GetValue());
	end

	-- The AbortDial Button
	self.VGUI.AbortDialImageButton:SetSize(16,16);
	self.VGUI.AbortDialImageButton:SetImage(Panel_Images.Abort);
	self.VGUI.AbortDialImageButton:SetToolTip(Language.GetMessage("stargate_vgui_dialab"));
	self.VGUI.AbortDialImageButton.DoClick = function(ImageButton)
		if(self.OnAbort) then self.OnAbort(self.Entity) end;
	end

	-- Add the gates to the list
	self.Gates = self:GetGates();
	self:AddGatesToList(self.Data.LastSearchText);
	PANEL_RegisterHooks(self)
end

--################# Sets the Address, entered in the dialbox @aVoN
function PANEL:SetText(text)
	self.VGUI.AddressMultiChoice.TextEntry:SetText(text or "");
end

--################# Gets the value of the addressfield @aVoN
function PANEL:GetValue()
	return self.VGUI.AddressMultiChoice.TextEntry:GetValue() or "";
end

--################# Adds the address we selected to the "LastDialled" list and plays a sound. Also calls the Dial function @aVoN
function PANEL:DialGate(address)
	address = (address or ""):upper():gsub(" ","");
	if(address:len() >= 6) then
		surface.PlaySound(self.Sounds.Info);
		-- Shall we add this address to the "already dialled" list?
		for k,v in pairs(self.Data.Addresses) do
			if(self:Find(v,address,true)) then
				self.Data.Addresses[k] = nil;
			end
		end
		local addresses = {address};
		-- Keep the last 15 dialled addresses in cache...
		for k,v in pairs(table.ClearKeys(self.Data.Addresses)) do
			if(k < 15) then table.insert(addresses,v) end;
		end
		self.Data.Address = address;
		self.Data.Addresses = addresses;
		-- Clear old choices first!
		self.VGUI.AddressMultiChoice.Choices = {};
		-- Now, add the choices!
		for _,v in pairs(self.Data.Addresses) do
			self.VGUI.AddressMultiChoice:AddChoice(v);
		end
		if(self.OnDial) then self.OnDial(self.Entity,address,self.VGUI.DialTypeCheckbox:GetChecked()) end;
	else
		surface.PlaySound(self.Sounds.Warning);
	end
end

--################# The necessary Entity, this panel comes along with (the gate) @aVoN
function PANEL:SetEntity(e)
	self.Entity = e;
	--##### Now also update the Text of the search field and the multichoice's diallied addresses
	self.VGUI.AddressMultiChoice.Choices = {};
	for _,v in pairs(self.Data.Addresses) do
		self.VGUI.AddressMultiChoice:AddChoice(v);
	end
	--##### Search text
	self.VGUI.SearchTextEntry:SetText(self.Data.LastSearchText or "");
	local caret_pos = math.Clamp(self.VGUI.AddressMultiChoice.TextEntry:GetCaretPos(),0,self.Data.Address:len());
	self.VGUI.AddressMultiChoice.TextEntry:SetText(self.Data.Address);
	self.VGUI.AddressMultiChoice.TextEntry:SetCaretPos(caret_pos);
	--##### The searchfield has been reset - Update the list
	self:RefreshList(true);
	-- "SetEntity" normally also means, we are getting "opened". So use this as an event and make the TextEntry focussed (for diallign a gate)
	self.VGUI.AddressMultiChoice.TextEntry:RequestFocus();
end

--################# Perform the layout @aVoN
function PANEL:PerformLayout()
	local w,h = self:GetSize();
	-- The Address List
	self.VGUI.AddressListView:SetSize(w,h-15);
	-- Fix a bug in the DListView: We will redraw it's Lines to fit to the altered size!
	self.VGUI.AddressListView:DataLayout();
	-- The Address Label
	self.VGUI.AddressLabel:SetPos(w-172,0);
	-- The Address TextEntry
	self.VGUI.AddressMultiChoice:SetPos(w-127,0);
	self.VGUI.DialTypeCheckbox:SetPos(w-55,3);
	-- The Dial Button
	self.VGUI.DialImageButton:SetPos(w-40,2);
	-- The Abort Button
	self.VGUI.AbortDialImageButton:SetPos(w-20,2);
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
	local g = self.Entity;
	-- Clear old view
	self.VGUI.AddressListView:Clear();
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
	ApplyColor(self);
	if(last_address) then
		for _,v in pairs(self.VGUI.AddressListView.Lines) do
			if(v:GetColumnText(1) == last_address) then
				v:SetSelected(true);
				break;
			end
		end
	end
	self.VGUI.AddressListView:SortByColumn(1,true); -- Resort by addresses
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
		if (v.class=="stargate_supergate") then
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


--################# Shows how this thing has to be used @aVoN
function PANEL:GenerateExample()
	local VGUI = vgui.Create("SAddressSelect");
	VGUI:SetSize(180,80);
	VGUI:SetEntity(NULL); -- This defines the stargate this Address Panel is allocated to (Necessary, so we know, what gate we are currently using)
	VGUI.OnDial = function(gate,address,fast_dhd_mode) end; -- The function which shall be triggered when the user dials a gate
	VGUI.OnAbort = function(gate) end; -- The function to call, if you want to abort dialling/close a gate
	return VGUI;
end

--##################################
--###### SAddressSelect_Group.lua
--##################################

local PANEL = {};

PANEL.Sounds = {
	Info = Sound("buttons/button9.wav"),
	Click = Sound("npc/turret_floor/click1.wav"),
	Warning = Sound("buttons/button2.wav"),
}
PANEL.Data = {
	Addresses = {}, -- Last Dialled Addresses
	Address = "", -- Last Address in the multichoice
	LastSearchText = "", -- The last search text a person entered
}

--################# Init @aVoN
function PANEL:Init()
	self:SetSize(400,100);
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
	self.Entity = NULL;
	self:SetCookieName("StarGate.SAddressSelect"); -- Just for the checkbox to save the value (it always annoyed me, it losses it after a restart)
	--####### Apply Sizes: Search Fields
	-- The Address List
	self.VGUI.AddressListView:SetPos(0,25);
	self.VGUI.AddressListView:AddColumn(Language.GetMessage("stargate_vgui_glyphs")):SetFixedWidth(150);
	self.VGUI.AddressListView:AddColumn(Language.GetMessage("stargate_vgui_address2")):SetFixedWidth(80);
	self.VGUI.Width = 80;
	self.VGUI.AddressListView:AddColumn(Language.GetMessage("stargate_vgui_grouptype")):SetFixedWidth(100);
	self.VGUI.AddressListView:AddColumn(Language.GetMessage("stargate_vgui_name2"));
	self.VGUI.AddressListView:SortByColumn(1,true);
	self.VGUI.AddressListView.OnRowSelected = function(ListView,Row)
		local selected = ListView:GetSelectedLine();
		if (ListView:GetLine(selected).Blocked) then ListView:GetLine(selected):SetSelected(false); self.LastSelected = 0; return end
		local address = ListView:GetLine(selected):GetColumnText(2):upper():gsub(" ","");
		self.VGUI.AddressMultiChoice.TextEntry:SetText(address);
		self.Data.Address = address;
		-- Avoids confusing soundspam on double click
		if(selected ~= self.LastSelected) then
			self.LastSelected = selected;
			surface.PlaySound(self.Sounds.Click);
		end
	end
	self.VGUI.AddressListView.DoDoubleClick = function(ListView,id,List)
		if (not List.Blocked) then
			self:DialGate(List:GetColumnText(2));
		end
	end

	local w = 40
	if (Language.ValidMessage("stargate_vgui_search_width")) then w = Language.GetMessage("stargate_vgui_search_width") end

	-- The Search Label
	self.VGUI.SearchLabel:SetPos(0,0);
	self.VGUI.SearchLabel:SetSize(w,self.VGUI.SearchLabel:GetTall());
	self.VGUI.SearchLabel:SetText(Language.GetMessage("stargate_vgui_search"));

	-- The Search Field
	self.VGUI.SearchTextEntry:SetPos(w,0);
	self.VGUI.SearchTextEntry:SetSize(140,self.VGUI.SearchTextEntry:GetTall());
	self.VGUI.SearchTextEntry:SetTooltip(Language.GetMessage("stargate_vgui_srchtip"));
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
	self.VGUI.SearchImageButton:SetImage(Panel_Images.Search);
	self.VGUI.SearchImageButton:SetTooltip(Language.GetMessage("stargate_vgui_search2"));
	self.VGUI.SearchImageButton.DoClick = function(ImageButton)
		-- Immediately do a search (Maybe a stargate has recently changed it's addresse or name?)
		self:RefreshList();
	end

	-- The Refresh Button (Refreshs the list of stargates we have) - Similar to a search, but it will find just recently added stargates
	self.VGUI.RefreshImageButton:SetPos(w+161,2);
	self.VGUI.RefreshImageButton:SetSize(16,16);
	self.VGUI.RefreshImageButton:SetImage(Panel_Images.Refresh);
	self.VGUI.RefreshImageButton:SetTooltip(Language.GetMessage("stargate_vgui_refresh"));
	self.VGUI.RefreshImageButton.DoClick = function(ImageButton)
		-- Immediately do a search (Maybe a stargate has recently changed it's addresse or name?)
		self:RefreshList(true);
	end

	--####### Apply Sizes: Address/Dial Fields - Positions set in PerformLayout
	-- The Address Label
	self.VGUI.AddressLabel:SetText(Language.GetMessage("stargate_vgui_address"));

	-- The Address TextEntry
	-- DMultiChoice instead of TextEntry and make it save the recent gate addresses being dialled!
	self.VGUI.AddressMultiChoice:SetSize(80,self.VGUI.AddressMultiChoice:GetTall());
	self.VGUI.AddressMultiChoice.TextEntry:SetTooltip(Language.GetMessage("stargate_vgui_dialadr"));
	-- This function restricts the letters you can enter to a valid address
	self.VGUI.AddressMultiChoice.TextEntry.OnTextChanged = function(TextEntry)
		local text = TextEntry:GetValue();
		if(text ~= self.Data.Address) then
			local pos = TextEntry:GetCaretPos();
			local len = text:len();
			local letters = text:upper():gsub("[^0-9A-Z@#]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
			local text = ""; -- Wipe
			for _,v in pairs(letters) do
				if(not text:find(v)) then
					text = text..v;
				end
			end
			text = text:sub(1,9);
			TextEntry:SetText(text);
			TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
			if(self.Data.Address ~= text and self.OnTextChanged) then
				self.OnTextChanged(TextEntry);
			end
			self.Data.Address = text;
		end
	end

	-- Add choices (Last 15 dialled addresses)
	for _,v in pairs(self.Data.Addresses) do
		self.VGUI.AddressMultiChoice:AddChoice(v);
	end

	-- The DHD/SGC Dialmode Checkbox
	self.VGUI.DialTypeCheckbox:SetToolTip(Language.GetMessage("stargate_vgui_dialtip"));
	self.VGUI.DialTypeCheckbox:SetValue(self:GetCookie("DHDDial",false));
	self.VGUI.DialTypeCheckbox.ConVarChanged = function(CheckBox)
		self:SetCookie("DHDDial",CheckBox:GetChecked());
	end

	-- The Dial Button
	self.VGUI.DialImageButton:SetSize(16,16);
	self.VGUI.DialImageButton:SetImage(Panel_Images.Dial);
	self.VGUI.DialImageButton:SetToolTip(Language.GetMessage("stargate_vgui_dialgt"));
	self.VGUI.DialImageButton.DoClick = function(ImageButton)
		self:DialGate(self.VGUI.AddressMultiChoice.TextEntry:GetValue());
	end

	-- The AbortDial Button
	self.VGUI.AbortDialImageButton:SetSize(16,16);
	self.VGUI.AbortDialImageButton:SetImage(Panel_Images.Abort);
	self.VGUI.AbortDialImageButton:SetToolTip(Language.GetMessage("stargate_vgui_dialab"));
	self.VGUI.AbortDialImageButton.DoClick = function(ImageButton)
		if(self.OnAbort) then self.OnAbort(self.Entity) end;
	end

	-- Add the gates to the list
	self.Gates = self:GetGates();
	self:AddGatesToList(self.Data.LastSearchText);
	PANEL_RegisterHooks(self)
end

--################# Sets the Address, entered in the dialbox @aVoN
function PANEL:SetText(text)
	self.VGUI.AddressMultiChoice.TextEntry:SetText(text or "");
end

--################# Gets the value of the addressfield @aVoN
function PANEL:GetValue()
	return self.VGUI.AddressMultiChoice.TextEntry:GetValue() or "";
end

--################# Adds the address we selected to the "LastDialled" list and plays a sound. Also calls the Dial function @aVoN
function PANEL:DialGate(address)
	address = (address or ""):upper():gsub(" ","");
	if(address:len() >= 6 and address:len() <=9) then
		surface.PlaySound(self.Sounds.Info);
		-- Shall we add this address to the "already dialled" list?
		for k,v in pairs(self.Data.Addresses) do
			if(self:Find(v,address,true)) then
				self.Data.Addresses[k] = nil;
			end
		end
		local addresses = {address};
		-- Keep the last 15 dialled addresses in cache...
		for k,v in pairs(table.ClearKeys(self.Data.Addresses)) do
			if(k < 15) then table.insert(addresses,v) end;
		end
		self.Data.Address = address;
		self.Data.Addresses = addresses;
		-- Clear old choices first!
		self.VGUI.AddressMultiChoice.Choices = {};
		-- Now, add the choices!
		for _,v in pairs(self.Data.Addresses) do
			self.VGUI.AddressMultiChoice:AddChoice(v);
		end
		if(self.OnDial) then self.OnDial(self.Entity,address,self.VGUI.DialTypeCheckbox:GetChecked()) end;
	else
		surface.PlaySound(self.Sounds.Warning);
	end
end

--################# The necessary Entity, this panel comes along with (the gate) @aVoN
function PANEL:SetEntity(e)
	self.Entity = e;
	--##### Now also update the Text of the search field and the multichoice's diallied addresses
	self.VGUI.AddressMultiChoice.Choices = {};
	for _,v in pairs(self.Data.Addresses) do
		self.VGUI.AddressMultiChoice:AddChoice(v);
	end
	--##### Search text
	self.VGUI.SearchTextEntry:SetText(self.Data.LastSearchText or "");
	local caret_pos = math.Clamp(self.VGUI.AddressMultiChoice.TextEntry:GetCaretPos(),0,self.Data.Address:len());
	self.VGUI.AddressMultiChoice.TextEntry:SetText(self.Data.Address);
	self.VGUI.AddressMultiChoice.TextEntry:SetCaretPos(caret_pos);
	--##### The searchfield has been reset - Update the list
	self:RefreshList(true);
	-- "SetEntity" normally also means, we are getting "opened". So use this as an event and make the TextEntry focussed (for diallign a gate)
	self.VGUI.AddressMultiChoice.TextEntry:RequestFocus();
end

--################# Perform the layout @aVoN
function PANEL:PerformLayout()
	local w,h = self:GetSize();
	-- The Address List
	self.VGUI.AddressListView:SetSize(w,h-30);
	-- Fix a bug in the DListView: We will redraw it's Lines to fit to the altered size!
	self.VGUI.AddressListView:DataLayout();
	-- The Address Label
	self.VGUI.AddressLabel:SetPos(w-182,0);
	-- The Address TextEntry
	self.VGUI.AddressMultiChoice:SetPos(w-137,0);
	self.VGUI.DialTypeCheckbox:SetPos(w-55,3);
	-- The Dial Button
	self.VGUI.DialImageButton:SetPos(w-40,2);
	-- The Abort Button
	self.VGUI.AbortDialImageButton:SetPos(w-20,2);
end

include("custom_groups.lua");

--################# Get group/type name by AlexALX
function PANEL:GetGroupName(g)
	local name = Language.GetMessage("stargate_vgui_grpc")
	if (g == "M@") then
		name = Language.GetMessage("stargate_vgui_grp1");
	elseif (g == "P@") then
		name = Language.GetMessage("stargate_vgui_grp2");
	elseif (g == "I@") then
		name = Language.GetMessage("stargate_vgui_grp3");
	elseif (g == "OT") then
		name = Language.GetMessage("stargate_vgui_grp8");
	elseif (g == "O@") then
		name = Language.GetMessage("stargate_vgui_grp4");
	elseif (g == "U@#") then
		name = Language.GetMessage("stargate_vgui_grp5");
	elseif (g == "SGI") then
		name = Language.GetMessage("stargate_vgui_grp6");
	elseif (g == "DST") then
		name = Language.GetMessage("stargate_vgui_grp7");
	elseif (SG_CUSTOM_GROUPS and SG_CUSTOM_GROUPS[g]) then
		name = SG_CUSTOM_GROUPS[g][1];
	elseif (SG_CUSTOM_TYPES and SG_CUSTOM_TYPES[g]) then
		name = SG_CUSTOM_TYPES[g][1];
	elseif (g:len()==3) then
		name = Language.GetMessage("stargate_vgui_grpc2");
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
			if(address != "" and group != "" and IsValid(ent) and (not locale and not ent:GetLocale() or (ent:GetGateGroup() == group or v.class=="stargate_universe" and ent:GetClass()=="stargate_universe")) and (address!=ent:GetGateAddress() or group!=ent:GetGateGroup())) then
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
				if(not table.HasValue(gates,address) and (not s or (self:Find(address,s) or (name ~= "" and self:Find(name,s))))) then
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
	ApplyGlyphs(self);
	if(last_address) then
		for _,v in pairs(self.VGUI.AddressListView.Lines) do
			if(v:GetColumnText(1) == last_address) then
				v:SetSelected(true);
				break;
			end
		end
	end
	self.VGUI.AddressListView:SortByColumn(1,true); -- Resort by addresses
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
		local letters = n:gsub("[^0-9A-Z@#]",""):TrimExplode(""); -- Removes illegal chars, because "letters" is only used for addresses in here
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
		if (v.groupgate) then
			table.insert(gates,v);
		end
	end
	return gates;
end

--################# Think @aVoN
function PANEL:Think()
	-- Do the search, but delayed
	if(self.Data.LastSearchTyped and CurTime() - self.Data.LastSearchTyped > 0.5) then
		--self.Gates = self:GetGates(); -- First, refresh stargates!
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

vgui.Register("SAddressSelect_Group",PANEL,"Panel");


--################# Shows how this thing has to be used @aVoN
function PANEL:GenerateExample()
	local VGUI = vgui.Create("SAddressSelect_Group");
	VGUI:SetSize(180,80);
	VGUI:SetEntity(NULL); -- This defines the stargate this Address Panel is allocated to (Necessary, so we know, what gate we are currently using)
	VGUI.OnDial = function(gate,address,fast_dhd_mode) end; -- The function which shall be triggered when the user dials a gate
	VGUI.OnAbort = function(gate) end; -- The function to call, if you want to abort dialling/close a gate
	return VGUI;
end

--##################################
--###### SAddressSelect_NoGroup.lua
--##################################

local PANEL = {};

PANEL.Sounds = {
	Info = Sound("buttons/button9.wav"),
	Click = Sound("npc/turret_floor/click1.wav"),
	Warning = Sound("buttons/button2.wav"),
}
PANEL.Data = {
	Addresses = {}, -- Last Dialled Addresses
	Address = "", -- Last Address in the multichoice
	LastSearchText = "", -- The last search text a person entered
}

--################# Init @aVoN
function PANEL:Init()
	self:SetSize(400,100);
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
	self.Entity = NULL;
	self:SetCookieName("StarGate.SAddressSelect"); -- Just for the checkbox to save the value (it always annoyed me, it losses it after a restart)
	--####### Apply Sizes: Search Fields
	-- The Address List
	self.VGUI.AddressListView:SetPos(0,25);
	self.VGUI.AddressListView:AddColumn(Language.GetMessage("stargate_vgui_glyphs")):SetFixedWidth(128);
	self.VGUI.AddressListView:AddColumn(Language.GetMessage("stargate_vgui_address2")):SetFixedWidth(60);
	self.VGUI.Width = 60;
	self.VGUI.AddressListView:AddColumn(Language.GetMessage("stargate_vgui_grouptype")):SetFixedWidth(100);
	self.VGUI.AddressListView:AddColumn(Language.GetMessage("stargate_vgui_name2"));
	self.VGUI.AddressListView:SortByColumn(1,true);
	self.VGUI.AddressListView.OnRowSelected = function(ListView,Row)
		local selected = ListView:GetSelectedLine();
		if (ListView:GetLine(selected).Blocked) then ListView:GetLine(selected):SetSelected(false); self.LastSelected = 0; return end
		local address = ListView:GetLine(selected):GetColumnText(2):upper():gsub(" ","");
		self.VGUI.AddressMultiChoice.TextEntry:SetText(address);
		self.Data.Address = address;
		-- Avoids confusing soundspam on double click
		if(selected ~= self.LastSelected) then
			self.LastSelected = selected;
			surface.PlaySound(self.Sounds.Click);
		end
	end
	self.VGUI.AddressListView.DoDoubleClick = function(ListView,id,List)
		if (not List.Blocked) then
			self:DialGate(List:GetColumnText(2));
		end
	end

	local w = 40
	if (Language.ValidMessage("stargate_vgui_search_width")) then w = Language.GetMessage("stargate_vgui_search_width") end

	-- The Search Label
	self.VGUI.SearchLabel:SetPos(0,0);
	self.VGUI.SearchLabel:SetSize(w,self.VGUI.SearchLabel:GetTall());
	self.VGUI.SearchLabel:SetText(Language.GetMessage("stargate_vgui_search"));

	-- The Search Field
	self.VGUI.SearchTextEntry:SetPos(w,0);
	self.VGUI.SearchTextEntry:SetSize(140,self.VGUI.SearchTextEntry:GetTall());
	self.VGUI.SearchTextEntry:SetTooltip(Language.GetMessage("stargate_vgui_srchtip"));
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
	self.VGUI.SearchImageButton:SetImage(Panel_Images.Search);
	self.VGUI.SearchImageButton:SetTooltip(Language.GetMessage("stargate_vgui_search2"));
	self.VGUI.SearchImageButton.DoClick = function(ImageButton)
		-- Immediately do a search (Maybe a stargate has recently changed it's addresse or name?)
		self:RefreshList();
	end

	-- The Refresh Button (Refreshs the list of stargates we have) - Similar to a search, but it will find just recently added stargates
	self.VGUI.RefreshImageButton:SetPos(w+161,2);
	self.VGUI.RefreshImageButton:SetSize(16,16);
	self.VGUI.RefreshImageButton:SetImage(Panel_Images.Refresh);
	self.VGUI.RefreshImageButton:SetTooltip(Language.GetMessage("stargate_vgui_refresh"));
	self.VGUI.RefreshImageButton.DoClick = function(ImageButton)
		-- Immediately do a search (Maybe a stargate has recently changed it's addresse or name?)
		self:RefreshList(true);
	end

	--####### Apply Sizes: Address/Dial Fields - Positions set in PerformLayout
	-- The Address Label
	self.VGUI.AddressLabel:SetText(Language.GetMessage("stargate_vgui_address"));

	-- The Address TextEntry
	-- DMultiChoice instead of TextEntry and make it save the recent gate addresses being dialled!
	self.VGUI.AddressMultiChoice:SetSize(70,self.VGUI.AddressMultiChoice:GetTall());
	self.VGUI.AddressMultiChoice.TextEntry:SetTooltip(Language.GetMessage("stargate_vgui_dialadr2"));
	-- This function restricts the letters you can enter to a valid address
	self.VGUI.AddressMultiChoice.TextEntry.OnTextChanged = function(TextEntry)
		local text = TextEntry:GetValue();
		if(text ~= self.Data.Address) then
			local pos = TextEntry:GetCaretPos();
			local len = text:len();
			local letters = text:upper():gsub("[^0-9A-Z@]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
			local text = ""; -- Wipe
			for _,v in pairs(letters) do
				if(not text:find(v)) then
					text = text..v;
				end
			end
			text = text:sub(1,6);
			TextEntry:SetText(text);
			TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
			if(self.Data.Address ~= text and self.OnTextChanged) then
				self.OnTextChanged(TextEntry);
			end
			self.Data.Address = text;
		end
	end

	-- Add choices (Last 15 dialled addresses)
	for _,v in pairs(self.Data.Addresses) do
		self.VGUI.AddressMultiChoice:AddChoice(v);
	end

	-- The DHD/SGC Dialmode Checkbox
	self.VGUI.DialTypeCheckbox:SetToolTip(Language.GetMessage("stargate_vgui_dialtip"));
	self.VGUI.DialTypeCheckbox:SetValue(self:GetCookie("DHDDial",false));
	self.VGUI.DialTypeCheckbox.ConVarChanged = function(CheckBox)
		self:SetCookie("DHDDial",CheckBox:GetChecked());
	end

	-- The Dial Button
	self.VGUI.DialImageButton:SetSize(16,16);
	self.VGUI.DialImageButton:SetImage(Panel_Images.Dial);
	self.VGUI.DialImageButton:SetToolTip(Language.GetMessage("stargate_vgui_dialgt"));
	self.VGUI.DialImageButton.DoClick = function(ImageButton)
		self:DialGate(self.VGUI.AddressMultiChoice.TextEntry:GetValue());
	end

	-- The AbortDial Button
	self.VGUI.AbortDialImageButton:SetSize(16,16);
	self.VGUI.AbortDialImageButton:SetImage(Panel_Images.Abort);
	self.VGUI.AbortDialImageButton:SetToolTip(Language.GetMessage("stargate_vgui_dialab"));
	self.VGUI.AbortDialImageButton.DoClick = function(ImageButton)
		if(self.OnAbort) then self.OnAbort(self.Entity) end;
	end

	-- Add the gates to the list
	self.Gates = self:GetGates();
	self:AddGatesToList(self.Data.LastSearchText);
	PANEL_RegisterHooks(self)
end

--################# Sets the Address, entered in the dialbox @aVoN
function PANEL:SetText(text)
	self.VGUI.AddressMultiChoice.TextEntry:SetText(text or "");
end

--################# Gets the value of the addressfield @aVoN
function PANEL:GetValue()
	return self.VGUI.AddressMultiChoice.TextEntry:GetValue() or "";
end

--################# Adds the address we selected to the "LastDialled" list and plays a sound. Also calls the Dial function @aVoN
function PANEL:DialGate(address)
	address = (address or ""):upper():gsub(" ","");
	if(address:len() == 6) then
		surface.PlaySound(self.Sounds.Info);
		-- Shall we add this address to the "already dialled" list?
		for k,v in pairs(self.Data.Addresses) do
			if(self:Find(v,address,true)) then
				self.Data.Addresses[k] = nil;
			end
		end
		local addresses = {address};
		-- Keep the last 15 dialled addresses in cache...
		for k,v in pairs(table.ClearKeys(self.Data.Addresses)) do
			if(k < 15) then table.insert(addresses,v) end;
		end
		self.Data.Address = address;
		self.Data.Addresses = addresses;
		-- Clear old choices first!
		self.VGUI.AddressMultiChoice.Choices = {};
		-- Now, add the choices!
		for _,v in pairs(self.Data.Addresses) do
			self.VGUI.AddressMultiChoice:AddChoice(v);
		end
		if(self.OnDial) then self.OnDial(self.Entity,address,self.VGUI.DialTypeCheckbox:GetChecked()) end;
	else
		surface.PlaySound(self.Sounds.Warning);
	end
end

--################# The necessary Entity, this panel comes along with (the gate) @aVoN
function PANEL:SetEntity(e)
	self.Entity = e;
	--##### Now also update the Text of the search field and the multichoice's diallied addresses
	self.VGUI.AddressMultiChoice.Choices = {};
	for _,v in pairs(self.Data.Addresses) do
		self.VGUI.AddressMultiChoice:AddChoice(v);
	end
	--##### Search text
	self.VGUI.SearchTextEntry:SetText(self.Data.LastSearchText or "");
	local caret_pos = math.Clamp(self.VGUI.AddressMultiChoice.TextEntry:GetCaretPos(),0,self.Data.Address:len());
	self.VGUI.AddressMultiChoice.TextEntry:SetText(self.Data.Address);
	self.VGUI.AddressMultiChoice.TextEntry:SetCaretPos(caret_pos);
	--##### The searchfield has been reset - Update the list
	self:RefreshList(true);
	-- "SetEntity" normally also means, we are getting "opened". So use this as an event and make the TextEntry focussed (for diallign a gate)
	self.VGUI.AddressMultiChoice.TextEntry:RequestFocus();
end

--################# Perform the layout @aVoN
function PANEL:PerformLayout()
	local w,h = self:GetSize();
	-- The Address List
	self.VGUI.AddressListView:SetSize(w,h-30);
	-- Fix a bug in the DListView: We will redraw it's Lines to fit to the altered size!
	self.VGUI.AddressListView:DataLayout();
	-- The Address Label
	self.VGUI.AddressLabel:SetPos(w-172,0);
	-- The Address TextEntry
	self.VGUI.AddressMultiChoice:SetPos(w-127,0);
	self.VGUI.DialTypeCheckbox:SetPos(w-55,3);
	-- The Dial Button
	self.VGUI.DialImageButton:SetPos(w-40,2);
	-- The Abort Button
	self.VGUI.AbortDialImageButton:SetPos(w-20,2);
end

--################# Get group/type name by AlexALX
function PANEL:GetGroupName(g)
	local name = Language.GetMessage("stargate_vgui_grpc")
	if (g == "M@") then
		name = Language.GetMessage("stargate_vgui_grp1");
	elseif (g == "P@") then
		name = Language.GetMessage("stargate_vgui_grp2");
	elseif (g == "I@") then
		name = Language.GetMessage("stargate_vgui_grp3");
	elseif (g == "OT") then
		name = Language.GetMessage("stargate_vgui_grp8");
	elseif (g == "O@") then
		name = Language.GetMessage("stargate_vgui_grp4");
	elseif (g == "U@#") then
		name = Language.GetMessage("stargate_vgui_grp5");
	elseif (g == "SGI") then
		name = Language.GetMessage("stargate_vgui_grp6");
	elseif (g == "DST") then
		name = Language.GetMessage("stargate_vgui_grp7");
	elseif (SG_CUSTOM_GROUPS and SG_CUSTOM_GROUPS[g]) then
		name = SG_CUSTOM_GROUPS[g][1];
	elseif (SG_CUSTOM_TYPES and SG_CUSTOM_TYPES[g]) then
		name = SG_CUSTOM_TYPES[g][1];
	elseif (g:len()==3) then
		name = Language.GetMessage("stargate_vgui_grpc2");
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
	local gates = {}
	for k,v in pairs(self.Gates) do
		-- Never add the gate we are dialling from to this panel
		if(tonumber(v.ent) ~= self.Entity:EntIndex() and not v.private) then
			local address = v.address;
			local group = v.group;
			local ent = self.Entity;
			if (self.Entity.IsStargate == true) then
				ent = self.Entity;
			elseif (self.Entity.IsDHD == true) then
				ent = self.Entity:GetParent();
			end
			if(address != "" and group != "" and IsValid(ent) and (address!=ent:GetGateAddress() or group!=ent:GetGateGroup())) then
				local range = (ent:GetPos() - v.pos):Length();
				local c_range = ent:GetNetworkedInt("SGU_FIND_RANDE"); -- GetConVar("stargate_sgu_find_range"):GetInt();
				if ((ent:GetGateGroup() == group or v.class=="stargate_universe" and ent:GetClass()=="stargate_universe") and (range<=c_range and ent:GetGateGroup():len()==3 or ent:GetGateGroup():len()==2 or c_range == 0 and ent:GetGateGroup():len()==3)) then
					local name = v.name;
					if(not table.HasValue(gates,address) and (not s or (self:Find(address,s) or (name ~= "" and self:Find(name,s))))) then
						if(name == "") then name = "N/A" end;
						local address2 = string.sub(address:gsub("#","").."#",1,9);
						local blocked, energy = "false", "true";
						if (v.blocked) then blocked = "true"; end
						if (not ent:CheckEnergy(v,address2:len())) then energy = "false"; end
						self.VGUI.AddressListView:AddLine(address2,address,self:GetGroupName(group),name,blocked,energy);
						table.insert(gates,address);
					end
				end
			end
		end
	end
	ApplyGlyphs(self, false, true);
	if(last_address) then
		for _,v in pairs(self.VGUI.AddressListView.Lines) do
			if(v:GetColumnText(1) == last_address) then
				v:SetSelected(true);
				break;
			end
		end
	end
	self.VGUI.AddressListView:SortByColumn(1,true); -- Resort by addresses
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
		local letters = n:gsub("[^0-9A-Z]",""):TrimExplode(""); -- Removes illegal chars, because "letters" is only used for addresses in here
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
		if (v.groupgate) then
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

vgui.Register("SAddressSelect_NoGroup",PANEL,"Panel");


--################# Shows how this thing has to be used @aVoN
function PANEL:GenerateExample()
	local VGUI = vgui.Create("SAddressSelect_NoGroup");
	VGUI:SetSize(180,80);
	VGUI:SetEntity(NULL); -- This defines the stargate this Address Panel is allocated to (Necessary, so we know, what gate we are currently using)
	VGUI.OnDial = function(gate,address,fast_dhd_mode) end; -- The function which shall be triggered when the user dials a gate
	VGUI.OnAbort = function(gate) end; -- The function to call, if you want to abort dialling/close a gate
	return VGUI;
end

--##################################
--###### SAddressSelect_Galaxy.lua
--##################################

local PANEL = {};

PANEL.Sounds = {
	Info = Sound("buttons/button9.wav"),
	Click = Sound("npc/turret_floor/click1.wav"),
	Warning = Sound("buttons/button2.wav"),
}
PANEL.Data = {
	Addresses = {}, -- Last Dialled Addresses
	Address = "", -- Last Address in the multichoice
	LastSearchText = "", -- The last search text a person entered
}

--################# Init @aVoN
function PANEL:Init()
	self:SetSize(400,100);
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
	self.Entity = NULL;
	self:SetCookieName("StarGate.SAddressSelect"); -- Just for the checkbox to save the value (it always annoyed me, it losses it after a restart)
	--####### Apply Sizes: Search Fields
	-- The Address List
	self.VGUI.AddressListView:SetPos(0,25);
	self.VGUI.AddressListView:AddColumn(Language.GetMessage("stargate_vgui_glyphs")):SetFixedWidth(150);
	self.VGUI.AddressListView:AddColumn(Language.GetMessage("stargate_vgui_address2")):SetFixedWidth(80);
	self.VGUI.Width = 80;
	self.VGUI.AddressListView:AddColumn(Language.GetMessage("stargate_vgui_name2"));
	self.VGUI.AddressListView:SortByColumn(1,true);
	self.VGUI.AddressListView.OnRowSelected = function(ListView,Row)
		local selected = ListView:GetSelectedLine();
		if (ListView:GetLine(selected).Blocked) then ListView:GetLine(selected):SetSelected(false); self.LastSelected = 0; return end
		local address = ListView:GetLine(selected):GetColumnText(2):upper():gsub(" ","");
		self.VGUI.AddressMultiChoice.TextEntry:SetText(address);
		self.Data.Address = address;
		-- Avoids confusing soundspam on double click
		if(selected ~= self.LastSelected) then
			self.LastSelected = selected;
			surface.PlaySound(self.Sounds.Click);
		end
	end
	self.VGUI.AddressListView.DoDoubleClick = function(ListView,id,List)
		if (not List.Blocked) then
			self:DialGate(List:GetColumnText(2));
		end
	end

	local w = 40
	if (Language.ValidMessage("stargate_vgui_search_width")) then w = Language.GetMessage("stargate_vgui_search_width") end

	-- The Search Label
	self.VGUI.SearchLabel:SetPos(0,0);
	self.VGUI.SearchLabel:SetSize(w,self.VGUI.SearchLabel:GetTall());
	self.VGUI.SearchLabel:SetText(Language.GetMessage("stargate_vgui_search"));

	-- The Search Field
	self.VGUI.SearchTextEntry:SetPos(w,0);
	self.VGUI.SearchTextEntry:SetSize(140,self.VGUI.SearchTextEntry:GetTall());
	self.VGUI.SearchTextEntry:SetTooltip(Language.GetMessage("stargate_vgui_srchtip"));
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
	self.VGUI.SearchImageButton:SetImage(Panel_Images.Search);
	self.VGUI.SearchImageButton:SetTooltip(Language.GetMessage("stargate_vgui_search2"));
	self.VGUI.SearchImageButton.DoClick = function(ImageButton)
		-- Immediately do a search (Maybe a stargate has recently changed it's addresse or name?)
		self:RefreshList();
	end

	-- The Refresh Button (Refreshs the list of stargates we have) - Similar to a search, but it will find just recently added stargates
	self.VGUI.RefreshImageButton:SetPos(w+161,2);
	self.VGUI.RefreshImageButton:SetSize(16,16);
	self.VGUI.RefreshImageButton:SetImage(Panel_Images.Refresh);
	self.VGUI.RefreshImageButton:SetTooltip(Language.GetMessage("stargate_vgui_refresh"));
	self.VGUI.RefreshImageButton.DoClick = function(ImageButton)
		-- Immediately do a search (Maybe a stargate has recently changed it's addresse or name?)
		self:RefreshList(true);
	end

	--####### Apply Sizes: Address/Dial Fields - Positions set in PerformLayout
	-- The Address Label
	self.VGUI.AddressLabel:SetText(Language.GetMessage("stargate_vgui_address"));

	-- The Address TextEntry
	-- DMultiChoice instead of TextEntry and make it save the recent gate addresses being dialled!
	self.VGUI.AddressMultiChoice:SetSize(70,self.VGUI.AddressMultiChoice:GetTall());
	self.VGUI.AddressMultiChoice.TextEntry:SetTooltip(Language.GetMessage("stargate_galaxy_vgui_dialadr"));
	-- This function restricts the letters you can enter to a valid address
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
			--
			TextEntry:SetText(text);
			TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
			if(self.Data.Address ~= text and self.OnTextChanged) then
				self.OnTextChanged(TextEntry);
			end
			self.Data.Address = text;
		end
	end

	-- Add choices (Last 15 dialled addresses)
	for _,v in pairs(self.Data.Addresses) do
		self.VGUI.AddressMultiChoice:AddChoice(v);
	end

	-- The DHD/SGC Dialmode Checkbox
	self.VGUI.DialTypeCheckbox:SetToolTip(Language.GetMessage("stargate_vgui_dialtip"));
	self.VGUI.DialTypeCheckbox:SetValue(self:GetCookie("DHDDial",false));
	self.VGUI.DialTypeCheckbox.ConVarChanged = function(CheckBox)
		self:SetCookie("DHDDial",CheckBox:GetChecked());
	end

	-- The Dial Button
	self.VGUI.DialImageButton:SetSize(16,16);
	self.VGUI.DialImageButton:SetImage(Panel_Images.Dial);
	self.VGUI.DialImageButton:SetToolTip(Language.GetMessage("stargate_vgui_dialgt"));
	self.VGUI.DialImageButton.DoClick = function(ImageButton)
		self:DialGate(self.VGUI.AddressMultiChoice.TextEntry:GetValue());
	end

	-- The AbortDial Button
	self.VGUI.AbortDialImageButton:SetSize(16,16);
	self.VGUI.AbortDialImageButton:SetImage(Panel_Images.Abort);
	self.VGUI.AbortDialImageButton:SetToolTip(Language.GetMessage("stargate_vgui_dialab"));
	self.VGUI.AbortDialImageButton.DoClick = function(ImageButton)
		if(self.OnAbort) then self.OnAbort(self.Entity) end;
	end

	-- Add the gates to the list
	self.Gates = self:GetGates();
	self:AddGatesToList(self.Data.LastSearchText);
	PANEL_RegisterHooks(self)
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

--################# Sets the Address, entered in the dialbox @aVoN
function PANEL:SetText(text)
	self.VGUI.AddressMultiChoice.TextEntry:SetText(text or "");
end

--################# Gets the value of the addressfield @aVoN
function PANEL:GetValue()
	return self.VGUI.AddressMultiChoice.TextEntry:GetValue() or "";
end

--################# Adds the address we selected to the "LastDialled" list and plays a sound. Also calls the Dial function @aVoN
function PANEL:DialGate(address)
	address = (address or ""):upper():gsub(" ","");
	if(address:len() >= 6) then
		surface.PlaySound(self.Sounds.Info);
		-- Shall we add this address to the "already dialled" list?
		for k,v in pairs(self.Data.Addresses) do
			if(self:Find(v,address,true)) then
				self.Data.Addresses[k] = nil;
			end
		end
		local addresses = {address};
		-- Keep the last 15 dialled addresses in cache...
		for k,v in pairs(table.ClearKeys(self.Data.Addresses)) do
			if(k < 15) then table.insert(addresses,v) end;
		end
		self.Data.Address = address;
		self.Data.Addresses = addresses;
		-- Clear old choices first!
		self.VGUI.AddressMultiChoice.Choices = {};
		-- Now, add the choices!
		for _,v in pairs(self.Data.Addresses) do
			self.VGUI.AddressMultiChoice:AddChoice(v);
		end
		if(self.OnDial) then self.OnDial(self.Entity,address,self.VGUI.DialTypeCheckbox:GetChecked()) end;
	else
		surface.PlaySound(self.Sounds.Warning);
	end
end

--################# The necessary Entity, this panel comes along with (the gate) @aVoN
function PANEL:SetEntity(e)
	self.Entity = e;
	--##### Now also update the Text of the search field and the multichoice's diallied addresses
	self.VGUI.AddressMultiChoice.Choices = {};
	for _,v in pairs(self.Data.Addresses) do
		self.VGUI.AddressMultiChoice:AddChoice(v);
	end
	--##### Search text
	self.VGUI.SearchTextEntry:SetText(self.Data.LastSearchText or "");
	local caret_pos = math.Clamp(self.VGUI.AddressMultiChoice.TextEntry:GetCaretPos(),0,self.Data.Address:len());
	self.VGUI.AddressMultiChoice.TextEntry:SetText(self.Data.Address);
	self.VGUI.AddressMultiChoice.TextEntry:SetCaretPos(caret_pos);
	--##### The searchfield has been reset - Update the list
	self:RefreshList(true);
	-- "SetEntity" normally also means, we are getting "opened". So use this as an event and make the TextEntry focussed (for diallign a gate)
	self.VGUI.AddressMultiChoice.TextEntry:RequestFocus();
end

--################# Perform the layout @aVoN
function PANEL:PerformLayout()
	local w,h = self:GetSize();
	-- The Address List
	self.VGUI.AddressListView:SetSize(w,h-15);
	-- Fix a bug in the DListView: We will redraw it's Lines to fit to the altered size!
	self.VGUI.AddressListView:DataLayout();
	-- The Address Label
	self.VGUI.AddressLabel:SetPos(w-172,0);
	-- The Address TextEntry
	self.VGUI.AddressMultiChoice:SetPos(w-127,0);
	self.VGUI.DialTypeCheckbox:SetPos(w-55,3);
	-- The Dial Button
	self.VGUI.DialImageButton:SetPos(w-40,2);
	-- The Abort Button
	self.VGUI.AbortDialImageButton:SetPos(w-20,2);
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
	local g = self.Entity;
	-- Clear old view
	self.VGUI.AddressListView:Clear();
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
					local blocked, energy = "false", "true";
					if (IsValid(g) and v.blocked) then blocked = "true"; end
					if (not ent:CheckEnergy(v,address2:len())) then energy = "false"; end
					self.VGUI.AddressListView:AddLine(address2,address,name,blocked,energy);
				end
			end
		end
	end
	ApplyGlyphs(self, true);
	if(last_address) then
		for _,v in pairs(self.VGUI.AddressListView.Lines) do
			if(v:GetColumnText(1) == last_address) then
				v:SetSelected(true);
				break;
			end
		end
	end
	self.VGUI.AddressListView:SortByColumn(1,true); -- Resort by addresses
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
		local letters = n:gsub("[^1-9A-Z@!]",""):TrimExplode(""); -- Removes illegal chars, because "letters" is only used for addresses in here
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
		if (v.groupgate) then
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

vgui.Register("SAddressSelect_Galaxy",PANEL,"Panel");


--################# Shows how this thing has to be used @aVoN
function PANEL:GenerateExample()
	local VGUI = vgui.Create("SAddressSelect_Galaxy");
	VGUI:SetSize(180,80);
	VGUI:SetEntity(NULL); -- This defines the stargate this Address Panel is allocated to (Necessary, so we know, what gate we are currently using)
	VGUI.OnDial = function(gate,address,fast_dhd_mode) end; -- The function which shall be triggered when the user dials a gate
	VGUI.OnAbort = function(gate) end; -- The function to call, if you want to abort dialling/close a gate
	return VGUI;
end

--##################################
--###### SAddressSelect_NoGalaxy.lua
--##################################

local PANEL = {};

PANEL.Sounds = {
	Info = Sound("buttons/button9.wav"),
	Click = Sound("npc/turret_floor/click1.wav"),
	Warning = Sound("buttons/button2.wav"),
}
PANEL.Data = {
	Addresses = {}, -- Last Dialled Addresses
	Address = "", -- Last Address in the multichoice
	LastSearchText = "", -- The last search text a person entered
}

--################# Init @aVoN
function PANEL:Init()
	self:SetSize(400,100);
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
	self.Entity = NULL;
	self:SetCookieName("StarGate.SAddressSelect"); -- Just for the checkbox to save the value (it always annoyed me, it losses it after a restart)
	--####### Apply Sizes: Search Fields
	-- The Address List
	self.VGUI.AddressListView:SetPos(0,25);
	self.VGUI.AddressListView:AddColumn(Language.GetMessage("stargate_vgui_glyphs")):SetFixedWidth(128);
	self.VGUI.AddressListView:AddColumn(Language.GetMessage("stargate_vgui_address2")):SetFixedWidth(80);
	self.VGUI.Width = 80;
	self.VGUI.AddressListView:AddColumn(Language.GetMessage("stargate_vgui_name2"));
	self.VGUI.AddressListView:SortByColumn(1,true);
	self.VGUI.AddressListView.OnRowSelected = function(ListView,Row)
		local selected = ListView:GetSelectedLine();
		if (ListView:GetLine(selected).Blocked) then ListView:GetLine(selected):SetSelected(false); self.LastSelected = 0; return end
		local address = ListView:GetLine(selected):GetColumnText(2):upper():gsub(" ","");
		self.VGUI.AddressMultiChoice.TextEntry:SetText(address);
		self.Data.Address = address;
		-- Avoids confusing soundspam on double click
		if(selected ~= self.LastSelected) then
			self.LastSelected = selected;
			surface.PlaySound(self.Sounds.Click);
		end
	end
	self.VGUI.AddressListView.DoDoubleClick = function(ListView,id,List)
		if (not List.Blocked) then
			self:DialGate(List:GetColumnText(2));
		end
	end

	local w = 40
	if (Language.ValidMessage("stargate_vgui_search_width")) then w = Language.GetMessage("stargate_vgui_search_width") end

	-- The Search Label
	self.VGUI.SearchLabel:SetPos(0,0);
	self.VGUI.SearchLabel:SetSize(w,self.VGUI.SearchLabel:GetTall());
	self.VGUI.SearchLabel:SetText(Language.GetMessage("stargate_vgui_search"));

	-- The Search Field
	self.VGUI.SearchTextEntry:SetPos(w,0);
	self.VGUI.SearchTextEntry:SetSize(140,self.VGUI.SearchTextEntry:GetTall());
	self.VGUI.SearchTextEntry:SetTooltip(Language.GetMessage("stargate_vgui_srchtip"));
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
	self.VGUI.SearchImageButton:SetImage(Panel_Images.Search);
	self.VGUI.SearchImageButton:SetTooltip(Language.GetMessage("stargate_vgui_search2"));
	self.VGUI.SearchImageButton.DoClick = function(ImageButton)
		-- Immediately do a search (Maybe a stargate has recently changed it's addresse or name?)
		self:RefreshList();
	end

	-- The Refresh Button (Refreshs the list of stargates we have) - Similar to a search, but it will find just recently added stargates
	self.VGUI.RefreshImageButton:SetPos(w+161,2);
	self.VGUI.RefreshImageButton:SetSize(16,16);
	self.VGUI.RefreshImageButton:SetImage(Panel_Images.Refresh);
	self.VGUI.RefreshImageButton:SetTooltip(Language.GetMessage("stargate_vgui_refresh"));
	self.VGUI.RefreshImageButton.DoClick = function(ImageButton)
		-- Immediately do a search (Maybe a stargate has recently changed it's addresse or name?)
		self:RefreshList(true);
	end

	--####### Apply Sizes: Address/Dial Fields - Positions set in PerformLayout
	-- The Address Label
	self.VGUI.AddressLabel:SetText(Language.GetMessage("stargate_vgui_address"));

	-- The Address TextEntry
	-- DMultiChoice instead of TextEntry and make it save the recent gate addresses being dialled!
	self.VGUI.AddressMultiChoice:SetSize(70,self.VGUI.AddressMultiChoice:GetTall());
	self.VGUI.AddressMultiChoice.TextEntry:SetTooltip(Language.GetMessage("stargate_galaxy_vgui_dialadr2"));
	-- This function restricts the letters you can enter to a valid address
	self.VGUI.AddressMultiChoice.TextEntry.OnTextChanged = function(TextEntry)
		local text = TextEntry:GetValue();
		if(text ~= self.Data.Address) then
			local pos = TextEntry:GetCaretPos();
			local len = text:len();
			local letters = text:upper():gsub("[^1-9A-Z]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
			local text = ""; -- Wipe
			for _,v in pairs(letters) do
				if(not text:find(v)) then
					text = text..v;
				end
			end
			text = text:sub(1,6);
			--
			TextEntry:SetText(text);
			TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
			if(self.Data.Address ~= text and self.OnTextChanged) then
				self.OnTextChanged(TextEntry);
			end
			self.Data.Address = text;
		end
	end

	-- Add choices (Last 15 dialled addresses)
	for _,v in pairs(self.Data.Addresses) do
		self.VGUI.AddressMultiChoice:AddChoice(v);
	end

	-- The DHD/SGC Dialmode Checkbox
	self.VGUI.DialTypeCheckbox:SetToolTip(Language.GetMessage("stargate_vgui_dialtip"));
	self.VGUI.DialTypeCheckbox:SetValue(self:GetCookie("DHDDial",false));
	self.VGUI.DialTypeCheckbox.ConVarChanged = function(CheckBox)
		self:SetCookie("DHDDial",CheckBox:GetChecked());
	end

	-- The Dial Button
	self.VGUI.DialImageButton:SetSize(16,16);
	self.VGUI.DialImageButton:SetImage(Panel_Images.Dial);
	self.VGUI.DialImageButton:SetToolTip(Language.GetMessage("stargate_vgui_dialgt"));
	self.VGUI.DialImageButton.DoClick = function(ImageButton)
		self:DialGate(self.VGUI.AddressMultiChoice.TextEntry:GetValue());
	end

	-- The AbortDial Button
	self.VGUI.AbortDialImageButton:SetSize(16,16);
	self.VGUI.AbortDialImageButton:SetImage(Panel_Images.Abort);
	self.VGUI.AbortDialImageButton:SetToolTip(Language.GetMessage("stargate_vgui_dialab"));
	self.VGUI.AbortDialImageButton.DoClick = function(ImageButton)
		if(self.OnAbort) then self.OnAbort(self.Entity) end;
	end

	-- Add the gates to the list
	self.Gates = self:GetGates();
	self:AddGatesToList(self.Data.LastSearchText);
	PANEL_RegisterHooks(self)
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

--################# Sets the Address, entered in the dialbox @aVoN
function PANEL:SetText(text)
	self.VGUI.AddressMultiChoice.TextEntry:SetText(text or "");
end

--################# Gets the value of the addressfield @aVoN
function PANEL:GetValue()
	return self.VGUI.AddressMultiChoice.TextEntry:GetValue() or "";
end

--################# Adds the address we selected to the "LastDialled" list and plays a sound. Also calls the Dial function @aVoN
function PANEL:DialGate(address)
	address = (address or ""):upper():gsub(" ","");
	if(address:len() >= 6) then
		surface.PlaySound(self.Sounds.Info);
		-- Shall we add this address to the "already dialled" list?
		for k,v in pairs(self.Data.Addresses) do
			if(self:Find(v,address,true)) then
				self.Data.Addresses[k] = nil;
			end
		end
		local addresses = {address};
		-- Keep the last 15 dialled addresses in cache...
		for k,v in pairs(table.ClearKeys(self.Data.Addresses)) do
			if(k < 15) then table.insert(addresses,v) end;
		end
		self.Data.Address = address;
		self.Data.Addresses = addresses;
		-- Clear old choices first!
		self.VGUI.AddressMultiChoice.Choices = {};
		-- Now, add the choices!
		for _,v in pairs(self.Data.Addresses) do
			self.VGUI.AddressMultiChoice:AddChoice(v);
		end
		if(self.OnDial) then self.OnDial(self.Entity,address,self.VGUI.DialTypeCheckbox:GetChecked()) end;
	else
		surface.PlaySound(self.Sounds.Warning);
	end
end

--################# The necessary Entity, this panel comes along with (the gate) @aVoN
function PANEL:SetEntity(e)
	self.Entity = e;
	--##### Now also update the Text of the search field and the multichoice's diallied addresses
	self.VGUI.AddressMultiChoice.Choices = {};
	for _,v in pairs(self.Data.Addresses) do
		self.VGUI.AddressMultiChoice:AddChoice(v);
	end
	--##### Search text
	self.VGUI.SearchTextEntry:SetText(self.Data.LastSearchText or "");
	local caret_pos = math.Clamp(self.VGUI.AddressMultiChoice.TextEntry:GetCaretPos(),0,self.Data.Address:len());
	self.VGUI.AddressMultiChoice.TextEntry:SetText(self.Data.Address);
	self.VGUI.AddressMultiChoice.TextEntry:SetCaretPos(caret_pos);
	--##### The searchfield has been reset - Update the list
	self:RefreshList(true);
	-- "SetEntity" normally also means, we are getting "opened". So use this as an event and make the TextEntry focussed (for diallign a gate)
	self.VGUI.AddressMultiChoice.TextEntry:RequestFocus();
end

--################# Perform the layout @aVoN
function PANEL:PerformLayout()
	local w,h = self:GetSize();
	-- The Address List
	self.VGUI.AddressListView:SetSize(w,h-15);
	-- Fix a bug in the DListView: We will redraw it's Lines to fit to the altered size!
	self.VGUI.AddressListView:DataLayout();
	-- The Address Label
	self.VGUI.AddressLabel:SetPos(w-172,0);
	-- The Address TextEntry
	self.VGUI.AddressMultiChoice:SetPos(w-127,0);
	self.VGUI.DialTypeCheckbox:SetPos(w-55,3);
	-- The Dial Button
	self.VGUI.DialImageButton:SetPos(w-40,2);
	-- The Abort Button
	self.VGUI.AbortDialImageButton:SetPos(w-20,2);
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
	local g = self.Entity;
	-- Clear old view
	self.VGUI.AddressListView:Clear();
	for k,v in pairs(self.Gates) do
		-- Never add the gate we are dialling from to this panel
		if(tonumber(v.ent) ~= self.Entity:EntIndex() and not v.private) then
		    local address = v.address;
			if(address ~= "") then
				if(IsValid(g))then
					local range = (g:GetPos() - v.pos):Length();
					local c_range = g:GetNetworkedInt("SGU_FIND_RANDE");
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
					if (address:len()==6) then
						local blocked, energy = "false", "true";
						if (IsValid(g) and v.blocked) then blocked = "true"; end
						if (not ent:CheckEnergy(v,address2:len())) then energy = "false"; end
						self.VGUI.AddressListView:AddLine(address2,address,name,blocked,energy);
					end
				end
			end
		end
	end
	ApplyGlyphs(self, true, true);
	if(last_address) then
		for _,v in pairs(self.VGUI.AddressListView.Lines) do
			if(v:GetColumnText(1) == last_address) then
				v:SetSelected(true);
				break;
			end
		end
	end
	self.VGUI.AddressListView:SortByColumn(1,true); -- Resort by addresses
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
		local letters = n:gsub("[^1-9A-Z]",""):TrimExplode(""); -- Removes illegal chars, because "letters" is only used for addresses in here
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
		if (v.groupgate) then
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

vgui.Register("SAddressSelect_NoGalaxy",PANEL,"Panel");


--################# Shows how this thing has to be used @aVoN
function PANEL:GenerateExample()
	local VGUI = vgui.Create("SAddressSelect_NoGalaxy");
	VGUI:SetSize(180,80);
	VGUI:SetEntity(NULL); -- This defines the stargate this Address Panel is allocated to (Necessary, so we know, what gate we are currently using)
	VGUI.OnDial = function(gate,address,fast_dhd_mode) end; -- The function which shall be triggered when the user dials a gate
	VGUI.OnAbort = function(gate) end; -- The function to call, if you want to abort dialling/close a gate
	return VGUI;
end