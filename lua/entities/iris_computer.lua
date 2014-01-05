if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Stargate Iris Computer"
ENT.Purpose	= "Open/Close Iris"
ENT.Author = "Rothon, AlexALX"
ENT.Contact	= "steven@facklerfamily.org"
ENT.Instructions= "Touch gate or Iris, press USE to change settings"
ENT.Category = "Stargate Carter Addon Pack"
ENT.WireDebugName = "Stargate Iris Computer"

list.Set("CAP.Entity", ENT.PrintName, ENT);

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end
AddCSLuaFile()

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

function ENT:Initialize()
	self.Entity:SetModel("models/props_lab/reciever01b.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)

	self.code = 0
	self.autoclose = false
	self.didclose = false	--Without this, the iris would close within a half second of opening.
	self.donotautoopen = false	--Open automatically when a correct code comes in?
	self.CodeStatus = 0
	self.closetime = 0
	self.wireCode = 0;
	self.LockedGate = self.Entity
	self.LockedIris = self.Entity
	self.Codes = {};
	self.wireDesc = "";
	self.GDOStatus = 0;
	self.GDOText = "";
	self.Busy = false;

	self:CreateWireInputs("Iris Control", "GDO Status", "GDO Text [STRING]","Auto-close","Don't Auto-Open","Close time","Disable Menu Mode")
	self:CreateWireOutputs("Incoming Wormhole", "Code Status", "Gate Active", "Received Code", "Code Description [STRING]", "Iris Active","Busy")

end

local function AutoClose(EntTable)	--timer function
	local gate, iris
	if EntTable.LockedGate == EntTable.Entity then
		gate, iris = EntTable:FindGate()
	else
		gate, iris = EntTable.LockedGate, EntTable.LockedIris
	end
	if gate.IsOpen and not iris.IsActivated then
		iris:Toggle()
		EntTable.didclose = true
	end
	EntTable.wireCode = 0;
	EntTable.CodeStatus = 0
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local PropLimit = GetConVar("CAP_iris_comp_max"):GetInt()
	if(ply:GetCount("CAP_iris_comp")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Iris computer limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("iris_computer");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos+Vector(0,0,20));
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply;
	ply:AddCount("CAP_iris_comp", ent)

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	return ent
end

util.AddNetworkString("gdopc_sendinfo")

function ENT:Use(ply)
	if (self:GetWire("Disable Menu Mode",0)>=2) then return end
	if (self:GetWire("Disable Menu Mode",0)==1 and self.Owner!=ply) then return end
	net.Start("gdopc_sendinfo")
	net.WriteEntity(self)
	net.WriteInt(self.closetime,8)
	net.WriteBit(self.autoclose)
	net.WriteBit(self.donotautoopen)
	net.WriteInt(table.Count(self.Codes),8)
	for k,v in pairs(self.Codes) do
		net.WriteString(v)
		net.WriteString(k)
	end
	net.Send(ply)
end

function ENT:Touch(ent)
	if self.LockedGate == self.Entity then
		if (string.find(ent:GetClass(), "stargate")) then
			local gate = self:FindGate()
			if IsValid(gate) and gate==ent and not IsValid(gate.LockedIrisComp) then
				local iris = gate:GetIris();
				if iris:IsValid() then
					self.LockedGate = gate
					self.LockedIris = iris
					gate.LockedIrisComp = self;
					local ed = EffectData()
	 					ed:SetEntity( self.Entity )
	 				util.Effect( "propspawn", ed, true, true )
 				end
			end
		end
	end
end

function ENT:Think()

	local gate, iris
	if self.LockedGate == self.Entity then
		gate, iris = self:FindGate()
	else
		gate = self.LockedGate
		iris = self.LockedIris
	end
	if IsValid(gate) and IsValid(iris) then
		if not gate.Outbound and (gate.IsOpen or gate.NewActive) then
			if self.autoclose and not self.didclose then
				if not iris.IsActivated and (not iris:IsBusy() or gate.NoxDialingType) then
					iris:Toggle()
					self.didclose = true	--We won't close the iris again until then next time the gate is active
				end
			end
		else
			self.wireCode = 0;
			self.CodeStatus = 0
			self.wireDesc = "";
		end

		if not (gate.IsOpen or gate.NewActive) and self.didclose and iris.IsActivated then
			if (not iris:IsBusy()) then
				self.didclose = false	--Resetting so we can autoclose again
				iris:Toggle()		--Make this optional in the future?
			end
		end

		if self.didclose and not (gate.IsOpen or gate.NewActive) and not iris:IsBusy() then
			self.didclose = false
		end


			if gate.IsOpen or gate.NewActive then
				self:SetWire("Gate Active", 1)
				if not gate.Outbound then
					self:SetWire("Incoming Wormhole", 1)
				else
					self:SetWire("Incoming Wormhole", 0)
				end
			else
				self:SetWire("Gate Active", 0)
			end

			if iris.IsActivated then
				self:SetWire("Iris Active", 1)
			else
				self:SetWire("Iris Active", 0)
			end

			if self.donotautoopen and not gate.IsOpen then
				self.CodeStatus = 0
			end
			self:SetWire("Code Status", self.CodeStatus)

			self:SetWire("Received Code", self.wireCode)
			self:SetWire("Code Description", self.wireDesc)

	else
		self.LockedGate = self.Entity;
		self.LockedIris = self.Entity;
	end

	self.Entity:NextThink(CurTime()+0.5)
	return true
end

function ENT:TriggerInput(iname, value)
	local gate, iris
	if self.LockedGate == self.Entity then
		gate, iris = self:FindGate()
	else
		gate = self.LockedGate
		iris = self.LockedIris
	end
	if (iname == "Iris Control" and IsValid(iris)) then
		if (value>0 and not iris.IsActivated or value<=0 and iris.IsActivated) then
			iris:Toggle()
		end
		if value == 0 and self.closetime ~= 0 then
			timer.Simple(self.closetime, function() AutoClose(self) end)
		end
	elseif (iname == "GDO Status") then
		self.GDOStatus = value;
	elseif (iname == "GDO Text") then
		self.GDOText = value;
	elseif (iname == "Don't Auto-Open") then
		if value > 0 then
			self.donotautoopen = true;
		else
			self.donotautoopen = false;
		end
	elseif (iname == "Auto-close") then
		if value > 0 then
			self.autoclose = true;
		else
			self.autoclose = false;
		end
	elseif (iname == "Close time") then
		if value > 0 then
			self.closetime = value;
		else
			self.closetime = 0;
		end
	end
end

---------------------------------------------
-- Server/Client crossover stuff
---------------------------------------------

local function ReceiveCodes(len, player)
	local ent = net.ReadEntity()
	if (not IsValid(ent)) then return end
	if (util.tobool(net.ReadBit())) then
		local gate, iris
		if ent.LockedGate == ent then
			gate, iris = ent:FindGate()
		else
			iris = ent.LockedIris
		end
		if IsValid(iris) then iris:Toggle() end
	else
		ent.closetime = net.ReadInt(8)
		ent.autoclose = util.tobool(net.ReadBit())
		ent.donotautoopen = util.tobool(net.ReadBit())
		local count = net.ReadInt(8)
		local codes = {}
		for i=1,count do
			local k,v = net.ReadString(),net.ReadString();
			if (k!="" and v!="") then
        		codes[k] = v
        	end
		end
		ent.Codes = codes;
	end
end
net.Receive("gdopc_sendinfo", ReceiveCodes)

---------------------------------------------
-- Gate Stuff
---------------------------------------------

function ENT:FindGate()  -- from aVoN's DHD
	local gate
	local iris
	local dist = 1000
	local pos = self.Entity:GetPos()
	for _,v in pairs(ents.FindByClass("stargate_*")) do
		if(v.IsStargate and (not IsValid(v.LockedIrisComp) or v.LockedIrisComp==self)) then
			local sg_dist = (pos - v:GetPos()):Length()
			if(dist >= sg_dist) then
				dist = sg_dist
				gate = v
				local ir = v:GetIris();
				if (IsValid(ir)) then
					iris = ir;
				end
			end
		end
	end
	return gate, iris
end

function ENT:RecieveIrisCode(code)
	if (self.Busy) then return -1 end

	local gate, iris
	if self.LockedGate == self.Entity then
		gate, iris = self:FindGate()
	else
		gate = self.LockedGate
		iris = self.LockedIris
	end
	local ret = 0
	self.wireCode = code
	self:SetWire("Received Code", self.wireCode)

	for v,k in pairs(self.Codes) do
		if code == v then
			self.wireDesc = k;
			self:SetWire("Code Description", self.wireDesc)
			if IsValid(iris) and iris.IsActivated then
				if not self.donotautoopen then
					iris:Toggle()
					ret = 1
					if self.closetime ~= 0 then
						timer.Simple(self.closetime, function() AutoClose(self) end)
					end
				else
					ret = 2
					self.CodeStatus = 1
				end
			else
				ret = 1; self.CodeStatus = 1;
			end
		end
	end
	if (self.GDOStatus>0) then
		self.CodeStatus = 1; ret = 1;
		if IsValid(iris) and iris.IsActivated then
			if not self.donotautoopen then
				iris:Toggle()
				if self.closetime ~= 0 then
					timer.Simple(self.closetime, function() AutoClose(self) end)
				end
			else
				ret = 2
				self.CodeStatus = 1
			end
		end
	end
	if self.CodeStatus == 0 and self.donotautoopen then	-- if no code was found, this'll be 0 still
		self.CodeStatus = 2			-- so, that means the code was wrong
	end

	self:SetBusy(true);

	timer.Remove("_sgiriscode"..self:EntIndex())
	timer.Create("_sgiriscode"..self:EntIndex(), 4.2, 0 , function()
		if (IsValid(self)) then
			self.wireCode = 0;
			self.wireDesc = "";
			self.CodeStatus = 0;
			self:SetBusy(false);
		end
	end)

	return ret
end

function ENT:SetBusy(busy)
	self.Busy = busy;
	self:SetWire("Busy",busy);
end

function ENT:OnRemove()
	if (self.LockedGate!=self) then
		self.LockedGate.LockedIrisComp = nil;
	end
end

function ENT:PreEntityCopy()
	local dupeInfo = {};

	dupeInfo.Codes = self.Codes or {};

	dupeInfo.closetime = self.closetime;
	dupeInfo.autoclose = self.autoclose;
	dupeInfo.donotautoopen = self.donotautoopen;
	dupeInfo.LockedIris = self.LockedIris:EntIndex();
	dupeInfo.LockedGate = self.LockedGate:EntIndex();

    duplicator.StoreEntityModifier(self, "StarGateIrisCompInfo", dupeInfo)
	StarGate.WireRD.PreEntityCopy(self);
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end

	if (IsValid(ply)) then
		local PropLimit = GetConVar("CAP_iris_comp_max"):GetInt()
		if(ply:GetCount("CAP_iris_comp")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(\"Iris computer limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			Ent:Remove();
			return
		end
		ply:AddCount("CAP_iris_comp", Ent);
	end

	local dupeInfo = Ent.EntityMods.StarGateIrisCompInfo
	if (dupeInfo.Codes) then
		self.Codes = dupeInfo.Codes;
	end
	if (dupeInfo.closetime) then
		self.closetime = dupeInfo.closetime;
	end
	if (dupeInfo.autoclose) then
		self.autoclose = dupeInfo.autoclose;
	end
	if (dupeInfo.donotautoopen) then
		self.donotautoopen = dupeInfo.donotautoopen;
	end
	if (dupeInfo.LockedIris) then
		self.LockedIris = CreatedEntities[dupeInfo.LockedIris];
	end
	if (dupeInfo.LockedGate and CreatedEntities[dupeInfo.LockedGate]) then
		self.LockedGate = CreatedEntities[dupeInfo.LockedGate];
		CreatedEntities[dupeInfo.LockedGate].LockedIrisComp = self;
	end
	if (IsValid(ply)) then
		self.Owner = ply;
	end

	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "iris_computer", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_main_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_iris_comp");
end

local function gdopc_menuhook(len)

	local ent = net.ReadEntity();
	if (not IsValid(ent)) then return end
	local closetimeval = net.ReadInt(8);
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
	--DermaPanel:SetTitle( SGLanguage.GetMessage("iriscomp_title") )
	DermaPanel:SetTitle("")
   	DermaPanel:SetVisible( true )
   	DermaPanel:SetDraggable( false )
   	DermaPanel:ShowCloseButton( true )
   	DermaPanel:MakePopup()
	DermaPanel.Paint = function(self,w,h)
        surface.SetDrawColor( 80, 80, 80, 185 )
        surface.DrawRect( 0, 0, w, h )
    end

	local image = vgui.Create("DImage" , DermaPanel);
    image:SetSize(16, 16);
    image:SetPos(5, 5);
    image:SetImage("gui/cap_logo");

  	local title = vgui.Create( "DLabel", DermaPanel );
 	title:SetText(SGLanguage.GetMessage("iriscomp_title"));
  	title:SetPos( 25, 0 );
 	title:SetSize( 400, 25 );

	local codeLabel = vgui.Create("DLabel" , DermaPanel )
	codeLabel:SetPos(10,25)
	codeLabel:SetText(SGLanguage.GetMessage("iriscomp_code"))

	local descLabel = vgui.Create("DLabel" , DermaPanel )
	descLabel:SetPos(120,25)
	descLabel:SetText(SGLanguage.GetMessage("iriscomp_desc"))

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
	desc:SetAllowNonAsciiCharacters(true)

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

		if not found and code:GetValue():gsub("[^1-9]","")!="" and desc:GetValue()!="" then
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
	codeList:SetSize(310, 100)
	codeList:AddColumn(SGLanguage.GetMessage("iriscomp_code"))
	codeList:AddColumn(SGLanguage.GetMessage("iriscomp_desc"))
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
	closetime:SetText( SGLanguage.GetMessage("iriscomp_time") )
    closetime:SetMin( 0 )
    closetime:SetMax( 10 )
	closetime:SetValue( closetimeval );
    closetime:SetDecimals( 0 )
	closetime:SetToolTip(SGLanguage.GetMessage("iriscomp_time_desc"))

	local saveClose = vgui.Create("DButton" , DermaPanel )
    saveClose:SetParent( DermaPanel )
    saveClose:SetText(SGLanguage.GetMessage("iriscomp_ok"))
    saveClose:SetPos(230, 260)
    saveClose:SetSize(80, 25)
	saveClose.DoClick = function ( btn3 )
		saveCodes()
		DermaPanel:Close()
    end

	local autoclose = vgui.Create("DCheckBoxLabel" , DermaPanel )
	autoclose:SetText(SGLanguage.GetMessage("iriscomp_close"))
	autoclose:SizeToContents()
	autoclose:SetPos(20, 240)
	autoclose:SetValue( autocloseval )
	autoclose:SizeToContents()
	autoclose:SetTooltip(SGLanguage.GetMessage("iriscomp_close_desc"))

	local autoopen = vgui.Create("DCheckBoxLabel" , DermaPanel )
	autoopen:SetText(SGLanguage.GetMessage("iriscomp_open"))
	autoopen:SizeToContents()
	autoopen:SetPos(150, 240)
	autoopen:SetValue( donotautoopen )
	autoopen:SetTooltip(SGLanguage.GetMessage("iriscomp_open_desc"))

	local cancelButton = vgui.Create("DButton" , DermaPanel )
    cancelButton:SetParent( DermaPanel )
    cancelButton:SetText(SGLanguage.GetMessage("iriscomp_cancel"))
    cancelButton:SetPos(10, 260)
    cancelButton:SetSize(80, 25)
	cancelButton.DoClick = function ( btn4 )
		DermaPanel:Close()
    end

	local ToggleIris = vgui.Create("DButton" , DermaPanel )
	ToggleIris:SetParent( DermaPanel )
	ToggleIris:SetText(SGLanguage.GetMessage("iriscomp_toggle"))
    ToggleIris:SetPos(110, 260)
    ToggleIris:SetSize(100, 25)
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
		net.WriteInt(math.Round(closetime:GetValue()),8)
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

end