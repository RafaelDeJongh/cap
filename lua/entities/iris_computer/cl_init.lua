include('shared.lua')
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_main_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_iris_comp");
end

local function gdopc_menuhook(len)

	local ent = net.ReadEntity();
	if (not IsValid(ent)) then return end
	local closetimeval = net.ReadInt(4);
	local autocloseval = util.tobool(net.ReadBit())
	local donotautoopen = util.tobool(net.ReadBit())
	local codes = {};
	local count = net.ReadInt(8)
	for i=1,count do
		codes[net.ReadString()] = net.ReadString()
	end

	local DermaPanel = vgui.Create( "DFrame" )
   	DermaPanel:SetPos(ScrW()/2-175, ScrH()/2-100)
   	DermaPanel:SetSize(330, 300)
	DermaPanel:SetTitle( "Iris Computer Menu" )
   	DermaPanel:SetVisible( true )
   	DermaPanel:SetDraggable( false )
   	DermaPanel:ShowCloseButton( true )
   	DermaPanel:MakePopup()
	DermaPanel.Paint = function()
        surface.SetDrawColor( 80, 80, 80, 185 )
        surface.DrawRect( 0, 0, DermaPanel:GetWide(), DermaPanel:GetTall() )
    end

	local image = vgui.Create("TGAImage" , DermaPanel);
    image:SetSize(10, 10);
    image:SetPos(10, 10);
    image:LoadTGAImage("materials/gui/cap_logo.tga", "MOD");

	local codeLabel = vgui.Create("DLabel" , DermaPanel )
	codeLabel:SetPos(10,25)
	codeLabel:SetText("Iris Code")

	local descLabel = vgui.Create("DLabel" , DermaPanel )
	descLabel:SetPos(120,25)
	descLabel:SetText("Description")

	local code = vgui.Create( "DTextEntry" , DermaPanel )
	code:SetPos(10, 45)
	code:SetSize(100, 20)
	code:SetText("")
 	code.OnTextChanged = function(TextEntry)
 		local pos = TextEntry:GetCaretPos();
 		local len = TextEntry:GetValue():len();
		local letters = TextEntry:GetValue():gsub("[^1-9]","");
		TextEntry:SetText(letters);
		TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,letters:len())); -- Reset the caretpos!
	end

	local desc = vgui.Create ("DTextEntry" , DermaPanel )
	desc:SetPos(120, 45)
	desc:SetSize(100, 20)
	desc:SetText("")

	local addButton = vgui.Create("DButton" , DermaPanel )
    addButton:SetParent( DermaPanel )
    addButton:SetText("+")
    addButton:SetPos(230, 45)
    addButton:SetSize(20, 25)
	addButton.DoClick = function ( btn1 )

		local found = false
		for k,v in pairs(codes) do
			if v == code:GetValue() or k == desc:GetValue() then
				found = true
			end
		end

		if not found then
			codes[desc:GetValue()] = code:GetValue():gsub("[^1-9]","")
			updateCodes()
		end

    end

	local remButton = vgui.Create("DButton" , DermaPanel )
    remButton:SetParent( DermaPanel )
    remButton:SetText("-")
    remButton:SetPos(260, 45)
    remButton:SetSize(20, 25)
	remButton.DoClick = function ( btn2 )

		local found = false
		for k,v in pairs(codes) do
			if v == code:GetValue() or k == desc:GetValue() then
				found = true
				codes[k] = nil
			end
		end

		if found then
			code:SetText("");
			desc:SetText("");
			updateCodes()
		end

    end

	local codeList = vgui.Create( "DListView", DermaPanel )
	codeList:SetPos(10, 75)
	codeList:SetSize(330, 100)
	codeList:AddColumn("Code")
	codeList:AddColumn("Description")
	codeList:SortByColumn(1, true)

	function updateCodes()
		codeList:Clear()
		for k,v in pairs(codes) do
			codeList:AddLine(v, k)
		end
	end

	updateCodes()

	function codeList:OnRowSelected(id, selected)
		local codeSs = selected:GetColumnText(1)
		local descSs = selected:GetColumnText(2)
		code:SetText(codeSs)
		desc:SetText(descSs)
	end

	local closetime = vgui.Create( "DNumSlider" , DermaPanel )
    closetime:SetPos( 10, 185 )
    closetime:SetSize( 320, 50 )
	closetime:SetText( "Close Time" )
    closetime:SetMin( 0 )
    closetime:SetMax( 10 )
	closetime:SetValue( closetimeval );
    closetime:SetDecimals( 0 )
	closetime:SetToolTip("The time in seconds the iris will stay open after a correct code is sent. Set to 0 to stay open forever.")

	local saveClose = vgui.Create("DButton" , DermaPanel )
    saveClose:SetParent( DermaPanel )
    saveClose:SetText("Ok")
    saveClose:SetPos(230, 260)
    saveClose:SetSize(80, 25)
	saveClose.DoClick = function ( btn3 )
		saveCodes()
		DermaPanel:Close()
    end

	local autoclose = vgui.Create("DCheckBoxLabel" , DermaPanel )
	autoclose:SetText("Auto-close?")
	autoclose:SizeToContents()
	autoclose:SetPos(20, 240)
	autoclose:SetValue( autocloseval )
	autoclose:SizeToContents()
	autoclose:SetTooltip("If checked, the iris will close as soon as an incoming connection is established.")

	local autoopen = vgui.Create("DCheckBoxLabel" , DermaPanel )
	autoopen:SetText("Don't Auto-open?")
	autoopen:SizeToContents()
	autoopen:SetPos(150, 240)
	autoopen:SetValue( donotautoopen )
	autoopen:SetTooltip("If checked, the iris will not open until the wire input tells it to.")

	local cancelButton = vgui.Create("DButton" , DermaPanel )
    cancelButton:SetParent( DermaPanel )
    cancelButton:SetText("Cancel")
    cancelButton:SetPos(10, 260)
    cancelButton:SetSize(80, 25)
	cancelButton.DoClick = function ( btn4 )
		DermaPanel:Close()
    end

	local ToggleIris = vgui.Create("DButton" , DermaPanel )
	ToggleIris:SetParent( DermaPanel )
	ToggleIris:SetText("Toggle Iris")
    ToggleIris:SetPos(120, 260)
    ToggleIris:SetSize(80, 25)
	ToggleIris.DoClick = function ( btn5 )
		net.Start("gdopc_sendinfo")
		net.WriteEntity(ent)
		net.WriteBit(true)
		net.SendToServer()
    end

	function saveCodes()
		addButton:DoClick()

		net.Start("gdopc_sendinfo")
		net.WriteEntity(ent)
		net.WriteBit(false)
		net.WriteInt(math.Round(closetime:GetValue()),4)
		net.WriteBit(autoclose:GetChecked())
		net.WriteBit(autoopen:GetChecked())
		net.WriteInt(table.Count(codes),8)
		for k,v in pairs(codes) do
			net.WriteString(v)
			net.WriteString(k)
		end
		net.SendToServer()

	end

end
net.Receive("gdopc_sendinfo", gdopc_menuhook)