
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
  Name = "7 Chevron",
  ID = 6,
}

if SERVER then
  function SCR:Initialize()
    self.Move = false
  end

  function SCR:Think(curr,dT)
  end
  function SCR:Trigger(curr,key,value)
    if not curr then return end
    if key == StarGate.KeyEnter and value and IsValid(self.Entity.Server) and IsValid(self.Entity.Server.LockedGate) then
      self.Move = not self.Move
      self.Entity.Server.LockedGate.RingSpeed = 0
      --self.Server.LockedGate:ActivateRing(self.Move,false)
      self.Entity.Server.LockedGate:ActivateRing(self.Move,self.Move )
    end
  end
else
  function SCR:Initialize()
  end

  local MainFrame = surface.GetTextureID("glebqip/chevron7_screen/mainframe")

  local Red = Color(239,0,0)
  local SEQ = "l/-\\"
  function SCR:Draw(MainColor, SecondColor, ChevBoxesColor)
  --local x, y = self:GetPos()
  local gate = self:GetServerEntity("Gate")
  if self:GetServerBool("Connected",false) and IsValid(gate) then
    render.RenderView( {
      origin = gate:LocalToWorld(Vector( 26, 0, 120 )), -- change to your liking
      angles = gate:LocalToWorldAngles(Angle( 0, 180, 20 )), -- change to your liking
      x = 1,
      y = 1,
      w = 510,
      h = 382,
      fov = 70,
     } )
   else
     draw.SimpleText("OFFLINE", "Marlett_61", 247, 190, Color(200,0,0,math.abs(math.sin(CurTime()*math.pi/2))*255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
   end

    surface.SetAlphaMultiplier(0.6)
    surface.SetDrawColor(MainColor)
    surface.SetTexture(MainFrame)
    surface.DrawTexturedRectRotated(256,192,512,512,0)
    if self:GetServerBool("RingRotation",false) then
      surface.SetAlphaMultiplier(1)
      --draw.SimpleText("ROTATING"..string.rep(".",CurTime()%0.5*6+0.5), "Marlett_40", 38, 344, Color(0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
      draw.SimpleText("ROTATING", "Marlett_40", 38, 344, Color(0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
      surface.SetDrawColor(0,0,0)
      local anim = math.ceil(CurTime()%0.5*8)
      if not self:GetServerBool("RingDir",false) then
        anim = 5-anim
      end
      if anim ~= 4 then
        draw.DrawTLine(218+3,344+math.max(-1,2-anim)*12,232+3,344-math.max(-1,2-anim)*12,4)--225
      else
        draw.DrawTLine(225+3,344-12,225+3,344+12,4)--225
      end
      --draw.SimpleText(SEQ[math.ceil(CurTime()%0.5*8)], "Marlett_40", 215, 344, Color(0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

  end
  function SCR:Think(curr)
    if not curr then return end
  end
end

return SCR
