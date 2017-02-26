if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "SGC Computer monitor"
ENT.Author = "glebqip / AlexALX"
ENT.Category = "Stargate Carter Addon Pack"

--list.Set("CAP.Entity", ENT.PrintName, ENT);

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.RequestScreenReload = true

function ENT:RegisterScreenFunctions(screen)
  screen.Entity = self
  screen.GetMonitorBool = function(_, id, default) return screen.Entity:GetNW2Bool(id, default) end
  screen.GetMonitorInt = function(_, id, default) return screen.Entity:GetNW2Int(id, default) end
  screen.GetMonitorString = function(_, id, default) return screen.Entity:GetNW2String(id, default) end
  screen.GetMonitorFloat = function(_, id, default) return screen.Entity:GetNW2Float(id, default) end
  screen.GetMonitorEntity = function(_, id, default) return screen.Entity:GetNW2Entity(id, default) end
  screen.GetServerBool = function(_,id, default)
    if not IsValid(screen.Entity.Server) then return default end
    return screen.Entity.Server:GetNW2Bool(id, default)
  end
  screen.GetServerEntity = function(_,id, default)
    if not IsValid(screen.Entity.Server) then return default end
    return screen.Entity.Server:GetNW2Entity(id, default)
  end
  screen.GetServerInt = function(_,id, default)
    if not IsValid(screen.Entity.Server) then return default end
    return screen.Entity.Server:GetNW2Int(id, default)
  end
  screen.GetServerFloat = function(_,id, default)
    if not IsValid(screen.Entity.Server) then return default end
    return screen.Entity.Server:GetNW2Float(id, default)
  end
  screen.GetServerString = function(_,id, default)
    if not IsValid(screen.Entity.Server) then return default end
    return screen.Entity.Server:GetNW2String(id, default)
  end
  screen.EmitSound = function(_,...) return screen.Entity:EmitSound(...) end
  if SERVER then
    screen.Server = self.Server
    screen.SetMonitorBool = function(_, id, val) return screen.Entity:SetNW2Bool(id, val) end
    screen.SetMonitorInt = function(_, id, val) return screen.Entity:SetNW2Int(id, val) end
    screen.SetMonitorFloat = function(_, id, val) return screen.Entity:SetNW2Float(id, val) end
    screen.SetMonitorString = function(_, id, val) return screen.Entity:SetNW2String(id, val) end
    screen.SetMonitorEntity = function(_, id, val) return screen.Entity:SetNW2Entity(id, val) end
  else
    screen.BindMonitorVar = function(_, ...) screen.Entity:BindNW2Hook(...) end
    screen.BindServerVar = function(_, ...)
      if not IsValid(screen.Entity.Server) then return end
      screen.Entity.Server:BindNW2Hook(screen.Entity,...)
    end
    function screen.TextEllipsis(str, maxw, font, ellipsis) //by Mijyuoon
      surface.SetFont(font)
      ellipsis = ellipsis or "..."
      local fullw, _ = surface.GetTextSize(str)
      if fullw <= maxw then return str end
      local waccum, etxt = 0, ellipsis
      local dotw, _ = surface.GetTextSize(etxt)
      for j, ci in utf8.codes(str) do
          local ch = utf8.char(ci)
          local chw = surface.GetTextSize(ch)
          waccum = waccum + chw
          if waccum + dotw > maxw then
              local newstr = str:sub(1, j-1)
              return newstr .. ellipsis
          end
      end
    end
  end
end

function ENT:LoadScreens()
  self.Screens = self.Screens or {}
  for x,filename in pairs(file.Find("entities/sgc_monitor/screens/*.lua","LUA")) do
    local init = false
    local SCR,test = include("entities/sgc_monitor/screens/"..filename)
	if not SCR then continue end
    local ID = SCR.ID
    if not self.Screens[ID] then                  
      self.Screens[ID] = {}
      init = true
    end
    for k,v in pairs(SCR) do
      self.Screens[ID][k] = v
    end
    if init then
      self:RegisterScreenFunctions(self.Screens[ID])
      self.Screens[ID]:Initialize()
    end
    if self.Screens[ID].Bind then self.Screens[ID]:Bind() end
  end
end
--[[
--Screens loading func
ENT.GetScreenFunctions = {}
for _,filename in pairs(file.Find("entities/gmod_sg_monitor/screens/*.lua","LUA")) do
  local ID,SCR = include("entities/gmod_sg_monitor/screens/"..filename)
  --Creating a function, that returns a copy! of screen functions
  ENT.GetScreenFunctions[ID] = function(self,noinit)
    local tbl = {}

    for k,v in pairs(SCR) do
      tbl[k] = v
    end

    tbl.Entity = self
    tbl.GetMonitorBool = function(_, id, default) return tbl.Entity:GetNW2Bool(id, default) end
    tbl.GetMonitorInt = function(_, id, default) return tbl.Entity:GetNW2Int(id, default) end
    tbl.GetMonitorString = function(_, id, default) return tbl.Entity:GetNW2String(id, default) end
    tbl.GetServerBool = function(_,id, default)
      if not IsValid(tbl.Entity.Server) then return default end
      return tbl.Entity.Server:GetNW2Bool(id, default)
    end
    tbl.GetServerInt = function(_,id, default)
      if not IsValid(tbl.Entity.Server) then return default end
      return tbl.Entity.Server:GetNW2Int(id, default)
    end
    tbl.GetServerString = function(_,id, default)
      if not IsValid(tbl.Entity.Server) then return default end
      return tbl.Entity.Server:GetNW2String(id, default)
    end
    tbl.EmitSound = function(_,...) return tbl.Entity:EmitSound(...) end
    if not noinit then tbl:Initialize() end
    return tbl
  end
end

function ENT:Think()
  print(2)
end
]]
