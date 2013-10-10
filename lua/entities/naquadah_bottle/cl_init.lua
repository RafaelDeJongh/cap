include("shared.lua");
ENT.RenderGroup = RENDERGROUP_BOTH; -- This FUCKING THING avoids the clipping bug I have had for ages since stargate BETA 1.0. DAMN!
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("naquadah_bottle",SGLanguage.GetMessage("stool_naq_bottle"));
end