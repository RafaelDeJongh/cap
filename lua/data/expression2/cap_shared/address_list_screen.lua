# Created by AlexALX (c) 2011-2014
# For addon Stargate Carter Addon Pack
# http://sg-carterpack.com/
@name Address list screen
@inputs Refresh SG:wirelink
@outputs ListOut:string
@persist AddressList:array
@trigger

if (Refresh==1) {
    AddressList = SG:stargateAddressList()
    List = ""

    # get all addresses
    foreach(K,V:array=AddressList) {
        Address = V[1,string] # Get address
        Name = V[2,string] # Get name
        Blocked = V[3,number] # Get blocked

        if (K!=1) { List = List + "<br>" }
        if (Blocked==1) {
            List = List + "BLOCKED! Address - " + Address + " Name - " + Name
        } else {
            List = List + "Address - " + Address + " Name - " + Name
        }
    }

    # Warning! Wire screen can't display more 255 symbols! You will have error.
    ListOut = List:sub(0,255)
}