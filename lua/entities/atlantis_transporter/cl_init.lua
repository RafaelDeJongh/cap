include("shared.lua");

function ENT:Draw() self:DrawModel() end;

local start;
local alpha = 0;
local go;
hook.Add("HUDPaint","AtlantisTransporterHUDPaint",
	function()
		if(not start) then return end;
		local rate = 1000;
		local offset = 0;
		if(not go) then
			rate = -1000;
			offset = 255;
		end
		alpha = math.Clamp(offset + (CurTime() - start)*rate,0,255);
		surface.SetDrawColor(255,255,255,alpha);
		surface.DrawRect(0,0,ScrW(),ScrH());
		if(alpha == 0) then start = nil end;
	end
);

usermessage.Hook("AtlantisTransporterTele",
	function (data)
		go = data:ReadBool()
		start = CurTime();
		if(go) then timer.Create("AtlantisTeleSafeTimer",5,1,function() start = nil end) end;
	end
);

local AtlTP_GetAll = {}

net.Receive( "UpdateAtlTP" , function(len)
	local ent = net.ReadInt(16);
	if (not ent) then return end
	local type = net.ReadInt(4);
	if (type==0) then
		AtlTP_GetAll[ent] = nil;
	elseif (type==1) then
		AtlTP_GetAll[ent] = AtlTP_GetAll[ent] or {};
		AtlTP_GetAll[ent].name = net.ReadString();
	elseif (type==2) then
		AtlTP_GetAll[ent] = AtlTP_GetAll[ent] or {};
		AtlTP_GetAll[ent].private = util.tobool(net.ReadBit());
	elseif (type==3) then
		AtlTP_GetAll[ent] = AtlTP_GetAll[ent] or {};
		AtlTP_GetAll[ent].name = net.ReadString();
		AtlTP_GetAll[ent].private = util.tobool(net.ReadBit());
		AtlTP_GetAll[ent].grp = net.ReadString();
		AtlTP_GetAll[ent].loc = util.tobool(net.ReadBit());	
	elseif(type==4) then
		AtlTP_GetAll[ent] = AtlTP_GetAll[ent] or {};
		AtlTP_GetAll[ent].grp = net.ReadString();
	elseif(type==5) then
		AtlTP_GetAll[ent] = AtlTP_GetAll[ent] or {};
		AtlTP_GetAll[ent].loc = util.tobool(net.ReadBit());
	end
end );

net.Receive( "RemoveAtlTPList", function(len)
	AtlTP_GetAll = {}
end );

local PANEL = {}

function PANEL:Init()
	self:SetSize(400,250)
	self:MakePopup();
	self:SetSizable(false)
	self:SetDraggable(false)
	self:SetTitle("")
	self.Logo = vgui.Create("DImage",self);
	self.Logo:SetPos(8,10);
	self.Logo:SetImage("gui/cap_logo");
	self.Logo:SetSize(16,16);
 	self.TextEntry = vgui.Create( "DTextEntry", self )
 	self.TextEntry:SetText("")
  	self.TextEntry:SetAllowNonAsciiCharacters(true)

  	self.ListView = vgui.Create( "DListView", self )
  	self.ListView:AddColumn(SGLanguage.GetMessage("atl_tp_05")):SetFixedWidth(285); //380
	self.ListView:AddColumn(SGLanguage.GetMessage("atl_tp_group")):SetFixedWidth(50);
	self.ListView:AddColumn(SGLanguage.GetMessage("atl_tp_local") .. "?"):SetFixedWidth(45);
  	self.ListView:SortByColumn(0,false);
  	self.ListView:SetSize(380,170);
  	self.ListView.OnRowSelected = function(ListView,Row)
		local selected = ListView:GetSelectedLine();
		local name = ListView:GetLine(selected):GetColumnText(1);
		self.TextEntry:SetText(name);
		-- Avoids confusing soundspam on double click
		if(selected ~= self.LastSelected) then
			self.LastSelected = selected;
			surface.PlaySound(Sound("npc/turret_floor/click1.wav"));
		end
	end
	self.ListView.DoDoubleClick = function(ListView,id,List)
		local panel2=ListView:GetParent()
		net.Start("atlantis_transport");
		net.WriteEntity(panel2.Entity);
		net.WriteBit(true);
		net.WriteString(List:GetColumnText(1));
		net.SendToServer();
		panel2:Remove();
	end

	self.RefreshImageButton = vgui.Create("DImageButton",self);
	self.RefreshImageButton:SetPos(285,40);
	self.RefreshImageButton:SetSize(16,16);
	self.RefreshImageButton:SetImage("icon16/arrow_refresh.png");
	self.RefreshImageButton:SetTooltip(SGLanguage.GetMessage("stargate_vgui_refresh"));
	self.RefreshImageButton.DoClick = function(ImageButton)
		local panel2=ImageButton:GetParent()
		panel2.ListView:Clear();
		panel2:UpdateList();
	end

 	self.L1 = vgui.Create( "DLabel", self )
 	self.L1:SetText(SGLanguage.GetMessage("atl_tp_02"))
 	self.L1:SetFont("OldDefaultSmall")

 	self.Button = vgui.Create( "Button", self)
 	self.Button.DoClick = function(self)
		local panel2=self:GetParent()
		net.Start("atlantis_transport");
		net.WriteEntity(panel2.Entity);
		net.WriteBit(true);
		net.WriteString(panel2.TextEntry:GetValue());
		net.SendToServer();
		panel2:Remove();
 	end
	self.Button:SetText(SGLanguage.GetMessage("atl_tp_04"))

	self.Button:SetPos(310,39)
	self.Button:SetSize(80,22)
 	self.TextEntry:SetSize( 270, self.TextEntry:GetTall() )
 	self.TextEntry:SetPos( 10, 40 )
 	self.ListView:SetPos(10,70)
 	self.L1:SetPos( 30, 3 )
 	self.L1:SetSize( 400, 30 )
end

local group;
function PANEL:UpdateList()
	for k,v in pairs(AtlTP_GetAll) do
		if (self.Entity:EntIndex()!=k and v.name and v.name!="" and not v.private) then
			local this = AtlTP_GetAll[self.Entity:EntIndex()];
			if(v.loc) then
				if(v.grp == this.grp and this.loc) then
					self.ListView:AddLine(v.name,v.grp,"Yes");

				end
			else
				self.ListView:AddLine(v.name,v.grp,"No");
			end
		end
	end
end

function PANEL:Paint(w,h)
	draw.RoundedBox( 10, 0, 0, w, h , Color(16,16,16,160) )
	return true
end

function PANEL:SetEntity(ent)
	self.Entity = ent;
end

vgui.Register( "AtlantisDestinationEntryCap", PANEL, "DFrame" )
local Window
local function RingTransporterShowWindow(um)
	local ent = um:ReadEntity();
	if (not IsValid(ent)) then return end
	Window = vgui.Create( "AtlantisDestinationEntryCap" )
	Window:SetKeyBoardInputEnabled( true )
	Window:SetMouseInputEnabled( true )
	Window:SetPos( (ScrW()/2 - 250) / 2, ScrH()/2 - 75 )
	Window:SetVisible( true )
	Window:SetEntity(ent)
	Window:UpdateList()
end
usermessage.Hook("AtlantisTransporterShowWindow", RingTransporterShowWindow)

local PANEL = {}

function PANEL:Init()
	self:SetSize(400,110)
	self:MakePopup();
	self:SetSizable(false)
	self:SetDraggable(false)
	self:SetTitle("")
	self.Logo = vgui.Create("DImage",self);
	self.Logo:SetPos(8,10);
	self.Logo:SetImage("gui/cap_logo");
	self.Logo:SetSize(16,16);
 	self.TextEntry = vgui.Create( "DTextEntry", self )
 	self.TextEntry:SetText("")
 	self.TextEntry:SetAllowNonAsciiCharacters(true)
	
 	self.L1 = vgui.Create( "DLabel", self )
 	self.L1:SetText(SGLanguage.GetMessage("atl_tp_01"))
 	self.L1:SetFont("OldDefaultSmall")
	
	
	self.NameLabel = vgui.Create( "DLabel", self );
	self.NameLabel:SetText(SGLanguage.GetMessage("atl_tp_name"))
	self.NameLabel:SetFont("OldDefaultSmall")
	self.NameLabel:SetSize( 400, 50 )
	self.NameLabel:SetPos(11,25)
	
	self.GroupLabel = vgui.Create( "DLabel", self );
	self.GroupLabel:SetText(SGLanguage.GetMessage("atl_tp_group"))
	self.GroupLabel:SetFont("OldDefaultSmall")
	self.GroupLabel:SetSize( 400, 50 )
	self.GroupLabel:SetPos(256,25)
	
	self.PrivateImage = vgui.Create("DImage",self)
	self.PrivateImage:SetPos(10,87);
	self.PrivateImage:SetSize(16,16);
	self.PrivateImage:SetImage("icon16/shield.png");

	self.PrivateCheckbox = vgui.Create("DCheckBoxLabel",self)
	self.PrivateCheckbox:SetPos(35,87);
	self.PrivateCheckbox:SetText(SGLanguage.GetMessage("atl_tp_06"));
	self.PrivateCheckbox:SetWide(110);
	local tip = SGLanguage.GetMessage("atl_tp_07");
	self.PrivateCheckbox:SetTooltip(tip);
	self.PrivateCheckbox.Label:SetTooltip(tip); -- Workaround/Fix
	
	self.LocalCheckbox = vgui.Create("DCheckBoxLabel",self)
	self.LocalCheckbox:SetPos(100,87);
	self.LocalCheckbox:SetText(SGLanguage.GetMessage("atl_tp_local")); //MAKE Language COMPATIBLE
	self.LocalCheckbox:SetWide(110);
	//local tip = SGLanguage.GetMessage("atl_tp_07");
	local tip = "Sets whether to use a Local Group or not";
	self.LocalCheckbox:SetTooltip(tip);
	self.LocalCheckbox.Label:SetTooltip(tip); -- Workaround/Fix
	
	self.GroupEntry = vgui.Create("DTextEntry",self);
	self.GroupEntry:SetText("ATL");
	self.GroupEntry:SetSize(50,self.GroupEntry:GetTall());
	self.GroupEntry:SetPos(255,60);
	self.GroupEntry:SetAllowNonAsciiCharacters(false)

 	self.Button = vgui.Create( "Button", self)
 	self.Button.DoClick = function(self)
		local panel2=self:GetParent()
		net.Start("atlantis_transport");
		net.WriteEntity(panel2.Entity);
		net.WriteBit(false);
		net.WriteString(panel2.TextEntry:GetValue());
		net.WriteBit(panel2.PrivateCheckbox:GetChecked());
		net.WriteString(panel2.GroupEntry:GetValue());
		group = panel2.GroupEntry:GetValue();
		net.WriteBit(panel2.LocalCheckbox:GetChecked());
		net.SendToServer();
		panel2:Remove();
 	end
	self.Button:SetText(SGLanguage.GetMessage("atl_tp_03"))

	self.Button:SetPos(310,59)
	self.Button:SetSize(80,22)
 	self.TextEntry:SetSize( 240, self.TextEntry:GetTall() )
 	self.TextEntry:SetPos( 10, 60 )
 	self.L1:SetPos( 30, 3 )
 	self.L1:SetSize( 400, 50 )
end

function PANEL:Paint(w,h)
	draw.RoundedBox( 10, 0, 0, w, h , Color(16,16,16,160) )
	return true
end

function PANEL:SetEntity(ent)
	self.Entity = ent;
end

function PANEL:SetVal(val,priv,grp,loc)
	self.TextEntry:SetText(val);
	self.PrivateCheckbox:SetChecked(priv);
	self.GroupEntry:SetText(grp);
	self.LocalCheckbox:SetChecked(loc);
	group = grp;

end

vgui.Register( "AtlantisDestinationEditCap", PANEL, "DFrame" )
local Window
local function RingTransporterEditWindow(um)
	local ent = um:ReadEntity();
	if (not IsValid(ent)) then return end
	Window = vgui.Create( "AtlantisDestinationEditCap" )
	Window:SetKeyBoardInputEnabled( true )
	Window:SetMouseInputEnabled( true )
	Window:SetPos( (ScrW()/2 - 250) / 2, ScrH()/2 - 75 )
	Window:SetVisible( true )
	Window:SetEntity(ent)
	Window:SetVal(um:ReadString(),um:ReadBool(),um:ReadString(),um:ReadBool())
end
usermessage.Hook("AtlantisTransporterEditWindow", RingTransporterEditWindow)