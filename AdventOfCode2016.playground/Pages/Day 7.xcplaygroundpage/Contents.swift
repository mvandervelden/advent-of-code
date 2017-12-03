//: [Previous](@previous)

import Foundation

struct IP {
    let sections: [Section]

    init(string: String) {
        
    }
}

struct Section {
    let string: String
    let containsHypernetSequence: Bool
}

func read1(_ fileName: String = "input") -> [String] {
    let fileURL = Bundle.main.url(forResource: fileName, withExtension: "txt")
    let content = try! String(contentsOf: fileURL!)
    return content
        .split(separator: "\n")
        .map { String($0) }
}

func solve1() {
    let ips = read1()

    print(ips)
}

solve1()
//: [Next](@next)
