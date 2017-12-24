
// to run: `swift code.swift [input_filename]`
import Foundation

func readTerminal(_ fileName: String) -> [String] {
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    guard let fileURL = URL(string: fileName, relativeTo: currentDirectoryURL) else {
        print("file not found: \(currentDirectoryURL.path)/\(fileName)")
        return []
    }
    let content = try! String(contentsOf: fileURL)
    let lines = content.split(separator: "\n")
    return lines.map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
}

enum Operation {
    case set, mul, sub, jnz
}

class Instruction {
    let op: Operation
    let param1: String
    private let param2: String?

    init(string: String) {
        let items = string.split(separator: " ")

        switch items[0] {
        case "set": op = .set
        case "mul": op = .mul
        case "jnz": op = .jnz
        case "sub": fallthrough
        default: op = .sub
        }
        param1 = String(items[1])
        if items.count == 3 {
            param2 = String(items[2])
        } else {
            param2 = nil
        }
    }

    var param1Str: String? {
        guard param1Int == nil else { return nil }
        return param1
    }

    var param1Int: Int? {
        return Int(param1)
    }

    var param2Str: String? {
        guard let param2 = param2 else { return nil }
        guard param2Int == nil else { return nil }
        return param2
    }

    var param2Int: Int? {
        guard let param2 = param2 else { return nil }
        return Int(param2)
    }
}

extension Instruction: CustomDebugStringConvertible {
    var debugDescription: String {
        return "\(op) \(param1) \(param2 ?? "")"
    }
}

var instructions: [Instruction] = []
var memory: [String: Int] = [:]
var index = 0
var mulInvokes = 0
var debugMode = false

func perform() {
    let instruction = instructions[index]
    let register = instruction.param1Str

    // print("'\(instruction)' on memory: \(memory)")
    if let register = register {
        if memory[register] == nil {
            if !debugMode && register == "a" {
                // print("init with 1")
                memory[register] = 1
            } else {
                memory[register] = 0
            }
        }
    }

    if let param2 = instruction.param2Str, memory[param2] == nil {
        if !debugMode && register == "a" {
            print("init with 1")
            memory[param2] = 1
        } else {
            memory[param2] = 0
        }
    }

    switch instruction.op {
    case .set:
        let value: Int = instruction.param2Int ?? memory[instruction.param2Str!]!
        memory[register!] = value
    case .mul:
        let memoryVal: Int = memory[register!]!
        let value: Int = instruction.param2Int ?? memory[instruction.param2Str!]!
        memory[register!] = memoryVal * value
        mulInvokes += 1
    case .sub:
        let memoryVal: Int = memory[register!]!
        let value: Int = instruction.param2Int ?? memory[instruction.param2Str!]!
        memory[register!] = memoryVal - value
        if register! == "h" {
            print("h increased to \(memory[register!]!)")
            print("memory: \(memory)")
        }
    case .jnz:
    ///// THIS CAN BE A F*CKING INT INSTEAD OF A REGISTER!!! HAD '1' IN THE REGISTER FIRST
        let memoryVal: Int = instruction.param1Int ?? memory[register!]!
        if memoryVal != 0 {
            let value: Int = instruction.param2Int ?? memory[instruction.param2Str!]!
            index += value
        } else {
            index += 1
        }
    }

    if instruction.op != .jnz {
        index += 1
    }
}

func solve1(fileName: String = "input.txt") {
    let input = readTerminal(fileName)
    instructions = input.map { Instruction(string: $0) }

    var i = 0
    while true {
        if index < 0 || index >= instructions.count {
            print("Out of Bounds")
            break
        }
        perform()
        i += 1
        if i % 1_000_000 == 0 {
            print(i)
        }
    }

    print("mul called: \(mulInvokes)")
    print("memory h: \(memory["h"] ?? 0)")
}

if CommandLine.arguments.count > 1 {
    debugMode = true
    solve1()
} else {
    debugMode = false
    solve1()
}
