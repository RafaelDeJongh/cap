---------------------
-- Screen: Dial --
-- Author: glebqip --
-- ID: 1 --
---------------------
local SCR = {
  Name = "Dialing computer",
  ID = 1,
}
if SERVER then
  function SCR:Initialize()
    self.EnteredAddress = ""
  end

  function SCR:Think()
    self:SetMonitorString("EnteredAddress",self.EnteredAddress)
    if #self.EnteredAddress > 0 and self:GetServerBool("Active",false) then
      self.EnteredAddress = ""
    end
  end
  function SCR:Trigger(curr,key, value)
    if not curr or self:GetMonitorInt("SDState",0) ~= 0 then return end
    if self:GetMonitorBool("ServerConnected",false) then
       -- \, iris toggle
      if key == 92 and value then self.Entity.Server:ToggleIris() end
      -- Backspace, close gate
      if key == 127 and self:GetServerBool("Connected",false) and self:GetServerBool("Active",false) and value then self.Entity.Server.LockedGate:AbortDialling() end
    end
    --Reset error by pressing any key
    if self.Entity.Server.DCError ~= 0 and CurTime()-self.Entity.Server.DCErrorTimer > 2 and value then self.Entity.Server.DCError = 0 end
    if not self:GetServerBool("Active",false) then
      --Backspace,remove a 1 symbol
      if key == 127 and value then self.EnteredAddress = self.EnteredAddress:sub(1,-2) end
      --Any char, add a 1 symbol
      local char = string.PatternSafe(string.char(key)):gsub("[^%w%d#@*]","")
      if char and value and not self.EnteredAddress:find(char:upper()) and (#self.EnteredAddress < 6 and char ~= "#" or #self.EnteredAddress >= 6) and #self.EnteredAddress < 7 then
        self.EnteredAddress = self.EnteredAddress..char:upper()
      end
      --Enter, try dial or get error
      if key == StarGate.KeysConst[KEY_ENTER] and value and #self.EnteredAddress >=6 then
        if 6 <= #self.EnteredAddress and #self.EnteredAddress < 9 and self.EnteredAddress[#self.EnteredAddress] ~= "#" then
          self.EnteredAddress = self.EnteredAddress.."#"
        elseif #self.EnteredAddress > 6 then
          if #self.EnteredAddress > 7 and self:GetServerBool("Local",false) or not self:GetServerBool("HaveEnergy",false) then
            if not self:GetServerBool("HaveEnergy",false) then
              self.Entity.Server.DCError = 4
            else
              self.Entity.Server.DCError = 3
            end
            self.Entity.Server.ErrorAnim = false
            self.Entity.Server.DCErrorTimer = CurTime()+2
            self.Entity.Server.DialingAddress = self.EnteredAddress:sub(1,-2)
            self.Entity.Server.ErrorSymb = self.EnteredAddress:sub(-1,-1)
          else
            self.Entity.Server:Dial(self.EnteredAddress)
          end
          self.EnteredAddress = ""
        end
      end
    end
  end
else
  local MainFrame = surface.GetTextureID("glebqip/dial_screen_1/mainframe")
  local Boxes = surface.GetTextureID("glebqip/dial_screen_1/boxes")
  local Ring = surface.GetTextureID("glebqip/dial_screen_1/ring")
  local RingArcs = surface.GetTextureID("glebqip/dial_screen_1/ringarcs")
  local Chevron = surface.GetTextureID("glebqip/dial_screen_1/chevron")
  local Chevron7 = surface.GetTextureID("glebqip/dial_screen_1/chevron7")
  local ChevronBox = surface.GetTextureID("glebqip/dial_screen_1/chevronbox")
  local Gradient = surface.GetTextureID("vgui/gradient_down")
  local Red = Color(239,0,0)

  function SCR:Bind()
    self:BindServerVar("Open","AnimDC",function(ent,name,old,new)
      self.OpenCTimer = CurTime()
      self.Open = new
    end)
  end

  function SCR:Initialize(reinital)
    -- Blinking boxes
    self.Boxes1 = {}
    self.Boxes2 = {}
    self.Boxes1Timer = CurTime()-10
    self.Boxes2Timer = CurTime()-10

    --Gradient anim boxes
    self.GradientsTimers = {}
    self.GradientSpeeds = {}

    --Random digits
    self.Digits = {}
    self.DigitsTimer = CurTime()-10
    local connected = self:GetServerBool("Connected",false)
    local active = self:GetServerBool("Active",false)
    if connected and active then
      for i=1,13 do
        local str = ""
        local typ = math.random()>0.3
        for _=math.random(2,4),math.random(6,11) do
          if typ then
            str = str..tostring(math.random(0,9))
          else
            str = str..tostring(math.random(0,1))
          end
        end
        table.insert(self.Digits,1,str)
      end
    end
    --Chevron open animation
    self.OpenCTimer = CurTime()-10
    self.Open = self:GetServerBool("Open",false)
    --Dial symbol animation
    self.SymbolAnim = nil
    self.SymbolAnim2 = nil
    --End timer
    self.EndTimer = nil
    for i=1,9 do
      self.GradientSpeeds[i] = math.Rand(0.4,0.8)
      self.GradientsTimers[i] = CurTime()-self.GradientSpeeds[i]/math.random()
    end

    self.OldDialingAddress = self:GetServerString("DialingAddress","")

    self.Matrix = Matrix()
    self.Dialed = false
    self.Locked = false
    self.LastDialSymb = ""
    self.ErrorTimer = nil

    self.Timer8 = nil
  end


  local function AnimFromToXY(srcx,srcy,targetx,targety,state)
    return Lerp(state,srcx,targetx), Lerp(state,srcy,targety)
  end

  function SCR:Draw(MainColor, SecondColor, ChevBoxesColor)
    local Alpha = math.abs(math.sin(CurTime()*math.pi/2))
    local dialadd = self:GetServerString("DialingAddress","")
    if self.SymbolAnim2 and (CurTime()-self.SymbolAnim2) > 0.6 then dialadd = dialadd..self:GetServerString("DialingAddressDelta","") end
    if dialadd == "" then
      dialadd = self:GetMonitorString("EnteredAddress","")
    end
    if self.Error ~= 0 and self.ErrorSymbol ~= "" then
      dialadd = dialadd.." "
    end
    local NLocal = not self:GetServerBool("Local",false) or #self:GetMonitorString("EnteredAddress","") == 8 or self.Error == 3 or #dialadd == 8
    surface.SetDrawColor(MainColor)
    surface.SetTexture(MainFrame)
    surface.DrawTexturedRectRotated(256,192,512,512,0)

    surface.SetTexture(Gradient)
    for i=0,8 do
      local state = (CurTime() - self.GradientsTimers[i+1])/self.GradientSpeeds[i+1]
      if state < 1 then
        local size = math.min(1,state*1.4)*45
        local alpha = 1-math.max(0,state*1.4-1)*2.5
        surface.SetDrawColor(MainColor.r,MainColor.g,MainColor.b,alpha*255)
        render.SetScissorRect( 10 + i*17,344,10 + i*17+14,344-size, true )
          surface.DrawTexturedRect(10 + i*17,299 + 0,14,47)
        render.SetScissorRect(0,0,0,0,false)
        --surface.SetDrawColor(0,0,0,alpha*255)
        --surface.DrawRect(10 + i*17,299,14,45-size)
      end
    end
    surface.SetAlphaMultiplier(1)

    surface.SetDrawColor(SecondColor)
    surface.SetTexture(RingArcs)
    surface.DrawTexturedRectRotated(257,166,256,256,0)
    surface.SetTexture(Ring)
    surface.DrawTexturedRectRotated(257,166,256,256,self:GetServerInt("RingAngle",0)-4.615)

    for i=1,36 do
      if self.Boxes2[i] then
        local x,y = 0,0
        if i > 18 then x = 34 end
        if i > 9 and i < 19 or i > 27 then y = 32 end
        if self.Boxes2[i] then
          surface.DrawRect(24+i%3*6+x,229+math.ceil(i/3-1)%3*6+y,4,4)
        end
      end
    end

    surface.SetDrawColor(MainColor)
    for i=0,12 do
      if self.Digits[13-i] then
        draw.SimpleText(self.Digits[13-i], "Marlett_15", 87, 45+i*13, MainColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
      end
    end

    surface.SetDrawColor(color_white)
    for i=1,24 do
      if self.Boxes1[i] then
        surface.DrawRect(171+i%8*8,298+math.ceil(i/8-1)*16,6,15)
      end
    end

    surface.SetDrawColor(MainColor)
    surface.SetTexture(Boxes)
    surface.DrawTexturedRectRotated(202,322,128,64,0)

    local ChevronState = math.Clamp((CurTime()-self.OpenCTimer)*4,0,1)
    if self.Error ~= 0 then
      ChevronState = math.max(1-ChevronState,0.6-(CurTime()-self.ErrorStart))
    end
    if not self:GetServerBool("Open") then ChevronState = 1-ChevronState end
    for i=1,9 do
      local ang = 180-(360/9)*i
      local rad = math.rad(ang)
      local X,Y = math.sin(rad)*(113-ChevronState*6), math.cos(rad)*(113-ChevronState*6)
      local X2,Y2 = math.sin(rad)*(122+ChevronState*6), math.cos(rad)*(122+ChevronState*6)
      local active = self:GetServerString("Chevrons","")[i == 9 and 7 or i>5 and i-2 or i > 3 and i+4 or i] == "1" or self.Error ~= 0
      surface.SetDrawColor(active and Red or SecondColor)
      if i < 9 then
        surface.SetTexture(Chevron)
        surface.DrawTexturedRectRotated(257+X,166+Y,32,32,ang+180)
      else
        surface.SetTexture(Chevron7)
        surface.DrawTexturedRectRotated(257+X,166+Y,32,32,0)
      end
      surface.SetDrawColor(active and Red or ChevBoxesColor)
      surface.SetTexture(ChevronBox)
      surface.DrawTexturedRectRotated(257+X2,166+Y2,16,16,ang+180)
    end
    surface.SetDrawColor(MainColor)
    if NLocal then
      local tm8 = self.Timer8 and math.min(1,CurTime()-self.Timer8)*3
      if not tm8 or tm8 < 1 then
        for i=1,7 do
          local state = (CurTime() - self.GradientsTimers[i+1])/self.GradientSpeeds[i+1]
          if state < 1 then
            local size = math.min(1,state*1.4)*40
            local alpha = 1-math.max(0,state*1.4-1)*2.5
            surface.SetDrawColor(MainColor.r,MainColor.g,MainColor.b,alpha*255)
            surface.DrawTexturedRect(437 + i*8-4,309 + (40-size),14,size)
          end
        end
        if tm8 then
          surface.SetDrawColor(color_black)
          surface.DrawRect(440, 35+7*39+40, 64, -40*tm8)
        end
      end
      surface.SetDrawColor(MainColor)
      for i=0,7 do
        draw.OutlinedBox(440, 35+i*39, 64, 40, 2)
      end
    else
      for i=0,6 do
        draw.OutlinedBox(440, 37+i*43, 64, 40, 2)
      end
    end

    if self.Movie and self.EndTimer and (CurTime()-self.EndTimer)%0.6 > 0.3 then
      for i=0,#dialadd-1 do
        surface.SetDrawColor(MainColor)
        if NLocal then surface.DrawRect(439,35+i*39,65,41) else surface.DrawRect(439,37+i*43,65,41) end
      end
    end

    if not self:GetServerBool("Inbound",false) then
      local color = color_white
      if self.Error ~= 0 then
        local anim = math.max(0,0.6-(CurTime()-self.ErrorStart))
        color = Color(Red.r+255-Red.r,255*anim,255*anim)
      end
      for i=0,#dialadd do
        if NLocal then
          draw.SimpleText(dialadd[i+1], "SGC_SG1", 472,56+i*39, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
          draw.SimpleText(dialadd[i+1], "SGC_SG1", 472,58+i*43, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
      end
    end

    if not self.Movie and self.EndTimer then
      local anim = math.abs(math.sin((CurTime()-self.EndTimer)%0.4/0.4*math.pi))*240---EndTimer
      for i=0,#dialadd-1 do
        surface.SetDrawColor(Color(12,96,104,math.min(255,anim)))
        if NLocal then surface.DrawRect(439,35+i*39,65,41) else surface.DrawRect(439,37+i*43,65,41) end
      end
    end

    surface.SetAlphaMultiplier(1)

    for i=1,#dialadd + (self.Timer8 and #dialadd < 8 and 1 or 0) do
      if NLocal then
        local tm8 = self.Timer8 and math.min(1,CurTime()-self.Timer8)*3
        draw.SimpleText(i, "Marlett_29", 436,15+i*39, i == 8 and tm8 and Red or SecondColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        if i == 8 and tm8 and tm8 < 1 then
          surface.SetDrawColor(color_black)
          surface.DrawRect(420, 4+8*39, 20, 20-20*tm8)
        end
      else
        draw.SimpleText(i, "Marlett_25", 436,33+i*43, SecondColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
      end
    end

    surface.SetDrawColor(color_white)
    --local OpenChev = CurTime()%2
    if self.SymbolAnim or self.SymbolAnim2 or self.Error ~= 0 then
      local x,y,scale = 0,0,0
      local symbol = ""
      local alpha = 0
      local Sm2 = self.SymbolAnim2 and (CurTime()-self.SymbolAnim2) < 0.6
      local color = color_white
      local xb,yb,wb,hb
      if Sm2 then
        local anim = math.min(1,(CurTime()-self.SymbolAnim2)*1.66)
        if NLocal then
          x,y = AnimFromToXY(258,167,472,17+39*(#dialadd+1),anim)
        else
          x,y = AnimFromToXY(258,167,472,15+43*(#dialadd+1),anim)
        end
        scale = 2.4-(anim*2.4)/90*76
        symbol = self:GetServerString("RingSymbol","")
        local xanim = 1-anim*0.8
        local yanim = 1-anim*0.842
        alpha = math.max(0,xanim)
        xb,yb = -325/2*xanim + (1-xanim)*1 + x, -256/2*yanim + y
        wb,hb = 325*xanim,257*yanim
      elseif self.SymbolAnim then
        local anim = math.min(1,(CurTime()-self.SymbolAnim)*1.5)
        x,y = 258, Lerp(anim,59,165)
        x,y = 258,59+anim*106
        scale = anim*2.4
        symbol = self:GetServerString("DialingSymbol","")
        alpha = anim
        xb,yb,wb,hb = -325/2*anim+x,-257/2*anim+y+1,325*anim,257*anim
      end
      if self.Error ~= 0 then
        x,y = 258,59+106
        scale = 2.4
        symbol = self.ErrorSymbol
        color = Red or Color(165,72,45)
        alpha = 1
        local timer = CurTime() - self.ErrorTimer
        if timer > 0 then
          surface.SetDrawColor(color_black)
          surface.DrawRect(x-100,y+75,200,50,2)
          surface.SetDrawColor(color)
          draw.OutlinedBox(x-100,y+75,200,50,2)
          if math.abs(self.Error) == 1 then
            draw.SimpleText("DIAL ERROR", "Marlett_Err", x,y+85, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("LINE 352", "Marlett_Err", x,y+85+15, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("\"NOT FOUND\"", "Marlett_Err", x,y+85+30, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          elseif math.abs(self.Error) == 2 then
            draw.SimpleText("DIAL ERROR", "Marlett_Err", x,y+85, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("LINE 352", "Marlett_Err", x,y+85+15, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("\"OCCUPIED\"", "Marlett_Err", x,y+85+30, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          elseif self.Error == 3 then
            draw.SimpleText("FATAL ERROR", "Marlett_Err", x,y+85, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("LINE 230", "Marlett_Err", x,y+85+15, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("\"DATA PARSE FAILURE\"", "Marlett_Err", x,y+85+30, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          elseif self.Error == 4 or math.abs(self.Error) == 5 then
            draw.SimpleText("FATAL ERROR", "Marlett_Err", x,y+85, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("LINE 152", "Marlett_Err", x,y+85+15, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("\"LOW ENERGY INPUT\"", "Marlett_Err", x,y+85+30, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          end
        elseif timer < 0 then
          local anim = math.Clamp(-timer*1.66,0,1)
          local animC = math.max(0,0.6-(CurTime()-self.ErrorStart))
          if NLocal then
            x,y = AnimFromToXY(258,167,472,17+39*(#dialadd),anim)
          else
            x,y = AnimFromToXY(258,167,472,15+43*(#dialadd),anim)
          end
          scale = 2.4-(anim*2.4)/90*76
        end
      end
      self.Matrix = Matrix()
      self.Matrix:Translate(Vector(x,y,0))
      self.Matrix:Scale(Vector(scale,scale,scale))
      self.Matrix:Translate(Vector(0,0,0))
      --surface.SetAlphaMultiplier(alpha)
      if xb then
        if self.Movie then
          surface.SetDrawColor(Color(239,50,50,alpha*255))
          surface.DrawOutlinedRect(xb,yb,wb,hb)
          surface.SetDrawColor(Color(255,255,255,alpha*255))
        else
          surface.SetDrawColor(Color(255,255,255,alpha*255))
          draw.OutlinedBox(xb,yb,wb,hb,2)
        end
      end
      --surface.SetAlphaMultiplier(1)
      cam.PushModelMatrix(self.Matrix)
        draw.SimpleText(symbol, "SGC_Symb", 0,0, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      cam.PopModelMatrix()
    end

    surface.SetDrawColor(MainColor)
    surface.SetAlphaMultiplier(Alpha)
    --local MainColorA = Color(MainColor.r,MainColor.g,MainColor.b,Alpha)
    if self.Error ~= 0 then
      surface.SetDrawColor(Red)
      surface.DrawRect(246,296,172,7)
      draw.SimpleText("ERROR", "Marlett_Error", 330,317+5, Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      surface.DrawRect(246,340,172,7)
    elseif self:GetServerBool("Inbound",false) then
      surface.SetDrawColor(Red)
      surface.DrawRect(97,39,38,38)
      surface.DrawRect(97,254,38,38)
      surface.DrawRect(380,39,38,38)
      surface.DrawRect(380,254,38,38)
      --surface.drawText(328,310,"OFFWORLD",1,1, red,font("Marlett",27))
      --surface.drawText(328,332,"ACTIVATION",1,1, red,font("Marlett",29))
      draw.SimpleText("OFFWORLD", "Marlett_27", 328,310, Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.SimpleText("ACTIVATION", "Marlett_29", 328,332, Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    elseif self:GetServerBool("Open",false) then
      surface.SetDrawColor(Red)
      surface.DrawRect(246,296,168,9)
      draw.SimpleText("LOCKED", "Marlett_Open", 330,317+5, Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      surface.DrawRect(246,338,168,9)
    elseif self:GetServerBool("ChevronLocked",false) then
      draw.SimpleText("SEQUENCE", "Marlett_22", 328,311, MainColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.SimpleText("COMPLETE", "Marlett_27", 328,331, MainColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    elseif self:GetServerBool("Active",false) then
      draw.SimpleText("SEQUENCE", "Marlett_25", 328,311, MainColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.SimpleText("IN PROGRESS", "Marlett_25", 328,331, MainColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    elseif self:GetServerBool("Connected",false) then
      draw.SimpleText("IDLE", "Marlett_22", 238,297, MainColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    else
      draw.SimpleText("DISCONNECTED", "Marlett_22", 328,320, Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    local entereda = self:GetMonitorString("EnteredAddress","")
    if #entereda == 9 or #entereda > 6 and entereda[#entereda] == "#" then
      --TODO
    end
  end

  function SCR:Think(curr)
    local connected = self:GetServerBool("Connected",false)
    local active = self:GetServerBool("Active",false)
    local open = self:GetServerBool("Open",false)
    local inbound = self:GetServerBool("Inbound",false)
    local chevron = self:GetServerInt("Chevron",0)
    local locked = self:GetServerBool("ChevronLocked",false)
    if not curr then return end
    self.Movie = self:GetServerBool("IsMovie",false)
    if CurTime()-self.Boxes1Timer > 0.5 and connected then
      for i=1,24 do
        self.Boxes1[i] = math.random()>0.6
      end
      if self.Movie then
        self.Boxes1Timer = CurTime()-0.25
      else
        self.Boxes1Timer = CurTime()
      end
    end
    if CurTime()-self.Boxes2Timer > 0.15 and connected then
      for i=1,36 do
        self.Boxes2[i] = math.random()>0.4
      end
      self.Boxes2Timer = CurTime()
    end

    if CurTime()-self.DigitsTimer > 0.15 then
      if connected and active and math.random()>0.15 then
        local str = ""
        if math.random() > 0.8 then
          self.DigitsType = math.random()>0.5
        end
        if not self.Movie or self.DigitsType then
          for _=math.random(2,4),math.random(6,11) do
            if self.DigitsType then
              str = str..tostring(math.random(0,9))
            else
              str = str..tostring(math.random(0,1))
            end
          end
        else
          local char = tostring(math.random(0,1))
          for _=1,11 do str = str..char end
        end
        table.insert(self.Digits,1,str)
      else
        table.insert(self.Digits,1,false)
      end
      table.remove(self.Digits,14)
      if self.Movie then
        self.DigitsTimer = CurTime()-0.05
      else
        self.DigitsTimer = CurTime()
      end
    end

    for i=1,9 do
      if CurTime() - self.GradientsTimers[i] > self.GradientSpeeds[i] and active and (inbound or open or self:GetServerBool("RingRotation",false)) then
        self.GradientSpeeds[i] = math.Rand(0.4,0.7)
        self.GradientsTimers[i] = CurTime()
      end
    end

    local dialadd = self:GetServerString("DialingAddress","")
    if self.SymbolAnim2 and (CurTime()-self.SymbolAnim2) > 0.6 then dialadd = dialadd..self:GetServerString("DialingAddressDelta","") end
    local dialsymb = self:GetServerString("DialingSymbol","")
    local dialdsymb = self:GetServerString("DialedSymbol","")
    local ringsymb = self:GetServerString("RingSymbol","")
    local ringrot = self:GetServerBool("RingRotation",false)
    self.Error = self:GetServerInt("DCError",0)
    self.ErrorSymbol = self:GetServerString("DCErrorSymbol","")
    if self.Error ~= 0 and not self.ErrorTimer then -- we fail dial
      self.ErrorTimer = CurTime()
      self.ErrorStart = self.ErrorTimer
      if self.Error < 0 then
        self.ErrorTimer = CurTime()+0.6
        --self:EmitSound("glebqip/dial_chevron_encode.wav",65,100,0.8)
      elseif self.Error >= 3 then
        self.ErrorTimer = CurTime()+2
        self:EmitSound("glebqip/error_start.wav",65,100,0.6)
      else
        self.Error1Played = true
      end
    elseif self.Error == 0 and self.ErrorTimer then
      self.ErrorTimer = nil
      self.ErrorStart = nil
    end
    if self.Error ~= 0 and self.ErrorTimer and CurTime() - self.ErrorTimer > 0 and not self.Error2Played then
      self:EmitSound("glebqip/error_end.wav",65,100,0.6)
      self.Error2Played = true
    end
    if self.Error ~= 0 and self.ErrorTimer and CurTime() - self.ErrorTimer > -0.6 and not self.Error1Played then
      self:EmitSound("glebqip/dial_chevron_encode2.wav",65,100,1)
      self.Error1Played = true
    end
    if (self.Error1Played or self.Error2Played) and self.Error == 0 then
      self.Error1Played = false
      self.Error2Played = false
    end

    if self:GetServerBool("ChevronFirst", false) and not self.SymbolAnim then
      self.SymbolAnim = CurTime()
      if self.Movie then
        self:EmitSound("glebqip/f_chevron_encode.wav",65,100,0.6)
      else
        self:EmitSound("glebqip/dial_chevron_encode2.wav",65,100,1)
      end
      --self:EmitSound("alexalx/glebqip/dp_locking.wav",65,100,0.8)
    elseif not self:GetServerBool("ChevronFirst", false) and self.SymbolAnim then
      self.SymbolAnim = nil
    end
    if self:GetServerBool("ChevronSecond", false) and not self.SymbolAnim2 then
      self.SymbolAnim2 = CurTime()
      if not self.Movie then
        self:EmitSound("glebqip/dial_chevron_encode2.wav",65,100,1)
      end
    elseif not self:GetServerBool("ChevronSecond", false) and self.SymbolAnim2 then
      self.SymbolAnim2 = nil
    end

    if self.OldDialingAddress ~= dialadd then
      if #self.OldDialingAddress < #dialadd and chevron ~= 0 and not inbound then
        if self.Movie then
          self:EmitSound("glebqip/f_chevron_lock.wav",65,100,0.6)
          self.Digits = {}
          self.DigitsTimer = CurTime()
        else
          self:EmitSound("glebqip/dial_chevron_beep2.wav",65,100,0.8)
        end
      end
      self.OldDialingAddress = dialadd
    end
    if self.Movie then
      local endT = self.EndTimer and (CurTime()-self.EndTimer)%0.6 > 0.3
      if self.OldLocked ~= endT then
        if endT then self:EmitSound("glebqip/f_complete.wav",65,100,0.6) end
        self.OldLocked = endT
      end
    else
      local endT = self.EndTimer and (CurTime()-self.EndTimer)%0.4 > 0.2
      if self.OldLocked ~= endT then
        if endT then self:EmitSound("alexalx/glebqip/dp_lock.wav",65,100,0.8) end
        self.OldLocked = endT
      end
    end
    local LastSecond = active and not open and not inbound and locked and (not self.SymbolAnim2 or (CurTime()-self.SymbolAnim2) > 0.6)
    if LastSecond then
      if self.EndTimer == nil then
        if self.Movie then
          self.EndTimer = CurTime()
        else
          self.EndTimer = CurTime()-0.2
        end
      end
    end
    if self.EndTimer ~= nil and (open or not active or inbound) then
      self.EndTimer = nil
    elseif self.EndTimer and CurTime()-self.EndTimer > 1.2 then
      self.EndTimer = false
    end
    --SG1 The fifth race series 8 chevron anim
    if not self:GetServerBool("Local",false) and not inbound and (#dialadd == 7 and not self:GetServerBool("LastChev",false) or #dialadd > 7) and not self.Timer8 then
      self.Timer8 = CurTime()
    end
    if (self:GetServerBool("Local",false) or #dialadd < 7 or inbound) and self.Timer8 then
      self.Timer8 = false
    end
  end
end

return  SCR
