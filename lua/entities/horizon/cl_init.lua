include('shared.lua');
ENT.RenderGroup = RENDERGROUP_BOTH;
ENT.EnginePos = {"Engine01", "Engine02", "Engine03"}

ENT.Category = Language.GetMessage("entity_weapon_cat");
ENT.PrintName = Language.GetMessage("entity_horizon_missile");

ENT.Sounds = {
	Flyby = Sound("weapons/horizon_missle_Flyby.wav"),
}

function ENT:Initialize( )
	--self:SetShouldDrawInViewMode( true );
	self.FXEmitter = ParticleEmitter( self:GetPos());
	self.Created = CurTime();
	self.Last = CurTime();
	self.Flying = false;
end

function ENT:Draw()
	self:DrawModel();
	if self.Flying then self:Effects(true); end
end

--################### Think: Play sounds! @aVoN
function ENT:Think()
	self.Flying = self.Entity:GetNetworkedBool("DrawEngines", false);
	local time = CurTime();
	-- ######################## Flyby-noise and screenshake!
	if((time-self.Created >= 0.1) and time-(self.Last or 0) > 0.3) then
		if self.Flying then
			local p = LocalPlayer();
			local pos = self.Entity:GetPos();
			local norm = self.Entity:GetVelocity():GetNormal();
			local dist = p:GetPos()-pos;
			local len = dist:Length();
			local dot_prod = dist:DotProduct(norm)/len;
			if(math.abs(dot_prod) < 0.5 and dot_prod ~= 0) then
				-- Vector math: Get the distance from the player orthogonally to the projectil's velocity vector
				local intensity = math.sqrt(1 - dot_prod^2)*len;
				self.Entity:EmitSound(self.Sounds.Flyby,100*(1-intensity/2500),math.random(80,120));
				self.Last = time;
			end
		end
	end
	self.Entity:NextThink(time);
	return true;
end

local UP = Vector(0,0,25);
function ENT:Effects()

	local roll = math.Rand(-90,90);
	local velocity = -5*self.Entity:GetForward();
	local fwd = self.Entity:GetForward();

	for i=1,3 do

		local data = self.Entity:GetAttachment(self.Entity:LookupAttachment(self.EnginePos[i]))
		if(not (data and data.Pos)) then return end

		local left = self.FXEmitter:Add("sprites/orangecore1",data.Pos);
		left:SetVelocity(velocity);
		left:SetDieTime(0.1);
		left:SetStartAlpha(255);
		left:SetEndAlpha(80);
		left:SetStartSize(40);
		left:SetEndSize(25);
		left:SetColor(math.Rand(80,100),math.Rand(80,100),math.Rand(240,255));
		left:SetRoll(roll);

		local right = self.FXEmitter:Add("sprites/heatwave",data.Pos);
		right:SetVelocity(velocity);
		right:SetDieTime(0.1);
		right:SetStartAlpha(255);
		right:SetEndAlpha(255);
		right:SetStartSize(80);
		right:SetEndSize(40);
		right:SetColor(255,255,255);
		right:SetRoll(roll);

		local particle = self.FXEmitter:Add("effects/blood2",data.Pos)
		particle:SetVelocity(velocity - 500*fwd+UP)
		particle:SetDieTime(0.5)
		particle:SetStartAlpha(50)
		particle:SetEndAlpha(0)
		particle:SetStartSize(30)
		particle:SetEndSize(20)
		particle:SetColor(200,200,200)
		particle:SetRoll(roll)

	end

	self.FXEmitter:Finish();
end

