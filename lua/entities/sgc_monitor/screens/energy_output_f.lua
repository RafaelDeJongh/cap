---------------------
-- Screen: IDC s1 --
-- Author: glebqip --
-- ID: 2 --
---------------------

local SCR = {
  Name = "Energy output (movie)",
  ID = 8,
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
    self.Digits = {}
    self.DigitsTimer = CurTime()-10

    self.Lines = {}
    self.LinesTimer = CurTime()-3
    self.Active = false
    self.Max = math.Rand(0.05,1)
  end

  local MainFrame = surface.GetTextureID("glebqip/energy_output_f/mainframe")

  local Gradient = surface.GetTextureID("glebqip/energy_output_f/gradient")

  local Red = Color(239,0,0)

  function SCR:Draw(MainColor, SecondColor, ChevBoxesColor)
    surface.SetDrawColor(MainColor)
    surface.SetTexture(MainFrame)
    surface.DrawTexturedRectRotated(256,192,512,512,0)
    render.SetScissorRect(0,37,178,350,true)
      local py = (CurTime()-self.DigitsTimer)%0.2*5-1
      for i=1,#self.Digits do
        if self.Digits[i] then
          draw.SimpleText(self.Digits[i], "Marlett_12", 97, 43+(i-1)*13+py*13, MainColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
      end
    render.SetScissorRect(0,0,0,0,false)

    local anim = (CurTime()-self.LinesTimer)%3
    local st, en = 0,1--math.Clamp(anim < 3 and anim*2 or 4-anim,0,1)
    if anim > 2 then st = anim-2 end
    if anim < 1 then en = anim end
    render.SetScissorRect(126+st*351,107,126+en*351,344,true)
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilTestMask(255);render.SetStencilWriteMask(255);render.SetStencilReferenceValue(10)
    render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
      --surface.SetDrawColor(Color(45,150,60))
      draw.DrawTLine(126,195,152,195,2)
      draw.DrawTLine(447,195,473,195,2)
      local st, en = 0,1--math.Clamp(anim < 3 and anim*2 or 4-anim,0,1)
      if anim < 1 then en = math.min(anim+anim*40/305-20/305,1) end
      if anim > 2 then
        anim = anim-2
        st = math.max(anim+anim*40/305-20/305,0)
      end
      local ie = math.ceil(60*(en+0.08))
      if ie ~= self.EndLine and ie > 1 and ie < 60 then
        if self.Active then
          local double = not self:GetServerBool("Local",false)
          local open = self:GetServerBool("Open",false)
          local power = (open and 1 or 0.8) + (double and 0.25 or 0)
          if math.random() > 0.7 then
            self.Max = math.Rand(0.5,1)
          end
          local maxval = self.Max*power*119*(ie%2 == 0 and -1 or 1)
          self.Lines[ie] = math.Rand(maxval/4,maxval)
        elseif self.Lines[ie] then
          self.Lines[ie] = nil
        end
        self.EndLine = ie
      end
      for i=1,60 do
        local x1 = math.floor(301/60*i)
        local x2 = math.floor(301/60*(i+1));
        local y1 = self.Lines[i] or 0
        local y2 = math.floor(self.Lines[i+1] or 0) ;oldy = y2
        --draw.DrawTLine(240+x1,263+y1,238+x2,263+y2,2)
        draw.DrawTLine(146+x1,195+y1,146+x2,195+y2,2)
      end
		render.SetStencilCompareFunction(STENCIL_EQUAL)
      surface.SetDrawColor(Color(150,150,150))
      surface.SetTexture(Gradient)
      surface.DrawTexturedRectRotated(300,194,351,301,0)
		render.SetStencilEnable(false)
    render.SetScissorRect(0,0,0,0,false)
		--render.SetStencilTestMask(3);render.SetStencilWriteMask(3);render.SetStencilReferenceValue(3)
  end

  function SCR:Think(curr)
    if not curr then return end
    if CurTime()-self.DigitsTimer > 0.2 then
      str = ""
      if self:GetServerBool("Connected",false) then
        if math.random() > 0.4 then
          for _=1,15 do
            str = str..tostring(math.random(0,9))
          end
        end
        table.insert(self.Digits,1,str)
      else
        table.insert(self.Digits,1,"")
      end
      table.remove(self.Digits,26)
      self.DigitsTimer = CurTime()
    end

    local active = self:GetServerBool("Connected",false) and self:GetServerBool("Active",false)
    local double = not self:GetServerBool("Local",false)
    local open = self:GetServerBool("Open",false)
    if active ~= self.Active then
      self.Active = active
    end
    if CurTime()-self.LinesTimer > 3 then
      if self.Active then
      elseif not self.Active and #self.Lines > 0 then
        self.Lines = {}
      end
      self.LinesTimer = CurTime()
    end
  end
end

return SCR
