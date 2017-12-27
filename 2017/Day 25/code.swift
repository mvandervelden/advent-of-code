
// to run: `swift code.swift [input_filename]`
import Foundation

func readTerminal(_ fileName: String) -> String {
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    guard let fileURL = URL(string: fileName, relativeTo: currentDirectoryURL) else {
        print("file not found: \(currentDirectoryURL.path)/\(fileName)")
        return ""
    }
    let content = try! String(contentsOf: fileURL)
    return content
}

enum Direction {
    case l, r
}

class Tape {
    private var tape: [Bool] = Array(repeatElement(false, count: 10))
    var position: Int = 0
    var offset: Int = 0

    subscript(i: Int) -> Bool {
        get {
            if offset + i >= tape.count || offset + i < 0 {
                return false
            }
            return tape[offset + i]
        }
        set {
            if i + offset < 0 {
                let increase = 10
                let newTape = tapeOfSize(tape.count + increase)
                fill(newTape, offset: increase)
                offset += increase
            }
            tape[i + offset] = newValue
        }
    }

    func move(direction: Direction) {
        switch direction {
        case .l:
            position -= 1
        case .r:
            position += 1
        }
    }

    func tapeOfSize(_ size: Int) -> [Bool] {
        return Array(repeatElement(false, count: size))
    }

    func fill(_ newTape: [Bool], offset: Int) {
        var newTape = newTape
        tape.enumerated().forEach { item in
            newTape[item.offset + offset] = item.element
        }
        tape = newTape
    }

    var checksum: Int {
        return tape.reduce(0) { (sum: Int, bool: Bool) -> Int in
            return sum + (bool ? 1 : 0)
        }
    }
}

extension Tape: CustomStringConvertible {
    var description: String {
        return tape.enumerated().reduce("") { (itemsString, item) in
            if offset + position == item.offset {
                return itemsString + "[\(item.element ? 1 : 0)]"
            }
            return itemsString + " \(item.element ? 1 : 0) "
        }
    }
}

protocol State: CustomStringConvertible {
    func move(tape: Tape) -> State
}

extension State {
    var description: String {
        return "\(type(of: self))"
    }
}

struct A: State {
    func move(tape: Tape) -> State {
        switch tape[tape.position] {
        case false:
            tape[tape.position] = true
            tape.move(direction: .r)
            return B()
        case true:
            tape[tape.position] = false
            tape.move(direction: .l)
            return B()
        }
    }
}

struct B: State {
    func move(tape: Tape) -> State {
        switch tape[tape.position] {
        case false:
            tape[tape.position] = false
            tape.move(direction: .r)
            return C()
        case true:
            tape[tape.position] = true
            tape.move(direction: .l)
            return B()
        }
    }
}

struct C: State {
    func move(tape: Tape) -> State {
        switch tape[tape.position] {
        case false:
            tape[tape.position] = true
            tape.move(direction: .r)
            return D()
        case true:
            tape[tape.position] = false
            tape.move(direction: .l)
            return A()
        }
    }
}

struct D: State {
    func move(tape: Tape) -> State {
        switch tape[tape.position] {
        case false:
            tape[tape.position] = true
            tape.move(direction: .l)
            return E()
        case true:
            tape[tape.position] = true
            tape.move(direction: .l)
            return F()
        }
    }
}

struct E: State {
    func move(tape: Tape) -> State {
        switch tape[tape.position] {
        case false:
            tape[tape.position] = true
            tape.move(direction: .l)
            return A()
        case true:
            tape[tape.position] = false
            tape.move(direction: .l)
            return D()
        }
    }
}

struct F: State {
    func move(tape: Tape) -> State {
        switch tape[tape.position] {
        case false:
            tape[tape.position] = true
            tape.move(direction: .r)
            return A()
        case true:
            tape[tape.position] = true
            tape.move(direction: .l)
            return E()
        }
    }
}

struct Ax: State {
    func move(tape: Tape) -> State {
        switch tape[tape.position] {
        case false:
            tape[tape.position] = true
            tape.move(direction: .r)
            return Bx()
        case true:
            tape[tape.position] = false
            tape.move(direction: .l)
            return Bx()
        }
    }
}

struct Bx: State {
    func move(tape: Tape) -> State {
        switch tape[tape.position] {
        case false:
            tape[tape.position] = true
            tape.move(direction: .l)
            return Ax()
        case true:
            tape[tape.position] = true
            tape.move(direction: .r)
            return Ax()
        }
    }
}

class Program {
    var state: State = A()
    var checksumAfterCount = 12_629_077
    let tape: Tape = Tape()

    init(example: Bool = false) {
        if example {
            state = Ax()
            checksumAfterCount = 6
        }
    }

    func run() {
        for _ in 0..<checksumAfterCount {
            state = state.move(tape: tape)
            
        }
        print(self)
    }
}

extension Program: CustomStringConvertible {
    var description: String {
        return "\(tape)\nState: \(state), sum: \(tape.checksum)"
    }
}

func solve1(fileName: String = "input.txt") {
    // let input = readTerminal(fileName)
    let program = Program(example: fileName == "input.txt" ? false : true)
    program.run()
    // print(sections)
}

if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve1(fileName: fileName)
} else {
    solve1()
}
