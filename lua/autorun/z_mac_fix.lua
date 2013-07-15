/*
	###################################
	StarGate with Group System
	Created by AlexALX (c) 2011
	###################################
*/
-- fixing file.FindInLua function on mac
-- file name should start at z_ or it will not help correctly

if SERVER then
	AddCSLuaFile( "autorun/z_mac_fix.lua" )
end

if (Gmod13Lib==nil) then
	include("autorun/a_gmod_beta.lua")
end
--  Maybe not needed anymore? not sure. But this file still needed for include a_gmod_beta on linux server first.
/*
if (system.IsOSX()) then
	local file_FindInLua = file.FindInLua

	function file.FindInLua(path)
   		local tbl = file_FindInLua(path);
   		for k,i in pairs(tbl) do
			if (i=="") then table.remove(tbl,k); end
   		end
  		return tbl
	end
end           */