//: [Previous](@previous)

import Foundation

func read1(_ fileName: String = "input") -> [[Int]] {
    let fileURL = Bundle.main.url(forResource: fileName, withExtension: "txt")
    let content = try! String(contentsOf: fileURL!)
    let lines = content.split(separator: "\n")
    return lines.map { line in
        line.split(separator: "\t").map {
            let string = String($0).trimmingCharacters(in: .whitespacesAndNewlines)
            return Int(string)! }
    }
}
func solve1() {
    let ints = read1()

    var sum = 0
    print(sum)
}

func solve2() {
    let ints = read1()

    print(ints)
}

solve1()
//solve2()
//: [Next](@next)
