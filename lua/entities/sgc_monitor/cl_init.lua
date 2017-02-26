include("shared.lua")

--Lite lib from Wiremod GPU

ENT.material = CreateMaterial("4:3DialComp","UnlitGeneric",{
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 0,
	["$nolod"] = 1,
})
--[[
local mat_pngrt = CreateMaterial("PngRT", "UnlitGeneric", {
	["$basetexture"] = "", ["$ignorez"] = 1,
	["$vertexcolor"] = 1, ["$vertexalpha"] = 1,
	["$nolod"] = 1,
})
function draw.PngToRT(tex)
	local m_type = type(tex)
	tex = tex:GetTexture("$basetexture")
	mat_pngrt:SetTexture("$basetexture", tex)
	return mat_pngrt
end]]

function ENT:ScreenInit(x,y,pos,ang,scale)
  self.XRes = x
  self.YRes = y
  self.SPos = pos
  self.SAng = ang
  self.SScale = scale
  --self.RT = GetRenderTarget("SGC_Mon"..math.random(1,1000), self.XRes, self.YRes)
	--self.material:SetTexture("$basetexture", self.RT)
end
function ENT:ScreenChange(pos,ang,scale)
  self.SPos = pos
  self.SAng = ang
  self.SScale = scale
end

function ENT:DrawRT(x,y,w,h,s)
  if not self.Screen then return end
	render.PushRenderTarget(self.RT,0,0,512 or self.XRes, 512 or self.YRes)
		render.Clear( 0, 0, 0, 0 )
	  cam.Start2D()
	    local succ,err = pcall(self.Screen,self)
	    if not succ then
	      surface.SetAlphaMultiplier(1)
	      ErrorNoHalt(err.."\n")
	    end
    cam.End2D()
	render.PopRenderTarget()
end

function ENT:DrawScreen(x,y,w,h,s)
  if not self.Screen then return end
	self.material:SetTexture("$basetexture", self.RT)
	cam.Start3D2D(self:LocalToWorld(self.SPos), self:LocalToWorldAngles(self.SAng), self.SScale)
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(x,y,w,h)
		render.ClearStencil()
		render.SetStencilEnable(true)
		render.SetStencilTestMask(1);render.SetStencilWriteMask(1);render.SetStencilReferenceValue(1)
		render.SetStencilPassOperation(STENCIL_REPLACE)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)
		render.SetStencilCompareFunction(STENCIL_ALWAYS)
			surface.SetDrawColor(0,0,0,255)
      surface.DrawRect(x,y,w,h)
    render.SetStencilCompareFunction(STENCIL_EQUAL)
			surface.SetDrawColor(255,255,255,255)
			surface.SetMaterial(self.material)
			local w,h = self.XRes,self.YRes
			surface.DrawTexturedRectRotated((w+(512-w))/2,(h+(512-h))/2,512*s,512*s,0)
    render.SetStencilEnable(false)
		render.SetStencilTestMask(0);render.SetStencilWriteMask(0);render.SetStencilReferenceValue(0)
	cam.End3D2D()
end

-------------------------------------

surface.CreateFont("SGC_SG1", {font="Stargate Address Glyphs Concept", size=35, weight=400, antialias=true, additive=false})
surface.CreateFont("SGC_ABS", {font="Stargate Address Glyphs Concept", size=19, weight=400, antialias=true, additive=false})
surface.CreateFont("SGC_ABS1", {font="Stargate Address Glyphs Concept", size=15, weight=400, antialias=true, additive=false})

surface.CreateFont("SGC_Symb", {font="Stargate Address Glyphs Concept", size=90, weight=400, antialias=true, additive=false, })
surface.CreateFont("Marlett_9", {font="Marlett", size=9, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_10", {font="Marlett", size=10, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_11", {font="Marlett", size=11, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_12", {font="Marlett", size=12, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_15", {font="Marlett", size=15, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_16", {font="Marlett", size=16, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_18", {font="Marlett", size=18, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_21", {font="Marlett", size=21, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_22", {font="Marlett", size=22, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_25", {font="Marlett", size=25, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_27", {font="Marlett", size=27, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_29", {font="Marlett", size=29, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_35", {font="Marlett", size=35, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_40", {font="Marlett", size=40, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_45", {font="Marlett", size=45, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_50", {font="Marlett", size=50, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_61", {font="Marlett", size=61, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_Open", {font="Marlett", size=46, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_Err", {font="Marlett", size=19, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_Error", {font="Marlett", size=56, weight=800, antialias=true, additive=false, })
surface.CreateFont("NOSignal", {font="Arial Black", size=30, weight=800, antialias=false, additive=false, })

local Select = surface.GetTextureID("glebqip/select")
local EnergyStar = surface.GetTextureID("glebqip/energystar")
local SGC = surface.GetTextureID("glebqip/sgc")

local SelfDestructCode = surface.GetTextureID("glebqip/active_screen_1/sd_code")
local SelfDestructStandby = surface.GetTextureID("glebqip/active_screen_1/sd_standby")

RT_SGC_Mon = RT_SGC_Mon or GetRTManager("SGC_Mon", 512, 512, 100)
if (SGLanguage ~=nil and SGLanguage.GetMessage ~=nil) then
  ENT.Category = SGLanguage.GetMessage("entity_main_cat")
  ENT.PrintName = SGLanguage.GetMessage("sgc_computer")
end

ENT.CusModelRS = {
	["models/blacknecro/tv_plasma_4_3.mdl"] = {0.11},
	["models/cheeze/pcb/pcb5.mdl"] = {0.078,-0.25},
	["models/cheeze/pcb/pcb6.mdl"] = {0.117,-0.35},
	["models/cheeze/pcb/pcb8.mdl"] = {0.156,-0.45},
	["models/props/cs_assault/billboard.mdl"] = {0.28,-0.7},
	["models/props/cs_militia/reload_bullet_tray.mdl"] = {0.0121},
	["models/props/cs_office/computer_monitor.mdl"] = {0.041},
	["models/props/cs_office/tv_plasma.mdl"] = {0.08,-0.15},
	["models/props_lab/monitor01b.mdl"] = {0.0182,0,-0.25},
}
                                                              
function ENT:Initialize()
  self.RT = RT_SGC_Mon:GetRT()
  self:LoadScreens()

  local monitor
  if WireGPU_Monitors then 
	monitor = WireGPU_Monitors[self:GetModel()]
  end
  local model = self:GetModel():Replace("//","/") -- wtf? why sometiems with two slashes
  if (monitor and model!="models/props_lab/monitor01a.mdl") then  
	local CusData = self.CusModelRS[model] or {}
	local RS = CusData[1] or monitor.RS
	local PFixX = CusData[2] or 0
	local PFixZ = CusData[3] or 0
	self:ScreenInit(512, 384, monitor.offset+monitor.rot:Forward()*(-512/2*RS)+monitor.rot:Right()*(-384/2*RS)+monitor.rot:Right()*PFixX+monitor.rot:Up()*PFixZ, monitor.rot, RS)  
  else  
	self:ScreenInit(512, 384, Vector(11.75, -512/2*0.04, 384/2*0.04+3.9), Angle(0, 90, 85.5), 0.04)
  end
  --[[
  --Colors:Movie
  self.MainColor = Color(30, 120, 240)
  self.ChevBoxesColor = self.MainColor
  self.SecondColor = Color(229, 238, 179)
  --Colors:First series
  self.MainColor = Color(40, 167, 240)
  self.ChevBoxesColor = self.MainColor
  self.SecondColor = Color(200, 200, 200)
  ]]
  --Colors:
  self.MainColor = Color(30, 180, 200)
  self.ChevBoxesColor = self.MainColor
  self.SecondColor = Color(200, 200, 182)
  --self.SecondColor = Color(208, 208, 144)

  self.NoSignalXDir = 1
  self.NoSignalYDir = 1
  self.NoSignalX = 0
  self.NoSignalY = 0
  self.IDCSound = CreateSound(self,"glebqip/idc_loop.wav")
  self.IDCSound:SetSoundLevel(55)
  self.ScrollSND = CreateSound(self,"glebqip/scroll.wav")
  self.ScrollSND:SetSoundLevel(55)
  self.Scrolling = false
end

function ENT:SolveHook(name,old,new)
  if not self.HookBinds[name] then return end
  for id, func in pairs(self.HookBinds[name]) do
    func(self,name,old,new)
  end
end

function ENT:BindNW2Hook(hookname, name, func)
  if not self.HookBinds then self.HookBinds = {} end
  if not self.HookBinds[hookname] then
    self:SetNWVarProxy(hookname,self.SolveHook)
    self.HookBinds[hookname] = {} --create table with funcs
  end
  --table.insert(self.HookBinds[hookname],func)
  self.HookBinds[hookname][name] = func
end

function ENT:Draw()
  self:DrawModel()
  self:DrawScreen(0, -10, 512, 410, 0.96)
  self.CanRender = true
  return true
end

--hi garrysmod.com, i am so lazy
function draw.OutlinedBox(x, y, w, h, thickness)
  for i=0, thickness - 1 do
    surface.DrawOutlinedRect(x + i, y + i, w - i * 2, h - i * 2)
  end
end
local function AnimFromToXY(srcx,srcy,targetx,targety,state)
  return Lerp(state,srcx,targetx), Lerp(state,srcy,targety)
end

function ENT:Screen()
  if not self:GetNW2Bool("On",false) then return end
  if not self:GetNW2Bool("ServerConnected",false) or not IsValid(self.Server) then
    self.NoSignalX = self.NoSignalX + 30*FrameTime()*self.NoSignalXDir
    if self.NoSignalX+210 > 512 then self.NoSignalXDir = -1 elseif self.NoSignalX < 0 then self.NoSignalXDir = 1 end
    self.NoSignalY = self.NoSignalY + 30*FrameTime()*self.NoSignalYDir
    if self.NoSignalY+130 > 384 then self.NoSignalYDir = -1 elseif self.NoSignalY < 0 then self.NoSignalYDir = 1 end

    local x,y = self.NoSignalX,self.NoSignalY
    --self.NoSignalX = self.NoSignalX + 10*FrameTime()
    surface.SetDrawColor(200,200,220)
    surface.DrawRect(x + 0,y + 0,210,30)
    draw.SimpleText("NO SIGNAL", "NOSignal", x+105,y+15, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    for i=0,2 do
      surface.SetDrawColor(i==0 and 255 or 0,i==1 and 255 or 0,i==2 and 255 or 0)
      surface.DrawRect(x + 70*i,y + 30,70,100)
    end
    --draw.SimpleText("POST PLACEHOLDER", "Marlett_21", 0,0, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
  elseif self:GetNW2Int("CurrScreen",0) > 0 then
    self.Screens[self:GetNW2Int("CurrScreen",0)]:Draw(self.MainColor,self.SecondColor,self.ChevBoxesColor)
    surface.SetAlphaMultiplier(1)
    local code = self:GetNW2String("SDCode","")
    if self:GetNW2Int("CurrScreen",0) ~= 7 and self.Server:GetNW2Bool("SelfDestruct",false) and CurTime()%1 > 0.5 then
      surface.SetDrawColor(255,255,255)
      surface.DrawRect(46,106,420,172)
      surface.SetDrawColor(200,40,40)
      surface.DrawRect(52,112,408,160)
      surface.SetDrawColor(45,165,235)
      surface.DrawRect(58,118,396,148)
      draw.SimpleText("DESTRUCT", "Marlett_61", 256,165, Color(200,40,40), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.SimpleText("SEQUENCE ACTIVATED", "Marlett_35", 256,212, Color(200,40,40), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.SimpleText("CODE 2165132146", "Marlett_21", 256,236, Color(200,40,40), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    if self.SDOpTimer or self.SDClTimer and CurTime()-self.SDClTimer <= 0.17 then
      mat = Matrix()
      local anim = 0
      if self.SDOpTimer then
        anim = 1-math.Clamp((CurTime()-self.SDOpTimer)*6,0,1)
      else
        anim = math.Clamp((CurTime()-self.SDClTimer)*6,0,1)
      end
      local x,y = AnimFromToXY(256,166,556,466,anim)
      local sd2t = self.SDEnTimer and CurTime()-self.SDEnTimer
      mat:Translate(Vector(x,y,0))
      mat:Scale(Vector(1-anim,1-anim,1-anim))
      mat:Translate(Vector(0,0,0))
      local color = Color(200,200,182)
      if self:GetNW2Int("SDState",0) == -2 then
        color = Color(114,55,37,255)
      end
      cam.PushModelMatrix(mat)
      surface.SetDrawColor(0,0,0)
      surface.DrawRect(-163,-70,327,140)
      for i=1,#code do
        draw.SimpleText("X", "Marlett_35", -143+i*32,-32, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      end
      surface.SetDrawColor(color)
      if sd2t and sd2t < 0.20 then
        local anim = (sd2t)*5
        surface.DrawRect(-127,-50,256*anim,36)
      elseif sd2t and sd2t < 0.60 and sd2t%0.2 > 0.1 then
        surface.DrawRect(-127,-50,256,36)
      elseif self:GetNW2Int("SDState",0) == -2 then
        surface.DrawRect(-127,-50,256,36)
        draw.SimpleText("Entered code is not valid", "Marlett_21", -143,45, Color(200, 100, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

      end
      surface.SetDrawColor(self.MainColor)
      surface.SetTexture(SelfDestructCode)
      surface.DrawTexturedRectRotated(0,0 ,512,256,0)
      cam.PopModelMatrix()
    end
    if self.SDStTimer then
      mat = Matrix()
      local anim = 0
      anim = 1-math.Clamp((CurTime()-self.SDStTimer)*6,0,1)
      local x,y = AnimFromToXY(256,166,556,466,anim)
      mat:Translate(Vector(x,y,0))
      mat:Scale(Vector(1-anim,1-anim,1-anim))
      mat:Translate(Vector(0,0,0))
      cam.PushModelMatrix(mat)
      surface.SetDrawColor(0,0,0)
      surface.DrawRect(-163,-70,327,140)
      surface.SetDrawColor(Color(114,55,37,255))
      surface.SetTexture(SelfDestructStandby)
      surface.DrawTexturedRectRotated(0,0 ,512,256,0)
      draw.SimpleText(self:GetNW2String("SDName",""), "Marlett_22", 0,-23, Color(114,55,37,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      cam.PopModelMatrix()
    end

    local menu = self:GetNW2Int("MenuChoosed",0)
    local scroll = self:GetNW2Int("MenuScroll",0)
    if menu > 0 then
      surface.SetDrawColor(0,0,0)
      surface.DrawRect(292,168,9,79)
      surface.SetDrawColor(self.MainColor)
      local maxscroll = math.max(0,(#self.Screens-8))
      local scrollsize = math.floor(75/(maxscroll+1))
      surface.DrawRect(293,171+(75-scrollsize)/maxscroll*scroll,7,scrollsize)

      surface.SetTexture(Select)
      surface.DrawTexturedRectRotated(256,192,256,256,0)

      surface.SetDrawColor(self.SecondColor)
      surface.DrawRect(156,149+(menu-scroll)*12,132,11)
      for i=1+scroll,math.min(8+scroll,#self.Screens) do
        if self.Screens[i] then
          draw.SimpleText(self.Screens[i].Name, "Marlett_15", 157,154+(i-scroll)*12, menu == i and Color(0,0,0) or self.SecondColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        else
          draw.SimpleText("*RESERVED*", "Marlett_15", 157,154+(i-scroll)*12, menu == i and Color(0,0,0) or self.SecondColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
      end
    end
  elseif self.Server:GetNW2Bool("On",false) then
    local LoadState = self.Server:GetNW2Int("LoadState",-1)
    if LoadState == -2 then
      for i=0,7 do
        local r = i%4 < 2 and 255 or 0
        local g = i%8 < 4 and 255 or 0
        local b = i%2 == 0 and 255 or 0
        surface.SetDrawColor(r,g,b)
        surface.DrawRect(512/8*i,1,64,384-130-1)
        surface.SetDrawColor(r/2,g/2,b/2)
        for i1=1,4 do
          surface.SetDrawColor(r/5*i1,g/5*i1,b/5*i1)
          surface.DrawRect(512/8*i,334-20*i1,64,20)
        end
        surface.SetDrawColor(255-i*36.4,255-i*36.4,255-i*36.4)
        surface.DrawRect(512/8*i,334,64,49)

        --surface.SetDrawColor(0,0,0,130)
        --surface.DrawRect(256-75,192-13,150,26)
        --draw.SimpleText("NO SIGNAL", "NOSignal", 256,192, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      end
    end
    if LoadState > 1 then
      surface.SetDrawColor(255,255,255)
      surface.SetTexture(EnergyStar)
      surface.DrawTexturedRectRotated(512-75,45,256,128,0)
      surface.SetTexture(SGC)
      surface.DrawTexturedRectRotated(34,25,64,64,0)
      draw.SimpleText("Stargate command BIOS", "Marlett_21", 60,5, Color(200,200,200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
      draw.SimpleText("Copyright (C) 1990-99", "Marlett_21", 60,25, Color(200,200,200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

      if LoadState > 2 then draw.SimpleText("Processor: Intel Pentium MMX 233 MHz", "Marlett_21", 10,20*3, Color(200,200,200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) end
      if LoadState > 3 then
        local time = math.min(25000,(CurTime()-self.StartTime)*25000/3)
        draw.SimpleText(string.format("Memory test: %d %s",time,time == 25000 and "OK" or ""), "Marlett_21", 10,20*4, Color(200,200,200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
      end
      if LoadState > 4 then
        local time = math.min(0x25A80000,(CurTime()-self.StartTime2)*0x25A80000/2)
        draw.SimpleText(string.format("Сhecking resources: 0x%X %s",time,time == 0x25A80000 and "OK" or ""), "Marlett_21", 10,20*5, Color(200,200,200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
      end
      if LoadState > 5 then draw.SimpleText("Booting"..string.rep(".",CurTime()%0.5*6+0.5), "Marlett_21", 10,20*7, Color(200,200,200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) end
    end
  end

  surface.SetAlphaMultiplier(1)
end

function ENT:Think()
  self.Server = self:GetNW2Entity("Server")
  if self.CurrScreen == 2 and self.Screens[2].Scrooling or self.CurrScreen == 5 and self.Screens[5].Scrooling then
    self.ScrollSND:Play()
  else
    self.ScrollSND:Stop()
  end

  if self.CurrScreen ~= 5 or self.Screens[5].State ~= 2 then
    self.IDCSound:Stop()
  else
    self.IDCSound:Play()
    self.IDCSound:ChangeVolume(0.4)
  end
  --Reload screen scripts on change
  if self.RequestScreenReload then
    self.RequestScreenReload = false
    self:LoadScreens()
  end

  if IsValid(self.Server) then
    if self.ColorType ~= self.Server:GetNW2Bool("IsMovie") and 0 or self.Server:GetNW2Bool("Local") and 1 or 2 then
      self.ColorType = self.Server:GetNW2Bool("IsMovie") and 0 or self.Server:GetNW2Bool("Local") and 1 or 2
      if self.ColorType == 0 then
        --Colors:Movie
        self.MainColor = Color(30, 120, 240)
        self.ChevBoxesColor = self.MainColor
        self.SecondColor = Color(229, 238, 179)
      elseif self.ColorType == 1 then
        --Colors:First series
        self.MainColor = Color(40, 167, 240)
        self.ChevBoxesColor = self.MainColor
        self.SecondColor = Color(200, 200, 200)
      else
        --Colors:Fifth race
        self.MainColor = Color(30, 180, 200)
        self.ChevBoxesColor = self.MainColor
        self.SecondColor = Color(200, 200, 182)
      end
    end

    if self.CurrScreen ~= self:GetNW2Int("CurrScreen",0) then
      self.CurrScreen = self:GetNW2Int("CurrScreen",0)
      if self.Screens[self.CurrScreen] then
        self.Screens[self.CurrScreen]:Initialize(true)
      end
    end
    if self:GetNW2Int("CurrScreen",0) > 0 then
      for k,v in pairs(self.Screens) do
        v:Think(self.CurrScreen == k)
      end
    end
    local LoadState = self.Server:GetNW2Int("LoadState",-1)
    if LoadState > 0 then
      if LoadState > 3 then
        if not self.StartTime then
          self.StartTime = CurTime()
        end
      else
        self.StartTime = nil
        self.StartTime2 = nil
      end
      if LoadState > 4 and not self.StartTime2 then
        self.StartTime2 = CurTime()
      end
    end
    local SDState = self:GetNW2Int("SDState",0)
    if SDState == 1 and not self.SDOpTimer then
      self.SDOpTimer = CurTime()--(1-math.Clamp((CurTime()-(self.SDClTimer or CurTime()))*6,0,1))
      self.SDClTimer = nil
    end
    if (SDState == -1 or SDState == 0 or SDState == 3) and not self.SDClTimer and self.SDOpTimer then
      self.SDClTimer = CurTime()--(1-math.Clamp((CurTime()-(self.SDOpTimer or CurTime()))*6,0,1))
      self.SDOpTimer = nil
    end
    if self.SDClTimer and CurTime()-self.SDClTimer > 0.2 then
      self.SDClTimer = nil
    end
    if SDState == 2 and not self.SDEnTimer then
      self.SDEnTimer = CurTime()
    elseif SDState ~= 2 and self.SDEnTimer then
      self.SDEnTimer = nil
    end
    if SDState == -1 and not self.SDStTimer and not self.SDOpTimer and not self.SDEnTimer then
      self.SDStTimer = CurTime()
    elseif SDState ~= -1 and self.SDStTimer then
      self.SDStTimer = nil
    end
    local timer = self.Server:GetNW2Int("SDTimer",0)
    if self.Server:GetNW2Bool("SelfDestruct",false) and timer ~= self.DestructTime then
      if self.DSound then self:EmitSound("glebqip/self_destruct_beep3.wav",65,100,0.2) end
      self.DSound = timer%1 < 0.5
      self.DestructTime = timer
    end
  end

  if self.CanRender then self:DrawRT(0, -10, 512, 410, 0.96) end
  self.CanRender = false
end

function ENT:OnRemove()
  self.ScrollSND:Stop()
  self.IDCSound:Stop()
	local RT = self.RT
	timer.Simple(0.1, function()
		if IsValid(self) then return end
		RT_SGC_Mon:FreeRT(RT)
	end)
end
