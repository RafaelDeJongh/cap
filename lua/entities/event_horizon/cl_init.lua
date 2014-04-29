include("shared.lua");
include("modules/bullets.lua");
include("modules/collision.lua");

ENT.RenderGroup = RENDERGROUP_OPAQUE -- This FUCKING THING avoids the clipping bug I have had for ages since stargate BETA 1.0. DAMN!
if (SGLanguage and SGLanguage.GetMessage) then
	ENT.PrintName = SGLanguage.GetMessage("event_horizon");
	language.Add("event_horizon",SGLanguage.GetMessage("event_horizon"))
end

if(file.Exists("materials/VGUI/weapons/event_horizon_killicon.vmt","GAME")) then
	killicon.Add("event_horizon","VGUI/weapons/event_horizon_killicon",Color(255,255,255));
end

--################# Think @aVoN
function ENT:Think()
	--###### Update the clientside self.Target (Necessary for the ENT:GetTeleportedVector function, if used clientside)
	self.Target = self.Entity:GetNetworkedEntity("Target",self.Entity);
	--###### Clientside lights, yeah! Can be toggled by clients this causes much less lag when deactivated. Method below is from Catdaemon's harvester
	if(not StarGate.VisualsMisc("cl_stargate_dynlights")) then return end;
	if(not self.Entity:GetNWBool("activate_lights",false)) then return end;
	self.Brightness = math.Clamp((self.Brightness or 0) + FrameTime()*10,0,1); -- Make the light fade in!
	if((self.NextLight or 0) < CurTime()) then -- Fixes a crashing bug, which spawns more and more lights all over the time until the clientside "overflowed blubb" message appears
		self.NextLight = CurTime()+0.001;
		local dlight = DynamicLight(self:EntIndex());
		if(dlight) then
			dlight.Pos = self.Entity:GetPos()+self.Entity:GetForward()*50;
			if (self.Entity:GetNWBool("universe",false)) then
				local rand = math.random(200,230);
				dlight.r = rand;
				dlight.g = rand;
				dlight.b = rand;
			else
				dlight.r = math.random(20,40);
				dlight.g = math.random(60,80);
				dlight.b = math.random(150,230);
			end
			dlight.Brightness = self.Brightness;
			dlight.Decay = math.random(300,350);
			dlight.Size = math.random(700,750);
			dlight.DieTime = CurTime()+1;
		end
	end
end

--################# Draw (for the EH being translucent from behind) @aVoN
function ENT:Draw()
	self.BaseClass.Draw(self);
	local alpha = self.Entity:GetColor().a;
	--if((LocalPlayer():GetShootPos()-self.Entity:GetPos()):DotProduct(self.Entity:GetForward()) < 0) then -- Behind
	if ((EyePos()-self.Entity:GetPos()):DotProduct(self.Entity:GetForward()) < 0) then
		alpha = math.Clamp(alpha,1,150);
		-- We are looking from behind on the gate
	elseif(alpha == 150) then
		alpha = 255;
	end
	self.MaxAlpha = alpha;
	-- Just set the alpha if we aren't initializing it, or it will look ugly from behind
	if (not self.AllowBacksideDrawing) then
		if (self:GetNWBool("AllowBacksideDrawing",false)) then
			self.Entity:SetColor(Color(255,255,255,255)); -- fix for invisible eh
		end
		self.AllowBacksideDrawing = self:GetNWBool("AllowBacksideDrawing",false);
	end
	if(self.AllowBacksideDrawing) then -- This is getting set by the "eventhorizon_stabilize" effect
		-- ugly workaround fix, damn you garry.
		local flicker = self:GetNWBool("Flicker",false); -- fix for infinity gate flicker
		if ((alpha == 150 or flicker) and self.RenderGroup != RENDERGROUP_BOTH) then
			self.RenderGroup = RENDERGROUP_BOTH
		elseif (alpha != 150 and self.RenderGroup != RENDERGROUP_OPAQUE and not flicker) then
			self.RenderGroup = RENDERGROUP_OPAQUE
		end
		self.Entity:SetColor(Color(255,255,255,alpha));
	end
end

--################# Sets the alpha of the gate and  @aVoN
function ENT:SetAlpha(alpha,min)
	if(min) then
		self.Entity:SetColor(Color(255,255,255,math.Clamp(alpha or 1,self.MaxAlpha or 1,255)));
	else
		self.Entity:SetColor(Color(255,255,255,math.Clamp(alpha or 1,1,self.MaxAlpha or 255)));
	end
end


--################# Draw teleport effect when entering/exiting the gate (somewhat inspired from catdaemon's Rings, LOL) @aVoN & Catdaemon

local started; -- When did we started the effect?
--################# FOV changing @aVoN
hook.Add("CalcView","StarGate.CalcView.TeleportEffect",
	function(p,pos,ang,fov)
		if(not started) then return end;
		local time = CurTime()-started;
		local mul = 1+math.cos(math.Clamp(time,0,1)*2*math.pi)*0.2; -- Will do the job in 1/4 second
		if(mul < 1 or time > 0.25) then
			started = nil;
			return;
		end
		local t = {
			origin = pos,
			angles = ang,
			fov=fov*mul,
		}
		return t;
	end
);

--################# White flash @aVoN
--local Material1 = StarGate.MaterialCopy("StargateEnterBlur","bluredges");
--local Material2 = StarGate.MaterialCopy("StargateEnterFizzle","effects/tp_eyefx/tpeye3");
hook.Add("HUDPaint","StarGate.HUDPaint.TeleportEffect",
	function()
		if(not started) then return end;
		local time = CurTime()-started;
		local mul = math.cos(math.Clamp(time,0,1)*2*math.pi); -- Will do the job in 1/4 second
		if(mul < 0 or time > 0.25) then
			started = nil;
			return;
		end
		surface.SetDrawColor(255,255,255,mul*255);
		surface.DrawRect(0,0,ScrW(),ScrH());
	end
);

--################# Start the FOV changed @aVoN
usermessage.Hook("StarGate.CalcView.TeleportEffectStart",
	function()
		started = CurTime();
	end
);


--########### All this handle's model clipping @RononDex
usermessage.Hook("StarGate.EventHorizon.ClipStart", function(um)
	local dir = um:ReadShort();
	local e = um:ReadEntity();
	local target = um:ReadEntity();
	if(not(IsValid(e) and IsValid(target))) then return end;
	local norm = target:GetForward()*dir;
	e.dir = dir;
	e:SetRenderClipPlaneEnabled(true);
	e:SetRenderClipPlane(norm, norm:Dot(target:GetPos()));
end)

usermessage.Hook( "StarGate.EventHorizon.ClipStop", function(um)
	local e = um:ReadEntity();
	if(not(IsValid(e))) then return end;
	e.dir = nil;
	e:SetRenderClipPlaneEnabled(false);
end)

usermessage.Hook( "StarGate.EventHorizon.PlayerKill", function(um)
	local e = um:ReadEntity();
	if(not(IsValid(e))) then return end;
	GAMEMODE:AddDeathNotice("#event_horizon",-1,"event_horizon",e:Name(),e:Team());
end)