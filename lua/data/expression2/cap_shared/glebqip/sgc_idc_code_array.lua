# Version 1.1
# Author glebqip(RUS)
# Created 23.11.13
# This is SGC IDC Code array
# Usage: IDC[code,array]=array(status,"name")
# Has 2 statuses: 1-Accept, 2-Expired
# Support thread: http://sg-carterpack.com/forums/topic/sgc-dialing-computer-v1-e2/

@name SGC IDC code array
@inputs
@outputs
@persist IDC:table GT:gtable
@trigger
if(dupefinished()){reset() gTable("SIca_"+entity():id()):clear()}
interval(1000)

#IDC[71629571282112,array]=array(1,"SG-1")

GT = gTable("SIca_"+entity():id())
GT[1,string]="SIcav1"
GT[2,table]=IDC