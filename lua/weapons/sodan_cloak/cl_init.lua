include("shared.lua")

-- Inventory Icon @aVoN
if(file.Exists("materials/VGUI/weapons/cloak_inventory.vmt","GAME")) then
	SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/cloak_inventory");
end

--################### Think @Catdaemon
hook.Add("Think","StarGate.SodanCloaking.Think",
	function()
		local cloaked_self = LocalPlayer():GetNetworkedBool("pCloaked",false);
		for _,p in pairs(player.GetAll()) do
			local cloaked = p:GetNetworkedBool("pCloaked",NULL); -- If a player hasn't cloaked himself yet, we do not want to override color at all (It conflicted on my server
			if(cloaked ~= NULL) then
				local weapon = p:GetActiveWeapon();
				local color = p:GetColor();
				local r,g,b,a = color.r,color.g,color.b,color.a;
				if(cloaked_self) then
					if(cloaked) then a = 255 end;
				else
					if(cloaked) then
						a = 0;
						p.__HasBeenCloaked = true;
					elseif(a == 0 and p.__HasBeenCloaked) then -- If he is uncloaked but still at 0 alpha, make him visible back again (Failsafe) - But do this only, if WE have cloaked him
						a = 255;
						p.__HasBeenCloaked = false;
					end
				end
				p:SetRenderMode( RENDERMODE_TRANSALPHA )
				p:SetColor(Color(r,g,b,a)); -- Cloak, lol
				if(IsValid(weapon)) then
					weapon:SetColor(Color(255,255,255,a)); -- Cloak his weapon too
				end
			end
		end
	end
);

--################### Color override @Catdaemon
local BlurEdges = Material("bluredges");
hook.Add("RenderScreenspaceEffects","StarGate.SodanCloaking.RenderScreenspaceEffects",
	function()
		if(LocalPlayer():GetNWBool("pCloaked",false)) then
			-- Color Modify - The "Bluish" overlay
			DrawColorModify(
				{
					["$pp_colour_addr"] = 0,
					["$pp_colour_addg"] = 0.56,
					["$pp_colour_addb"] = 0.96,
					["$pp_colour_brightness"] = -0.6,
					["$pp_colour_contrast"] = 0.93,
					["$pp_colour_colour"] = 0.19,
					["$pp_colour_mulr"] = 0,
					["$pp_colour_mulg"] = 0,
					["$pp_colour_mulb"] = 0,
				}
			);
			-- Makes view blurry
			DrawMotionBlur(0.2,0.7,0);
			-- Draw blurred edges @aVoN
			render.SetMaterial(BlurEdges);
			render.UpdateScreenEffectTexture();
			render.DrawScreenQuad();
		end
	end
);

--################### Footsteps sound? (Hopefully comes along the next update) @aVoN
hook.Add("PlayerFootstep","StarGate.SodanCloaking.PlayerFootStep",
	function(p)
		if(IsValid(p) and p:IsPlayer()) then
			if(p:GetNWBool("pCloaked",false) and not LocalPlayer():GetNWBool("pCloaked",false)) then
				return true;
			end
		end
	end
);

-- HACKY HACKY HACKY HACKY HACKY @aVoN
-- Stops making players "recognizeable" if they are cloaked (E.g. by looking at them - Before you e.g. saw "Catdaemon - Health 100" if you lookaed at a cloaked player. Now, you dont see anything if he is cloaked
if(util.__TraceLine) then return end;
util.__TraceLine = util.TraceLine;
function util.TraceLine(...)
	local t = util.__TraceLine(...);
	if(t and IsValid(t.Entity)) then
		if(t.Entity:IsPlayer()) then
			if(not LocalPlayer():GetNetworkedBool("pCloaked",false) and t.Entity:GetNWBool("pCloaked",false)) then t.Entity = NULL end;
		end
	end
	return t;
end
