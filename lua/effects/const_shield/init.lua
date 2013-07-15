/*
	Goauld Iris Buble
	Copyright (C) 2010  Madman07

*/

EFFECT.Material = StarGate.MaterialFromVMT(
	"ShieldBubbleGlow",
	[["UnLitGeneric"
	{
		"$basetexture" "models/props_combine/portalball001b_sheet"
	 	"$model" 1
		"$nocull" "1"
		"$additive" "1"

		"Proxies"
		{
			"TextureScroll"
			{
				"texturescrollvar" "$basetexturetransform"
				"texturescrollrate" -.1
				"texturescrollangle" 60
			}
		}
	}]]
);

function EFFECT:Init(data)

	local e = data:GetEntity();
	if(not e:IsValid()) then return end;
	self.Parent = e;
	self.Grow = true;
	self.Multiply = 0;
	self.Created = CurTime();
	self.Color = self.Parent:GetNetworkedVector("DoorColor");
	self.DoorModel = self.Parent:GetNWString("DoorModel")
	self.Entity:SetModel(Model(self.DoorModel));
	self.Entity:SetPos(e:GetPos());
	self.Entity:SetColor(Color(self.Color.x*255,self.Color.y*255,self.Color.z*255,1));
	if (self.DoorModel == "models/Madman07/shields/goauld_iris.mdl") then self.AlphaOver = true
	else self.AlphaOver = falsee end

end

function EFFECT:Think()

	if self.Parent:GetNWBool("StopBuble") and self.Grow then
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
	if not IsValid(self.Parent) or not IsValid(self.Entity) then return end
	self.Entity:SetPos(self.Parent:GetPos());

	if self.Grow then
		if (self.Multiply < 0.5) then self.Multiply = (CurTime()-self.Created);
		else self.Multiply = 0.5; end
	else
		self.Multiply = (self.Created - CurTime());
	end

	if(self.Multiply >= 0) then
		local factor = 3.5;
		if self.AlphaOver then factor = 2 end
		local alpha = math.Clamp(math.Clamp(math.sin(self.Multiply*math.pi)*1.3,0,1)*70,1,70);
		self.Entity:SetColor(Color(self.Color.x*255,self.Color.y*255,self.Color.z*255,alpha*factor));
		render.MaterialOverride(self.Material);
		self.Entity:SetAngles(self.Parent:GetAngles());
		self.Entity:DrawModel();
		render.MaterialOverride(nil);
	end

end