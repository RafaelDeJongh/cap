/* Copyright (C) 2016 by glebqip */
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
for _,filename in pairs(file.Find("entities/sgc_monitor/screens/*.lua","LUA")) do AddCSLuaFile("entities/sgc_monitor/screens/"..filename) end
ENT.ClientVer = 1

include("shared.lua")

function ENT:Initialize()
  //self:SetModel(self.Model or "models/props_lab/monitor01a.mdl")
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)
  self:SetUseType(1)

  self.On = true

  self.Key = self.Key or 83
  self.KeyD = self.KeyD or 92
  self.Screen = self.Screen or 0
  self:LoadScreens()
  if WireLib then
    self:CreateWireInputs("Toggle","Disable Use")
    self:CreateWireOutputs("On","Program","Program Name [STRING]")
  end
  self.Keys = {}

  self.MenuChoosed = 0
  self.MenuScroll = 0
  
  self.Keyboard = NULL;
  self.Server = NULL;
  
  self:UpdateProgram()
  self.DeltaTime = 0
  self.OldTime = CurTime()
end

function ENT:SpawnFunction(ply, tr)
  if (not tr.Hit) then return end

  local ang = ply:GetAimVector():Angle()
  ang.p,ang.r = 0,0
  ang.y = (ang.y+180)%360

  local ent = ents.Create("sgc_monitor")
  ent:SetAngles(ang)
  ent:SetPos(tr.HitPos+Vector(0, 0, 20))
  ent:Spawn()
  ent:Activate()
  ent.SpawnedPly = ply

  local phys = ent:GetPhysicsObject()
    if IsValid(phys) then phys:EnableMotion(false) end
  return ent
end

function ENT:Think()
  if self.RequestScreenReload then
    self.RequestScreenReload = false
    self:LoadScreens()
    self.RequestScreenReload = false
  end
  local srv = self.Server
  self:SetNW2Bool("ServerConnected",IsValid(srv))
  self:SetNW2Bool("On",self.On)
  if not IsValid(srv) then
    self:NextThink(CurTime()+0.05)
    return true
  end

  if not self.Server.On and self.Screen!=0 then 
    self.TmpScreen = self.Screen
    self.Screen = 0
	self:UpdateProgram()
  end

  if self.Server.State == -1 and self.Screen == 0 and self.Server.On then
    self.Screen = self.TmpScreen or 1
    self.TmpScreen = nil
    self:UpdateProgram()
  elseif (self.Server.State ~= -1 or not self.Server.On) and self.Screen ~= 0 then
    self.TmpScreen = self.Screen
    self.Screen = 0
    self.MenuChoosed = 0
    self:UpdateProgram()
  end
  self:SetNW2Entity("Server",srv)
  self:SetNW2Int("CurrScreen",self.Screen)
  self:SetNW2Int("MenuChoosed",self.MenuChoosed)
  self:SetNW2Int("MenuScroll",self.MenuScroll)
  --if self.Inputs.Keyboard.Path then
  if IsValid(self.Keyboard) then
    local keyb = self.Keyboard --self.Inputs.Keyboard.Path[1].Entity
    for k,v in pairs(self.Keys) do
      if not keyb.ActiveKeys[v] then
        self:Trigger(k,false)
        self.Keys[k] = nil
      end
    end
    for k,v in pairs(keyb.ActiveKeys) do
      local key = keyb:GetRemappedKey(k)
      if not self.Keys[key] then
        self:Trigger(key,true)
        self.Keys[key] = k
      end
    end
  end
  for k,v in pairs(self.Screens) do
    v:Think(self.Screen == k,self.DeltaTime)
  end
  self.DeltaTime = CurTime()-self.OldTime
  self.OldTime = CurTime()
  self:NextThink(CurTime()+0.05)
  return true
end

function ENT:UpdateProgram()
  self:SetWire("Program",self.Screen or 0)
  if (self.Screens[self.Screen]) then
    self:SetWire("Program Name",self.Screens[self.Screen].Name)
  else
    self:SetWire("Program Name","")
  end
end

function ENT:Trigger(key, value)
  if key == StarGate.KeysConst[KEY_ENTER] and value and self.MenuChoosed > 0 and self.Screens[self.MenuChoosed] then
    self.Screen = self.MenuChoosed
    self.MenuChoosed = 0
    self:UpdateProgram()
    return
  end
  if IsValid(self.Keyboard) and key == self.Keyboard:GetRemappedKey(self.Key) and value then
    if self.MenuChoosed > 0 then
      self.MenuChoosed = 0
    else
      self.MenuChoosed = self.Screen
      self.MenuScroll = 0
    end
  end
  if self.MenuChoosed > 0 and key == 18 and value then
    self.MenuChoosed = math.min(#self.Screens,self.MenuChoosed + 1)
  end
  if self.MenuChoosed > 0 and key == 17 and value then
    self.MenuChoosed = math.max(1,self.MenuChoosed - 1)

  end
  if self.MenuScroll < self.MenuChoosed-8 then
    self.MenuScroll = self.MenuChoosed-8
  end
  if self.MenuScroll > self.MenuChoosed-1 then
    self.MenuScroll = self.MenuChoosed-1
  end
  if self.MenuChoosed ~= 0 then return end
  for k,v in pairs(self.Screens) do
    if v:Trigger(self.Screen == k,key,value) then return end
  end
end

function ENT:TriggerInput(key, value)
  if(key=="Toggle" and value > 0) then
    self.On = not self.On
    self:SetWire("On",self.On)
  elseif(key=="Disable Use") then
    self.DisableUse = util.tobool(value)
  end
end

function ENT:Use(_,_,val)
  if val > 0 and not self.DisableUse then
    self.On = not self.On
    self:SetWire("On",self.On)
  end
end

function ENT:IsHoldDKey()
	if IsValid(self.Keyboard) and self.Keys[self.Keyboard:GetRemappedKey(self.KeyD)] then
		return true
	end
	return false
end

function ENT:Touch(ent)
  if not IsValid(self.Server) and ent.ServerVer == self.ClientVer then
    self.Server = ent
    local ed = EffectData()
    ed:SetEntity(self)
    util.Effect("propspawn", ed, true, true)
  elseif not IsValid(self.Keyboard) and ent.ActiveKeys and not IsValid(ent.SGCScreen) then
    self.Keyboard = ent
	ent.SGCScreen = self
    local ed = EffectData()
    ed:SetEntity(self)
    util.Effect("propspawn", ed, true, true)
  end
end

function ENT:OnRemove()
	if (IsValid(self.Keyboard)) then
		self.Keyboard.SGCScreen = nil
		if (self.KeyboardSpawned) then
			self.Keyboard:Remove()
		end
	end
end

function ENT:FindNearestClass(class,pos,dist)
	dist = dist or 2000;
	local ents = ents.FindByClass(class)
	local fent,ldist = nil,dist
	for k,v in pairs(ents) do
		local e_pos = v:GetPos();
		if ((e_pos - pos):Length()<=dist) then
			local dist = (e_pos - pos):Length();
			if (dist<ldist) then
				fent = v
				ldist = dist
			end
		end                                  
	end
	return fent
end

function ENT:PreEntityCopy()
	local dupeInfo = {};

	dupeInfo.Screen = self.TmpScreen or self.Screen;
	dupeInfo.On = self.On;

	dupeInfo.Keyboard = self.Keyboard:EntIndex();
	dupeInfo.Server = self.Server:EntIndex();
	
    duplicator.StoreEntityModifier(self, "StarGateSGCMonitorInfo", dupeInfo)
	StarGate.WireRD.PreEntityCopy(self);
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable("sgc_screen",ply,"tool")) then Ent:Remove(); return end

	if (IsValid(ply)) then
		if(ply:GetCount("CAP_sgc_screens")>=GetConVar("sbox_maxsgc_monitor"):GetInt()) then
			ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"stool_sgcscreen_limit\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			Ent:Remove();
			return
		end
		ply:AddCount("CAP_sgc_screens", Ent);
	end

	local dupeInfo = Ent.EntityMods.StarGateSGCMonitorInfo

	if (dupeInfo.Screen) then
		self.TmpScreen = dupeInfo.Screen;
	end
	
	if (dupeInfo.On!=nil) then
		self.On = dupeInfo.On;
		self:SetWire("On",self.On)
	end
	
	if (dupeInfo.Keyboard and CreatedEntities[dupeInfo.Keyboard]) then
		self.Keyboard = CreatedEntities[dupeInfo.Keyboard];
		CreatedEntities[dupeInfo.Keyboard].SGCScreen = Ent;
	end
	if (dupeInfo.Server and CreatedEntities[dupeInfo.Server]) then
		self.Server = CreatedEntities[dupeInfo.Server];
	end
	
	if (IsValid(ply)) then
		self.Owner = ply;
		self:SetNWEntity("Owner",ply);
	end

	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "sgc_server", StarGate.CAP_GmodDuplicator, "Data" )
end