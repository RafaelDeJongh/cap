-- print_r function by aVoN - use it anywhere you want - Dumps data from all datatypes into console

-- ########## Recursive print @aVoN
local function do_print_r(arg,spaces,passed)
	local t = type(arg);
	--Recursion
	if(t == "table") then
		if(arg.r and arg.g and arg.b and arg.a and table.Count(arg) == 4) then
			Msg("Color("..arg.r..","..arg.g..","..arg.b..","..arg.a..")\n");
			return;
		end
		passed[arg] = true;
		Msg("(table) "..tostring(arg):gsub("table: ","").." { \n");
		for k,v in pairs(arg) do
			if(not passed[v]) then
				Msg("  "..spaces.."("..type(k)..") "..tostring(k).." => ");
				do_print_r(rawget(arg,k),spaces.."  ",passed);
			else
				Msg("  "..spaces.."("..type(k)..") "..tostring(k).." => [RECURSIVE TABLE: "..tostring(v).."]\n");
			end
		end
		Msg(spaces.."}\n");
	elseif(t == "function") then
		Msg("("..t..") "..tostring(arg):gsub("function: ","").."\n");
	elseif(t == "string") then
		Msg("("..t..") '"..tostring(arg).."'\n");
	elseif(t == "Vector") then
		Msg(t.."("..arg.x..","..arg.y..","..arg.z..")\n");
	elseif(t == "Angle") then
		Msg(t.."("..arg.p..","..arg.y..","..arg.r..")\n");
	else
		Msg("("..t..") "..tostring(arg).."\n");
	end
end

-- ########## print_r @aVoN
function print_r(...)
	local arg = {...};
	-- Single data input
	local passed = {}; -- Every table, which already got passed is stored in here, so we won't go into an infinite-loop
	if(#arg == 1) then
		do_print_r(arg[1],"",passed);
	else
		for k = 1,#arg do
			do_print_r(arg[k],"",passed);
		end
	end
end