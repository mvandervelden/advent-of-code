// let result = 10_000_000_000
// var register = [result, 0, 0, 0, 0, 0]
var R0, R1, R2, R4, R5 = 0

R0 = 0 //To find?
//6
R2 = R1 | 65536
R1 = 10605201
//8
R5 = R2 & 256
R1 += R5
R1 = R1 & 16777216
R1 = R1 * 65899
R1 = R1 & 16777216

if 256 <= R2 {
    R5 = 0
    while (R5 + 1) * 256 <= R2 {
        R5 += 1
    }
    R2 = R5
    //goto 8
} else {
    if R1 == R0 {
        print("Finished")
    } else {
        //goto 6
    }
}

// 259641090 lastIP=16 ip=28 [9223372036854775807, 15144665, 127, 28, 1, 1] eqrr 1 0 5 [9223372036854775807, 15144665, 127, 28, 1, 0]
// 260056858 lastIP=16 ip=28 [9223372036854775807, 4662993, 231, 28, 1, 1] eqrr 1 0 5 [9223372036854775807, 4662993, 231, 28, 1, 0]
// 260184898 lastIP=16 ip=28 [9223372036854775807, 16747753, 71, 28, 1, 1] eqrr 1 0 5 [9223372036854775807, 16747753, 71, 28, 1, 0]
// 260644668 lastIP=16 ip=28 [9223372036854775807, 4083535, 255, 28, 1, 1] eqrr 1 0 5 [9223372036854775807, 4083535, 255, 28, 1, 0]
// 260758603 lastIP=16 ip=28 [9223372036854775807, 1576716, 63, 28, 1, 1] eqrr 1 0 5 [9223372036854775807, 1576716, 63, 28, 1, 0]
// 260803728 lastIP=16 ip=28 [9223372036854775807, 11239729, 25, 28, 1, 1] eqrr 1 0 5 [9223372036854775807, 11239729, 25, 28, 1, 0]
// 261112305 lastIP=16 ip=28 [9223372036854775807, 2317976, 171, 28, 1, 1] eqrr 1 0 5 [9223372036854775807, 2317976, 171, 28, 1, 0]
// 261175973 lastIP=16 ip=28 [9223372036854775807, 451546, 35, 28, 1, 1] eqrr 1 0 5 [9223372036854775807, 451546, 35, 28, 1, 0]
// 261190200 lastIP=16 ip=28 [9223372036854775807, 6615977, 7, 28, 1, 1] eqrr 1 0 5 [9223372036854775807, 6615977, 7, 28, 1, 0]
// 261373645 lastIP=16 ip=28 [9223372036854775807, 5601440, 101, 28, 1, 1] eqrr 1 0 5 [9223372036854775807, 5601440, 101, 28, 1, 0]
// 261527445 lastIP=16 ip=28 [9223372036854775807, 5264418, 85, 28, 1, 1] eqrr 1 0 5 [9223372036854775807, 5264418, 85, 28, 1, 0]
// 261673797 lastIP=16 ip=28 [9223372036854775807, 8879000, 81, 28, 1, 1] eqrr 1 0 5 [9223372036854775807, 8879000, 81, 28, 1, 0]
// 261917568 la

// 153.800
// 146.352
// 243.771

// reg1: 431003 -> 28402666697 -> 15617225 -> 15617226 -> 1029159576174 -> 11592302
// reg2: 65536 (1+16*0) -> 256 (1+8*0) -> 1 

// reg1: -> 10605201 -> 10605311 -> 698879389589 -> 7679893 (long) -> 7680119 -> 506112161981 -> 10664125 -> 10664302 -> 702766837498 -> 2813690
// reg2: -> 11657838 -> 45538 -> 177
