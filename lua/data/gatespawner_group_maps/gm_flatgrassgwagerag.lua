[gatespawner]
version = 3 Group


[stargate]
classname=stargate_sg1
position=1023.6116 665.7407 144.3826
angles=0 -90 0
address=SPAWNG
group=M@
name=Spawn Gate
private=false
locale=false

[stargate]
classname=stargate_sg1
position=1023.6146 582.7399 144.3823
angles=0.000 90.000 0.000
address=SPAWN1
name=Spawn Ground
private=false
galaxy=false

[dhd]
classname=dhd_sg1
position=1187.8368 522.5563 39.6556
angles=15.000 -93.456 0.000
destroyed=false

[ring_panel]
classname=ring_panel_goauld
position=1029.6191 -524.8882 56.7763
angles=0.000 -90.000 0.000

[ring_base]
classname=ring_base_ancient
position=1029.6190 -630.8907 11.2821
angles=0.000 0.000 0.000
address=1

[ramp]
classname=ramp
position=1029.6190 -622.8914 -0.7184
angles=-0.000 -90.000 -0.000
model=models/madman07/spawn_ramp/spawn_ring.mdl

[ramp]
classname=ramp
position=1023.6116 600.7407 -0.6174
angles=-0.000 270.000 0.000
model=models/boba_fett/ramps/ramp2.mdl


#####################################

[stargate]
classname=stargate_atlantis
position=0 0 7000
angles=0 0 0
address=SPACEG
group=P@
name=Space Gate
private=false
locale=false

[gravitycontroller]
classname=GravityController
position=-0 0 6865
angles=0 -90 180
model=models/cebt/sga_pwnode.mdl
sound=ambient/atmosphere/underground_hall_loop1.wav

[gravitycontroller]
classname=GravityController
position=0 120 7065
angles=60 90 0
model=models/cebt/sga_pwnode.mdl
sound=ambient/atmosphere/underground_hall_loop1.wav

[gravitycontroller]
classname=GravityController
position=0 -120 7065
angles=-60 90 0
model=models/cebt/sga_pwnode.mdl
sound=ambient/atmosphere/underground_hall_loop1.wav