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
net.Receive( "RefreshGateList", StarGateRefreshList);

local function StarGateRemoveFromList( len )
	local ent = net.ReadInt(16);
	if (not ent) then return end
	StarGate_GetAll[ent] = nil;
end
net.Receive( "RemoveGateFromList" , StarGateRemoveFromList );

local Panel_Images = {
	Valid = "icon16/accept.png",
	Invalid = "icon16/cancel.png",
	Editing = "icon16/table_edit.png",
	Warning = "icon16/error.png",
	Info = "icon16/information.png",
}

--################# Register Hooks AlexALX
local function PANEL_RegisterHooks(self)
	-- for smaller font from gmod10
	for k,v in pairs(self.VGUI) do
		if (k=="AddressTextEntry" or k=="GroupTextEntry ") then continue end
		if (v.SetFont) then
			v:SetFont("OldDefaultSmall");
		end
		if (v.Label and v.Label.SetFont) then
			v.Label:SetFont("OldDefaultSmall");
		end
	end
end

local PANEL = {};
PANEL.Images = Panel_Images;
PANEL.Sounds = {
	Warning = Sound("buttons/button2.wav"),
	Info = Sound("buttons/button9.wav"),
}

--################# Init @aVoN
function PANEL:Init()
	self:SetSize(200,80);
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
	self.Entity = NULL;

	--####### Apply Sizes...
	-- The Description above the TextEntry
 	self.VGUI.AddressLabel:SetPos(0,0);

	-- The Address TextEntry
	self.VGUI.AddressTextEntry:SetPos(45,0);
	self.VGUI.AddressTextEntry:SetSize(60,self.VGUI.AddressTextEntry:GetTall());
	self.VGUI.AddressTextEntry:SetTooltip(SGLanguage.GetMessage("stargate_vgui_adrtip"));
	--This function restricts the letters you can enter to a valid address
	self.VGUI.AddressTextEntry.OnTextChanged = function(TextEntry)
		local text = TextEntry:GetValue();
		if(text ~= self.LastAddress) then
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
			self.LastAddress = text;
			TextEntry:SetText(text);
			TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
			self:SetStatus(text);
		end
	end

	-- Status Label
	self.VGUI.StatusImage:SetPos(110,3);
	self.VGUI.StatusImage:SetSize(16,16);
	self.VGUI.StatusLabel:SetPos(130,0);
	self.VGUI.StatusLabel:SetWide(200);

	-- Message (What went wrong?)
	self.VGUI.MessageImage:SetPos(2,23);
	self.VGUI.MessageImage:SetSize(16,16);
	self.VGUI.MessageLabel:SetPos(22,21);
	self.VGUI.MessageLabel:SetWide(200);
	PANEL_RegisterHooks(self);
end

-- You should always call SetEntity BEFORE SetText!!!

--################# Setting text on this panel will set the text on the TextEntry instead @aVoN
function PANEL:SetText(s)
	local s = (s or ""):upper();
	self.VGUI.AddressTextEntry:SetText(s);
	self:SetStatus(s,true);
	self.LastAddress = s;
end

-- You should always call SetEntity BEFORE SetText!!!

--################# The necessary Entity, this panel comes along with (the gate) @aVoN
function PANEL:SetEntity(e)
	self.Entity = e;
	self:SetText(e:GetGateAddress());
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
			local w,_ = surface.GetTextSize(self.Message or "");
			draw.RoundedBox(8,0,21,w+20+2,20,Color(16,16,16,160*alpha));
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
		if (v.class=="stargate_supergate") then
			table.insert(gates,v);
		end
	end
	return gates;
end

--################# Sets the status (Valid/Invalid/Already Exists) @aVoN
function PANEL:SetStatus(s,no_message)
	local s = (s or ""):upper();
	local len = s:len();
	if(len == 6) then
		local letters = s:TrimExplode("");
		local valid = true;
		local set = true;
		for _,v in pairs(self:GetGates()) do
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

vgui.Register("SAddressPanel",PANEL,"Panel");


--################# Shows how this thing has to be used @aVoN
function PANEL:GenerateExample()
	local VGUI = vgui.Create("SAddressPanel");
	VGUI:SetSize(180,80);
	VGUI:SetEntity(NULL); -- This defines the stargate this Address Panel is allocated to (Necessary, so we know, what gate we are currently using)
	VGUI.OnAddressSet = function(gate,address) end; -- The function which shall be triggered when the user set the address on this gate
	return VGUI;
end

--##################################
--###### SAddressPanel_Group.lua
--##################################

local PANEL = {};
PANEL.Images = Panel_Images;
PANEL.Sounds = {
	Warning = Sound("buttons/button2.wav"),
	Info = Sound("buttons/button9.wav"),
}

--################# Init @aVoN
function PANEL:Init()
	self:SetSize(200,80);
	-- Create the Address Field
	self.VGUI = {
		AddressLabel = vgui.Create("DLabel",self),
		AddressTextEntry = vgui.Create("DTextEntry",self),
		GroupLabel = vgui.Create("DLabel",self),
		GroupTextEntry = vgui.Create("DMultiChoice",self),
		StatusLabel = vgui.Create("DLabel",self),
		StatusImage = vgui.Create("DImage",self),
		MessageImage = vgui.Create("DImage",self),
		MessageLabel = vgui.Create("DLabel",self),
		GroupStatus = vgui.Create("DLabel",self),
	}
	self.VGUI.AddressLabel:SetText(SGLanguage.GetMessage("stargate_vgui_address"));
	self.VGUI.GroupLabel:SetText(SGLanguage.GetMessage("stargate_vgui_group"));
	self.VGUI.StatusLabel:SetText("");
	self.VGUI.MessageLabel:SetText("");
	self.VGUI.GroupStatus:SetText("");
	self.Entity = NULL;

	--####### Apply Sizes...
	-- The Description above the TextEntry
 	self.VGUI.AddressLabel:SetPos(0,0);

	-- The Address TextEntry
	self.VGUI.AddressTextEntry:SetPos(45,0);
	self.VGUI.AddressTextEntry:SetSize(60,self.VGUI.AddressTextEntry:GetTall());
	self.VGUI.AddressTextEntry:SetTooltip(SGLanguage.GetMessage("stargate_vgui_adrtip"));
	--This function restricts the letters you can enter to a valid address
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
			self:SetStatus(text,group);
		end
	end

	-- The Description above the TextEntry
 	self.VGUI.GroupLabel:SetPos(0,30);

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
			self:SetStatus(address,text,false,"",true);
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
				self:SetStatus(address,text,false,text);
			elseif (not add1) then
				self:SetStatus(address,text,false,letters[1]);
			elseif (not add2) then
				self:SetStatus(address,text,false,letters[2]);
			else
				self:SetStatus(address,text,false,"",true);
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

	-- Status Label
	self.VGUI.StatusImage:SetPos(110,3);
	self.VGUI.StatusImage:SetSize(16,16);
	self.VGUI.StatusLabel:SetPos(130,0);
	self.VGUI.StatusLabel:SetWide(200);

	-- Message (What went wrong?)
	self.VGUI.MessageImage:SetPos(2,52);
	self.VGUI.MessageImage:SetSize(16,16);
	self.VGUI.MessageLabel:SetPos(22,50);
	self.VGUI.MessageLabel:SetWide(200); -- 200

	self.VGUI.GroupStatus:SetPos(85,30);
	self.VGUI.GroupStatus:SetWide(200);
	PANEL_RegisterHooks(self);
end

-- You should always call SetEntity BEFORE SetText!!!

--################# Setting text on this panel will set the text on the TextEntry instead @aVoN
function PANEL:SetText(s,g)
	local s = (s or ""):upper();
	self.VGUI.AddressTextEntry:SetText(s);
	self.LastAddress = s;
	local g = (g or ""):upper();
	self.VGUI.GroupTextEntry.TextEntry:SetText(g);
	self.LastGroup = g;
	self:SetStatus(s,g,true);
end

-- You should always call SetEntity BEFORE SetText!!!

--################# The necessary Entity, this panel comes along with (the gate) @aVoN
function PANEL:SetEntity(e)
	self.Entity = e;
	self:SetText(e:GetGateAddress(),e:GetGateGroup());
	--player.GetByID(1):ChatPrint(e:GetGateGroup());
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
			local w,_ = surface.GetTextSize(self.Message or "");
			draw.RoundedBox(8,0,51,w+20+2,20,Color(16,16,16,160*alpha));
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
		if (v.groupgate) then
			table.insert(gates,v);
		end
	end
	return gates;
end

--################# Sets the status (Valid/Invalid/Already Exists) @aVoN
function PANEL:SetStatus(s,g,no_message,letters,gs)
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

vgui.Register("SAddressPanel_Group",PANEL,"Panel");


--################# Shows how this thing has to be used @aVoN
function PANEL:GenerateExample()
	local VGUI = vgui.Create("SAddressPanel_Group");
	VGUI:SetSize(180,80);
	VGUI:SetEntity(NULL); -- This defines the stargate this Address Panel is allocated to (Necessary, so we know, what gate we are currently using)
	VGUI.OnAddressSet = function(gate,address) end; -- The function which shall be triggered when the user set the address on this gate
	return VGUI;
end

--##################################
--###### SAddressPanel_GroupSGU.lua
--##################################

local PANEL = {};
PANEL.Images = Panel_Images
PANEL.Sounds = {
	Warning = Sound("buttons/button2.wav"),
	Info = Sound("buttons/button9.wav"),
}

--################# Init @aVoN
function PANEL:Init()
	self:SetSize(200,80);
	-- Create the Address Field
	self.VGUI = {
		AddressLabel = vgui.Create("DLabel",self),
		AddressTextEntry = vgui.Create("DTextEntry",self),
		GroupLabel = vgui.Create("DLabel",self),
		GroupTextEntry = vgui.Create("DMultiChoice",self),
		StatusLabel = vgui.Create("DLabel",self),
		StatusImage = vgui.Create("DImage",self),
		MessageImage = vgui.Create("DImage",self),
		MessageLabel = vgui.Create("DLabel",self),
		GroupStatus = vgui.Create("DLabel",self),
	}
	self.VGUI.AddressLabel:SetText(SGLanguage.GetMessage("stargate_vgui_address"));
	self.VGUI.GroupLabel:SetText(SGLanguage.GetMessage("stargate_vgui_type"));
	self.VGUI.StatusLabel:SetText("");
	self.VGUI.MessageLabel:SetText("");
	self.VGUI.GroupStatus:SetText("");
	self.Entity = NULL;

	--####### Apply Sizes...
	-- The Description above the TextEntry
 	self.VGUI.AddressLabel:SetPos(0,0);

	-- The Address TextEntry
	self.VGUI.AddressTextEntry:SetPos(45,0);
	self.VGUI.AddressTextEntry:SetSize(60,self.VGUI.AddressTextEntry:GetTall());
	self.VGUI.AddressTextEntry:SetTooltip(SGLanguage.GetMessage("stargate_vgui_adrtip"));
	--This function restricts the letters you can enter to a valid address
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
			self:SetStatus(text,group);
		end
	end

	-- The Description above the TextEntry
 	self.VGUI.GroupLabel:SetPos(0,30);

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
			self:SetStatus(address,text,false,"",true);
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
				self:SetStatus(address,text,false,text);
			elseif (not add1 and not add2) then
				self:SetStatus(address,text,false,letters[1]..letters[2]);
			elseif (not add1 and not add3) then
				self:SetStatus(address,text,false,letters[1]..letters[3]);
			elseif (not add2 and not add3) then
				self:SetStatus(address,text,false,letters[2]..letters[3]);
			elseif (not add1) then
				self:SetStatus(address,text,false,letters[1]);
			elseif (not add2) then
				self:SetStatus(address,text,false,letters[2]);
			elseif (not add3) then
				self:SetStatus(address,text,false,letters[3]);
			else
				self:SetStatus(address,text,false,"",true);
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

	-- Status Label
	self.VGUI.StatusImage:SetPos(110,3);
	self.VGUI.StatusImage:SetSize(16,16);
	self.VGUI.StatusLabel:SetPos(130,0);
	self.VGUI.StatusLabel:SetWide(200);

	-- Message (What went wrong?)
	self.VGUI.MessageImage:SetPos(2,52);
	self.VGUI.MessageImage:SetSize(16,16);
	self.VGUI.MessageLabel:SetPos(22,50);
	self.VGUI.MessageLabel:SetWide(200); -- 200

	self.VGUI.GroupStatus:SetPos(92,30);
	self.VGUI.GroupStatus:SetWide(200);
	PANEL_RegisterHooks(self);
end

-- You should always call SetEntity BEFORE SetText!!!

--################# Setting text on this panel will set the text on the TextEntry instead @aVoN
function PANEL:SetText(s,g)
	local s = (s or ""):upper();
	self.VGUI.AddressTextEntry:SetText(s);
	self.LastAddress = s;
	local g = (g or ""):upper();
	self.VGUI.GroupTextEntry.TextEntry:SetText(g);
	self.LastGroup = g;
	self:SetStatus(s,g,true);
end

-- You should always call SetEntity BEFORE SetText!!!

--################# The necessary Entity, this panel comes along with (the gate) @aVoN
function PANEL:SetEntity(e)
	self.Entity = e;
	self:SetText(e:GetGateAddress(),e:GetGateGroup());
	--player.GetByID(1):ChatPrint(e:GetGateGroup());
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
			local w,_ = surface.GetTextSize(self.Message or "");
			draw.RoundedBox(8,0,51,w+20+2,20,Color(16,16,16,160*alpha));
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
		if (v.groupgate) then
			table.insert(gates,v);
		end
	end
	return gates;
end

function PANEL:IsSharedGroup(group)
	if (group=="U@#" or group=="SGI" or SG_CUSTOM_TYPES and SG_CUSTOM_TYPES[group] and SG_CUSTOM_TYPES[group][2] and SG_CUSTOM_TYPES[group][2]>=1) then return true end
	return false
end

--################# Sets the status (Valid/Invalid/Already Exists) @aVoN
function PANEL:SetStatus(s,g,no_message,letters,gs)
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
					(group:len()==3 or not self:IsSharedGroup(group) and g == group)
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
			if(	not self:IsSharedGroup(group) and g == group
			) then
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

vgui.Register("SAddressPanel_GroupSGU",PANEL,"Panel");


--################# Shows how this thing has to be used @aVoN
function PANEL:GenerateExample()
	local VGUI = vgui.Create("SAddressPanel_GroupSGU");
	VGUI:SetSize(180,80);
	VGUI:SetEntity(NULL); -- This defines the stargate this Address Panel is allocated to (Necessary, so we know, what gate we are currently using)
	VGUI.OnAddressSet = function(gate,address) end; -- The function which shall be triggered when the user set the address on this gate
	return VGUI;
end

--##################################
--###### SAddressPanel_CAP.lua
--##################################


local PANEL = {};
PANEL.Images = Panel_Images
PANEL.Sounds = {
	Warning = Sound("buttons/button2.wav"),
	Info = Sound("buttons/button9.wav"),
}

--################# Init @aVoN
function PANEL:Init()
	self:SetSize(200,80);
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
	self.Entity = NULL;

	--####### Apply Sizes...
	-- The Description above the TextEntry
 	self.VGUI.AddressLabel:SetPos(0,0);

	-- The Address TextEntry
	self.VGUI.AddressTextEntry:SetPos(45,0);
	self.VGUI.AddressTextEntry:SetSize(60,self.VGUI.AddressTextEntry:GetTall());
	self.VGUI.AddressTextEntry:SetTooltip(SGLanguage.GetMessage("stargate_galaxy_vgui_adrtip"));
	--This function restricts the letters you can enter to a valid address
	self.VGUI.AddressTextEntry.OnTextChanged = function(TextEntry)
		local text = TextEntry:GetValue();
		if(text ~= self.LastAddress) then
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
			self.LastAddress = text;
			TextEntry:SetText(text);
			TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
			self:SetStatus(text);
		end
	end

	-- Status Label
	self.VGUI.StatusImage:SetPos(110,3);
	self.VGUI.StatusImage:SetSize(16,16);
	self.VGUI.StatusLabel:SetPos(130,0);
	self.VGUI.StatusLabel:SetWide(200);

	-- Message (What went wrong?)
	self.VGUI.MessageImage:SetPos(2,23);
	self.VGUI.MessageImage:SetSize(16,16);
	self.VGUI.MessageLabel:SetPos(22,21);
	self.VGUI.MessageLabel:SetWide(200);
	PANEL_RegisterHooks(self);
end

-- You should always call SetEntity BEFORE SetText!!!

--################# Setting text on this panel will set the text on the TextEntry instead @aVoN
function PANEL:SetText(s)
	local s = (s or ""):upper();
	self.VGUI.AddressTextEntry:SetText(s);
	self:SetStatus(s,true);
	self.LastAddress = s;
end

-- You should always call SetEntity BEFORE SetText!!!

--################# The necessary Entity, this panel comes along with (the gate) @aVoN
function PANEL:SetEntity(e)
	self.Entity = e;
	self:SetText(e:GetGateAddress());
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
			local w,_ = surface.GetTextSize(self.Message or "");
			draw.RoundedBox(8,0,21,w+20+2,20,Color(16,16,16,160*alpha));
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
		if (v.groupgate) then
			table.insert(gates,v);
		end
	end
	return gates;
end

--################# Sets the status (Valid/Invalid/Already Exists) @aVoN
function PANEL:SetStatus(s,no_message)
	local s = (s or ""):upper();
	local len = s:len();
	if(len == 6) then
		local letters = s:TrimExplode("");
		local valid = true;
		local set = true;
		for _,v in pairs(self:GetGates()) do
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

vgui.Register("SAddressPanel_Galaxy",PANEL,"Panel");


--################# Shows how this thing has to be used @aVoN
function PANEL:GenerateExample()
	local VGUI = vgui.Create("SAddressPanel_Galaxy");
	VGUI:SetSize(200,80);
	VGUI:SetEntity(NULL); -- This defines the stargate this Address Panel is allocated to (Necessary, so we know, what gate we are currently using)
	VGUI.OnAddressSet = function(gate,address) end; -- The function which shall be triggered when the user set the address on this gate
	return VGUI;
end