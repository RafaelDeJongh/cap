include('shared.lua')
ENT.RenderGroup = RENDERGROUP_OPAQUE
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_main_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_telchak");
end

ENT.TelchakSprite = Material("effects/multi_purpose_noz");
ENT.Col = Color(255,255,255,50);

function ENT:Initialize()
	self.Healing = false;
end

function ENT:Think()
	self.Healing = self.Entity:GetNetworkedBool("healing",false);
end

function ENT:Draw()
	self.Entity:DrawModel();

	if self.Healing then
		render.SetMaterial(self.TelchakSprite);
		local endpos = self.Entity:GetPos() + self.Entity:GetUp()*10;
		if StarGate.LOSVector(EyePos(), endpos, LocalPlayer(), 15) then
			render.DrawSprite(endpos,75,75,self.Col);
		end
	end
end

local function BlindPlayer()
	if (not IsValid(LocalPlayer())) then return end
	local health = LocalPlayer():Health();
	local used = LocalPlayer():GetNWBool("Telchak_Heal", false);
	if (health > 150 and used) then
		if (health>200) then health = 200 end
		DrawMotionBlur( 0.2, (-150+health)/50, 0.05)

		local tab = {}
		tab[ "$pp_colour_addr" ] = 0
		tab[ "$pp_colour_addg" ] = 0
		tab[ "$pp_colour_addb" ] = 0
		tab[ "$pp_colour_brightness" ] = (-150+health)/150
		tab[ "$pp_colour_contrast" ] = (-150+health)/150+1
		tab[ "$pp_colour_colour" ] = 1
		tab[ "$pp_colour_mulr" ] = 1
		tab[ "$pp_colour_mulg" ] = 1
		tab[ "$pp_colour_mulb" ] = 1

		DrawColorModify( tab )

	end
end
hook.Add( "RenderScreenspaceEffects", "BlindPlayer", BlindPlayer )
