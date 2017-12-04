//: [Previous](@previous)

import Foundation

func read1(_ fileName: String = "input") -> [[String]] {
    let fileURL = Bundle.main.url(forResource: fileName, withExtension: "txt")
    let content = try! String(contentsOf: fileURL!)
    let lines = content.split(separator: "\n")
    return lines.map { line in
        line.split(separator: " ").map {
            return String($0).trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}

func solve1() {
    let strings: [[String]] = read1()
    let valids = strings.reduce(0) { (validAmount, line) in
        let sortedWords: [String] = line.map { String($0.sorted()) }
        return Set(sortedWords).count == line.count ? validAmount + 1 : validAmount
    }
    print(valids)
}
solve1()

//: [Next](@next)
