if (E2Helper==nil) then return end

if EGP and EGP.ValidFonts then
	local insertid
	for k,v in pairs(EGP.ValidFonts) do
		if v:StartWith("WireEGP_") then
			insertid = k;
			break;
		end
	end
	-- insert to table with correct order client-side
	if insertid then
		table.insert(EGP.ValidFonts,insertid,"Stargate Address Glyphs SG1");
		table.insert(EGP.ValidFonts,insertid+1,"Stargate Address Glyphs Concept");
		table.insert(EGP.ValidFonts,insertid+2,"Stargate Address Glyphs U");
		table.insert(EGP.ValidFonts,insertid+3,"Stargate Address Glyphs Atl");
		table.insert(EGP.ValidFonts,insertid+4,"Anquietas");
		table.insert(EGP.ValidFonts,insertid+5,"Quiver");
	end
end

E2Helper.Descriptions["stargateDial"] = "Dial gate.\nSyntax: address, mode.\nModes: 0 - slow, 1 - fast, 2 - nox.";
E2Helper.Descriptions["stargateClose"] = "Close stargate or abort dialling.";
E2Helper.Descriptions["stargateDHDPressButton"] = "Press button on DHD (not stargate!).";
E2Helper.Descriptions["stargateSystemType"] = "Return stargate system.\n1 - Group System, 0 - Galaxy System.";
E2Helper.Descriptions["stargateAsgardTeleport"] = "Teleport things using Asgard Teleport.\nSyntax: from, to, all (if all = 0 - only players).\nExample: stargateAsgardTeleport(vec(0,0,0),vec(10,10,10),0)";
E2Helper.Descriptions["stargateOverloadPerc"] = "Return stargate overload percent.\nGate will explode in 30 seconds after get 100 percent.";
E2Helper.Descriptions["stargateOverload"] = "Return 1 if stargate has overload by overloader\nReturn 2 if gate will explode in 30 seconds.";
E2Helper.Descriptions["stargateAsuranBeam"] = "Return 1 if stargate has asuran gate weapon active.";
E2Helper.Descriptions["stargateRandomAddress"] = "Generate new random address and/or name.\nModes:\n0 - Generate new address and name.\n1 - Generate only new address.\n2 - Generate only new name.";
E2Helper.Descriptions["stargateTransferEnergy"] = "Transfer energy between two connected stargates.\nUse negative value to retrieve energy.\nReturns transferred amount of energy if successful.";
E2Helper.Descriptions["stargateTransferResource"] = "Transfer resource between two connected stargates.\nUse negative value to retrieve resource.\nCan transfer only to dialled gate (not from).\nReturns transferred amount of resource if successful.";