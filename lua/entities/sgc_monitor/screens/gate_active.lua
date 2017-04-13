---------------------
-- Screen: IDC s1 --
-- Author: glebqip --
-- ID: 2 --
---------------------

local SCR = {
  Name = "Gate active",
  ID = 7,
}

if SERVER then
  function SCR:Initialize()
    self.SelfDestructState = 0
    self.SelfDestructCode = ""
    self.SelfDestructName = ""

    self.SelfDestructResetState = 0
    self.SelfDestructResetCode = ""
    self.SelfDestructResetName = ""
  end

  function SCR:Think(curr)
    local server = self.Entity.Server
    if self.SelfDestructDetect and CurTime()-self.SelfDestructDetect > 0.8 then
      if self.SelfDestructState == 2 then
        local good = false
        if not server.SelfDestruct then
          --Check for good code
          for k,v in pairs(server.SelfDestructCodes) do
            if tostring(k)==self.SelfDestructCode then
              self.SelfDestructName = v
              good = true
              break
            end
          end
        end
        if good and table.Count(server.SelfDestructCodes)>1 then
          --Check, that this code is not already entered
          for ent in pairs(server.SelfDestructClients) do
            if ent:GetNW2String("SDCode",0)==self.SelfDestructCode then
              good = false
              break
            end
          end
        end
        if good then
          server.SelfDestructClients[self.Entity] = true
          self.SelfDestructState = -1
        else
          self.SelfDestructState = -2
          self.SDOffTimer = CurTime()
        end
      end
      self.SelfDestructDetect = nil
    end
    if server.SelfDestruct and self.SelfDestructState ~= 0 then
      if self.Entity.Screen == 3 then
        self.Entity.Screen = 7
      end
      self.SelfDestructState = 0
    end
    if not server.SelfDestruct and self.SelfDestructResetState == 1 then
      if self.Entity.Screen == 7 then
        self.ResetTimer = CurTime()
        self.SelfDestructResetState = 3
        self:EmitSound("glebqip/self_destruct_off.wav",65,100,1)
      else
        self.SelfDestructResetState = 0
        self.SelfDestructResetCode = ""
      end
    end
    if self.ResetTimer and CurTime()-self.ResetTimer > 10 then
      self.ResetTimer = nil
      self.SelfDestructResetState = 0
      self.SelfDestructResetCode = ""
    end
    if self.SDOffTimer and CurTime()-self.SDOffTimer > 3 then
      self.SelfDestructState = 0
      self.SelfDestructCode = ""
      self.SDOffTimer = nil
    end
    self:SetMonitorInt("SDState",self.SelfDestructState)
    self:SetMonitorInt("SDRState",self.SelfDestructResetState)
    self:SetMonitorString("SDCode",self.SelfDestructCode)
    self:SetMonitorString("SDRCode",self.SelfDestructResetCode)
    self:SetMonitorString("SDName",self.SelfDestructName)
    self:SetMonitorString("SDRName",self.SelfDestructResetName)
  end
  function SCR:Trigger(curr,key,value)
    if self.Entity.Screen ~= 3 and self.Entity.Screen ~= 7 then
      self.SelfDestructState = 0
      self.SelfDestructCode = ""
      return
    end
    if IsValid(self.Entity.Keyboard) and key == self.Entity.Keyboard:GetRemappedKey(self.Entity.KeyD) and self.SelfDestructState!=-1 and value and not self.SDOffTimer then
      self.SelfDestructState = self.SelfDestructState == 0 and 1 or 0
      self.SelfDestructCode = ""
      return true
    end
    if self.SelfDestructState == 1 then
      if key == 127 and value then
        self.SelfDestructCode = self.SelfDestructCode:sub(1,-2)
      end
      local char = string.PatternSafe(string.char(key)):gsub("[^0-9]","")
      if char and value and #self.SelfDestructCode < 8 then
        self.SelfDestructCode = self.SelfDestructCode..char
      end
      if key == StarGate.KeyEnter and value and #self.SelfDestructCode >= 1 then
        self.SelfDestructState = 2
        self.SelfDestructDetect = CurTime()
        --self.SelfDestructEnterCode = false
      end
      return true
    elseif self.SelfDestructState == 2 then
      if key == StarGate.KeyEnter and value then
        self.SelfDestructCode = ""
        self.SelfDestructState = 0
      end
      return true
    elseif self.SelfDestructState == -1 then
      if key == StarGate.KeyEnter and value then
        self.SelfDestructCode = ""
        self.SelfDestructState = 0
      end
      return true
    end
    if self.Entity.Server.SelfDestruct then
      if key == 127 and value then
        self.SelfDestructResetCode = self.SelfDestructResetCode:sub(1,-2)
      end
      local char = string.PatternSafe(string.char(key)):gsub("[^0-9]","")
      if char and value and #self.SelfDestructResetCode < 8 then
        self.SelfDestructResetCode = self.SelfDestructResetCode..char
      end
      if key == StarGate.KeyEnter and value and #self.SelfDestructResetCode >= 1 then
        local server = self.Entity.Server
        local good = false
        --Check for good code
        for k,v in pairs(server.SelfDestructResetCodes) do
          if tostring(k)==self.SelfDestructResetCode then
            self.SelfDestructResetName = v
            good = true
            break
          end
        end
        if good and table.Count(server.SelfDestructResetCodes)>1 then
          --Check, that this code is not already entered
          for ent in pairs(server.SelfDestructClients) do
            if ent:GetNW2String("SDRCode",0)==self.SelfDestructResetCode then
              good = false
              break
            end
          end
        end
        if good then
          self.SelfDestructResetState = 1
          server.SelfDestructClients[self.Entity] = true
        else
          self.SelfDestructResetState = 0
          self.SelfDestructResetCode = ""
        end
      end
    end
  end
else

  function SCR:Bind()
    self:BindServerVar("Open","AnimA",function(ent,name,old,new)
      self.OpenCTimer = CurTime()
      self.Open = new
    end)
  end
  function SCR:Initialize(reinit)
    if not reinit then
      self.Digits1 = {}
      self.Digits1Timer = CurTime()-10
      self.Digits2 = {}
      self.Digits2Timer = CurTime()-10

      self.Digits3 = ""
      self.Digits3Timer = CurTime()-10

      self.Lines = {}
      self.LinesTimer = CurTime()-10
    end
    self.Open = self:GetServerBool("Open",false)
    self.OpenCTimer = CurTime()-10

    self.Matrix = Matrix()
  end

  local MainFrame = surface.GetTextureID("glebqip/active_screen_1/mainframe")
  local EnterCode = surface.GetTextureID("glebqip/active_screen_1/sd_entercode")

  local IDCLeft = surface.GetTextureID("glebqip/data_screen_1/main_left")
  local IDCRight = surface.GetTextureID("glebqip/data_screen_1/main_right")
  local GateFrame = surface.GetTextureID("glebqip/data_screen_1/gate_frame")

  local Gate = surface.GetTextureID("glebqip/data_screen_1/gate_back")
  local Ring = surface.GetTextureID("glebqip/dial_screen_1/ring")
  local RingArcs = surface.GetTextureID("glebqip/dial_screen_1/ringarcs")
  local Chevron = surface.GetTextureID("glebqip/dial_screen_1/chevron")
  local Chevron7 = surface.GetTextureID("glebqip/dial_screen_1/chevron7")
  local ChevronBox = surface.GetTextureID("glebqip/dial_screen_1/chevronbox")

  local OpenRed = surface.GetTextureID("glebqip/data_screen_1/openred")

  local BWCircle = surface.GetTextureID("glebqip/active_screen_1/circle")

  local Red = Color(239,0,0)

  function SCR:Draw(MainColor, SecondColor, ChevBoxesColor)
    local connected = self:GetServerBool("Connected",false)
    local open = connected and (self:GetServerBool("Open",false) or self:GetServerBool("SelfDestruct",false))
    local anim = self.StartAnim and CurTime()-self.StartAnim or 1.5
    local fanim1 = math.Clamp(anim*4,0,1)
    local fanim2 = math.Clamp((anim-0.25)*4,0,1)

      surface.SetDrawColor(MainColor)
      surface.SetTexture(MainFrame)
      surface.DrawTexturedRectRotated(256,192,512,512,0)
      draw.SimpleText("SYSTEMS", "Marlett_12", 459,219, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
      surface.SetDrawColor(Color(255,255,255))
      surface.SetTexture(BWCircle)
      for i=0,3 do
        surface.DrawTexturedRectRotated(437+i*15,153,13,13,(CurTime()%2*360))
      end
      render.SetScissorRect(18,56,18+32,120,true)
        local py = (CurTime()-self.Digits1Timer)%0.25*4-1
        if #self.Digits1 > 0 then
          for i=0,#self.Digits1-1 do
            if self.Digits1[i+1] then
              --SCR.drawText(92,97+(i+py)*9,Digits[i+1],0,1,SecondColor,font("Marlett",10))
              draw.SimpleText(self.Digits1[i+1], "Marlett_10", 20,54+(i+py)*9+2, SecondColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
          end
        end
      render.SetScissorRect(463,56,463+32,120,true)
        local py = (CurTime()-self.Digits2Timer)%0.25*4-1
        if #self.Digits2 > 0 then
          for i=0,#self.Digits2-1 do
            if self.Digits2[i+1] then
              --SCR.drawText(92,97+(i+py)*9,Digits[i+1],0,1,SecondColor,font("Marlett",10))
              draw.SimpleText(self.Digits2[i+1], "Marlett_10", 465,54+(i+py)*9+2, SecondColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
          end
        end
      render.SetScissorRect(185,327,327,341,true)
        local py = (CurTime()-self.Digits3Timer)%0.1*10-2
        for i=1,#self.Digits3 do
          draw.SimpleText(self.Digits3[i], "Marlett_15", 330-i*7-py*7-2,333, SecondColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
      render.SetScissorRect(23,153,23+56*(CurTime()-self.LinesTimer),308,true)
      surface.SetDrawColor(Color(0,133,44))
        --surface.SetDrawColor(Red)
        if connected then
          for i=0,#self.Lines do
            local x1 = 56/#self.Lines*i
            local x2 = 56/#self.Lines*(i+1)
            local y1 = self.Lines[i] or 0
            local y2 = self.Lines[i+1] or 0
            surface.DrawLine(23+x1,167+y1,23+x2,167+y2)
          end
        end
      render.SetScissorRect(0,0,0,0,false)
      if connected then
        for i=0,3 do
          surface.DrawRect(430+i*15,205,13,-44*(CurTime()%1))
        end
      end


      surface.SetDrawColor(Color(0,133,44))
      surface.DrawLine(23,167,23+56*math.Clamp((CurTime()-self.LinesTimer)*4,0,1),167)
      local code = self:GetMonitorString("SDRCode","")
      if #code > 0 then
        surface.SetDrawColor(Color(0,0,0))
        surface.DrawRect(166,325,180,16)
        surface.SetDrawColor(MainColor)
        surface.SetTexture(EnterCode)
        surface.DrawTexturedRectRotated(256,321,256,64,0)
        draw.SimpleText("ENTER CODE", "Marlett_29", 256,345, Color(100,35,15), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
      elseif self:GetServerBool("SelfDestruct",false) then
        draw.SimpleText("AUTODESTRUCT IN PROGRESS", "Marlett_21", 256,290, Color(215,75,35), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
      elseif open then
        draw.SimpleText("DEVICE ACTIVE", "Marlett_35", 256,290, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
      elseif not connected then
        draw.SimpleText("OFFLINE", "Marlett_35", 256,290, Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
      end
      for i=1,#code do
        draw.SimpleText(code[i], "Marlett_35", 126+i*29,329, Color(200,200,182), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      end
      if self:GetMonitorInt("SDRState",0) > 0 then
        surface.SetDrawColor(Color(20,200,20,150))
        surface.DrawRect(139,310,29.2*#code,36)
        local name = self:GetMonitorString("SDRName","")
        for i=1,#name do draw.SimpleText(name[i], "Marlett_12", 132+i*11,301, Color(200,200,182), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
      end

      surface.SetDrawColor(Color(54,66,11))
      local banim = 8-math.floor(CurTime()%2*10)
      if 0 <= banim and banim <= 8 then
        surface.DrawRect(95,61+banim*26.2,16,8)
        surface.DrawRect(401,61+banim*26.2,16,8)
      end
    render.SetScissorRect(0,0,0,0,false)
    local banim = 1-math.Clamp((anim-1)*2,0,1)----CurTime()%1.3/1.3
    surface.SetDrawColor(Color(0,0,0))
    surface.DrawRect(0,0,512,384*banim)

    surface.SetDrawColor(MainColor)
    surface.SetTexture(IDCLeft)
    surface.DrawTexturedRectRotated(127-fanim1*256,192,256,512,0)
    surface.SetTexture(IDCRight)
    surface.DrawTexturedRectRotated(380,303+256*fanim2,256,256,0)
    surface.SetTexture(GateFrame)
    surface.DrawTexturedRectRotated(380+fanim1*262,105,256,256,0)

    local manim = 1-math.Clamp((anim-0.5)*2,0,1)----CurTime()%1.3/1.3
    local scale = 1+(1-manim)*0.25
    self.Matrix = Matrix()
    self.Matrix:Translate(Vector(Lerp(manim,256,381),Lerp(manim,164,105),0))
    self.Matrix:Scale(Vector(scale,scale,scale))
    self.Matrix:Translate(Vector(0,0,0))
    cam.PushModelMatrix(self.Matrix)
    surface.SetTexture(Gate)
    surface.DrawTexturedRectRotated(0,0,256,256,0)
    surface.SetDrawColor(SecondColor)
    surface.SetTexture(RingArcs)
    surface.DrawTexturedRectRotated(0,0,196,196,0)
    surface.SetTexture(Ring)
    surface.DrawTexturedRectRotated(0,0,197,197,self:GetServerInt("RingAngle",0)-4.615)
    surface.SetTexture(OpenRed)
    if open then
      for i=0,(CurTime()-self.OpenCTimer > 2 and 2 or 0) do
        local anim = (CurTime()+i*2-self.OpenCTimer)%4
        if anim < 3 then
          surface.SetDrawColor(Red)
          surface.DrawTexturedRectRotated(0,0,256*anim/3,256*anim/3,0)
        elseif anim < 4 then
          surface.SetDrawColor(Color(220,0,0,(4-anim)*255))
          surface.DrawTexturedRectRotated(0,0,256,256,0)
        end
      end

      surface.SetDrawColor(Red)
      draw.DrawTLine(0,-74,0,74,2)
      draw.DrawTLine(-75,0,75,0,2)
    else
      surface.SetDrawColor(MainColor)
      draw.DrawTLine(0,-22,0,22,2)
      draw.DrawTLine(-22,0,22,0,2)
    end

    surface.SetDrawColor(SecondColor)

    local ChevronState = math.Clamp((CurTime()-self.OpenCTimer)*4,0,1)
    if not self:GetServerBool("Open") then ChevronState = 1-ChevronState end
    for i=1,9 do
      local ang = 180-(360/9)*i
      local rad = math.rad(ang)
      local X,Y = math.sin(rad)*(86-ChevronState*4.5), math.cos(rad)*(86-ChevronState*4.5)
      local X2,Y2 = math.sin(rad)*(93+ChevronState*4.5), math.cos(rad)*(93+ChevronState*4.5)
      local active = self:GetServerString("Chevrons")[i == 9 and 7 or i>5 and i-2 or i > 3 and i+4 or i] == "1"
      surface.SetDrawColor(active and Red or SecondColor)
      if i < 9 then
        surface.SetTexture(Chevron)
        surface.DrawTexturedRectRotated(0+X,0+Y,25,25,ang+180)
      else
        surface.SetTexture(Chevron7)
        surface.DrawTexturedRectRotated(0+X,0+Y,25,25,0)
      end
      surface.SetDrawColor(active and Red or ChevBoxesColor)
      surface.SetTexture(ChevronBox)
      surface.DrawTexturedRectRotated(0+X2,0+Y2,12,12,ang+180)
    end
    if self:GetServerBool("SelfDestruct",false) and anim > 2 then
      local time = math.abs(self:GetServerInt("SDTimer"))
      local str1 = string.format("%02d", math.floor(time/60))
      local str2 = string.format(".%02d",math.floor(time%60))
      draw.SimpleText(str1, "Marlett_45", 0-2,0, Color(255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
      draw.SimpleText(str2, "Marlett_45", -5,0, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    cam.PopModelMatrix()

    if self:GetMonitorInt("SDRState",0) > 1 then
      surface.SetDrawColor(255,255,255)
      surface.DrawRect(88,136,336,120)
      surface.SetDrawColor(220,84,45)
      surface.DrawRect(93,141,326,110)
      draw.SimpleText("DESTRUCT", "Marlett_50", 256,165, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.SimpleText("ABORTED", "Marlett_50", 256,208, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
  end

  function SCR:Think(curr)
    if not curr then
      if not self:GetServerBool("SelfDestruct",false) and self.StartAnim then
        self.StartAnim = nil
      end
      return
    end
    local connected = self:GetServerBool("Connected",false)
    local active = connected and self:GetServerBool("Active",false)
    local open = active and self:GetServerBool("Open",false)
    --self.Digits2 = {}
    if CurTime()-self.Digits1Timer > 0.25 then
      str = ""
      if connected then
        for _=1,7 do
          str = str..tostring(math.random(0,9))
        end
        table.insert(self.Digits1,1,str)
      else
        table.insert(self.Digits1,1,false)
      end
      table.remove(self.Digits1,10)
      self.Digits1Timer = CurTime()
    end
    if CurTime()-self.Digits2Timer > 0.25 then
      str = ""
      if connected then
        for _=1,7 do
          str = str..tostring(math.random(0,9))
        end
        table.insert(self.Digits2,1,str)
      else
        table.insert(self.Digits2,1,nil)
      end
      table.remove(self.Digits2,10)
      self.Digits2Timer = CurTime()
    end
    if connected then
      if CurTime()-self.Digits3Timer > 0.1 then
        self.Digits3 = tostring(math.random(0,9))..self.Digits3:sub(1,21)
        self.Digits3Timer = CurTime()
      end
      if CurTime()-self.LinesTimer > 1 then
        local maxval = math.Rand(3,13)
        for i=1,40 do
          if math.random() > 0.7 then
            maxval = math.Rand(0,13)
          end
          if i%2 > 0 then
            self.Lines[i] = math.Rand(-maxval/3,maxval)
          else
            self.Lines[i] = math.Rand(maxval/3,-maxval)
          end
        end
        self.LinesTimer = CurTime()
      end
    else
      if CurTime()-self.Digits3Timer > 0.1 then
        self.Digits3 = " "..self.Digits3:sub(1,21)
        self.Digits3Timer = CurTime()
      end
      if CurTime()-self.LinesTimer > 1 then
        local maxval = math.Rand(3,13)
        for i=1,40 do
          self.Lines[i] = nil
        end
        self.LinesTimer = CurTime()
      end
    end
    if self:GetServerBool("SelfDestruct",false) and not self.StartAnim then
      self.StartAnim = CurTime()
    end
    if curr and not self.StartAnim then
      self.StartAnim = CurTime()-3
    end
  end
end

return SCR
