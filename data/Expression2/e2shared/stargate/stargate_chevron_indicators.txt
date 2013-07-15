# Created by AlexALX (c) 2011
# For addon Stargate with Group System
# http://www.facepunch.com/threads/1163292
@name "Stargate Chevron Indicators"
@inputs Chevrons:string
@outputs Chev1 Chev2 Chev3 Chev4 Chev5 Chev6 Chev7 Chev8 Chev9
@persist I
@trigger 

for (I=1,9) {
    if (Chevrons[I] == "1") {
        if (I==1) {
            Chev1 = 1   
        } elseif (I==2) {
            Chev2 = 1  
        } elseif (I==3) {
            Chev3 = 1   
        } elseif (I==4) {
            Chev4 = 1   
        } elseif (I==5) {
            Chev5 = 1   
        } elseif (I==6) {
            Chev6 = 1   
        } elseif (I==7) {
            Chev7 = 1   
        } elseif (I==8) {
            Chev8 = 1   
        } elseif (I==9) {
            Chev9 = 1   
        }  
    } else {
        if (I==1) {
            Chev1 = 0   
        } elseif (I==2) {
            Chev2 = 0  
        } elseif (I==3) {
            Chev3 = 0   
        } elseif (I==4) {
            Chev4 = 0   
        } elseif (I==5) {
            Chev5 = 0   
        } elseif (I==6) {
            Chev6 = 0   
        } elseif (I==7) {
            Chev7 = 0   
        } elseif (I==8) {
            Chev8 = 0   
        } elseif (I==9) {
            Chev9 = 0   
        }
    }  
}
