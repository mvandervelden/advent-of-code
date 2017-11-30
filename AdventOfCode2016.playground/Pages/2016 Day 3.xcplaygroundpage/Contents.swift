//: [Previous](@previous)

import Foundation

class Reader {
    func read1(_ fileName: String = "input") -> [TriangleDefinition] {
        let fileURL = Bundle.main.url(forResource: fileName, withExtension: "txt")
        let content = try! String(contentsOf: fileURL!)
        return content
            .split(separator: "\n")
            .map {
                TriangleDefinition(string: String($0))
        }
    }

    func read2(_ fileName: String = "input") -> [TriangleDefinition] {
        let fileURL = Bundle.main.url(forResource: fileName, withExtension: "txt")
        let content = try! String(contentsOf: fileURL!)
        let rows = content.split(separator: "\n")
        let values = rows.flatMap { $0.split(separator: " ").filter { String($0) != "" }.map { Int($0)! } }

        let definitions = stride(from: 0, to: values.count, by: 9).map {
            Array(values[$0..<min($0 + 9, values.count)])
            }.flatMap { TriangleDefinition.colWizeTriangles($0) }
        return definitions
    }
}


struct TriangleDefinition: CustomDebugStringConvertible {
    let sides: [Int]

    init(string: String) {
        sides = string.split(separator: " ").filter { String($0) != "" }.map { Int($0)! }
    }

    init(sides: [Int]) {
        self.sides = sides
    }

    static func colWizeTriangles(_ array: [Int]) -> [TriangleDefinition] {
        return [
            TriangleDefinition(sides: [ array[0], array[3], array[6]]),
            TriangleDefinition(sides: [ array[1], array[4], array[7]]),
            TriangleDefinition(sides: [ array[2], array[5], array[8]])
        ]
    }

    var isPossible: Bool {
        return sides[0] + sides[1] > sides[2]
            && sides[0] + sides[2] > sides[1]
            && sides[1] + sides[2] > sides[0]
    }

    var debugDescription: String {
        return sides.map { String($0) }.joined(separator: " ")
    }
}

func solve1(_ file: String = "input") {
    let definitions = Reader().read1(file).filter { $0.isPossible }.count
    print(definitions)
}

func solve2(_ file: String = "input") {
    let definitions = Reader().read2(file).filter { $0.isPossible }.count
    print(definitions)
}

solve1()
solve2()
//: [Next](@next)
