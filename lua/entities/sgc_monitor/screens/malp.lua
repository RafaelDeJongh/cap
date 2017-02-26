
hook.Add("SetupPlayerVisibility","ScreenPVSChecks",function(ply)
  for _,ent in pairs(ents.FindByClass("gmod_sg_monitor")) do
    if ent.On and ent.Screen == 6 and IsValid(ent.Server) and IsValid(ent.Server.LockedGate) and ply:TestPVS(ent) then
      AddOriginToPVS(ent.Server.LockedGate:GetPos())
    end
  end
end)
---------------------
-- Screen: IDC s1 --
-- Author: glebqip --
-- ID: 2 --
---------------------
local SCR = {
  Name = "MALP Screen",
  ID = 11,
}

if SERVER then
  function SCR:Initialize()
    self.MALPCheck = CurTime()-10
    self.Selected = 1
	self.MALPList = {}
  end

  function SCR:Think(curr,dT)
    if self.MALP and not IsValid(self.MALP) then
      self.MALPCheck = CurTime()-12
    end
    if self.Selected > #self.MALPList then
      self.MALP = self.MALPList[self.Selected]
      self.Selected = #self.MALPList
    end
	if CurTime()-self.MALPCheck > 10 then
      self.MALPList = ents.FindByClass("malp")
      self.MALPCheck = CurTime()
    end

    self:SetMonitorBool("MALPConnected",true)
    self:SetMonitorEntity("MALP",self.MALP and self.MALP.SignalLost and NULL or self.MALP)
  end
  function SCR:Trigger(curr,key,value)
    if not curr then return end
    if key == 19 and value then
      self.Selected = self.Selected - 1
      if self.Selected < 1 then self.Selected = #self.MALPList end
      self.MALP = self.MALPList[self.Selected]
    end
    if key == 20 and value then
      self.Selected = self.Selected + 1
      if #self.MALPList < self.Selected then self.Selected = 1 end
      self.MALP = self.MALPList[self.Selected]
    end
  end
else
  function SCR:Initialize()
    self.Boxes = {}
    self.BoxesTimer = CurTime()-10
    self.BoxTimer = CurTime()
  end

  local MainFrame = surface.GetTextureID("glebqip/malp_screen/mainframe")
  local SignalLost = surface.GetTextureID("effects/security_noise2")

  local Red = Color(239,0,0)
  --local mat = StarGate.MaterialCopy("MalpBlur","pp/blurscreen");
  function SCR:Draw(MainColor, SecondColor, ChevBoxesColor)
  --local x, y = self:GetPos()
  local malp = self:GetMonitorEntity("MALP")
  if self:GetMonitorBool("MALPConnected",false) and IsValid(malp) then
    render.RenderView( {
      origin = malp:LocalToWorld(Vector( 32.5, 15, 35.5 )), -- change to your liking
      angles = malp:LocalToWorldAngles(Angle( 0, 0, 0 )), -- change to your liking
      x = 1,
      y = 1,
      w = 510,
      h = 382,
      fov = 90,
     } )
   end
   surface.SetAlphaMultiplier(0.6)
   surface.SetDrawColor(Color(255,255,255,20))
   surface.SetTexture(SignalLost)

    surface.SetAlphaMultiplier(0.6)
    surface.SetDrawColor(MainColor)
    surface.SetTexture(MainFrame)
    surface.DrawTexturedRectRotated(256,192,512,512,0)

    local anim = (CurTime()-self.BoxTimer)
    if anim < 0.5 then
      surface.SetAlphaMultiplier(anim*2)
      print(anim*2)
    elseif anim > 3 then
      surface.SetAlphaMultiplier((3.5-anim)*2)
    else
      surface.SetAlphaMultiplier(1)
    end
    surface.SetDrawColor(MainColor)
    surface.DrawRect(173,332,14,14,0)
    surface.SetAlphaMultiplier(math.abs(math.sin(CurTime()*math.pi/1.1)))
    draw.SimpleText("INPUT", "Marlett_16", 16, 305, Color(0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    surface.SetAlphaMultiplier(1)
    draw.SimpleText("M.A.L.P.", "Marlett_21", 287, 335-20, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("SIGNAL", "Marlett_21", 287, 335, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    if self:GetMonitorBool("MALPConnected",false) and IsValid(malp) then
      draw.SimpleText("UPLINKED", "Marlett_21", 287, 335+20, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
      draw.SimpleText("LOST", "Marlett_21", 287, 335+20, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    surface.SetDrawColor(MainColor)
    for i=1,18 do
      if self.Boxes[i] then
        local x,y = 0,0
        if i > 9 then x = 38 end
        surface.DrawRect(101+i%3*7+x,330+math.ceil(i/3-1)%3*7+y,4,4)
      end
    end
    --[[
      local dist = (pos-malp:GetPos()):Length()

      -- this is the distance at which we start losing the signal
      local badDist = 5000-350;

      if (dist > badDist) then
        if(p.SignalLost) then
          -- FIXME: make a better effect (tv static or something)
          local n = dist-badDist;

          mat:SetFloat( "$blur", (n/20)*(math.sin(time)+3));
          surface.SetMaterial(mat);
          surface.SetDrawColor(255, 255, 255, 255);
          surface.DrawTexturedRect(0, 0, w, h);
          render.UpdateScreenEffectTexture();

          surface.SetDrawColor(0, 0, 0, math.Clamp(n*3/4, 0, 255));
          surface.DrawRect(-1, -1, w+1, h+1);
          ]]
  end
  function SCR:Think(curr)
    if not curr then return end
    if CurTime()-self.BoxTimer > 6 then
      self.BoxTimer = CurTime()
    end
    if CurTime()-self.BoxesTimer > 3 and self:GetMonitorBool("MALPConnected",false) then
      for i=1,18 do
        self.Boxes[i] = math.random()>0.6
      end
      self.BoxesTimer = CurTime()
    end
  end
end

--return SCR
