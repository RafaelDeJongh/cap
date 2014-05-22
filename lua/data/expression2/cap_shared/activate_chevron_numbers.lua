# Created by AlexALX (c) 2011
# For addon Stargate Carter Addon Pack
# http://sg-carterpack.com/
@name "Activate chevron numbers"
@inputs NoSound Chev1 Chev2 Chev3 Chev4 Chev5 Chev6 Chev7 Chev8 Chev9
@outputs Activate_chevron_numbers:string
@persist
@trigger

I = 1
if (NoSound) {
    I = 2
}

Activate_chevron_numbers = toString(I*Chev1) + toString(I*Chev2) + toString(I*Chev3) + toString(I*Chev4) + toString(I*Chev5) + toString(I*Chev6) + toString(I*Chev7) + toString(I*Chev8) + toString(I*Chev9)
