---------------------
-- Screen: IDC s1 --
-- Author: glebqip --
-- ID: 2 --
---------------------

local SCR = {
  Name = "Galaxy map",
  ID = 5,
}

if SERVER then
  function SCR:Initialize()
    self.ScrollX = 0
    self.ScrollingX = false
    self.ScrollY = 0
    self.ScrollingY = false
    self.Zoom = 0
    self.Zooming = 0
  end
  local ADD = 1.11
  function SCR:Think(curr,dT)
    if not curr then return end
    if self.ScrollingX then
      self.ScrollX = math.Clamp(self.ScrollX + dT*self.ScrollingX,-self.Zoom*ADD,self.Zoom*ADD)
      self:SetMonitorFloat("GalaxyMapScrollX",self.ScrollX)
    end
    if self.ScrollingY then
      self.ScrollY = math.Clamp(self.ScrollY + dT*self.ScrollingY,-self.Zoom*ADD,self.Zoom*ADD)
      self:SetMonitorFloat("GalaxyMapScrollY",self.ScrollY)
    end
    if self.Zooming then
      self.Zoom = math.Clamp(self.Zoom + dT*2*self.Zooming,0,2)
      self.ScrollX = math.Clamp(self.ScrollX,-self.Zoom*ADD,self.Zoom*ADD)
      self.ScrollY = math.Clamp(self.ScrollY,-self.Zoom*ADD,self.Zoom*ADD)
      self:SetMonitorFloat("GalaxyMapZoom",self.Zoom)
      self:SetMonitorFloat("GalaxyMapScrollX",self.ScrollX)
      self:SetMonitorFloat("GalaxyMapScrollY",self.ScrollY)
    end
  end
  function SCR:Trigger(curr,key,value)
    if key == 151 then self.Zooming = value and 1 end
    if key == 152 then self.Zooming = value and -1 end
    if key == 17 then self.ScrollingY = value and -1 end
    if key == 18 then self.ScrollingY = value and 1 end
    if key == 19 then self.ScrollingX = value and -1 end
    if key == 20 then self.ScrollingX = value and 1 end
  end
else
  function SCR:Bind()
    self:BindMonitorVar("GalaxyMapZoom", "Sound", function() self.Scrooling = CurTime() end)
    self:BindMonitorVar("GalaxyMapScrollX", "Sound", function() self.Scrooling = CurTime() end)
    self:BindMonitorVar("GalaxyMapScrollY", "Sound", function() self.Scrooling = CurTime() end)
  end
  local Stars = {}
  for i=1,20 do
    Stars[i] = surface.GetTextureID("glebqip/galaxy_map_1/stars"..i)
  end
  function SCR:Initialize()
    self.Show = -1
    self.ShowTimer = CurTime()-2
    self.Stars = {}

    local layers = 1
    for ly=layers,0,-1 do --layers
      for i=1,ly==0 and 4 or 9 do
        local x,y
        local xsize, ysize = 395/2,364/2
        if ly == 0 then
          x = xsize*((i-1)%2)-xsize/2; y = ysize*math.floor((i-1)/2)-ysize/2
        else
          x = -xsize + xsize*((i-1)%3); y = -ysize + ysize*math.floor((i-1)/3)
        end
        local mxx,mxy = xsize + ly*80, (328-32)/2 + ly/layers*80
        table.insert(self.Stars,{
            xsz = mxx,
            ysz = mxy,
            x = x,
            y = y,
            texture = Stars[math.random(1,#Stars)],
            ang = math.random(1,4),
            col = Color(200,200,200,255-150/layers*ly)
          })
      end
    end
  end

  local MainFrame = surface.GetTextureID("glebqip/galaxy_map_1/mainframe")
  local Gate = surface.GetTextureID("glebqip/galaxy_map_1/gate")
  local Arrow = surface.GetTextureID("glebqip/galaxy_map_1/arrow")
  local Red = Color(239,0,0)

  local gates ={"STD","MOV","INF","ATL","TOL","UNI"}
  function SCR:Draw(MainColor, SecondColor, ChevBoxesColor)
    surface.SetDrawColor(MainColor)
    surface.SetTexture(MainFrame)
    surface.DrawTexturedRectRotated(256,192,512,512,0)

    local zoom = self:GetMonitorFloat("GalaxyMapZoom",0)+1
    local size = zoom-1
    local scrx,scry = self:GetMonitorFloat("GalaxyMapScrollX",0),self:GetMonitorFloat("GalaxyMapScrollY",0)
    --render stars
    local xsize, ysize = 395/2*zoom,364/2*zoom
    render.SetScissorRect( 11, 12, 402, 372, true )
      for i, tbl in ipairs(self.Stars) do
        local x = 207+tbl.x*zoom - tbl.xsz*scrx-- + (xsize-1)*(i%2) - xsize/2
        local y = 192+tbl.y*zoom - tbl.ysz*scry--(scry*layer)/2*(328-32)+ysize*math.ceil(i/2-1) - ysize/2
        surface.SetTexture(tbl.texture)
        --surface.SetDrawColor(Color(150 - (layer-1)*150,150 - (layer-1)*150,150 - (layer-1)*150))
        surface.SetDrawColor(tbl.col)
        local ang = tbl.ang
        surface.DrawTexturedRectRotated(x,y,ang%2 == 0 and xsize or ysize,ang%2 == 1 and xsize or ysize,ang*90)
      end
      if self.Show >= 0 then
        surface.SetTexture(Gate)
        local minx,maxx,miny,maxy = 9-16*zoom, 404+16*zoom, 10-(16+8)*zoom, 374+16*zoom
        for i=0,self.Show do
          local col = self:GetServerBool("AddressBlocked"..i,false) and Red or SecondColor
          local tcol = self:GetServerBool("AddressBlocked"..i,false) and Red or Color(50,150,50)
          local x,y = (self:GetServerFloat("AddressX"..i,0)-0.5)*zoom-scrx/2,(self:GetServerFloat("AddressY"..i,0)-0.5)*zoom-scry/2
          local xpos, ypos = 207+16+x*(359+16)+2, 192-8+y*(328-24)
          --local xpos, ypos = 207+x*359+2, 192+y*(328-32) FIXME TEST
          if i==0 and (xpos < minx or xpos > maxx or ypos < miny or ypos > maxy) then
            local x = math.Clamp(x,-0.54,0.5)
            local y = math.Clamp(y,-0.51,0.57)
            surface.SetDrawColor(Color(50,200,50))
            surface.SetTexture(Arrow)
            surface.DrawTexturedRectRotated(207+x*375+20, 192+y*(328-24)-8,32,32,180+math.deg(math.atan2((x-0.02)/1.04,(y-0.03)/1.08)))
            surface.SetTexture(Gate)
          end
          if xpos < minx or xpos > maxx then continue end
          if ypos < miny or ypos > maxy then continue end
          if i == 0 then
            surface.SetDrawColor(Color(50,200,50))
          else
            surface.SetDrawColor(col)
          end

          local text = self.TextEllipsis(self:GetServerString("AddressName"..i,""),50,"Marlett_10")
          surface.DrawTexturedRectRotated(xpos,ypos,32+20*(size),32+20*(size),0)
          draw.SimpleText(text, "Marlett_10",xpos, ypos+20+10*size, tcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          draw.SimpleText(self:GetServerString("Address"..i,""), "Marlett_10", xpos,ypos+28+10*size, tcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          --draw.SimpleText(gates[self:GetServerInt("AddressType"..i,1)], "Marlett_12", 9+x*359+2, 10+y*328+38, SecondColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
      end
    render.SetScissorRect( 0, 0, 0, 0, false)
    local iadd = math.max(0,math.floor((self.Show-1)/14))
    for i=iadd*14+1,self.Show do
      local col = self:GetServerBool("AddressBlocked"..i,false) and Red or SecondColor
      local y = i-iadd*14-1
      local text = self.TextEllipsis(self:GetServerString("AddressName"..i,""),33,"Marlett_10")
      draw.SimpleText(text, "Marlett_10",414, 16+y*26, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
      draw.SimpleText(self:GetServerString("AddressGalaxy"..i,""), "Marlett_10", 414, 23+y*26, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
      draw.SimpleText(gates[self:GetServerInt("AddressType"..i,1)], "Marlett_10", 414, 30+y*26, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

      draw.SimpleText(Format("%08X",self:GetServerInt("AddressCRC"..i,0)), "Marlett_10",472, 23+y*26, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      --draw.SimpleText(self:GetServerString("Address"..i,""), "Marlett_10", xpos,ypos+28+10*size, Color(50,150,50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
  end

  function SCR:Think(curr)
    if not curr then return end
    local count = self:GetServerBool("Connected",false) and self:GetServerInt("AddressCount",0) or 0
    if self.Show ~= count and CurTime()-self.ShowTimer > 0.1 then
      if self.Show < count then
        self.Show = self.Show + 1
      else
        self.Show = self.Show - 1
      end
      self:EmitSound("glebqip/galaxy_map_beep2.wav",65,100,0.8)
      self.ShowTimer = CurTime()
    end
    if self.Scrooling and CurTime()-self.Scrooling > 0.15 then self.Scrooling = false end
  end
end

return SCR
