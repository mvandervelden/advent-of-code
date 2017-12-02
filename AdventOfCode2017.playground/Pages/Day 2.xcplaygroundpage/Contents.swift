//: [Previous](@previous)

import Foundation

class Reader {
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
}

func solve1() {
    let sheet = Reader().read1()
    let checksum = sheet.reduce(0) { (sum, line) in
        return sum + (line.max()! - line.min()!)
    }
    print(checksum)
}

func solve2() {
    let sheet = Reader().read1()

    print(sheet)
}

//solve1()
solve2()
//: [Next](@next)
