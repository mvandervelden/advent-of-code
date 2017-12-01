//: [Previous](@previous)

import Foundation

class Reader {
    func read1(_ fileName: String = "input") -> [Int] {
        let fileURL = Bundle.main.url(forResource: fileName, withExtension: "txt")
        let content = try! String(contentsOf: fileURL!)
        return content.flatMap {
            Int(String($0))
        }
    }
}

func solve1() {
    let ints = Reader().read1()

    print(ints)
}

func solve2() {
    let ints = Reader().read1()

    print(ints)
}

solve1()
//solve2()
//: [Next](@next)
