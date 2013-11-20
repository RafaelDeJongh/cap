/*
	Goauld Iris Buble
	Copyright (C) 2010  Madman07

*/

EFFECT.Materiala = Material("effects/shielda");
EFFECT.Materialb = Material("effects/shieldb");

function EFFECT:Init(data)

	local e = data:GetEntity();
	if(not e:IsValid()) then return end;
	self.Parent = e;
	self.Grow = true;
	self.Multiply = 0;
	self.Created = CurTime();
	self:SetModel(Model("models/Madman07/shields/goauld_iris.mdl"));
	self:SetPos(e:GetPos());
	self:SetColor(Color(200,100,0,1));
	self:SetRenderMode(RENDERMODE_TRANSALPHA);
	local offset = Vector(1,1,1)*100000000000;
	self:SetRenderBounds(-1*offset,offset); -- FIX
end

function EFFECT:Think()

	if (not IsValid(self.Parent)) then
		self:Remove();
		return false
	end

	if self.Parent:GetNetworkedBool("StopBuble") and self.Grow then
		self.Grow = false;
		self.Multiply = 0.5;
		self.Created = CurTime()+0.5;
	end

	if self.Grow then return true
	else
		if (self.Multiply <= 0) then
			self:Remove();
			return false
		else return true end
	end

end

function EFFECT:Render()
	if not IsValid(self.Parent) or not IsValid(self) then return end
	self:SetPos(self.Parent:GetPos());
	self:SetAngles(self.Parent:GetAngles());
	if self.Grow then
		if (self.Multiply < 0.5) then self.Multiply = (CurTime()-self.Created);
		else self.Multiply = 0.5; end
	else
		self.Multiply = (self.Created - CurTime());
	end

	if(self.Multiply >= 0) then
		local alpha = math.Clamp(math.Clamp(math.sin(self.Multiply*math.pi)*1.3,0,1)*70,1,70);
		self:SetColor(Color(200,100,0,alpha*2));

		render.MaterialOverride(self.Materiala);
		self:DrawModel();
		render.MaterialOverride(self.Materialb);
		self:DrawModel();
		render.MaterialOverride(nil);
	end

end