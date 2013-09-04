include('shared.lua');
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_main_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_lant_holo");
end

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

if (StarGate==nil or StarGate.MaterialFromVMT==nil) then return end
ENT.Stars = StarGate.MaterialFromVMT(
	"Stars",
	[["Sprite"
	{
		"$spriteorientation" "vp_parallel"
		"$spriteorigin" "[ 0.50 0.50 ]"
		"$basetexture" "sprites/glow04"
		"$spriterendermode" 5
	}]]
);

function ENT:Initialize()
	self.Speed = 5;
	self.Created = CurTime();
	self.Alpha = 0;

	self.RandRadius = {};
	self.RandAngle = {};
	self.RandZ = {};
	self.Col = {};
	self.Size = {};

	for i=1,200 do
		local randrad = math.Rand(20,150);
		local randangle = math.Rand(0,360);
		local randz = math.Rand(100,150);
		local size = math.Rand(5,20);
		local col = Vector(255,255,255,255);
		if (math.random(0,1) == 0) then col = Vector(math.random(150,200),math.random(0,30),math.random(0,30));
		else col = Vector(math.random(0,30),math.random(0,30),math.random(150,200)); end

		table.insert(self.RandRadius, randrad);
		table.insert(self.RandAngle, randangle);
		table.insert(self.RandZ, randz);
		table.insert(self.Size, size);
		table.insert(self.Col, col);
	end
end

function ENT:Draw()
	if self:GetNetworkedBool("Display", false) then
		self.Alpha = math.Approach(self.Alpha, 255, 5);
	else
		self.Alpha = math.Approach(self.Alpha, 0, -5);
	end

	self:DrawSprities();
	self.Entity:DrawModel();
end

function ENT:DrawSprities()
	local selfpos = self:GetPos();
	local time = (CurTime() - self.Created)*self.Speed;

	self:SetRenderBoundsWS(selfpos+1000*Vector(1,1,1), selfpos-1000*Vector(1,1,1));

	render.SetMaterial(self.Stars);

	for i=1,200 do
		local randrad = self.RandRadius[i];
		local randangle = self.RandAngle[i];
		local randz = self.RandZ[i];
		local size = self.Size[i];
		local col0 = self.Col[i];

		local pos =  selfpos + Vector(math.sin(math.rad(time+randangle))*randrad,math.cos(math.rad(time+randangle))*randrad,randz);

		local col = Color(col0.x, col0.y, col0.z, self.Alpha);
		render.DrawSprite(pos,size,size,col);

		col = Color(255, 255, 255, self.Alpha);
		render.DrawSprite(pos,size/4,size/4,col);
	end
end

function ENT:Think()
	if self:GetNWBool("Display", false) then
		if not self.Light then
			local dlight = DynamicLight(self:EntIndex().."light");
			if dlight then
				dlight.Pos = self.Entity:LocalToWorld(Vector(0,0,30));
				dlight.r = 255;
				dlight.g = 255;
				dlight.b = 255;
				dlight.Brightness = 7;
				dlight.Decay = 0;
				dlight.Size = 150;
				dlight.DieTime = CurTime()+0.25;
				self.Light = dlight;
				timer.Create( "Light"..self:EntIndex(), 0.1, 0, function()
					if IsValid(self.Entity) then
						self.Light.Pos = self.Entity:LocalToWorld(Vector(0,0,30));
						self.Light.DieTime = CurTime()+0.25;
					end
				end);
			end
		end
	else
		if timer.Exists("Light"..self:EntIndex()) then timer.Destroy("Light"..self:EntIndex()); end
		self.Light = nil;
	end
end

function ENT:OnRemove()
	if timer.Exists("Light"..self:EntIndex()) then timer.Destroy("Light"..self:EntIndex()); end
end
