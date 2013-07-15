include("shared.lua");
ENT.Category = Language.GetMessage("entity_weapon_cat");
ENT.PrintName = Language.GetMessage("entity_stat_railgun");
ENT.RenderGroup = RENDERGROUP_BOTH;

local font = {
	font = "quiver",
	size = ScreenScale(20),
	weight = 400,
	antialias = true,
	additive = false,
}
surface.CreateFont("Digital", font);

function ENT:Initialize()
	LocalPlayer().GUp = 150;
	LocalPlayer().GForw  = 150;
	LocalPlayer().View = 0;
	self.Ammo = 1000;
end

function ENT:Draw()
	self.Entity:DrawModel();
	if IsValid(self.Turn) then
		local data = self.Turn:GetAttachment(self.Turn:LookupAttachment("ScreenCenter"))
		if not (data and data.Pos and data.Ang) then return end
		cam.Start3D2D(data.Pos,data.Ang+Angle(0,90,90),0.05);
			surface.SetDrawColor(0,0,0,255)
			draw.SimpleText(tostring(self.Ammo),"Digital",0,0,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
		cam.End3D2D();
	end
end

function ENT:Think()
	if not IsValid(self.Stand) then self.Stand = self:GetNetworkedEntity("Stand"); end
	if not IsValid(self.Turn) then self.Turn = self:GetNWEntity("Turn"); end
	if not IsValid(self.Cann) then self.Cann = self:GetNWEntity("Cann"); end
	self.Ammo = self.Entity:GetNWInt("ammo",1000);
end


function HUDPaint()
	if LocalPlayer():GetNWBool("InRailgun") then
		local x = ScrW() / 2
		local y = ScrH() / 2
		local gap = 5
		local length = gap + 5

		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawLine( x - length, y, x - gap, y )
		surface.DrawLine( x + length, y, x + gap, y )
		surface.DrawLine( x, y - length, x, y - gap )
		surface.DrawLine( x, y + length, x, y + gap )
	end
end
hook.Add( "HUDPaint", "HUDPaint", HUDPaint )


function StatRailGCalcView(Player, Origin, Angles, FieldOfView)
	local view = {}
	local p = LocalPlayer()
	local self = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	if (self and self:IsValid() and self:GetClass()=="stationary_railgun") then

		if not IsValid(self.Cann) then return end
		if not IsValid(self.Turn) then return end
		if not IsValid(self.Stand) then return end
		local ang = self.Cann:GetAngles();
		local data = self.Turn:GetAttachment(self.Turn:LookupAttachment("head"))
		if(not (data and data.Pos)) then data.Pos = self.Stand:GetPos() + self.Stand:GetUp()*500 end

		view.origin = data.Pos+Vector(0,0,10);
		view.angles = Angle(-1*ang.Pitch, ang.Yaw + 180, ang.Roll);
		return view;
	end
end
hook.Add("CalcView", "StatRailGCalcView", StatRailGCalcView)