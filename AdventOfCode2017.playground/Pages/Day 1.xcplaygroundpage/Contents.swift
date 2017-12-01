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

    var sum = 0
    for i in 0..<ints.count - 1 {
        if ints[i] == ints[i+1] {
            sum += ints[i]
        }
    }
    if ints.first == ints.last {
        sum += ints.first!
    }
    print(sum)
}

func solve2() {
    let ints = Reader().read1()

    var sum = 0
    let halfRound = ints.count / 2
    for i in 0..<ints.count {
        let match = (i + halfRound) % ints.count
        if ints[i] == ints[match] {
            sum += ints[i]
        }
    }

    print(sum)
}

solve1()
solve2()
//: [Next](@next)
