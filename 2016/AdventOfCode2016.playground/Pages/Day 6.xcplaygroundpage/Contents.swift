//: [Previous](@previous)

import Foundation

func read1(_ fileName: String = "input") -> [String] {
    let fileURL = Bundle.main.url(forResource: fileName, withExtension: "txt")
    let content = try! String(contentsOf: fileURL!)
    return content
        .split(separator: "\n")
        .map { String($0) }
}

func solve1() {
    let strings = read1()

    var result = ""
    for i in 0..<strings.first!.count {
        var histogram: [Character: Int] = [:]
        strings.forEach { string in
            let char = string[string.index(string.startIndex, offsetBy: i)]
            if !histogram.keys.contains(char) {
                histogram[char] = 0
            }
            histogram[char] = histogram[char]! + 1
        }
        var max = 0
        var maxChar: Character = " "
        histogram.forEach { (kvPair) in
            if kvPair.value > max {
                max = kvPair.value
                maxChar = kvPair.key
            }
        }
        result.append(maxChar)
    }
    print(result)
}

func solve2() {
    let strings = read1()

    var result = ""
    for i in 0..<strings.first!.count {
        var histogram: [Character: Int] = [:]
        strings.forEach { string in
            let char = string[string.index(string.startIndex, offsetBy: i)]
            if !histogram.keys.contains(char) {
                histogram[char] = 0
            }
            histogram[char] = histogram[char]! + 1
        }
        var min = Int.max
        var minChar: Character = " "
        histogram.forEach { (kvPair) in
            if kvPair.value < min {
                min = kvPair.value
                minChar = kvPair.key
            }
        }
        result.append(minChar)
    }
    print(result)
}

//solve1()
solve2()
//: [Next](@next)
