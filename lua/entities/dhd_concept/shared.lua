/*
	DHD SENT for GarrysMod10
	Copyright (C) 2007  aVoN, Madman07

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
StarGate.LifeSupportAndWire(ENT); -- When you need to add LifeSupport and Wire capabilities, you NEED TO CALL this before anything else or it wont work!
ENT.Type = "anim"
ENT.Base = "dhd_base"
ENT.PrintName = "DHD Group (Concept)"
ENT.Author = "aVoN, Madman07, Boba Fett, MarkJaw, AlexALX"
list.Set("CAP.Entity", ENT.PrintName, ENT);
ENT.Category = "Stargate Carter Addon Pack: Gates and Rings"
ENT.IsDHD = true;
ENT.IsDHDSg1 = true;
ENT.IsConceptDHD = true;

ENT.Color = {
	chevron="200 65 0"
};

-- The directionvectors, relativly from the EntPos to to the chevrons pos - The numbers and chars behind it will aquire a human readable adress like 1B3D5F-Chevron7 - Chevron7 will always be "Â", because the gmod10 servers are on earth :D
ENT.ChevronPositionsGroup = {
	--
	[0] = Vector(48.5569, -30.4505, 56.1191),
	[1] = Vector(49.5642, -25.8098, 57.2148),
	[2] = Vector(50.2756, -20.8445, 57.9749),
	[3] = Vector(51.1915, -15.5731, 58.9647),
	[4] = Vector(51.6003, -10.4547, 59.4690),
	[5] = Vector(51.3220, 10.7452, 59.3014),
	[6] = Vector(50.9710, 15.6241, 58.9700),
	[7] = Vector(50.2451, 20.9936, 58.0682),
	[8] = Vector(49.0729, 25.9128, 56.8758),
	[9] = Vector(48.2129, 30.8747, 55.8424),
	--
	A = Vector(52.0142, -30.6008, 52.5906),
	B = Vector(53.1413, -25.6796, 53.6922),
	C = Vector(54.1025, -20.6430, 54.3428),
	D = Vector(55.0149, -15.5521, 55.1457),
	E = Vector(55.4167, -10.0641, 55.7302),
	F = Vector(54.9046, 10.6529, 55.7267),
	G = Vector(54.6106, 15.7367, 55.2937),
	H = Vector(53.8456, 20.8703, 54.5095),
	I = Vector(52.8774, 26.2914, 53.0632),
	J = Vector(51.9053, 30.6530, 52.2831),
	K = Vector(55.8152, -30.4803, 48.8467),
	L = Vector(56.9366, -25.8528, 49.7983),
	M = Vector(57.8356, -20.6021, 50.7556),
	N = Vector(58.5811, -15.5133, 51.5877),
	O = Vector(59.0638, -10.3743, 52.0215),
	P = Vector(58.6544, 10.5961, 51.8802),
	Q = Vector(58.3514, 15.6265, 51.5889),
	R = Vector(57.5330, 20.8074, 50.8435),
	S = Vector(56.6752, 26.1958, 49.4457),
	T = Vector(55.4500, 30.3079, 48.6428),
	U = Vector(59.7849, -30.4418, 44.8727),
	V = Vector(60.6485, -25.6816, 46.1295),
	W = Vector(61.4295, -20.4695, 47.1451),
	X = Vector(62.3360, -15.6191, 47.8105),
	Y = Vector(62.1660, 15.7282, 47.7411),
	Z = Vector(61.1725, 20.9851, 47.1436),
	--
	["@"] = Vector(60.2137, 25.9327, 46.1211),
	["*"] = Vector(59.2734, 30.8548, 44.7939),
	["#"] = Vector(52.1807, 0.0444, 59.7953),
	-- Engage
	DIAL = Vector(56.1807, 0.0444, 50.7953), -- The middle "enter" button ;)

}

ENT.ChevronPositionsGalaxy = {
	--
	["!"] = Vector(48.5569, -30.4505, 56.1191),
	[1] = Vector(49.5642, -25.8098, 57.2148),
	[2] = Vector(50.2756, -20.8445, 57.9749),
	[3] = Vector(51.1915, -15.5731, 58.9647),
	[4] = Vector(51.6003, -10.4547, 59.4690),
	[5] = Vector(51.3220, 10.7452, 59.3014),
	[6] = Vector(50.9710, 15.6241, 58.9700),
	[7] = Vector(50.2451, 20.9936, 58.0682),
	[8] = Vector(49.0729, 25.9128, 56.8758),
	[9] = Vector(48.2129, 30.8747, 55.8424),
	--
	A = Vector(52.0142, -30.6008, 52.5906),
	B = Vector(53.1413, -25.6796, 53.6922),
	C = Vector(54.1025, -20.6430, 54.3428),
	D = Vector(55.0149, -15.5521, 55.1457),
	E = Vector(55.4167, -10.0641, 55.7302),
	F = Vector(54.9046, 10.6529, 55.7267),
	G = Vector(54.6106, 15.7367, 55.2937),
	H = Vector(53.8456, 20.8703, 54.5095),
	I = Vector(52.8774, 26.2914, 53.0632),
	J = Vector(51.9053, 30.6530, 52.2831),
	K = Vector(55.8152, -30.4803, 48.8467),
	L = Vector(56.9366, -25.8528, 49.7983),
	M = Vector(57.8356, -20.6021, 50.7556),
	N = Vector(58.5811, -15.5133, 51.5877),
	O = Vector(59.0638, -10.3743, 52.0215),
	P = Vector(58.6544, 10.5961, 51.8802),
	Q = Vector(58.3514, 15.6265, 51.5889),
	R = Vector(57.5330, 20.8074, 50.8435),
	S = Vector(56.6752, 26.1958, 49.4457),
	T = Vector(55.4500, 30.3079, 48.6428),
	U = Vector(59.7849, -30.4418, 44.8727),
	V = Vector(60.6485, -25.6816, 46.1295),
	W = Vector(61.4295, -20.4695, 47.1451),
	X = Vector(62.3360, -15.6191, 47.8105),
	Y = Vector(62.1660, 15.7282, 47.7411),
	Z = Vector(61.1725, 20.9851, 47.1436),
	--
	["@"] = Vector(60.2137, 25.9327, 46.1211),
	["*"] = Vector(59.2734, 30.8548, 44.7939),
	["#"] = Vector(52.1807, 0.0444, 59.7953),
	-- Engage
	DIAL = Vector(56.1807, 0.0444, 50.7953), -- The middle "enter" button ;)

}