# Created by AlexALX (c) 2011
# For addon Stargate with Group System
# http://www.facepunch.com/threads/1163292
@name Activate chevron fun
@inputs Start
@outputs ActivateChevromNumbers:string
@persist Started
@trigger

interval(500)
if (Start == 1) {
    if (Started == 0) {
        timer("delay0", 1000)
        Started = 1
    }
    if (clk("delay0")) {
        ActivateChevromNumbers = "100000000"
        timer("delay1", 1000)
    }
    if (clk("delay1")) {
        ActivateChevromNumbers = "010000000"
        timer("delay2", 1000)
    }
    if (clk("delay2")) {
        ActivateChevromNumbers = "001000000"
        timer("delay3", 1000)
    }
    if (clk("delay3")) {
        ActivateChevromNumbers = "000000010"
        timer("delay4", 1000)
    }
    if (clk("delay4")) {
        ActivateChevromNumbers = "000000001"
        timer("delay5", 1000)
    }
    if (clk("delay5")) {
        ActivateChevromNumbers = "000100000"
        timer("delay6", 1000)
    }
    if (clk("delay6")) {
        ActivateChevromNumbers = "000010000"
        timer("delay7", 1000)
    }
    if (clk("delay7")) {
        ActivateChevromNumbers = "000001000"
        timer("delay8", 1000)
    }
    if (clk("delay8")) {
        ActivateChevromNumbers = "000000100"
        timer("delay9", 1000)
    }
    if (clk("delay9")) {
        ActivateChevromNumbers = "111111011"
        timer("delay10", 750)
    }
    if (clk("delay10")) {
        ActivateChevromNumbers = "000000200" # 2 is for no sound
        timer("delay11", 1250)
    }
    if (clk("delay11")) {
        ActivateChevromNumbers = "111111011"
        timer("delay12", 750)
    }
    if (clk("delay12")) {
        ActivateChevromNumbers = "000000200" # 2 is for no sound
        timer("delay13", 1250)
    }
    if (clk("delay13")) {
        ActivateChevromNumbers = "111111011"
        timer("delay14", 750)
    }
    if (clk("delay14")) {
        ActivateChevromNumbers = "000000200"  # 2 is for no sound
        timer("delay16", 1250)
    }
    if (clk("delay16")) {
        ActivateChevromNumbers = "000001000"
        timer("delay17", 1000)
    }
    if (clk("delay17")) {
        ActivateChevromNumbers = "000010000"
        timer("delay18", 1000)
    }
    if (clk("delay18")) {
        ActivateChevromNumbers = "000100000"
        timer("delay19", 1000)
    }
    if (clk("delay19")) {
        ActivateChevromNumbers = "000000001"
        timer("delay20", 1000)
    }
    if (clk("delay20")) {
        ActivateChevromNumbers = "000000010"
        timer("delay21", 1000)
    }
    if (clk("delay21")) {
        ActivateChevromNumbers = "001000000"
        timer("delay22", 1000)
    }
    if (clk("delay22")) {
        ActivateChevromNumbers = "010000000"
        timer("delay23", 1000)
    }
    if (clk("delay23")) {
        ActivateChevromNumbers = "100000000"
        timer("delay24", 1000)
    }
    if (clk("delay24")) {
        ActivateChevromNumbers = "000000100"
        timer("delay25", 1000)
    }
    if (clk("delay25")) {
        ActivateChevromNumbers = "010010011"
        timer("delay26", 1500)
    }
    if (clk("delay26")) {
        ActivateChevromNumbers = "000000000"
        timer("delay27", 750)
    }
    if (clk("delay27")) {
        ActivateChevromNumbers = "101101000"
        timer("delay28", 1500)
    }
    if (clk("delay28")) {
        ActivateChevromNumbers = "000000000"
        timer("delay29", 750)
    }
    if (clk("delay29")) {
        ActivateChevromNumbers = "010010111"
        timer("delay32", 1500)
    }
    if (clk("delay32")) {
        ActivateChevromNumbers = "000000000"
        timer("delay33", 750)
    }
    if (clk("delay33")) {
        ActivateChevromNumbers = "010010011"
        timer("delay34", 1500)
    }
    if (clk("delay34")) {
        ActivateChevromNumbers = "000000000"
        timer("delay35", 750)
    }
    if (clk("delay35")) {
        ActivateChevromNumbers = "000000111"
        timer("delay36", 1500)
    }
    if (clk("delay36")) {
        ActivateChevromNumbers = "000000000"
        timer("delay37", 750)
    }
    if (clk("delay37")) {
        ActivateChevromNumbers = "111111111"
        timer("delay38", 1500)
    }
    if (clk("delay38")) {
        ActivateChevromNumbers = "000000000"
    }
} else {
    ActivateChevromNumbers = "000000000"
    Started = 0
}
