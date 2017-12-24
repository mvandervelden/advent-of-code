

// How many non-primes in range 184_000...201_000
func instr1() {
    var h = 0
    
    let startVal = 84 * 100 + 100_000
    let endVal = startVal + 17_000
    print("range: \(startVal)...\(endVal)")
    for b in stride(from: startVal, through: endVal, by: 17) {
        // print("start loop: b: \(b), c: \(endVal)")

        for d in 2..<(b / 2) {
            if b % d == 0 {
                h += 1
                // print("h increased: \(h)")
                break
            }
        }
    }
    
    print("EXIT: h=\(h)")
}

instr1()
