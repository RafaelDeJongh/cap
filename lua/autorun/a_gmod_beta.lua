-- Support for gmod13 by AlexALX
-- Now going to recode stuff to new functions, so some thing now removed from this lib
-- This lib still needed for fix some problems and add removed functions

if (Gmod13Lib!=nil) then return end -- prevent calling this file twice

if (SERVER) then
	AddCSLuaFile("autorun/a_gmod_beta.lua");
end

-- needed for detect when this lib loaded or not in other files.
function Gmod13Lib()
	return true;
end

-- Fix for file.* function not finding files from legacy addon system in data folder (needed for other addons like wiremod, for find cap e2 chips etc).
local file_Read = file.Read
local file_Find = file.Find
local file_IsDir = file.IsDir
local file_Exists = file.Exists
local file_Size = file.Size

-- need keep old way for compatibility with other mods (including wiremod)
function file.Read(path,param)
	local dir = "GAME";
	if (not param) then
		dir = "DATA"
	elseif (param==true) then
		dir = "GAME";
	else
		dir = param
	end
	if (dir:upper()=="DATA" and not file_Exists(path,dir)) then
		return file_Read("data/"..path,"GAME");
	end
	return file_Read(path,dir);
end

function file.Find(path,dir,order)
	if (path==nil or dir==nil) then return {},{} end
	if (dir:upper()=="DATA") then
		local files,folders = file_Find(path,dir,order);
		local fi,fo = file_Find("data/"..path,"GAME",order);
		if (fi) then
			for _,d in pairs(fi) do
				if (not table.HasValue(files,d)) then
					table.insert(files,d);
				end
			end
		end
		if (fo) then
			for _,d in pairs(fo) do
				if (not table.HasValue(folders,d)) then
					table.insert(folders,d);
				end
			end
		end
		-- i know, order will not work correct in this case, later will fix probably
		return files,folders;
	else
		return file_Find(path,dir,order);
	end
end

function file.IsDir(path,dir)
	if (path==nil or dir==nil) then return false end
	local tmp = file_IsDir(path,dir);
	if (dir:upper()=="DATA" and not tmp) then tmp = file_IsDir("data/"..path,"GAME"); end
	return tmp;
end

function file.Exists(path,dir)
	if (path==nil or dir==nil) then return false end
	local tmp = file_Exists(path,dir);
	if (dir:upper()=="DATA" and not tmp) then tmp = file_Exists("data/"..path,"GAME"); end
	return tmp;
end

function file.Size(path,dir)
	if (path==nil or dir==nil) then return -1 end
	local tmp = file_Exists(path,dir);
	if (dir:upper()=="DATA" and not tmp) then tmp = file_Size("data/"..path,"GAME"); end
	return file_Size(path,dir);
end

function Vertex( pos, u, v, normal )
	return { pos = pos, u = u, v = v, normal = normal };
end

-- still needed to be here
function GetAddonList(lower)
	local _,folders = file.Find("addons/*","GAME");
	local addons = {};
	for _,v in pairs(folders) do
		if (file.Exists("addons/"..v.."/addon.txt","GAME")) then
			if (lower) then	 v = v:lower(); end
			table.insert(addons,v);
		end
	end
	return addons;
end

function GetAddonInfo(addon)
	-- damn you garry, i have to code this function myself now...
	local info = {Info="",Version="0",URL="",LastUpdate="",Author="",Name="",Email=""};
	if (file.Exists("addons/"..addon.."/addon.txt","GAME")) then
		local file = file.Read("addons/"..addon.."/addon.txt","GAME");
		if (file) then
			local lines = string.Explode("\n", file);
			for _,l in pairs(lines) do
				local line = string.Trim(l);
				if (line=="") then continue; end
				local inf = string.Explode("\"", line);
				if (inf[2] and inf[4]) then
					local str = string.lower(inf[2]);
					if (str=="info") then
						info["Info"] = tostring(inf[4]);
					elseif (str=="version") then
						info["Version"] = string.format("%f",tonumber(inf[4]) or 0);
					elseif (str=="author_url") then
						info["URL"] = tostring(inf[4]);
					elseif (str=="up_date") then
						info["LastUpdate"] = tostring(inf[4]);
					elseif (str=="author_name") then
						info["Author"] = tostring(inf[4]);
					elseif (str=="name") then
						info["Name"] = tostring(inf[4]);
					elseif (str=="author_email") then
						info["Email"] = tostring(inf[4]);
					end
				end
			end
		end
	end
	return info;
end

if (CLIENT) then
	local tbl = {
		font = "coolvetica",
		size = 64,
		weight = 500,
		antialias = true,
		additive = false,
	}
	surface.CreateFont( "SandboxLabel", tbl )
	local tbl2 = {
		font = "Tahoma",
		size = 16,
		weight = 1000,
		antialias = true,
		additive = false,
	}
	surface.CreateFont("ScoreboardText", tbl2)
end

if (SERVER) then
	function UpdateRenderTarget( Ent )
	    if ( !Ent || !Ent:IsValid() ) then return end

	    if ( !RenderTargetCamera || !RenderTargetCamera:IsValid() ) then

	        RenderTargetCamera = ents.Create( "point_camera" )
	        RenderTargetCamera:SetKeyValue( "GlobalOverride", 1 )
	        RenderTargetCamera:Spawn()
	        RenderTargetCamera:Activate()
	        RenderTargetCamera:Fire( "SetOn", "", 0.0 )

	    end
	    Pos = Ent:LocalToWorld( Vector( 12,0,0) )
	    RenderTargetCamera:SetPos(Pos)
	    RenderTargetCamera:SetAngles(Ent:GetAngles())
	    RenderTargetCamera:SetParent(Ent)

	    RenderTargetCameraProp = Ent
	end
end