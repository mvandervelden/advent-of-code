//: [Previous](@previous)

import Foundation

class Reader {
    func read(_ fileName: String = "input") -> [KeySequence] {
        let fileURL = Bundle.main.url(forResource: fileName, withExtension: "txt")
        let content = try! String(contentsOf: fileURL!)
        return content
            .split(separator: "\n")
            .map {
                KeySequence(string: String($0))
        }
    }
}

enum Move {
    case u, d, l, r
}

struct KeySequence: CustomDebugStringConvertible {
    let moves: [Move]

    init(string: String) {
        moves = string.map { character in
            switch character {
            case "U":
                return .u
            case "D":
                return .d
            case "L":
                return .l
            case "R":
                return .r
            default:
                fatalError("invalid character \(character)")
            }
        }
    }

    var debugDescription: String {
        return moves.map { "\($0)" }.joined()
    }
}

enum KeyPad1 {
    static let numbers: [[Int]] = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
}

enum KeyPad2 {
    static let pad: [[String?]] = [[nil, nil, "1", nil, nil], [nil, "2", "3", "4", nil], ["5", "6", "7", "8", "9"], [nil, "A", "B", "C", nil], [nil, nil, "D", nil, nil]]

}

struct Key1 {
    let row: Int
    let col: Int

    static var start: Key1 { return Key1(row: 1, col: 1) }//5

    func next(move: Move) -> Key1 {
        switch (move, row, col) {
        case (.u, 0, _), (.d, 2, _), (.l, _, 0), (.r, _, 2):
            return self
        case (.u, _, _):
            return Key1(row: row - 1, col: col)
        case (.d, _, _):
            return Key1(row: row + 1, col: col)
        case (.l, _, _):
            return Key1(row: row, col: col - 1)
        case (.r, _, _):
            return Key1(row: row, col: col + 1)
        }
    }

    var value: Int {
        return KeyPad1.numbers[row][col]
    }
}

struct Key2 {
    let row: Int
    let col: Int

    static var start: Key2 { return Key2(row: 2, col: 0) }//5

    func next(move: Move) -> Key2 {
        let theoreticalNext: Key2
        switch (move, row, col) {
        case (.u, 0, _), (.d, 4, _), (.l, _, 0), (.r, _, 4):
            return self
        case (.u, _, _):
            theoreticalNext = Key2(row: row - 1, col: col)
        case (.d, _, _):
            theoreticalNext = Key2(row: row + 1, col: col)
        case (.l, _, _):
            theoreticalNext = Key2(row: row, col: col - 1)
        case (.r, _, _):
            theoreticalNext = Key2(row: row, col: col + 1)
        }
        if theoreticalNext.value == nil {
            return self
        }
        return theoreticalNext
    }

    var value: String? {
        return KeyPad2.pad[row][col]
    }
}

func solve1() {
    let sequences = Reader().read()
    var pressedKeys: [Int] = []
    var lastKey = Key1.start
    for sequence in sequences {
        sequence.moves.forEach { move in
            lastKey = lastKey.next(move: move)
        }
        pressedKeys.append(lastKey.value)
    }
    print(pressedKeys.map { String($0) }.joined())
}

func solve2(_ file: String = "input") {
    let sequences = Reader().read(file)
    var pressedKeys: [String] = []
    var lastKey = Key2.start
    for sequence in sequences {
        sequence.moves.forEach { move in
            lastKey = lastKey.next(move: move)
        }
        pressedKeys.append(lastKey.value!)
    }
    print(pressedKeys.joined())
}

//solve1()
solve2()
//: [Next](@next)
