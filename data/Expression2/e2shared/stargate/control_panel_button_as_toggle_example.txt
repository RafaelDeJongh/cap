# Created by AlexALX (c) 2012
# For addon Carter Addon Pack
# http://sg-carterpack.com/
@name Control Panel Button as Toggle Example
@inputs Button
@outputs Toggle
@persist
@trigger

if (Button>0) {
    if (Toggle==1) {
        Toggle = 0
    } else {
        Toggle = 1
    }
}
