# Created by AlexALX (c) 2012
# For addon Stargate with Group System
# http://www.facepunch.com/threads/1163292
@name GDO Text usage
@inputs Code
@outputs GDOStatus GDOText:string
@persist
@trigger

if (Code == 12345) {
    GDOStatus = 1
    GDOText = "OK!!!"
} else {
    GDOStatus = 0
    GDOText = "INVALID"
}

# note: if you will not add any text,
# then it will return default text on GDO (like WRONG or OPEN).