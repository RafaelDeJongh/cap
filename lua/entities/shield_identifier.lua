if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Shield Identifier"
ENT.Purpose	= "Pass throught a shield or not"
ENT.Author = "Matspyder"
ENT.Contact	= "mat.spyder@gmail.com"
ENT.Instructions= "Press E to use and set a frequency with the Wire Advanced"
ENT.Category = "Stargate Carter Addon Pack: Others"
ENT.WireDebugName = "Shield Identifier"

--list.Set("CAP.Entity", ENT.PrintName, ENT);
ENT.Spawnable = false
ENT.AdminSpawnable = false

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
AddCSLuaFile()

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	--self.Entity:SetModel("models/props_lab/reciever01b.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self.IsEnabled = false;
	self.Frequency = 0;
	self.MaxFrequency = 1500;

	if (WireAddon) then
		self:CreateWireInputs("Activate","Frequency");
		self:CreateWireOutputs("Activated","ActiveFrequency");
	end
	self:ShowOutput(true);
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	/*local PropLimit = GetConVar("CAP_shield_identifier_max"):GetInt()
	if(ply:GetCount("CAP_shield_identifier")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(You have hit the limit of Shield Identifier, NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end*/

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("shield_identifier");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos+Vector(0,0,20));
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply;
	ply:AddCount("CAP_shield_identifier", ent)

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	return ent
end
-----------------------------------WIRE----------------------------------

function ENT:TriggerInput(variable, value)
	if (variable == "Activate") then
		self.IsEnabled = util.tobool(value)
		self:SetWire("Activated",self.IsEnabled);
	elseif (variable == "Frequency") then
		self:SetFrequency(value);
	end
end

function ENT:Enabled()
	return self.IsEnabled;
end

function ENT:SetFrequency(number)
	local value = number;
	if number < 0 then value = 0; end
	if number > self.MaxFrequency then value = self.MaxFrenquency; end
	self.Frequency = value;
	self:SetWire("ActiveFrequency",value);
end

function ENT:GetFrequency()
	return self.Frequency;
end

function ENT:Toggle()
	if self:Enabled() then
		self.IsEnabled = false;
		self:SetWire("Activated",0);
	else
		self.IsEnabled = true;
		self:SetWire("Activated",1)
	end
end

-----------------------------------THINK----------------------------------

function ENT:Think()
	self.Entity:ShowOutput(true);
	self.Entity:NextThink(CurTime()+0.25);
	return true
end

function ENT:ShowOutput(active)
	local add = "Off";
	local enabled = 0;
	if(active) then
		add = "On";
		enabled = 1;
	end
	self:SetOverlayText("Shield Identifier ("..add..")");
end

function ENT:SetOverlayText( text )
    self:SetNetworkedString( "GModOverlayText", text )
end

-----------------------------------USE---------------------------------
util.AddNetworkString("shieldid_sendinfo")

function ENT:Use(ply)
	/*if(self.IsEnabled) then
		self.IsEnabled = false;
		self:SetWire("Activated",0);
	else
		self.IsEnabled = true;
		self:SetWire("Activated",1);
	end*/
	net.Start("shieldid_sendinfo")
	net.WriteEntity(self)
	net.WriteUInt(self.Frequency,12)
	net.WriteBool(self.IsEnabled)
	net.Send(ply)
end

local function ReceiveNewInfos()
	local ent = net.ReadEntity()
	if (not IsValid(ent)) then return end
	if (util.tobool(net.ReadBit())) then
		ent:Toggle();
	else
		ent:SetFrequency(net.ReadUInt(12));
	end
end
net.Receive("shieldid_sendinfo", ReceiveNewInfos)

end

if CLIENT then
	local function shieldid_menuhook(len)
		local ent = net.ReadEntity();
		if (not IsValid(ent)) then return end
		local SIfrequency = net.ReadUInt(12);
		local active = util.tobool(net.ReadBit());

		local DermaPanel = vgui.Create( "DFrame" )
	   	--DermaPanel:SetPos(ScrW()/2-175, ScrH()/2-100)
	   	DermaPanel:SetSize(330, 90)
		DermaPanel:Center()

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
	 	title:SetText(SGLanguage.GetMessage("shieldid_title"));
	  	title:SetPos( 25, 0 );
	 	title:SetSize( 400, 25 );

		local frequency = vgui.Create( "DNumSlider" , DermaPanel )
	    frequency:SetPos( 10, 15 )
	    frequency:SetSize( 320, 50 )
		frequency:SetText( SGLanguage.GetMessage("shieldid_frequency") )
	    frequency:SetMin(0)
	    frequency:SetMax(1500)
		frequency:SetDecimals(0)
		frequency:SetValue(SIfrequency);
		frequency:SetToolTip(SGLanguage.GetMessage("stool_stargate_shield_ident_text"))

		local function saveFrequency()
			net.Start("shieldid_sendinfo")
			net.WriteEntity(ent)
			net.WriteBit(false)
			net.WriteUInt(math.Round(frequency:GetValue()),12)
			net.SendToServer()
		end

		local saveClose = vgui.Create("DButton" , DermaPanel )
	    saveClose:SetParent( DermaPanel )
	    saveClose:SetText(SGLanguage.GetMessage("shieldid_save"))
	    saveClose:SetPos(180,60)
	    saveClose:SetSize(120,25)
		saveClose.DoClick = function ( btn3 )
			saveFrequency();
	    end

	    local ToggleActive = vgui.Create("DButton" , DermaPanel )
		ToggleActive:SetParent( DermaPanel )
		ToggleActive:SetText(SGLanguage.GetMessage("shieldid_toggle"))
	    ToggleActive:SetPos(30, 60)
		if (active) then
			ToggleActive:SetImage("icon16/lightbulb.png")		
		else
			ToggleActive:SetImage("icon16/lightbulb_off.png")
		end
	    ToggleActive:SetSize(120, 25)
		ToggleActive.DoClick = function ( btn5 )
			net.Start("shieldid_sendinfo")
			net.WriteEntity(ent)
			net.WriteBit(true)
			net.SendToServer()
			active = !(active)
			if (active) then
				ToggleActive:SetImage("icon16/lightbulb.png")		
			else
				ToggleActive:SetImage("icon16/lightbulb_off.png")
			end
	    end
	end

	net.Receive("shieldid_sendinfo", shieldid_menuhook)
end