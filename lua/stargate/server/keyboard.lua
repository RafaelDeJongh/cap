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

concommand.Add("_StarGate.KeyPressed",
	function(p,_,args)
		StarGate.KeyBoard:SetKeyPressed(p,args[1],args[2]);
	end
);

concommand.Add("_StarGate.KeyReleased",
	function(p,_,args)
		StarGate.KeyBoard:SetKeyReleased(p,args[1],args[2]);
	end
);