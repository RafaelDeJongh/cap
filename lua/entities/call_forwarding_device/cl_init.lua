/*
	Module for GarrysMod10
	Copyright (C) 2011  Llapp
*/

include("shared.lua");
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_main_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_cfd");
language.Add("call_forwarding_device",SGLanguage.GetMessage("entity_cfd_full"));
end