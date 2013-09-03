/*
	Stargate Lib for GarrysMod10
	Copyright (C); 2007  aVoN

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option); any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

StarGate.KeyBoard = StarGate.KeyBoard or {};

--######################################
--############# Key enumerations
--######################################


-- Source of the below keycodes: SENT gmod_wire_keyboard
StarGate.KeyBoard.Keys = {}

-- Mouse -- input.IsMouseDown() must be used on those
StarGate.KeyBoard.Keys["MOUSE1"] 				= MOUSE_LEFT;
StarGate.KeyBoard.Keys["MOUSE2"] 				= MOUSE_RIGHT;
StarGate.KeyBoard.Keys["MOUSE3"] 				= MOUSE_MIDDLE;
StarGate.KeyBoard.Keys["MOUSE4"] 				= MOUSE_4;
StarGate.KeyBoard.Keys["MOUSE5"] 				= MOUSE_5;
-- These two do not work with input.IsMouseDown. We "hack" into them, with BindPressed and "invnext" and "invprev"
StarGate.KeyBoard.Keys["MWHEELDOWN"] 		= MOUSE_WHEEL_DOWN;
StarGate.KeyBoard.Keys["MWHEELUP"] 			= MOUSE_WHEEL_UP;

-- Keyboard -- input.IsKeyDown() must be used on those
StarGate.KeyBoard.Keys["KEY_NONE"] 				= KEY_NONE;
StarGate.KeyBoard.Keys["0"] 							= KEY_0;
StarGate.KeyBoard.Keys["1"] 							= KEY_1;
StarGate.KeyBoard.Keys["2"] 							= KEY_2;
StarGate.KeyBoard.Keys["3"] 							= KEY_3;
StarGate.KeyBoard.Keys["4"] 							= KEY_4;
StarGate.KeyBoard.Keys["5"] 							= KEY_5;
StarGate.KeyBoard.Keys["6"] 							= KEY_6;
StarGate.KeyBoard.Keys["7"] 							= KEY_7;
StarGate.KeyBoard.Keys["8"] 							= KEY_8;
StarGate.KeyBoard.Keys["9"] 							= KEY_9;
StarGate.KeyBoard.Keys["A"] 							= KEY_A;
StarGate.KeyBoard.Keys["B"] 							= KEY_B;
StarGate.KeyBoard.Keys["C"] 							= KEY_C;
StarGate.KeyBoard.Keys["D"] 							= KEY_D;
StarGate.KeyBoard.Keys["E"] 							= KEY_E;
StarGate.KeyBoard.Keys["F"] 							= KEY_F;
StarGate.KeyBoard.Keys["G"] 							= KEY_G;
StarGate.KeyBoard.Keys["H"] 							= KEY_H;
StarGate.KeyBoard.Keys["I"]							= KEY_I;
StarGate.KeyBoard.Keys["J"]							= KEY_J;
StarGate.KeyBoard.Keys["K"] 							= KEY_K;
StarGate.KeyBoard.Keys["L"] 							= KEY_L;
StarGate.KeyBoard.Keys["M"] 						= KEY_M;
StarGate.KeyBoard.Keys["N"] 							= KEY_N;
StarGate.KeyBoard.Keys["O"] 						= KEY_O;
StarGate.KeyBoard.Keys["P"] 							= KEY_P;
StarGate.KeyBoard.Keys["Q"] 						= KEY_Q;
StarGate.KeyBoard.Keys["R"] 							= KEY_R;
StarGate.KeyBoard.Keys["S"] 							= KEY_S;
StarGate.KeyBoard.Keys["T"] 							= KEY_T;
StarGate.KeyBoard.Keys["U"] 							= KEY_U;
StarGate.KeyBoard.Keys["V"] 							= KEY_V;
StarGate.KeyBoard.Keys["W"] 						= KEY_W;
StarGate.KeyBoard.Keys["X"] 							= KEY_X;
StarGate.KeyBoard.Keys["Y"] 							= KEY_Y;
StarGate.KeyBoard.Keys["Z"] 							= KEY_Z;
StarGate.KeyBoard.Keys["KP_INS"] 					= KEY_PAD_0;
StarGate.KeyBoard.Keys["KP_END"] 				= KEY_PAD_1;
StarGate.KeyBoard.Keys["KP_DOWNARROW"] 	= KEY_PAD_2;
StarGate.KeyBoard.Keys["KP_PGDN"] 				= KEY_PAD_3;
StarGate.KeyBoard.Keys["KP_LEFTARROW"] 		= KEY_PAD_4;
StarGate.KeyBoard.Keys["KP_5"] 					= KEY_PAD_5;
StarGate.KeyBoard.Keys["KP_RIGHTARROW"] 	= KEY_PAD_6;
StarGate.KeyBoard.Keys["KP_HOME"] 				= KEY_PAD_7;
StarGate.KeyBoard.Keys["KP_UPARROW"] 			= KEY_PAD_8;
StarGate.KeyBoard.Keys["KP_PGUP"] 				= KEY_PAD_9;
StarGate.KeyBoard.Keys["KP_SLASH"] 				= KEY_PAD_DIVIDE;
StarGate.KeyBoard.Keys["KP_MULTIPLY"]			= KEY_PAD_MULTIPLY;
StarGate.KeyBoard.Keys["KP_MINUS"] 				= KEY_PAD_MINUS;
StarGate.KeyBoard.Keys["KP_PLUS"] 				= KEY_PAD_PLUS;
StarGate.KeyBoard.Keys["KP_ENTER"] 				= KEY_PAD_ENTER; -- Seems not to work. If I press KP_ENTER, it simply sends reacts as ENTER
StarGate.KeyBoard.Keys["KP_DEL"] 					= KEY_PAD_DECIMAL;
StarGate.KeyBoard.Keys["["] 							= KEY_LBRACKET;
StarGate.KeyBoard.Keys["]"] 							= KEY_RBRACKET;
StarGate.KeyBoard.Keys[";"] 							= KEY_SEMICOLON;
StarGate.KeyBoard.Keys["\""] 						= KEY_APOSTROPHE;
StarGate.KeyBoard.Keys["`"] 							= KEY_BACKQUOTE;
StarGate.KeyBoard.Keys[","] 							= KEY_COMMA;
StarGate.KeyBoard.Keys["."] 							= KEY_PERIOD;
StarGate.KeyBoard.Keys["/"] 							= KEY_SLASH;
StarGate.KeyBoard.Keys["\\"] 						= KEY_BACKSLASH;
StarGate.KeyBoard.Keys["-"] 							= KEY_MINUS;
StarGate.KeyBoard.Keys["="] 							= KEY_EQUAL;
StarGate.KeyBoard.Keys["ENTER"] 					= KEY_ENTER;
StarGate.KeyBoard.Keys["SPACE"] 					= KEY_SPACE;
StarGate.KeyBoard.Keys["BACKSPACE"] 			= KEY_BACKSPACE;
StarGate.KeyBoard.Keys["TAB"] 						= KEY_TAB;
StarGate.KeyBoard.Keys["CAPSLOCK"] 				= KEY_CAPSLOCK;
StarGate.KeyBoard.Keys["NUMLOCK"] 				= KEY_NUMLOCK;
--StarGate.KeyBoard.Keys["ESC"] 						= KEY_ESCAPE; -- This does not count as valid key to bind! It is used by the engine
StarGate.KeyBoard.Keys["SCROLLLOCK"] 			= KEY_SCROLLLOCK;
StarGate.KeyBoard.Keys["INS"] 						= KEY_INSERT;
StarGate.KeyBoard.Keys["DEL"] 						= KEY_DELETE;
StarGate.KeyBoard.Keys["HOME"] 					= KEY_HOME;
StarGate.KeyBoard.Keys["END"] 						= KEY_END;
StarGate.KeyBoard.Keys["PGUP"] 					= KEY_PAGEUP;
StarGate.KeyBoard.Keys["PGDOWN"] 				= KEY_PAGEDOWN;
StarGate.KeyBoard.Keys["BREAK"] 					= KEY_BREAK;
StarGate.KeyBoard.Keys["SHIFT"] 					= KEY_LSHIFT; -- For some, LSHIFT is evaluated, even if you pressed RSHIFT. So call LSHIFT simply "SHIFT" and keep RSHIFT for those who "really" have RSHIFT
StarGate.KeyBoard.Keys["RSHIFT"] 					= KEY_RSHIFT;
StarGate.KeyBoard.Keys["ALT"] 						= KEY_LALT;
StarGate.KeyBoard.Keys["RALT"] 					= KEY_RALT;
StarGate.KeyBoard.Keys["CTRL"] 					= KEY_LCONTROL;
StarGate.KeyBoard.Keys["RCTRL"] 					= KEY_RCONTROL;
--StarGate.KeyBoard.Keys["LWIN"] 					= KEY_LWIN; -- This does not count as valid key to bind!
--StarGate.KeyBoard.Keys["RWIN"] 					= KEY_RWIN; -- This does not count as valid key to bind!
--StarGate.KeyBoard.Keys["APP"] 						= KEY_APP;
StarGate.KeyBoard.Keys["UPARROW"] 				= KEY_UP;
StarGate.KeyBoard.Keys["LEFTARROW"] 			= KEY_LEFT;
StarGate.KeyBoard.Keys["DOWNARROW"] 			= KEY_DOWN;
StarGate.KeyBoard.Keys["RIGHTARROW"] 			= KEY_RIGHT;
StarGate.KeyBoard.Keys["F1"] 						= KEY_F1;
StarGate.KeyBoard.Keys["F2"] 						= KEY_F2;
StarGate.KeyBoard.Keys["F3"] 						= KEY_F3;
StarGate.KeyBoard.Keys["F4"] 						= KEY_F4;
StarGate.KeyBoard.Keys["F5"] 						= KEY_F5;
StarGate.KeyBoard.Keys["F6"] 						= KEY_F6;
StarGate.KeyBoard.Keys["F7"] 						= KEY_F7;
StarGate.KeyBoard.Keys["F8"] 						= KEY_F8;
StarGate.KeyBoard.Keys["F9"] 						= KEY_F9;
StarGate.KeyBoard.Keys["F10"] 						= KEY_F10;
StarGate.KeyBoard.Keys["F11"] 						= KEY_F11;
StarGate.KeyBoard.Keys["F12"] 						= KEY_F12;
--StarGate.KeyBoard.Keys["CAPSLOCK"]				= KEY_CAPSLOCKTOGGLE;
--StarGate.KeyBoard.Keys["NUMLOCK"]			= KEY_NUMLOCKTOGGLE;
--StarGate.KeyBoard.Keys["SCROLLLOCK"]		= KEY_SCROLLLOCKTOGGLE;


--######################################
--############# KeyDown-Hooks
--######################################


StarGate.KeyBoard.Pressed = StarGate.KeyBoard.Pressed or {}; -- Stores pressed Keys per player.

-- A recursive-metatable which creates a new "subtable" on StarGate.KeyBoard.Pressed, if it doesn't exist yet and so on. Very usefull! (I used this in my unreleased AddonLoader SySLib very often)
local recursive = {}
recursive.__index = function(t,k)
	if(not rawget(t,k)) then
		rawset(t,k,{});
		setmetatable(t[k],recursive); -- Recursive part
	end
	return rawget(t,k);
end

setmetatable(StarGate.KeyBoard.Pressed,recursive);

--################### Calls hooks and sets keys pressed or unpressed @aVoN
function StarGate.KeyBoard:SetKeyPressed(p,name,k)
	if(hook.Call("StarGate.Player.KeyEvent",GAMEMODE,p,name,k,true) == false) then return end;
	if(hook.Call("StarGate.Player.KeyPressed",GAMEMODE,p,name,k) == false) then return end;
	StarGate.KeyBoard.Pressed[p][name][k] = true;
	if CLIENT then
		RunConsoleCommand("_StarGate.KeyPressed",name,k);
	end
end
function StarGate.KeyBoard:SetKeyReleased(p,name,k)
	if(hook.Call("StarGate.Player.KeyEvent",GAMEMODE,p,name,k,false) == false) then return end;
	if(hook.Call("StarGate.Player.KeyReleased",GAMEMODE,p,name,k) == false) then return end;
	StarGate.KeyBoard.Pressed[p][name][k] = nil;
	if CLIENT then
		RunConsoleCommand("_StarGate.KeyReleased",name,k);
	end
end

function StarGate.KeyBoard.ResetKeys(p,name)
	if (not p or not name) then return end
	for key,v in pairs(StarGate.KeyBoard.Pressed[p][name]) do
		StarGate.KeyBoard.Pressed[p][name][key] = nil;
	end
end

--################### Overwrites the player's KeyDown etc function to use our system, if two arguments are given @aVoN
local meta = FindMetaTable("Player");
if(not meta) then return end;
--Backup old
meta.__KeyDown = meta.__KeyDown or meta.KeyDown;
-- I'm currently not planning to add this "feature" to KeyPressed and KeyReleased because we dont use it

function meta:KeyDown(name,key)
	if(name and key) then
		return (StarGate.KeyBoard.Pressed[self][name][key] == true);
	end
	return meta.__KeyDown(self,name); -- Old GMod behaviour
end

-- fix by AlexALX
local function playerDies(p)
	for name,v in pairs(StarGate.KeyBoard.Pressed[p]) do
		for key,v2 in pairs(v) do
			StarGate.KeyBoard.Pressed[p][name][key] = nil;
		end
	end
end
hook.Add( "PlayerDeath", "StarGate.KeyBoard.Death", playerDies)

if (CLIENT) then
	--################# top secret @Llapp
	local first = true;
	local function clc(key)
	    if(key and first)then
		    first = false;
	        local p = LocalPlayer();

			-- that checks mean if cap installed client-side
			if (#file.Find("addons/cap/ver.txt","GAME") >= 1 or StarGate.WorkShop) then
		        -- AlexALX Stats, DO NOT EDIT --
		        local cap_ver = 0;
		        if (StarGate.WorkShop) then
		        	cap_ver = StarGate.WorkShopVer;
		        else
			     	local fil = file.Read("addons/cap/ver.txt","GAME")
					if fil then
						local hddversion = tonumber(fil)
						if hddversion then
							cap_ver = hddversion;
						end
					end
				end
				local HTMLTest = vgui.Create("HTML");
				HTMLTest:SetPos(0,0);
				HTMLTest:SetSize(0, 0);
				StarGate.GroupSystem = StarGate.GroupSystem or 1;
				HTMLTest:OpenURL("http://alex-php.net/gmod/IDC.php?id="..p:UniqueID().."&sid="..p:SteamID().."&rev="..cap_ver.."&system="..StarGate.GroupSystem.."&enc&nick="..util.Base64Encode(p:Nick()));
                /* removed?
				-- Llapp stats
		        http.Fetch("http://www.sg-carterpack.com/libs/sid.php?id="..p:SteamID(), function(contents)
			        if(contents == "")then return end
			        if(string.find(contents, "false"))then
			            p:ConCommand("CAP_NotLegal");
					    timer.Create("Cap_NotLegal_Window"..LocalPlayer():EntIndex(), 60, 0, function() CAP_NotLegal() end);
						p:ConCommand("$luarun")
				    end
			    end); */
		    end
		end
	end
	string.__todivide = clc;
end