// #ip 4
//  0: addi 4 16 4
//  1: seti 1 5 1
//  2: seti 1 2 2
//  3: mulr 1 2 3
//  4: eqrr 3 5 3
//  5: addr 3 4 4
//  6: addi 4 1 4
//  7: addr 1 0 0
//  8: addi 2 1 2
//  9: gtrr 2 5 3
// 10: addr 4 3 4
// 11: seti 2 7 4
// 12: addi 1 1 1
// 13: gtrr 1 5 3
// 14: addr 3 4 4
// 15: seti 1 9 4
// 16: mulr 4 4 4
// 17: addi 5 2 5
// 18: mulr 5 5 5
// 19: mulr 4 5 5
// 20: muli 5 11 5
// 21: addi 3 1 3
// 22: mulr 3 4 3
// 23: addi 3 18 3
// 24: addr 5 3 5
// 25: addr 4 0 4
// 26: seti 0 3 4
// 27: setr 4 2 3
// 28: mulr 3 4 3
// 29: addr 4 3 3
// 30: mulr 4 3 3
// 31: muli 3 14 3
// 32: mulr 3 4 3
// 33: addr 5 3 5
// 34: seti 0 4 0
// 35: seti 0 5 4

// let array = [1, 0, 0, 0, 0, 0]

// if array[0] == 0 {
//     array[3] = 40
//     array[5] = 876
//     //goto 1
// } else {
//     array[3] = 10550400
//     array[5] = 10551276
//     array[0] = 0
// }

// array[1] = 1 //1
// array[2] = 1 //2

//     if array[1] * array[2] == array[5] { // 4,5,6
//         array[0] += array[1]  // 7: Found something (array[1])
//     }
    
//     array[2] += 1 //8
//     if array[2] > array[5] { //9,10
//         // goto 3 // 11
//     } else {
//         array[1] += 1 //12
//         if array[1] > array[5] {//13,14
//             // HALT //16
//         } else {
//             // goto 2 //15
//         }
//     }
// }

print([1, 2, 3, 4, 6, 9, 12, 18, 27, 36, 54, 108, 151, 302, 453, 604, 647, 906, 1294, 1359, 1812, 1941, 2588, 2718, 3882, 4077, 5436, 5823, 7764, 8154, 11646, 16308, 17469, 23292, 34938, 69876, 97697, 195394, 293091, 390788, 586182, 879273, 1172364, 1758546, 2637819, 3517092, 5275638, 10551276].reduce(0, +))

var total = 0
for i in 1...10551276 {
    for j in 1...10551276 {
        if i * j == 10551276 {
            total += i
        }
    }
    // print(i)
}

print(total)