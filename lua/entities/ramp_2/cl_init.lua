/*   Copyright 2010 by Llapp   */

include('shared.lua') ;
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("ramp",SGLanguage.GetMessage("ramp_kill"));
end