include('shared.lua')

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("naquadah_bomb", SGLanguage.GetMessage("entity_naq_bomb"))
end

local cycleInterval = 0.5

function OnUserMessage(userMessage)
	local self = userMessage:ReadEntity()
	if (IsValid(self)) then
   	self.showCodeWindow = userMessage:ReadBool()
   end
end

function ENT:Initialize()
	self.DAmt=0
	self.RAmt=255

	self.showCodeWindow = false
end

function ENT:Draw()

	self.Entity:DrawModel()
	local pos = self.Entity:LocalToWorld(Vector(-7.5, 9.5, 25));
	local ang = self.Entity:GetAngles();


	if self.Entity:GetNetworkedBool("Hud", false) then

		if(self:GetModel()=="models/markjaw/gate_buster.mdl") then
			pos = self.Entity:LocalToWorld(Vector(-7.5, 9.5, 25));
			ang = self.Entity:GetAngles();
		elseif(self:GetModel()=="models/boba_fett/props/goauldbomb/goauldbomb.mdl") then
			pos = self.Entity:LocalToWorld(Vector(0,0,20));
			ang = self.Entity:GetAngles()+Angle(0,-90,0);
		elseif(self:GetModel()=="models/boba_fett/props/lucian_bomb/lucian_bomb.mdl") then
			pos = self.Entity:LocalToWorld(Vector(-5,0,52));
			ang = self.Entity:GetAngles()+Angle(0,-90,0);
		end

		ang:RotateAroundAxis(ang:Up(), 180)
		ang:RotateAroundAxis(ang:Forward(),	65)


		local str=self.Entity:GetNetworkedString("BombOverlay","")
		local time=self.Entity:GetNetworkedInt("BombOverlayTime",0)
		if time > 0 then str = str.."\n"..tostring(time); end
		surface.SetFont("SandboxLabel")
		local w,h=surface.GetTextSize(str)

		cam.Start3D2D(pos, ang, 0.05 )
			surface.SetDrawColor( 128, 128, 128, 200 )
			surface.DrawRect(0-w/2, 0, w, h)
			draw.DrawText(str, "SandboxLabel", 0, 0, Color(255,255,255,255), TEXT_ALIGN_CENTER )
		cam.End3D2D()

	end

end

usermessage.Hook("naquadah_bomb", OnUserMessage)

function ENT:Think()
   self:NextThink(CurTime() + cycleInterval)

   if(self.showCodeWindow == true) then
      self.showCodeWindow = false
      self:ShowCodeWindow()
   end

   return true
end

function ENT:ShowCodeWindow()
   local codeWindow = self:CreateCodeWindow()

   codeWindow:MakePopup()
end

function ENT:CreateCodeWindow()
   local ALIGN_RIGHT = 6
   local padding = 20

   local function GetRight(panel)
      return panel:GetPos() + panel:GetWide()
   end

   local CodeWindow = vgui.Create("DFrame")
   CodeWindow:SetDeleteOnClose(true)
   if (self:GetNWInt("State",0)==3) then
   	CodeWindow:SetTitle(SGLanguage.GetMessage("naq_bomb_menu_01a"))

   	CodeWindow.CodeBoxLabel = Label(SGLanguage.GetMessage("naq_bomb_menu_02a").." ", CodeWindow)
   else
   	CodeWindow:SetTitle(SGLanguage.GetMessage("naq_bomb_menu_01"))

   	CodeWindow.CodeBoxLabel = Label(SGLanguage.GetMessage("naq_bomb_menu_02").." ", CodeWindow)
   end
   CodeWindow.CodeBoxLabel:SetPos(padding, padding + 50)
   CodeWindow.CodeBoxLabel:SetContentAlignment(ALIGN_RIGHT)
   CodeWindow.CodeBoxLabel:SizeToContents()

   CodeWindow.CodeBox = vgui.Create("DTextEntry", CodeWindow)
   CodeWindow.CodeBox:SetPos(GetRight(CodeWindow.CodeBoxLabel) + padding, padding + 50)
   CodeWindow.CodeBox:SetWidth(100)
   CodeWindow.CodeBox:SetEditable(true)
   CodeWindow.CodeBox:SetEnterAllowed(true)
   CodeWindow.CodeBox.OnEnter = function()
		if (not IsValid(self)) then return end
      local playerDistance = self:GetPos():Distance(LocalPlayer():GetPos())

      if(playerDistance < 100) then
         if(self:GetNWInt("State", 1) ~= 3) then
            RunConsoleCommand("StartDetonation", self.Entity:EntIndex(), tostring(CodeWindow.CodeBox:GetValue()))
         else
            RunConsoleCommand("AbortDetonation", self.Entity:EntIndex(), tostring(CodeWindow.CodeBox:GetValue()))
         end
      else
         LocalPlayer():PrintMessage(HUD_PRINTCENTER, "You are too far away to enter the code.")
      end

      CodeWindow:Close()
   end

   local frameWidth = GetRight(CodeWindow.CodeBox) + padding
   local frameHeight = (padding * 2) + CodeWindow.CodeBox:GetTall() + 100

   CodeWindow:SetSize(frameWidth, frameHeight)
   CodeWindow:AlignBottom(200)
   CodeWindow:CenterHorizontal()

   CodeWindow.CodeBox:RequestFocus()

   return CodeWindow
end
