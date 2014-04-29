/*
	Stargate Universe for GarrysMod10
	Copyright (C) 2010  Llapp
*/

include("shared.lua");
ENT.ChevronColor = Color(255,255,255);

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("stargate_category");
ENT.PrintName = SGLanguage.GetMessage("stargate_universe");
end

ENT.RenderGroup = RENDERGROUP_BOTH; -- needed in gmod13

ENT.LightPositions = {
	Vector(8,88.2829,104.5427),
	Vector(8,134.7614,23.2695),
	Vector(8,118.6142,-68.3697),
	Vector(8,-118.5464,-68.4004),
	Vector(8,-134.9181,22.6665),
	Vector(8,-86.8867,105.0110),
	Vector(8,0.0461,136.2538),
	Vector(8,47.0651,-128.8588),
	Vector(8,-46.6631,-128.9825),
	Vector(-8,88.2829,104.5427),
	Vector(-8,134.7614,23.2695),
	Vector(-8,118.6142,-68.3697),
	Vector(-8,-118.5464,-68.4004),
	Vector(-8,-134.9181,22.6665),
	Vector(-8,-86.8867,105.0110),
	Vector(-8,0.0461,136.2538),
	Vector(-8,47.0651,-128.8588),
	Vector(-8,-46.6631,-128.9825),
}
ENT.SpritePositions = {
	Vector(8,84.7845,100.6584),
	Vector(8,128.5390,23.2034),
	Vector(8,114.1802,-65.6066),
	Vector(8,-113.6151,-65.8050),
	Vector(8,-130.3172,22.9665),
	Vector(8,-84.0521,100.6424),
	Vector(8,0.1143,131.3542),
	Vector(8,44.9670,-123.5822),
	Vector(8,-45.0003,-123.5938),
	Vector(-8,84.7845,100.6584),
	Vector(-8,128.5390,23.2034),
	Vector(-8,114.1802,-65.6066),
	Vector(-8,-113.6151,-65.8050),
	Vector(-8,-130.3172,22.9665),
	Vector(-8,-84.0521,100.6424),
	Vector(-8,0.1143,131.3542),
	Vector(-8,44.9670,-123.5822),
	Vector(-8,-45.0003,-123.5938),
}

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self.Entity:GetPos());
	self.DestinyConsoleRange = StarGate.CFG:Get("destiny_console","range",1000);
	self.Entity:SetNetworkedBool( "Smoke", false );
	local snd = "stargate/universe/steam.wav";
	local parsedsound = snd:Trim()
	util.PrecacheSound(parsedsound)
	self.Steam = parsedsound
	self.SND = CreateSound(self.Entity, Sound(self.Steam))
end

--############# Steam sound module
function ENT:SteamSound(steam)
    if(self.Entity:GetNetworkedBool( "Smoke", bool ) and steam)then
        self.SND:Play();
    else
        self.SND:Stop();
    end
end

function ENT:OnRemove()
	if (self.SND) then
		self.SND:Stop();
	end
end

function ENT:FindDestinyConsole()
	if (IsValid(self:GetNWEntity("LockedDestC"))) then return {self:GetNWEntity("LockedDestC")} end
	local pos = self.Entity:GetPos();
	local destinyconsole = {};
	for _,v in pairs(ents.FindByClass("destiny_console")) do
		local e_pos = v:GetPos();
		local dist = (e_pos - pos):Length(); --
		if(dist <= self.DestinyConsoleRange) then
			local add = true;
			for _,gate in pairs(self:GetAllGates()) do
				if(gate ~= self.Entity and (gate:GetPos() - e_pos):Length() < dist) then
					add = false;
					break;
				end
			end
			if(add) then
				table.insert(destinyconsole,v);
			end
		end
	end
	return destinyconsole;
end

function ENT:Think(ply)
	if (not IsValid(self.Entity)) then return end
    ran = math.random(230,255);
	ran2 = math.random(0,5);
	die = math.random(-0.1,0);
	start = math.random(0,2);
	alph = math.random(0,5);
	for k,v in pairs(self:FindDestinyConsole()) do
		if(v:IsValid() and v.Target ~= self.Entity) then
			timer.Create("destiny_console"..k..self.Entity:EntIndex(),0,1,
				function()
					if(IsValid(v) and IsValid(self) and self.Entity:GetNWBool( "Smoke", true )) then
					    self:SteamSound(true);
					    self:SmokeRight();
                        self:SmokeLeft();
						self:WaveRight();
						self:WaveLeft();
					elseif (IsValid(self)) then
						self:SteamSound(false);
					end
				end
			);
		end
	end
	--######### Dynamic Lights, toggleable by the client!
	if(not StarGate.VisualsMisc("cl_stargate_un_dynlights")) then return end;
	if(self.ChevronColor and (self.NextLight or 0) < CurTime()) then
		self.NextLight = CurTime()+0.001;
		for i=1,18 do
			if(self.Entity:GetNWBool("chevron"..i,false)) then
    		-- Clientside lights, yeah! Can be toggled by clients this causes much less lag when deactivated. Method below is from Catdaemon's harvester
				local dlight = DynamicLight(self:EntIndex()..i);
				local gate = self.Entity:GetNetworkedEntity("GateLights",self.Gate);
				if(dlight and IsValid(gate)) then
					dlight.Pos = gate:LocalToWorld(self.LightPositions[i]);
					dlight.r = self.ChevronColor.r;
					dlight.g = self.ChevronColor.g;
					dlight.b = self.ChevronColor.b;
					dlight.Brightness = 0.5;
					dlight.Decay = 150;
					dlight.Size = 250;
					dlight.DieTime = CurTime()+1;
				end
			end
		end
	end
end

function ENT:Draw()
	self.Entity:DrawModel();
	if(not self.ChevronColor) then return end;
	render.SetMaterial(self.ChevronSprite);
	local col = Color(self.ChevronColor.r,self.ChevronColor.g,self.ChevronColor.b,50); -- Decent please -> Less alpha
	local col2 = Color(self.ChevronColor.r,self.ChevronColor.g,self.ChevronColor.b,40); -- Decent please -> Less alpha
	if (IsValid(self.Gate)) then
		for i=1,18 do
			if(self.Entity:GetNWBool("chevron"..i,false)) then
				local endpos = self.Entity:GetNetworkedEntity("GateLights",self.Gate):LocalToWorld(self.SpritePositions[i]);
				if StarGate.LOSVector(EyePos(), endpos, LocalPlayer(), 10) then
					render.DrawSprite(endpos,24,24,col);
				end
			end
		end
	end
end

function ENT:SmokeRight()
	local UP = Vector(0,0,50);
	local roll = math.Rand(-90,90)
	local rand = math.random(-15,15);
	local angle = self.Entity:GetUp()*170+self.Entity:GetRight()*(-100+rand)+self.Entity:GetForward()*rand
	local pos = self.Entity:GetPos() + self.Entity:GetRight()*(-160) - self.Entity:GetUp()*80
	local particle = self.Emitter:Add("Llapp/particles/Smoke01_Main",pos)
	particle:SetVelocity(UP+angle)
	particle:SetDieTime(0.6+die)
	particle:SetStartAlpha(60+alph)
	particle:SetEndAlpha(0)
	particle:SetStartSize(13+start)
	particle:SetEndSize(35+ran2)
	particle:SetColor(ran,ran,ran)
    particle:SetRoll(roll)
	particle:SetRollDelta(1)
	particle:SetAirResistance( 20 );
	--self.Emitter:Finish()
end

function ENT:SmokeLeft()
	local UP = Vector(0,0,50);
	local roll = math.Rand(-90,90)
	local rand = math.random(-15,15);
	local angle = self.Entity:GetUp()*170+self.Entity:GetRight()*(100+rand)+self.Entity:GetForward()*rand
	local pos = self.Entity:GetPos() + self.Entity:GetRight()*(160) - self.Entity:GetUp()*80
	local particle = self.Emitter:Add("Llapp/particles/Smoke01_Main",pos)
	particle:SetVelocity(UP+angle)
	particle:SetDieTime(0.6+die)
	particle:SetStartAlpha(60+alph)
	particle:SetEndAlpha(0)
	particle:SetStartSize(13+start)
	particle:SetEndSize(35+ran2)
	particle:SetColor(ran,ran,ran)
    particle:SetRoll(roll)
	particle:SetRollDelta(1)
	particle:SetAirResistance( 20 );
	--self.Emitter:Finish()
end

function ENT:WaveRight()
	local UP = Vector(0,0,50);
	local roll = math.Rand(-90,90)
	local rand = math.random(-15,15);
	local angle = self.Entity:GetUp()*170+self.Entity:GetRight()*(-100+rand)+self.Entity:GetForward()*rand
	local pos = self.Entity:GetPos() + self.Entity:GetRight()*(-160) - self.Entity:GetUp()*80
	local particle = self.Emitter:Add("sprites/heatwave",pos)
	particle:SetVelocity(UP+angle)
	particle:SetDieTime(0.6+die)
	particle:SetStartAlpha(60+alph)
	particle:SetEndAlpha(0)
	particle:SetStartSize(13+start)
	particle:SetEndSize(35+ran2)
	particle:SetColor(ran,ran,ran)
    particle:SetRoll(roll)
	particle:SetRollDelta(1)
	particle:SetAirResistance( 20 );
	--self.Emitter:Finish()
end

function ENT:WaveLeft()
	local UP = Vector(0,0,50);
	local roll = math.Rand(-90,90)
	local rand = math.random(-15,15);
	local angle = self.Entity:GetUp()*170+self.Entity:GetRight()*(100+rand)+self.Entity:GetForward()*rand
	local pos = self.Entity:GetPos() + self.Entity:GetRight()*(160) - self.Entity:GetUp()*80
	local particle = self.Emitter:Add("sprites/heatwave",pos)
	particle:SetVelocity(UP+angle)
	particle:SetDieTime(0.6+die)
	particle:SetStartAlpha(60+alph)
	particle:SetEndAlpha(0)
	particle:SetStartSize(13+start)
	particle:SetEndSize(35+ran2)
	particle:SetColor(ran,ran,ran)
    particle:SetRoll(roll)
	particle:SetRollDelta(1)
	particle:SetAirResistance( 20 );
	--self.Emitter:Finish()
end

--################# Gets all (valid) gates @aVoN
function ENT:GetAllGates(closed)
	local sg = {};
	for _,v in pairs(ents.FindByClass("stargate_*")) do
		if(v.IsStargate and not (closed and (v.IsOpen or v.Dialling))) then
			table.insert(sg,v);
		end
	end
	return sg;
end