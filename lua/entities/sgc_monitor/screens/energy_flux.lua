---------------------
-- Screen: IDC s1 --
-- Author: glebqip --
-- ID: 2 --
---------------------

local SCR = {
  Name = "Energy flux",
  ID = 10,
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
    self.GradientsTimers = {}
    self.GradientSpeeds = {}
    for i=1,30 do
      self.GradientSpeeds[i] = math.Rand(0.8,1.2)
      self.GradientsTimers[i] = CurTime()-self.GradientSpeeds[i]/math.random()
    end
  end

  local MainFrame = surface.GetTextureID("glebqip/energy_flux_1/mainframe")

  local Gradient = surface.GetTextureID("vgui/gradient_down")

  local Red = Color(239,0,0)

  function SCR:Draw(MainColor, SecondColor, ChevBoxesColor)
    surface.SetDrawColor(MainColor)
    surface.SetTexture(MainFrame)
    surface.DrawTexturedRectRotated(256,192,512,512,0)

    surface.SetTexture(Gradient)
    surface.SetDrawColor(MainColor)

    for i=1,3*5*3*2 do
      local id = math.ceil(i/3)-1
      if (CurTime() - self.GradientsTimers[id+1])/self.GradientSpeeds[id+1] > 1 then continue end
      local speed = i%3 == 0 and 5 or i%3 == 1 and 3 or 1
      local state = ((CurTime() - self.GradientsTimers[id+1])/self.GradientSpeeds[id+1])*speed%1
      local size = state*39

      local x = i%3*14 + id%5*60 + (id%5 == 4 and 13 or 0)
      local y = (math.ceil((id-4)/5))*53 + (id >= 15 and 25 or 0)--(39-size) +
      render.SetScissorRect( 182 + x,18+39 + y,182 + x+11,18+39 + y-size, true )
        surface.DrawTexturedRect(182 + x,18 + y,11,39)
      render.SetScissorRect(0,0,0,0,false)
    end

    render.SetScissorRect(54,14,178,351,true)
      local py = (CurTime()-self.DigitsTimer)%0.2*5-1
      for i=1,27 do
        if self.Digits[i] then
          draw.SimpleText(self.Digits[i], "Marlett_12", 150,  20+(i-1)*13+py*13, MainColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
      end
    render.SetScissorRect(0,0,0,0,false)
  end

  function SCR:Think(curr)
    if not curr then return end
    for i=1,30 do
      if CurTime() - self.GradientsTimers[i] > self.GradientSpeeds[i] and self:GetServerBool("Active",false) then
        self.GradientSpeeds[i] = math.Rand(0.8,1.2)
        self.GradientsTimers[i] = CurTime()
      end
    end
    if CurTime()-self.DigitsTimer > 0.2 then
      str = ""
      if self:GetServerBool("Connected",false) then
        if math.random() > 0.4 then
          for _=1,16 do
            str = str..tostring(math.random(0,9))
          end
        end
        table.insert(self.Digits,1,str)
      else
        table.insert(self.Digits,1,"")
      end
      table.remove(self.Digits,28)
      self.DigitsTimer = CurTime()
    end
  end
end

return SCR
