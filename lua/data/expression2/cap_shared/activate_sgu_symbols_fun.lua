# Created by AlexALX (c) 2013
# For addon Stargate Carter Addon Pack
# http://sg-carterpack.com/
@name Activate Universe Symbols
@inputs Start
@outputs Activate_Symbols:string Activate_Symbols_Sound
@persist I Chars:string
@trigger

interval(500)

if (Start==1) {
Activate_Symbols_Sound = 1

Chars = "ZB9JQNLMVKO6DCWY#R@S8APUT7H54IG012E3"
# yeah, this is order from one to last symbol

I = I + 1

Activate_Symbols = Chars[I]

if (I>=Chars:length()) {
    I = 0
}
} else {
    I = 0
    Activate_Symbols = ""
    Activate_Symbols_Sound = 0
}
