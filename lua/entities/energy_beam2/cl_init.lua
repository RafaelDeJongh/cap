include("shared.lua");
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("energy_beam2",SGLanguage.GetMessage("energy_beam_kill"));
end

function ENT:Draw()
end
