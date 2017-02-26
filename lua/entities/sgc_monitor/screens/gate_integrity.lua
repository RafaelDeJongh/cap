---------------------
-- Screen: IDC s1 --
-- Author: glebqip --
-- ID: 2 --
---------------------

local SCR = {
  Name = "Gate integrity monitor",
  ID = 4,
}

if SERVER then
  function SCR:Initialize()
  end

  function SCR:Think(curr)
  end
  function SCR:Trigger(curr,key,value)
  end
else
  function SCR:Initialize(reinit)
    self.Boxes = {}
    self.BoxesTimer = CurTime()

    self.Digits = {}
    self.DigitsTimer = CurTime()

    self.Lines = {}
    self.LinesState = 0
    self.LinesTimer = CurTime()
    self.Matrix = Matrix()
    if not reinit then
      self.WarnPlayed = true
      self.Warn = 0
      self.WarnState = false
      self.WarnTimer = CurTime()-10


      self.AnalyzingCode = {}
      self.AnalyzedCode = {}
      self.State = 0
      self.CodeState = 0
    end
  end

  local MainFrame = surface.GetTextureID("glebqip/integrity_screen_1/mainframe")
  local CodeRes = surface.GetTextureID("glebqip/integrity_screen_1/code_response")

  local WarnIncom = surface.GetTextureID("glebqip/integrity_screen_1/warn_incomming")
  local WarnRec = surface.GetTextureID("glebqip/integrity_screen_1/warn_receive")
  local WarnAcc = surface.GetTextureID("glebqip/integrity_screen_1/warn_accept")
  local WarnExp = surface.GetTextureID("glebqip/integrity_screen_1/warn_expired")
  local WarnErr = surface.GetTextureID("glebqip/integrity_screen_1/warn_error")

  --local Gradient = surface.GetTextureID("vgui/gradient_down")
  local CenterGrad = surface.GetTextureID("gui/center_gradient")

  local Red = Color(239,0,0)

  function SCR:Draw(MainColor, SecondColor, ChevBoxesColor)
    surface.SetDrawColor(MainColor)
    surface.SetTexture(MainFrame)
    surface.DrawTexturedRectRotated(256,192,512,512,0)
    if self.WarnState and self.Warn == 1 then
      surface.SetDrawColor(196,33,33)
      draw.DrawTLine(0,3,512,3,8)
      draw.DrawTLine(0,0,0,384,8)
      draw.DrawTLine(0,381,512,381,8)
      draw.DrawTLine(514,0,514,384,8)
    end
    surface.SetDrawColor(SecondColor)
    for i=1,36 do
      if self.Boxes[i] then
        local x,y = 0,0
        if i > 18 then x = 26 end
        if i > 9 and i < 19 or i > 27 then y = 26 end
        surface.DrawRect(21+i%3*5+x,305+math.ceil(i/3-1)%3*5+y,3,3)
      end
    end

    draw.SimpleText("SIGNAL DATA", "Marlett_21", 305, 32, SecondColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    draw.SimpleText("DECODING", "Marlett_16", 305, 38, SecondColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    local py = (CurTime()-self.DigitsTimer)%0.1*10-1
    render.SetScissorRect(306 ,45,493,205,true)
      if #self.Digits > 0 then
        for i=0,#self.Digits-1 do
          if self.Digits[i+1] then
            draw.SimpleText(self.Digits[i+1], "Marlett_10", 306,49+(i+py)*9, SecondColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
          end
        end
      end
    render.SetScissorRect(0,0,0,0,false)

    if self.State > 0 and self.State < 3 then
      local oldx = 0
      local oldy = 0
      local max = self.State == 1 and math.min(1,(CurTime()-self.LinesTimer)*3) or 1
      render.SetScissorRect(240,217,240+265*max,309,true)
        for i=1,#self.Lines do
          local x1 = oldx--269/#self.Lines*i
          local x2 = math.floor(263/#self.Lines*(i+1)); oldx = x2
          local y1 = oldy--self.Lines[i] or 0
          local y2 = math.floor(self.Lines[i+1] or 0) ;oldy = y2

          if self.State == 2 and ((CurTime()-self.LinesTimer) >= (i/#self.Lines)*2) then
            surface.SetDrawColor(Color(184,100,85))
          else
            surface.SetDrawColor(Color(114,99,84))
          end
          --draw.DrawTLine(240+x1,263+y1,238+x2,263+y2,2)
          surface.DrawLine(240+x1,263+y1,240+x2,263+y2)
        end
        if self.State == 2 and self.LinesTimer and (CurTime()-self.LinesTimer) < 2.14 then
          surface.SetDrawColor(Color(100,190,120))
          surface.SetTexture(CenterGrad)
          surface.DrawTexturedRect(243+(CurTime()-self.LinesTimer)/2*259,216,10,94,0)
            render.SetScissorRect(306 ,45,493,205,true)
          surface.DrawTexturedRect(305,196-(CurTime()-self.LinesTimer)/2*150,189,10,0)
        end
      render.SetScissorRect(0,0,0,0,false)
    end
    if self.State >= 3 then
      surface.SetDrawColor(MainColor)
      surface.SetTexture(CodeRes)
      surface.DrawTexturedRectRotated(372,262,256,128,0)
      for i=1,14 do
        if not self.AnalyzedCode[i] then continue end
        draw.SimpleText(self.AnalyzedCode[i], "Marlett_35", 264+(i-1)%7*36, 247+math.ceil(i/7-1)*41, Color(57,153,87), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      end
    end
    if self.State == 1 then
      surface.SetAlphaMultiplier(math.abs(math.sin(CurTime()*math.pi)))
      draw.SimpleText("UNAUTHORIZED", "Marlett_29", 373, 330, SecondColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.SimpleText("ACTIVATION", "Marlett_29", 373, 355, SecondColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      surface.SetAlphaMultiplier(1)
    elseif self.State == 2 then
      draw.SimpleText("ANALYZING", "Marlett_29", 373, 330, SecondColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.SimpleText("SIGNAL", "Marlett_29", 373, 355, SecondColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    elseif self.State >= 3 then
      draw.SimpleText("SIGNAL", "Marlett_29", 373, 330, SecondColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.SimpleText("ANALYZED", "Marlett_29", 373, 355, SecondColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local anim = self.WarnTimer and math.Clamp((CurTime()-self.WarnTimer)*8,0,1) or 1
    local scale = self.WarnState and anim or 1-anim
    if self.WarnState or scale > 0 then
      if self.Warn == 1 then
        surface.SetTexture(WarnIncom)
      elseif self.Warn == 2 then
        surface.SetTexture(WarnRec)
      elseif self.Warn == 3 then
        surface.SetTexture(WarnAcc)
      elseif self.Warn == 4 then
        surface.SetTexture(WarnExp)
      elseif self.Warn == 5 then
        surface.SetTexture(WarnErr)
      end
      self.Matrix = Matrix()
      self.Matrix:Translate(Vector(373,108,0))
      self.Matrix:Scale(Vector(scale,scale,scale))
      self.Matrix:Translate(Vector(0,0,0))
      cam.PushModelMatrix(self.Matrix)
        surface.SetDrawColor(Color(255,255,255))
        surface.DrawTexturedRectRotated(0,0,512,256,0)
        if self.Warn == 3 or self.Warn == 4 then
          draw.SimpleText(self:GetServerString("IDCName",""), "Marlett_29", 0, 20, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
      cam.PopModelMatrix()
    end
  end

  function SCR:Think(curr)
    if not curr then return end
    local connected = self:GetServerBool("Connected",false)
    local state = self:GetServerInt("IDCState",0)
    if CurTime()-self.BoxesTimer > 0.15 and connected then
      for i=1,36 do
        self.Boxes[i] = math.random()>0.4
      end
      self.BoxesTimer = CurTime()
    end
    if CurTime()-self.DigitsTimer > 0.1 then
      if connected and self:GetServerBool("Inbound",false) then
        str = ""
        for _=1,math.random(15,37) do
          str = str..string.format("%X",math.random(0,15))
        end
        table.insert(self.Digits,1,str)
      else
        table.insert(self.Digits,1,false)
      end
      table.remove(self.Digits,20)
      self.DigitsTimer = CurTime()
    end

    if self.State ~= state then
      self.State = state
      if self.State == 1 then
        local code = self:GetServerString("IDCCode","")
        for i=1,200 do
          local symb = (tonumber(code[math.ceil(i/200*14)]) or 0)/10
          local maxval = (1+44*symb)*(i%2 == 0 and -1 or 1)
          self.Lines[i] = math.Rand(maxval/4,maxval)
        end
      end
      self.LinesTimer = CurTime()
      if self.State == 2 then
        self:EmitSound("glebqip/idc_beep_start.wav",65,100,0.3)
        self.LinesTimer = CurTime()+0.15
      end
      if self.State == 3 then
        self:EmitSound("glebqip/idc_numb_start.wav",65,100,0.3)
        self.AnalyzingCode = string.Explode("",self:GetServerString("IDCCode",""))
        self.AnalyzedCode = {}
        self.LinesTimer = CurTime()-0.1
      end
	  if self.State == 6 then
		self.AnalyzedCode = {}
		self.AnalyzingCode = ""
	  end
    end
    if self.State > 2 and CurTime()-self.LinesTimer > 0.1 then
      local done = true
      for i=1,#self.AnalyzingCode do
        if self.AnalyzedCode[i] == nil then done = false end
      end
      if not done then
        self:EmitSound("glebqip/idc_number_beep.wav",65,100,0.2)
        for i=1,100 do
          local i = math.random(1,#self.AnalyzingCode)
          if not self.AnalyzedCode[i] then
            self.AnalyzedCode[i] = self.AnalyzingCode[i]
            break
          end
        end
        self.LinesTimer = CurTime()
      end
    end
    
    --Fancy warning timers
    if self:GetServerBool("Inbound",false) and (self.State <= 2 or self.State == 4) then
      local state = (self.State == 1 or self.State == 2) and 2 or self.State == 4 and self:GetServerInt("IDCCodeState",0)+3 or 1
      if not self.WarnPlayed or self.Warn ~= state then
        if state == 1 then self.TestTimer = CurTime() self:EmitSound("glebqip/idc_incomming.wav",65,100,0.6) end
        if state == 2 then self:EmitSound("glebqip/idc_incomming.wav",65,100,0.6) end
        if state == 3 then self:EmitSound("glebqip/idc_accept.wav",65,100,0.6) end
        if state > 3 then self:EmitSound("glebqip/idc_error.wav",65,100,0.6) end

		self.Warn = state 
		self.WarnState = true
		self.WarnPlayed = state == 2 and 1.5 or state == 1 and 11 or -1
		self.WarnTimer = CurTime()
      end
    elseif self.WarnState or self.WarnPlayed then
      if self.WarnState ~= false then
        self.WarnTimer = CurTime()
        self.WarnState = false
      end
      self.WarnPlayed = false
      self.TestTimer = nil
    end
    if not self:GetServerBool("Inbound",false) and self.State > 0 then self.State = 0 end
    if self.WarnState and self.WarnPlayed ~= -1 and CurTime()-self.WarnTimer > self.WarnPlayed then
      self.WarnState = false
      self.WarnTimer = CurTime()
    end
  end
end

return SCR
