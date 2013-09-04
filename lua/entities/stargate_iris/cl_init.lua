include("shared.lua");
ENT.RenderGroup = RENDERGROUP_OPAQUE -- This FUCKING THING avoids the clipping bug I have had for ages since stargate BETA 1.0. DAMN!
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("stargate_iris",SGLanguage.GetMessage("stool_iris"));
end