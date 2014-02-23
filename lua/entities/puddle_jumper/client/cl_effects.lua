local ATTACHMENTS = {"epodleft","epodright"};
--################ Add smoke effect @ RononDex
local UP = Vector(0,0,50); -- Smoke always moves up
function ENT:Smoke(b)

	local p = LocalPlayer();
	local jumper = p:GetNetworkedEntity("jumper",NULL);

	if(b) and (jumper and jumper:IsValid() and jumper==self) then
		local fwd = self:GetForward()
		local vel = self:GetVelocity()
		local roll = math.Rand(-90,90)

		local data = self:GetAttachment(self:LookupAttachment("epodright"))
		if(not (data and data.Pos)) then return end -- Old or no valid model - Don't draw!
		local pos = data.Pos


		local particle = self.Emitter:Add("effects/blood2",pos)
		particle:SetVelocity(vel - 500*fwd+UP)
		particle:SetDieTime(0.6)
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(15)
		particle:SetEndSize(20)
		particle:SetColor(40,40,40)
		particle:SetRoll(roll)

		self.Emitter:Finish()
	end
end

--############## Add engine pod effects(Lights, sprites etc) @ RononDex
function ENT:JumperEffects(b)

	local p = LocalPlayer();
	local jumper = p:GetNWEntity("jumper",NULL);

	if(b) and (jumper and jumper:IsValid() and jumper==self) then
		local FWD = self:GetForward();
		local vel = self:GetVelocity();
	--	local roll = math.Rand(-90,90);
		local roll = math.Rand(-45,45);
		local id = self:EntIndex();
		local normal = (self.Entity:GetForward() * -1):GetNormalized();

		for k,v in pairs(ATTACHMENTS) do
			local data = self:GetAttachment(self:LookupAttachment(v))
			if(not (data and data.Pos)) then return end -- Old or no valid model - Don't draw!
			local pos = data.Pos

			-- Blue core
			if(StarGate.VisualsShips("cl_jumper_sprites")) then
				local particle = self.Emitter:Add("sprites/bluecore",pos+FWD*-10);
				particle:SetVelocity(vel - 500*FWD);
				particle:SetDieTime(0.015);
				particle:SetStartAlpha(150);
				particle:SetEndAlpha(150);
				particle:SetStartSize(22.5);
				particle:SetEndSize(22.5);
				particle:SetColor(255,255,255);
				particle:SetRoll(roll);
			end

			-- Heatwave
			if(StarGate.VisualsShips("cl_jumper_heatwave")) then
				local heatwv = self.Emitter:Add("sprites/heatwave",pos+FWD*-15);
				heatwv:SetVelocity(normal*2);
				heatwv:SetDieTime(0.1);
				heatwv:SetStartAlpha(255);
				heatwv:SetEndAlpha(255);
				heatwv:SetStartSize(35);
				heatwv:SetEndSize(20);
				heatwv:SetColor(255,255,255);
				heatwv:SetRoll(roll);
			end

			-- Light from the engine
			if(StarGate.VisualsShips("cl_jumper_dynlights")) then
				local dynlight = DynamicLight(id + 4096*k);
				dynlight.Pos = pos+FWD*-25;
				dynlight.Brightness = 5;
				dynlight.Size = 334;
				dynlight.Decay = 1024;
				dynlight.R = 124;
				dynlight.G = 205;
				dynlight.B = 235;
				dynlight.DieTime = CurTime()+1;
			end
		end
		self.Emitter:Finish();
	end
end

