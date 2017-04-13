---------------------
-- Screen: IDC s1 --
-- Author: glebqip --
-- ID: 2 --
---------------------

local SCR = {
  Name = "Address book",
  ID = 2,
}

if SERVER then
  function SCR:Initialize()
    self.Selected = 0
    self.Scroll = 0
    self.OldScroll = 0
    self.Scrolling = false
  end

  function SCR:Think(curr,dT)
    if not curr then return end
    local count = self:GetServerBool("Connected",false) and self:GetServerInt("AddressCount",0) or 0
    if self.Scrolling then
      self.Scroll = math.Clamp(self.Scroll + dT*4*self.Scrolling,0,count-1)
      self:SetMonitorFloat("ABScroll",self.Scroll)
    elseif count == 0 and (self.Scroll ~= 0 or self.Selected ~= 0) then
      self.Scrolling = 0
      self.Selected = 0
    end
    if self.Selected < math.floor(self.Scroll) and math.floor(self.Scroll) < count then
      self.Selected = math.floor(self.Scroll)
    end
    local max = math.floor(self.Scroll) ~= self.Scroll and 7 or 6
    if self.Selected > math.floor(self.Scroll)+max then
      self.Selected = math.floor(self.Scroll)+max
    end
    if self.Selected > count-1 then
      self.Selected = count-1
    end
    if self.Scroll > count and count < self.Count then
      local min = self.Count-self.Scroll
      self.Scroll = count-min
      self:SetMonitorFloat("ABScroll",self.Scroll)
    end
    self.Count = count
    self:SetMonitorInt("ABSelected",self.Selected)
    --self:SetMonitorBool("ABScrolling", self.OldScroll ~= self.Scroll)
    --self.OldScroll = self.Scroll
    --
  end
  function SCR:Trigger(curr,key,value)
    if not curr then return end
    local count = self:GetServerBool("Connected",false) and self:GetServerInt("AddressCount",0) or 0
    if count == 0 then
      return
    end
    if self:GetMonitorBool("ServerConnected",false) then
       -- \, iris toggle
      if key == 92 and value then self.Entity.Server.Iris = not self.Entity.Server.Iris end
      -- Backspace, close gate
      if key == 127 and self:GetServerBool("Connected",false) and self:GetServerBool("Active",false) and value then self.Entity.Server.LockedGate:AbortDialling() end
    end
    if key == StarGate.KeysConst[KEY_ENTER] and value then
      self.Entity.Screens[1].EnteredAddress = self:GetServerString("Address"..(self:GetMonitorInt("ABSelected",0)+1),"")
      self.Entity.Screen = 1
    end
    if key == 17 and value then self.Selected = math.Clamp(self.Selected-1,0,count-1) end
    if key == 18 and value then self.Selected = math.Clamp(self.Selected+1,0,count-1) end
    if key == 151 and value then self.Scrolling = 1 end
    if key == 151 and not value then self.Scrolling = false end
    if key == 152 and value then self.Scrolling = -1 end
    if key == 152 and not value then self.Scrolling = false end

  end
else
  function SCR:Bind()
    self:BindMonitorVar("ABScroll", "Sound", function() self.Scrooling = CurTime() end)
  end

  function SCR:Initialize()
    self.Symbols = {}
    self.SymbolsTimer = CurTime()-1
  end

  local MainFrame = surface.GetTextureID("glebqip/address_book_1/mainframe")
  local Address7 = surface.GetTextureID("glebqip/address_book_1/address")
  local Address8 = surface.GetTextureID("glebqip/address_book_1/address8")
  local Address9 = surface.GetTextureID("glebqip/address_book_1/address9")

  local Red = Color(239,0,0)

  local gates ={"STD","MOV","INF","ATL","TOL","UNI"}
  function SCR:Draw(MainColor, SecondColor, ChevBoxesColor)
    surface.SetDrawColor(MainColor)
    surface.SetTexture(MainFrame)
    surface.DrawTexturedRectRotated(256,192,512,512,0)

    local count = self:GetServerBool("Connected",false) and self:GetServerInt("AddressCount",0) or 0
    local scr = self:GetMonitorFloat("ABScroll",0)%1
    local scrg = math.floor(self:GetMonitorFloat("ABScroll",0))
    local add = scrg-self:GetMonitorInt("ABSelected",0)
    for i=0,math.min(7,count-scrg-1) do

      render.SetScissorRect(14,54,413,302,true)
        local id = (i+scrg+1)
        local min = #self:GetServerString("Address"..id,"")-6
        if min > 2 then surface.SetTexture(Address9) elseif min == 2 then surface.SetTexture(Address8) else surface.SetTexture(Address7) end
        surface.DrawTexturedRectRotated(212,73+(i-scr)*35,512,32,0)

        local addr = self:GetServerString("Address"..id,"")
        for i1=1,#addr do draw.SimpleText(addr[i1], "SGC_ABS1", 293+(i1-1-min)*21, 79+(i-scr)*35, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
        local text = self.TextEllipsis(self:GetServerString("AddressName"..id,""),90,"Marlett_15")
        draw.SimpleText(text, "Marlett_15", 19, 65+(i-scr)*35, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        if self:GetServerBool("AddressBlocked"..id,false) then
          draw.SimpleText("BLOCKED!", "Marlett_12", 19, 80+(i-scr)*35, Red, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
          surface.SetDrawColor(Red)
        else
          surface.SetDrawColor(MainColor)
        end
        draw.SimpleText("Dist:", "Marlett_12", 113, 63+(i-scr)*35, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Group:", "Marlett_12", 113, 72+(i-scr)*35, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Type:", "Marlett_12", 113, 81+(i-scr)*35, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(Format("%.02f kU",self:GetServerInt("AddressDistance"..id,0)/1000), "Marlett_12", 147, 63+(i-scr)*35, SecondColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(self:GetServerString("AddressGalaxy"..id,""), "Marlett_12", 147, 72+(i-scr)*35, SecondColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(gates[self:GetServerInt("AddressType"..id,1)], "Marlett_12", 147, 81+(i-scr)*35, SecondColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

      render.SetScissorRect(419,54,470,302,true)
        draw.SimpleText(Format("0x%08X",self:GetServerInt("AddressCRC"..id,0)/2), "Marlett_10", 421, 65+(i-scr)*35, MainColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    if count > 0 then
      if self:GetServerBool("AddressBlocked"..(self:GetMonitorInt("ABSelected",0)+1),false) then
        surface.SetDrawColor(SecondColor)
      else
        surface.SetDrawColor(Red)
      end
    end
    render.SetScissorRect(14,54,413,302,true)
      draw.OutlinedBox(14, 57+(0-scr-add)*35,396,32,1)
    render.SetScissorRect(0,0,0,0,false)
    for i=1,#self.Symbols do
      if self.Symbols[i] then
        if i < 8 then
          draw.SimpleText(self.Symbols[i], "SGC_ABS", 1+i*28, 352, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
          draw.SimpleText(self.Symbols[i], "SGC_ABS", 262+(i-7)*28, 352, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
      end
    end

    draw.SimpleText("BILINEAR SEARCH ALGORITHM", "Marlett_15", 18, 333, SecondColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    draw.SimpleText(os.date("!%d.%m.%y %H:%M:%S"), "Marlett_12", 473, 30, MainColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    draw.SimpleText("1", "Marlett_12", 226, 346, SecondColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("2", "Marlett_12", 261, 357, SecondColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  end

  local randstr = "#?"
  for i=48,57 do randstr = randstr..string.char(i) end
  for i=64,90 do randstr = randstr..string.char(i) end
  function SCR:Think(curr)
    if not curr then return end
    if CurTime()-self.SymbolsTimer > 0.1 then
      str = ""
      for i=1,14 do
        if math.random() > 0.5 then self.Symbols[i] = randstr[math.random(1,#randstr)] end
      end
      self.SymbolsTimer = CurTime()
    end

    if self.Scrooling and CurTime()-self.Scrooling > 0.15 then self.Scrooling = false end
  end

end

return SCR
