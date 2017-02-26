---------------------
-- Screen: IDC s1 --
-- Author: glebqip --
-- ID: 2 --
---------------------

local SCR = {
  Name = "Energy output (series)",
  ID = 9,
}

if SERVER then
  function SCR:Initialize()
  end

  function SCR:Think(curr)
  end
  function SCR:Trigger(curr,key,value)
  end
else
  function SCR:Initialize()
    self.Lines = {}
    self.Lines2 = {}
    self.Lines3 = {}
    self.LinesTimer = CurTime()-3
    self.Active = false

    self.String1 = "4572 FGO895"
    self.FileIter = 0

    self.Max = math.Rand(0.05,1)
  end

  local MainFrame = surface.GetTextureID("glebqip/energy_output_s/mainframe")
  local Circle = surface.GetTextureID("glebqip/energy_output_s/rw_circle")

  local GradientL = surface.GetTextureID("gui/gradient")
  local GradientR = surface.GetTextureID("vgui/gradient-r")
  local Gradient = surface.GetTextureID("glebqip/energy_output_f/gradient")


  local Red = Color(239,0,0)

  function SCR:Draw(MainColor, SecondColor, ChevBoxesColor)
    surface.SetDrawColor(MainColor)
    surface.SetTexture(MainFrame)
    surface.DrawTexturedRectRotated(256,192,512,512,0)
    local anim = (CurTime()-self.LinesTimer)%3
    local st, en = 0,1--math.Clamp(anim < 3 and anim*2 or 4-anim,0,1)
    if anim <= 1 then st,en = 0,0 end
    if anim > 1 then en = math.min(1,anim-1) end
    if anim > 2 then st = math.min(1,anim-2) end

    surface.SetDrawColor(Color(141,150,110))
    --math.ceil((#self.Lines2-1)*st),math.ceil((#self.Lines2-1)*en)
    render.SetScissorRect(19+89*st,194,19+89*en,227,true)
      for i=1,#self.Lines2-1 do
        local x1 = math.floor(89/#self.Lines2*i)
        local x2 = math.floor(89/#self.Lines2*(i+1))
        local y1 = self.Lines2[i] or 0
        local y2 = math.floor(self.Lines2[i+1])
        surface.DrawLine(15+x1,224+y1,15+x2,224+y2)
      end
      surface.SetDrawColor(Color(133,60,38))
      for i=1,#self.Lines3-1 do
        local x1 = math.floor(89/#self.Lines3*i)
        local x2 = math.floor(89/#self.Lines3*(i+1));
        local y1 = self.Lines3[i] or 0
        local y2 = math.floor(self.Lines3[i+1])
        surface.DrawLine(15+x1,224+y1,15+x2,224+y2)
      end
    render.SetScissorRect(0,0,0,0,false)

    local st, en = 0,1--math.Clamp(anim < 3 and anim*2 or 4-anim,0,1)
    if anim > 2 then st = anim-2 end
    if anim < 1 then en = anim end
    render.SetScissorRect(136+367*st,347,136+367*en,371,true)
      surface.SetTexture(GradientL)
      surface.SetDrawColor(Color(75,42,47))
      surface.DrawTexturedRect(134,345,371,29)
      surface.SetTexture(GradientR)
      surface.SetDrawColor(Color(14,26,52))
      surface.DrawTexturedRect(134,345,371,29)
    render.SetScissorRect(0,0,0,0,false)

    surface.SetTexture(Circle)
    surface.SetDrawColor(Color(255,255,255))
    surface.DrawTexturedRectRotated(25,237,16,16,90)
    draw.SimpleText("STARGATE ENERGY OUTPUT", "Marlett_29", 134, 35, Color(138,170,222), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("SGO 463-TR 5029", "Marlett_15", 470, 55, Color(138,170,222), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

    for i=-100,100,10 do
      draw.SimpleText(-i, "Marlett_16", 161, 202+i*1.18, Color(141,150,110), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    if self:GetServerBool("Open") then
      draw.SimpleText("HIGH rad. alert.", "Marlett_15", 13, 50, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    draw.SimpleText(self.String1, "Marlett_15", 13, 65, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("Start file:"..self.FileIter, "Marlett_15", 13, 80, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("Resonance of", "Marlett_15", 13, 105, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("Stargate:", "Marlett_15", 13, 120, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    if self:GetServerBool("Open") then
      draw.SimpleText("245 Khz", "Marlett_15", 30, 135, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    elseif self:GetServerBool("Active",false) then
      draw.SimpleText("50 Khz", "Marlett_15", 30, 135, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    elseif self:GetServerBool("Connected",false) then
      draw.SimpleText("20 Khz", "Marlett_15", 30, 135, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    else
      draw.SimpleText("unknown Khz", "Marlett_15", 20, 135, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    draw.SimpleText("AMPLITUDE PEAK", "Marlett_10", 70, 232, Color(141,150,110), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("SGC-68477 345", "Marlett_11", 70, 242, Color(141,150,110), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    draw.SimpleText("Stargate Energy", "Marlett_15", 13, 290, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("Field Output", "Marlett_15", 13, 305, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("locked in", "Marlett_15", 13, 320, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("magnatomic flux", "Marlett_15", 13, 335, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    surface.SetDrawColor(Color(255,255,255))

    render.SetScissorRect(183+313*st,76,183+313*en,327,true)
		render.ClearStencil()
		render.SetStencilEnable(true)
		render.SetStencilTestMask(255);render.SetStencilWriteMask(255);render.SetStencilReferenceValue(10)
		render.SetStencilPassOperation(STENCIL_REPLACE)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)
		render.SetStencilCompareFunction(STENCIL_ALWAYS)
      draw.DrawTLine(183,202,208,202,2)
      draw.DrawTLine(471,202,496,202,2)
      --surface.DrawLine(126+310+29*st,193,126+347,193)
      local st, en = 0,1--math.Clamp(anim < 3 and anim*2 or 4-anim,0,1)
      if anim < 1 then en = math.min(anim+anim*40/305-20/305,1) end
      if anim > 2 then
        anim = anim-2
        st = math.max(anim+anim*40/305-20/305,0)
      end
      local ie = math.ceil(55*(en+0.08))
      if ie ~= self.EndLine and ie > 1 and ie < 55 then
        if self:GetServerBool("Connected",false) and self.Active then
          local double = not self:GetServerBool("Local",false)
          local open = self:GetServerBool("Open",false)
          local power = (open and 1 or 0.8) + (double and 0.25 or 0)
          if math.random() > 0.7 then
            self.Max = math.Rand(0.5,1)
          end
          local maxval = (self.Max*power)*100*(ie%2 == 0 and -1 or 1)
          self.Lines[ie] = math.Rand(maxval/4,maxval)
        elseif self.Lines[ie] then
          self.Lines[ie] = nil
        end
        self.EndLine = ie
      end
        for i=1,55 do
          local x1 = math.floor(269/55*i)
          local x2 = math.floor(269/55*(i+1));
          local y1 = self.Lines[i] or 0
          local y2 = math.floor(self.Lines[i+1] or 0) ;oldy = y2
          --draw.DrawTLine(240+x1,263+y1,238+x2,263+y2,2)
          draw.DrawTLine(203+x1,202+y1,203+x2,202+y2,2)
        end
      render.SetScissorRect(0,0,0,0,false)
    render.SetStencilCompareFunction(STENCIL_EQUAL)
      surface.SetDrawColor(Color(150,150,150))
      surface.SetTexture(Gradient)
      surface.DrawTexturedRectRotated(340,202,313,252,0)
    render.SetStencilEnable(false)
  end

  function SCR:Think(curr)
    if not curr then return end

    local active = self:GetServerBool("Connected",false) and self:GetServerBool("Active",false)
    local double = not self:GetServerBool("Local",false)
    local open = self:GetServerBool("Open",false)
    if active ~= self.Active then
      self.Active = active
    end
    if CurTime()-self.LinesTimer > 3 then
      if self:GetServerBool("Connected",false) then
        if self.Active then
          self:EmitSound("glebqip/energy_big.wav",65,100,0.55)
        elseif not self.Active and #self.Lines > 0 then
          self.Lines = {}
        end
        for i=1,20 do
          local maxval = 28
          self.Lines2[i] = -math.Rand(2,maxval)
          self.Lines3[i] = -math.Rand(5,maxval-5)
        end
        self.FileIter = self.FileIter + 1
        if self.FileIter > 1000 then self.FileIter = 1 end
      end

      if math.random() > 0.6 then
        self.String1 = ""
        for i=1,4 do
          self.String1 = self.String1..math.random(0,9)
        end
        self.String1 = self.String1.." FGO"
        for i=1,3 do
          self.String1 = self.String1..math.random(0,9)
        end
      end
      self.LinesTimer = CurTime()
    end
  end
end

return SCR
