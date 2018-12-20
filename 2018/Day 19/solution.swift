let array = [0, 0, 0, 0, 0, 0]

if array[0] == 0 {
    array[3] = 40
    array[5] = 876
    //goto 1
} else {
    array[3] = 10550400
    array[5] = 10551276
    array[0] = 0
}

array[1] = 1
array[2] = 1

for/while ??? {
    if array[1] * array[2] == array[5] {
        array[0] += array[1]
    }
    
    array[2] += 1
    if array[2] > array[5] {
        //goto 12
    } else {
        array[1] += 1
        if array[1] > array[5] {
            
        }
    }
}