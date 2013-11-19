@name Activate Universe Symbols
@inputs Start
@outputs ActivateSymbols:string ActivateSymbolsSound
@persist I Chars:string
@trigger

interval(500)

if (Start==1) {
ActivateSymbolsSound = 1

Chars = "ZB9JQNLMVKO6DCWY#R@S8APUT7H54IG012E3"
# yeah, this is order from one to last symbol

I = I + 1

ActivateSymbols = Chars[I]

if (I>=Chars:length()) {
    I = 0
}
} else {
    I = 0
    ActivateSymbols = ""
    ActivateSymbolsSound = 0
}
