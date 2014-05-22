# Created by AlexALX (c) 2012
# For addon Stargate with Group System
# http://www.facepunch.com/threads/1163292
@name GDO Text usage
@inputs Received_Code
@outputs GDO_Status GDO_Text:string
@persist
@trigger

if (Received_Code == 12345) {
    GDOStatus = 1
    GDOText = "OK!!!"
} else {
    GDOStatus = 0
    GDOText = "INVALID"
}

# note: if you will not add any text,
# then it will return default text on GDO (like WRONG or OPEN).