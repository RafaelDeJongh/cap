ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "MALP"
ENT.Author = "RononDex\n \n Mobile Analysis Labatory Probe"
ENT.Category = "Stargate Carter Addon Pack"
list.Set("CAP.Entity", ENT.PrintName, ENT);

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end
AddCSLuaFile()

ENT.Sounds = {
	Drive = Sound("vehicles/malp_drive.wav"),
}

function ENT:SpawnFunction(pl,tr)
	if(pl:GetCount("malp")>0) then return end
	local e = ents.Create("malp");
	e:SetPos(tr.HitPos + Vector(0,0,20));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0))
	e:Spawn();
	e:Activate();
	e:SetVar("Owner",pl)
	e.Owner = pl;

	e:SpawnWheels() -- Spawn the wheels
	e:SpawnCamera() -- Spawn the camera prop
	e:SpawnCamStand() -- Spawn the camera stand
	e:SpawnRTCam()

	pl:Give("weapon_malp_remote")
	pl:SelectWeapon("weapon_malp_remote")
	pl:AddCount("malp",e)
	return e;
end


function ENT:Initialize()

	self:SetModel("models/madjawa/malp/malp.mdl")
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)

	self.MalpWheels={}

	self.environment={} -- LS Table
	self.NextUse=CurTime() -- For toggling

	self.Sounds.LoopSound = CreateSound(self.Entity, self.Sounds.Drive);
end

--########## Spawn our wheel props @RononDex
function ENT:SpawnWheels(pl)
	util.PrecacheModel("models/madjawa/malp/malpwheel.mdl");

	local right = self:GetRight();
	local forward = self:GetForward();
	local poss = self:GetPos();
	local angg = self:GetAngles();

	local pos = {}
	pos[1] = poss+right*-25
	pos[2] = poss+right*-25+forward*30
	pos[3] = poss+right*-25+forward*-30
	pos[4] = poss+right*25
	pos[5] = poss+right*25+forward*30
	pos[6] = poss+right*25+forward*-30

	local norm = {}
	norm[1] = right*-1
	norm[2] = right*-1
	norm[3] = right*-1
	norm[4] = right
	norm[5] = right
	norm[6] = right

	local ang = {}
	ang[1] = angg+Angle(90,0,0)
	ang[2] = angg+Angle(90,0,0)
	ang[3] = angg+Angle(90,0,0)
	ang[4] = angg+Angle(-90,180,0)
	ang[5] = angg+Angle(-90,180,0)
	ang[6] = angg+Angle(-90,180,0)

	for i=1,6 do
		local e = ents.Create("prop_physics");
		e:SetModel("models/madjawa/malp/malpwheel.mdl");
		e:SetPos(pos[i]);
		e:SetAngles(ang[i]);
		e:Spawn();
		e:Activate();
		e:GetPhysicsObject():Wake();
		e:GetPhysicsObject():SetMass(100);
		--constraint.Axis(self, e, 0, 0, pos[i], pos[i], 0, 0, 50, 1, norm[i])
		constraint.Ballsocket(self, e, 0, 0, Vector(0, 20, 0), 0, 0, 1);
		constraint.Ballsocket(self, e, 0, 0, Vector(0, -20, 0), 0, 0, 1);
		self.MalpWheels[i] = e;
	end
end

--######### What happens when we remove it @RononDex
function ENT:OnRemove()
	if self.Sounds.LoopSound then
		self.Sounds.LoopSound:Stop();
		self.Sounds.LoopSound = nil;
	end
	for i=1,6 do
		if(IsValid(self.MalpWheels[i])) then
			self.MalpWheels[i]:Remove()
		end
	end
	if(self.Control) then
		if(self.FirstPerson) then
			self:StopSpectate(self.Controler)
		end
		self:UnControl(self.Controler)
	end
	UpdateRenderTarget(NULL)
end

--######### Take control @RononDex
function ENT:StartControl(p)

	if(IsValid(self)) then
		self.Control=true
		self.Controler=p
		p:SetNetworkedBool("ControllingMALP",true)
	end
end

--########Loose control @RononDex
function ENT:UnControl(p)

	if(IsValid(self)) then
		if(self.FirstPerson) then
			self:StopSpectate(p)
		end
		self.Control=false
		self.Controler:SetNWBool("ControllingMALP",false)
		self.Controler=NULL
	end
end


function ENT:Think()

	if(IsValid(self.Controler)) then
		self.environment = self.environment or {};
		umsg.Start("MALPData", self.Controler)
			umsg.Bool(self.SignalLost)
			umsg.Short(self.gravity2 or 1)
			umsg.Short(self.environment.habitat or 1)
			umsg.Short(self.environment.atmosphere or 1)
			umsg.Short(self.environment.temperature or 288)
		umsg.End()
	end

	if(self.HasRD) then
		if(self.FirstPerson) then
			self:Sense()
		end
	end


	
	local dist = (self.Owner:GetPos() - self:GetPos()):Length();	
	if(dist>5000) then
		self.gate = self:FindGate(5000)
		self.pgate = self:FindPlayerGate(5000)
		if(IsValid(self.pgate)) then
			if(self.pgate.IsOpen) then
				self.pgate.EventHorizon.AutoClose = false;
				self.pgate.DisAutoClose = true;
				for k,v in pairs(self.gate) do
					if(v.EventHorizon==self.pgate.EventHorizon.Target) then
						if(IsValid(v.EventHorizon)) then
							v.EventHorizon.AutoClose = false;
						end
						self.pgate.DisAutoClose = true;
						self.SignalLost = false;
						UpdateRenderTarget(self.RTCamera);
					end
				end
			else
				self.SignalLost = true;
				UpdateRenderTarget(NULL);
			end
		end
	else
		self.SignalLost = false;
		UpdateRenderTarget(self.RTCamera);
	end
	/*
	if(IsValid(self.gate)) then
		if(self.gate.IsOpen) then
			self.gate.EventHorizon.AutoClose=false
			if(IsValid(self.pgate) and IsValid(self.pgate.EventHorizon)) then
				self.pgate.EventHorizon.AutoClose=false
				if(IsValid(self.pgate.EventHorizon.Target) and self.pgate.EventHorizon.Target==self.gate.EventHorizon) then --Only if the player is near the gate that is active with the malps gate
					self.SignalLost=false
					UpdateRenderTarget(self.RTCamera)
				end
			end
		else
			self.SignalLost=true
			UpdateRenderTarget(NULL)
		end
	end
	*/
	if(IsValid(self.Controler)) then
		if(self.FirstPerson) then

			if(self.Controler:KeyDown("MALP","CAMUP")) then
				self.Camera:SetAngles(self.Camera:GetAngles()+Angle(-1,0,0))
			elseif(self.Controler:KeyDown("MALP","CAMLEFT")) then
				self.Camera:SetAngles(self.Camera:GetAngles()+Angle(0,1,0))
					self.CamStand:SetAngles(self.CamStand:GetAngles()+Angle(0,1,0))
			elseif(self.Controler:KeyDown("MALP","CAMRIGHT")) then
				self.Camera:SetAngles(self.Camera:GetAngles()+Angle(0,-1,0))
				self.CamStand:SetAngles(self.CamStand:GetAngles()+Angle(0,-1,0))
			elseif(self.Controler:KeyDown("MALP","CAMDOWN")) then
				self.Camera:SetAngles(self.Camera:GetAngles()+Angle(1,0,0))
			end

			if(self.Controler:KeyDown("MALP","RESETCAM")) then
				self.Camera:SetAngles(self:GetAngles())
			end
		end
	end

	if(self.Control) then
		if(IsValid(self.Controler)) then

			if(self.Controler:KeyDown("MALP","CONTROL")) then
				self:UnControl(self.Controler)
			end

			if(self.Controler:KeyDown("MALP","VIEW")) then
				if(self.NextUse<CurTime()) then
					if(not(self.FirstPerson)) then
						self:FirstPersonSpectate(self.Controler)
					else
						self:StopSpectate(self.Controler)
					end
					self.NextUse=CurTime()+1
				end
			end

			self:PhysicOverdrive() -- Added by Mad

		end
	end

	-- this sohuld be enabled or we have too slow camera rotation @AlexALX
	if(self.Control) then
		self:NextThink(CurTime())
		return true
	else
		self:NextThink(CurTime()+1)
		return true
	end
end

--######### Added by Madman07 to avoid flying malp:p
function ENT:PhysicOverdrive()
	-- prevent malp flying @AlexALX
	if (self.nextphys and self.nextphys>CurTime()) then return end
	self.nextphys = CurTime()+0.1;

	local spd = 0;
	local trn = 0;
	local dovel = false;

	if(self.Controler:KeyDown("MALP","LEFT")) then trn = 70; dovel = true;
	elseif(self.Controler:KeyDown("MALP","RIGHT")) then trn = -70; dovel = true; end

	if(self.Controler:KeyDown("MALP","FWD")) then spd = 160; dovel = true;
	elseif(self.Controler:KeyDown("MALP","BACK")) then spd = -100; dovel = true; end

	local vel1 = self:GetForward()*(spd-trn);
	local vel2 = self:GetForward()*(spd+trn);

	if dovel then
		if self.Sounds.LoopSound then
			self.Sounds.LoopSound:Play();
			self.Sounds.LoopSound:SetSoundLevel(130);
			self.Sounds.LoopSoundFade = false;
		end

  		if (IsValid(self.MalpWheels[1]) and IsValid(self.MalpWheels[1]:GetPhysicsObject())) then
			self.MalpWheels[1]:GetPhysicsObject():SetVelocity(vel1);
		end
  		if (IsValid(self.MalpWheels[2]) and IsValid(self.MalpWheels[2]:GetPhysicsObject())) then
			self.MalpWheels[2]:GetPhysicsObject():SetVelocity(vel1);
		end
  		if (IsValid(self.MalpWheels[3]) and IsValid(self.MalpWheels[3]:GetPhysicsObject())) then
			self.MalpWheels[3]:GetPhysicsObject():SetVelocity(vel1);
		end

  		if (IsValid(self.MalpWheels[4]) and IsValid(self.MalpWheels[4]:GetPhysicsObject())) then
			self.MalpWheels[4]:GetPhysicsObject():SetVelocity(vel2);
		end
  		if (IsValid(self.MalpWheels[5]) and IsValid(self.MalpWheels[5]:GetPhysicsObject())) then
			self.MalpWheels[5]:GetPhysicsObject():SetVelocity(vel2);
		end
  		if (IsValid(self.MalpWheels[6]) and IsValid(self.MalpWheels[6]:GetPhysicsObject())) then
			self.MalpWheels[6]:GetPhysicsObject():SetVelocity(vel2);
		end
	else
		if self.Sounds.LoopSound and not self.Sounds.LoopSoundFade then
			self.Sounds.LoopSound:FadeOut(1);
			self.Sounds.LoopSoundFade = true;
		end
	end
end

function ENT:SpawnCamera(ent)

	if(IsValid(self)) then
		local e = ent or ents.Create("prop_physics")
		e:SetModel("models/madjawa/malp/malpcam.mdl")
		e:SetPos(self:GetPos()+self:GetRight()*-15+self:GetUp()*35.5+self:GetForward()*32.5)
		e:SetAngles(self:GetAngles())
		e:Spawn()
		e:Activate()
		e:SetParent(self)
		self.Camera=e
	end
end

function ENT:SpawnCamStand(ent)

	if(IsValid(self)) then
		local e = ent or ents.Create("prop_physics")
		e:SetModel("models/madjawa/malp/malpcamstand.mdl")
		e:SetPos(self:GetPos()+self:GetRight()*-15+self:GetUp()*35.5+self:GetForward()*32.5)
		e:SetAngles(self:GetAngles())
		e:Spawn()
		e:Activate()
		e:SetParent(self)
		self.CamStand=e
	end
end

function ENT:FirstPersonSpectate(p)
	self.FOV = self.Controler:GetFOV()
	--self.Controler:Spectate( OBS_MODE_FIXED );
	self.Controler:SetObserverMode( OBS_MODE_FIXED )
	--self.Controler:DrawViewModel(false)
	self.Controler:SetMoveType(MOVETYPE_OBSERVER);
	--self.Controler:SetPos(self.Controler:GetPos()+Vector(0,0,-65));
	self.Controler:SetNWEntity("MALP",self);
	self.Controler:SetNWBool("FirstPerson",true)
	self.Controler:SetEyeAngles(self.Camera:GetAngles()+Angle(0,180,0));
	self.Controler:SetViewEntity(self.Camera)
	self.FirstPerson=true
	self.OriginPos=self.Controler:GetPos()
end

function ENT:StopSpectate(p)
	--self.Controler:UnSpectate();
	self.Controler:SetMoveType(MOVETYPE_VPHYSICS);
	--self.Controler:DrawViewModel(true)
	self.Controler:Spawn();
	self.Controler:SetPos(self.OriginPos)
	self.Controler:SetFOV(self.FOV,0.3);
	self.Controler:SetNWBool("FirstPerson",false)
	self.Controler:SetNWEntity("MALP", NULL);
	self.Controler:SetViewEntity(self.Controler)
	self.Controler:SelectWeapon("weapon_malp_remote")
	self.FirstPerson=false
end

function ENT:FindGate(dist)  --######### @ aVoN
	local gate = {};
	local pos = self:GetPos();
	for k,v in pairs(ents.FindByClass("stargate_*")) do -- Find the gates by their class name
		local sg_dist = (pos - v:GetPos()):Length();
		if(dist >= sg_dist) then
			dist = sg_dist;
			gate[k] = v;
		end
	end
	return gate; -- Returns what we've found, a gate or no gate.
end

function ENT:SpawnRTCam(ent)

	if(IsValid(self)) then
		local e = ent or ents.Create("gmod_cameraprop")
		e:SetPos(self.Camera:GetPos())
		e:Spawn()
		e:Activate()
		e:SetParent(self.Camera)
		e:SetAngles(self:GetAngles())
		e:SetRenderMode(RENDERMODE_TRANSALPHA)
		e:SetColor(Color(255,255,255,0))
		UpdateRenderTarget(e)
		self.RTCamera=e
	end
end

function ENT:FindPlayerGate(dist)
	if (not IsValid(self.Owner)) then return end
	local gate;
	local pos = self.Owner:GetPos();
	for _,v in pairs(ents.FindByClass("stargate_*")) do -- Find the gates by their class name
		local sg_dist = (pos - v:GetPos()):Length(); -- Distance between the player and the gate
		if(dist >= sg_dist) then -- is the defined distance bigger than the distance between the player and gate
			dist = sg_dist;
			gate = v;
		end
	end
	return gate; -- Returns what we've found, a gate or no gate.
end

--######### Get Environment info @RononDex
function ENT:Sense()

	if self.planet then
		self.gravity2 = self.gravity
	else
		self.gravity2 = 0
	end
	if (self.damaged == 1) then
		local test = math.random(1, 10)
		if (test <= 2) then
			self.environment.habitat = math.random(0, 1)
		elseif (test <= 3) then
			self.environment.atmosphere = self.environment.atmosphere + math.random(-100, 100)
		elseif (test <= 4) then
			self.environment.temperature = self.environment.temperature + math.random((1 - self.environment.temperature), self.environment.temperature)
		elseif (test <= 5) then
			self.gravity2 = self.gravity + math.random(-1, 1)
		end
	end
	self.gravity2 = self.gravity2 * 100
end

function ENT:PreEntityCopy()
	local dupeInfo = {}

	dupeInfo.MalpWheels = {}
	for i=1,6 do
		if(IsValid(self.MalpWheels[i])) then
			dupeInfo.MalpWheels[i] = self.MalpWheels[i]:EntIndex();
		end
	end

	if (IsValid(self.CamStand)) then
		dupeInfo.CamStand = self.CamStand:EntIndex();
	end

	if (IsValid(self.Camera)) then
		dupeInfo.Camera = self.Camera:EntIndex();
	end

	if (IsValid(self.RTCamera)) then
		dupeInfo.RTCamera = self.RTCamera:EntIndex();
	end

	duplicator.StoreEntityModifier(self, "MALPDupeInfo", dupeInfo)
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	local dupeInfo = Ent.EntityMods.MALPDupeInfo

	if (dupeInfo.MalpWheels) then
		for i=1,6 do
			if(dupeInfo.MalpWheels[i]) then
				self.MalpWheels[i] = CreatedEntities[dupeInfo.MalpWheels[i]];
			end
		end
	end

	if (dupeInfo.Camera) then
		self:SpawnCamera(CreatedEntities[dupeInfo.Camera]);
	end

	if (dupeInfo.CamStand) then
		self:SpawnCamStand(CreatedEntities[dupeInfo.CamStand]);
	end

	if (dupeInfo.RTCamera) then
		self:SpawnRTCam(CreatedEntities[dupeInfo.RTCamera]);
	end

	if (IsValid(ply) and ply:GetCount("malp")>0 or StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end

	if (IsValid(ply)) then
		self.Owner = ply;
	    ply:AddCount("malp",self)
	end
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "malp", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_main_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_malp");
end

if (StarGate==nil or StarGate.MaterialCopy==nil or StarGate.KeyBoard==nil) then return end

local MAXDIST = 5000
local KBD = StarGate.KeyBoard:New("MALP")
--Navigation
KBD:SetDefaultKey("FWD",StarGate.KeyBoard.BINDS["+forward"] or "W")
KBD:SetDefaultKey("LEFT",StarGate.KeyBoard.BINDS["+moveleft"] or "A")
KBD:SetDefaultKey("RIGHT",StarGate.KeyBoard.BINDS["+moveright"] or "D")
KBD:SetDefaultKey("BACK",StarGate.KeyBoard.BINDS["+back"] or "S")
KBD:SetDefaultKey("VIEW","1")

KBD:SetDefaultKey("CAMUP","UPARROW")
KBD:SetDefaultKey("CAMDOWN","DOWNARROW")
KBD:SetDefaultKey("CAMLEFT","LEFTARROW")
KBD:SetDefaultKey("CAMRIGHT","RIGHTARROW")
KBD:SetDefaultKey("RESETCAM","R")

function ENT:Draw() self:DrawModel() end

function ENT:Initialize()

	self.KBD = self.KBD or KBD:CreateInstance(self)

end


local function SetData(um)
	local p = LocalPlayer()
	p.SignalLost = um:ReadBool()
	gravity = um:ReadShort()
	habitat = um:ReadShort()
	atmosphere = um:ReadShort()
	temp = um:ReadShort()
end
usermessage.Hook("MALPData", SetData)

function ENT:Think()

	local p = LocalPlayer()
	local control = p:GetNetworkedBool("ControllingMALP",false)

	if(control) then
		self.KBD:SetActive(true)
	else
		self.KBD:SetActive(false)
	end
end


--[[ The following is taken from MadJawa's malp code,
but edited to work with mine. It is not a complete copy and paste
but most credit should go to Madjawa
]]--
--################# Renders the fullscreen MALP view @MadJawa, RononDex
local mat = StarGate.MaterialCopy("MalpBlur","pp/blurscreen");
local TEXTURES = {
	Overlay = surface.GetTextureID("VGUI/malp/malpoverlay"),
	Input = surface.GetTextureID("VGUI/malp/malpoverlayinput"),
	Square = surface.GetTextureID("VGUI/malp/malpoverlaysquare"),
	Dots = surface.GetTextureID("VGUI/malp/malpoverlaydots"),
	Signal = {
		surface.GetTextureID("VGUI/malp/malpoverlaysignal0"),
		surface.GetTextureID("VGUI/malp/malpoverlaysignal1"),
	}
}
local FONT = "MALP_Font";
local fnt = {
	font = "Old Republic",
	size = math.ceil(0.023*ScrH() + 3.85),
	weight = 500,
	antialias = true,
	additive = true,
}
surface.CreateFont(FONT, fnt)

local function RenderMALPHud()
	if (not IsValid(LocalPlayer())) then return end
	local p = LocalPlayer();
	local malp = p:GetNWEntity("MALP")
	local pos = p:GetPos()
	local time = CurTime();
	local w,h = ScrW(),ScrH();
	local fpv = p:GetNWBool("FirstPerson")
	if (fpv) then
		if(IsValid(malp)) then
			local dist = (pos-malp:GetPos()):Length()

			-- this is the distance at which we start losing the signal
			local badDist = 5000-350;

			if (dist > badDist) then
				if(p.SignalLost) then
					-- FIXME: make a better effect (tv static or something)
					local n = dist-badDist;

					mat:SetFloat( "$blur", (n/20)*(math.sin(time)+3));
					render.UpdateScreenEffectTexture();
					surface.SetMaterial(mat);
					surface.SetDrawColor(255, 255, 255, 255);
					surface.DrawTexturedRect(0, 0, w, h);

					surface.SetDrawColor(0, 0, 0, math.Clamp(n*3/4, 0, 255));
					surface.DrawRect(-1, -1, w+1, h+1);
				end
			end


			-- drawing various MALP HUD parts
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetTexture(TEXTURES.Overlay)
			surface.DrawTexturedRect(0, 0, w, h);

			-- multiplicator used to scale the MALP HUD to all resolutions
			local widthMul, heightMul = w/1280, h/1024;
			local width, height = 512*widthMul, 256*heightMul;

			surface.SetDrawColor(255, 255, 255, math.abs(math.sin(3*time)*255))
			surface.SetTexture(TEXTURES.Input)
			surface.DrawTexturedRect(0, h-height, width, height);

			surface.SetDrawColor(255, 255, 255, math.Clamp(4*math.sin(2*time)*255, 0, 255))
			surface.SetTexture(TEXTURES.Square)
			surface.DrawTexturedRect(0, h-height, width, height);

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetTexture(TEXTURES.Dots)
			surface.DrawTexturedRect(0, h-height, width, height);

			local alpha, signal = 255, 2;
			if (dist > MAXDIST) then
				if(p.SignalLost) then
					alpha = math.abs(math.sin(2*time)*255);
					signal = 1;
				end
			end

			-- drawing Signal Lost or Uplinked depending on the distance
			surface.SetDrawColor(255, 255, 255, alpha)
			surface.SetTexture(TEXTURES.Signal[signal])
			surface.DrawTexturedRect(w/2-(512*widthMul/2), h-(128*heightMul), 512*widthMul, 128*heightMul);


			-- If SB isn't installed, it'll show default values. I think it's better than having nothing in the corner

			local habitable = habit or 1;
			local mgravity = gravity or 1;
			local pressure = atmosphere or 1;
			local temperature = temp or 288;

			if(habitable == 1) then habitable = "Yes"; else habitable = "No"; end

			-- too far: don't show the informations
			if(dist > MAXDIST) then
				if(p.SignalLost) then -- Too far away and no active gate connecting the signals
					habitable = "-";
					mgravity = "-";
					pressure = "-";
					temperature = "-";
				end
			end

			draw.SimpleText("Habitable: "..habitable,FONT, 955*widthMul, 862*heightMul, color_white);
			draw.SimpleText("Gravity: "..mgravity.." G",FONT, 955*widthMul, 891*heightMul, color_white);
			draw.SimpleText("Pressure: "..pressure.." Bar",FONT, 955*widthMul, 920*heightMul, color_white);
			draw.SimpleText("Temperature: "..temperature.." K",FONT, 955*widthMul, 949*heightMul, color_white);
		end
	end
end
hook.Add("HUDPaint", "RenderMALPHud", RenderMALPHud);

end