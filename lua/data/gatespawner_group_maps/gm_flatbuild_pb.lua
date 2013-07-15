[gatespawner]
version = 3 Group


[stargate]
classname=stargate_sg1
position=-3455 1478 -366.6183
angles=0 90 0
address=SPAWNG
group=M@
name=Spawn Gate
private=false
galaxy=true

[dhd]
classname=dhd_sg1
position=-3297 1637 -472.4476
angles=15 245 0

[ring_panel]
classname=ring_panel_goauld
position=-3455 370 -454.3253
angles=0 -90 0

[ring_base]
classname=ring_base_ancient
position=-3455 264 -499.8195
angles=0 0 0
address=2

[ramp]
classname=ramp
position=-3455 272.3679 -511.618
angles=-0 -90 -0
model=models/madman07/spawn_ramp/spawn_ring.mdl

[ramp]
classname=ramp
position=-3455 1543 -511.719
angles=-0 90 0
model=models/boba_fett/ramps/ramp2.mdl

[stargate]
classname=stargate_atlantis
position=3000 9604 -421
angles=0 270 0
address=WATERG
group=P@
name=Water Gate
private=false
galaxy=true

[dhd]
classname=dhd_atlantis
position=3160 9504 -525.8
angles=15 285 0

[stargate]
classname=stargate_atlantis
position=10000 1000 -575
angles=90 0 0
address=FLOATG
group=P@
name=Floating Gate
private=false
galaxy=true

[dhd]
classname=dhd_atlantis
position=10150 1000 -600
angles=15 180 0

[stargate]
classname=stargate_universe
position=15369 1000 -460
angles=0 180 0
address=BOATDG
group=U@!
name=Boat Dock Gate
private=false
galaxy=true

[dhd]
classname=dhd_universe
position=15500 1000 -560
angles=15 0 0

[ring_panel]
classname=ring_panel_goauld
position=-3328 840 -1327
angles=0 180 0

[ring_base]
classname=ring_base_ancient
position=-3455 840 -1184
angles=0 0 180
address=3

[stargate]
classname=stargate_orlin
position=-3455 995 -1318
angles=0 270 0
address=UNDERG
group=M@
name=Underground Gate Right
private=true
galaxy=true
blocked=true

[ramp]
classname=ramp
position=-3455 995 -1318
angles=-0 270 0
model=models/zsdaniel/minigate-ramp/ramp.mdl

[stargate]
classname=stargate_orlin
position=-3455 685 -1318
angles=0 90 0
address=UNDELG
group=M@
name=Underground Gate Left
private=true
galaxy=true
blocked=true

[ramp]
classname=ramp
position=-3455 685 -1318
angles=-0 90 0
model=models/zsdaniel/minigate-ramp/ramp.mdl

[kino_dispenser]
classname=kino_dispenser
position=-3350 1000 -1375.3529
angles=0 270 0

[kino_dispenser]
classname=kino_dispenser
position=-3350 680 -1375.3529
angles=0 90 0

#####################################

[stargate]
classname=stargate_atlantis
position=0 0 9500
angles=0 0 0
address=SPACEG
group=P@
name=Space Gate
private=false
locale=false

[gravitycontroller]
classname=GravityController
position=-0 0 9365
angles=0 -90 180
model=models/cebt/sga_pwnode.mdl
sound=ambient/atmosphere/underground_hall_loop1.wav

[gravitycontroller]
classname=GravityController
position=0 120 9565
angles=60 90 0
model=models/cebt/sga_pwnode.mdl
sound=ambient/atmosphere/underground_hall_loop1.wav

[gravitycontroller]
classname=GravityController
position=0 -120 9565
angles=-60 90 0
model=models/cebt/sga_pwnode.mdl
sound=ambient/atmosphere/underground_hall_loop1.wav