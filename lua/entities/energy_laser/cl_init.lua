include("shared.lua");
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("energy_laser",SGLanguage.GetMessage("energy_laser_kill"));
end

function ENT:Draw()
end
