SG_CUSTOM_GROUPS = {}
SG_CUSTOM_TYPES = {}

net.Receive("_SGCUSTOM_GROUPS",function(len)
	SG_CUSTOM_GROUPS = net.ReadTable();
	SG_CUSTOM_TYPES = net.ReadTable();
end)