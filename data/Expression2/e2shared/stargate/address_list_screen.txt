# Created by AlexALX (c) 2011-2012
# For addon Carter Addon Pack
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
    for (I=1,AddressList:count()) {

        # By default it outputs "ADDRESS NAME",
        # stargate can return "1 ADDRESS NAME" if address is blocked

        # But we can get address and name separately
        N = 2 # for name offset
        Blocked = 0 # for sgu
        Array = AddressList[I,string]:explode(" ") # Explode it by space
        Address = Array[1,string] # Get address
        if (Address=="1") { # if address blocked
             Blocked = 1
            	Address = Array[2,string] # Get address
            	N = 3
        }
        # Name can have spaces, so we need a cycle for get correct name
        Name = "" # Reset old value
        for (I=N,Array:count()) {
            if (I!=N) { Name = Name + " " } # add space between words
            Name = Name + Array[I,string]
        }

        if (I!=1) { List = List + "<br>" }
        if (Blocked==1) {
            List = List + "BLOCKED! Address - " + Address + " Name - " + Name
        } else {
            List = List + "Address - " + Address + " Name - " + Name
        }
    }

    # Warning! Wire screen can't display more 255 symbols! You will have error.
    ListOut = List:sub(0,255)
}
# ps i know this way is not really good, but i can't done different with array in wire outputs.