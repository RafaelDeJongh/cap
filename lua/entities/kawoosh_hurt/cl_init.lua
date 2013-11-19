include("shared.lua");
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.PrintName = SGLanguage.GetMessage("kawoosh_hurt");
language.Add("kawoosh_hurt",SGLanguage.GetMessage("kawoosh_hurt"))
end

if(file.Exists("materials/VGUI/weapons/kawoosh_hurt_killicon.vmt","GAME")) then
	killicon.Add("kawoosh_hurt","VGUI/weapons/kawoosh_hurt_killicon",Color(255,255,255));
end