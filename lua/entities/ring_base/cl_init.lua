include('shared.lua')

function ENT:Initialize()
	self.DAmt=0
end

function ENT:Draw()
	self:DrawModel();
end

function ENT:GetRingAddress()
	return self:GetNetworkedString("address","");
end

--################# Show the addresse of a ring when set @aVoN, madman07
hook.Add("HUDPaint","Ring.Hook.HUDPaint.ShowAddressAndNames",
	function()
		local x,y = gui.MousePos();
		if(x == 0 and y == 0) then -- Avoids this popping up, if the dial dialogue is opened
			local p = LocalPlayer();
			if(IsValid(p)) then
				local trace = LocalPlayer():GetEyeTrace();
				if(trace and trace.Hit and IsValid(trace.Entity)) then
					local e = trace.Entity;
					if(e.IsRings) then
						local address = e:GetRingAddress();
						if(address ~= "") then
							local message = SGLanguage.GetMessage("stargate_address")..": "..address;
							draw.WordBox(8,40,ScrH()/2,message,"Default",Color(50,50,75,100),Color(255,255,255,255));
						end
					end
				end
			end
		end
	end
);


local PANEL = {}

function PANEL:DoClick()
	local panel2=self:GetParent()
	LocalPlayer():ConCommand("setringname "..panel2.TextEntry:GetValue())
	panel2:Remove()
end

vgui.Register( "RingNameButtonCap", PANEL, "Button" )

local PANEL = {}
function PANEL:Init()
	self:SetSize(400,80)
	self:SetName( "Name" )
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
 	self.TextEntry.OnTextChanged = function(TextEntry)
 		local pos = TextEntry:GetCaretPos();
 		local len = TextEntry:GetValue():len();
		local letters = TextEntry:GetValue():gsub("[^0-9]",""):TrimExplode("");
		local text = ""; -- Wipe
		for _,v in pairs(letters) do
			if(not text:find(v)) then
				text = text..v;
			end
		end
		TextEntry:SetText(text);
		TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
	end

 	self.L1 = vgui.Create( "DLabel", self )
 	self.L1:SetText(SGLanguage.GetMessage("ring_name"))
 	self.L1:SetFont("OldDefaultSmall")

 	self.Button = vgui.Create( "RingNameButtonCap", self)
	self.Button:SetText("OK")

	self.Button:SetPos(325,39)
 	self.TextEntry:SetSize( 305, self.TextEntry:GetTall() )
 	self.TextEntry:SetPos( 10, 40 )
 	self.L1:SetPos( 30, 3 )
 	self.L1:SetSize( 400, 30 )
end

function PANEL:Paint(w,h)
	draw.RoundedBox( 10, 0, 0, w, h , Color(16,16,16,160) )
	return true
end

vgui.Register( "RingNameEntryCap", PANEL, "DFrame" )

function RingTransporterShowNameWindow(um)
	local Window = vgui.Create( "RingNameEntryCap" )
	Window:SetKeyBoardInputEnabled( true )
	Window:SetMouseInputEnabled( true )
	Window:SetPos( (ScrW()/2 - 350) / 2, ScrH()/2 - 75 )
	Window:SetVisible( true )
	local e = um:ReadEntity();
	if(not IsValid(e)) then return end;
	Window.TextEntry:SetText(e:GetNWString("address"));
end
usermessage.Hook("RingTransporterShowNameWindowCap", RingTransporterShowNameWindow)

-- Old method I don't like
--[[
local efa=0
local eff=1
local ef=-1
function RingTransporterCalcView(ply,origin,angles,fov)
	if ef==-1 then return end
	if ef==0 then
		eff=math.Clamp(eff+0.1,1,1.5)
	end
	if ef==1 then
		eff=math.Clamp(eff-0.01,1,1.5)
		if eff==1 then ef=-1 return end
	end
	local view={}
	view.origin=origin
	view.angles=angles
	view.fov=fov*eff
	return view
end
hook.Add("CalcView", "RingTransporterCalcView", RingTransporterCalcView)

function RingTransporterHUDPaint()
	if ef==-1 then return end
	if ef==0 then
		efa=math.Clamp(efa+100,0,255)
	end
	if ef==1 then
		efa=math.Clamp(efa-20,0,255)
	end
	surface.SetDrawColor(255,255,255,efa)
	surface.DrawRect(0,0,ScrW(),ScrH())
end
hook.Add("HUDPaint","RingTransporterHUDPaint",RingTransporterHUDPaint)
function RingTransporterTele(um)
	local stat=um:ReadBool()
	if stat==true then
		ef=0
		timer.Create("RingTeleSafeTimer", 10, 1, function() ef=1 end)
	else
		ef=1
	end
end
usermessage.Hook("RingTransporterTele", RingTransporterTele)
--]]

local start;
local alpha = 0;
local go;
hook.Add("HUDPaint","RingTransporterHUDPaint",
	function()
		if(not start) then return end;
		local rate = 2000;
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

usermessage.Hook("RingTransporterTele",
	function (data)
		go = data:ReadBool()
		start = CurTime();
		if(go) then timer.Create("RingTeleSafeTimer",5,1,function() start = nil end) end;
	end
);