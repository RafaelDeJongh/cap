--@name Test
--@author AlexALX

if SERVER then

wire.adjustInputs( { "ENT" }, { "wirelink" } ) 

timer.create("test_getaddress",0.5,0,function()
local ent = wire.ports.ENT
if (ent and ent:isValid()) then
    print(ent:stargateAddress());
end
end)

end

