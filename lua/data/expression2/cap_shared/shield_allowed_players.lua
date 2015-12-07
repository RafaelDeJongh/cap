@name Shield Allowed Players
@inputs 
@outputs Allowed:array
@persist 
@trigger 

Allowed[1,entity] = findPlayerByName("matspyder")
Allowed[2,entity] = findPlayerByName("alexalx")

# Add Allowed[3,entity] = findPlayerByName("glebqip")
# Again and Again if you wan't add more Allowed Players
# You don't need to restart your shield for add the players
# But you need to restart him if a player was removed from this list
