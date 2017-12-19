
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
    case set, mul, jgz, snd, add, mod, rcv
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
        case "jgz": op = .jgz
        case "snd": op = .snd
        case "add": op = .add
        case "mod": op = .mod
        case "rcv": fallthrough
        default: op = .rcv
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
var memories: [[String: Int]] = [[:], [:]]
var queues: [[Int]] = [[], []]
var locks = [false, false]
var indexes = [0, 0]
var valsSent: [Int] = [0, 0]

func perform(queueIdx: Int) {
    let otherQueueIdx = (queueIdx + 1) % 2
    let idx = indexes[queueIdx]
    let instruction = instructions[idx]
    let register = instruction.param1Str
    var memory = memories[queueIdx]

    // print("'\(instruction)' on memory \(queueIdx): \(memory)")
    if let register = register {
        if memory[register] == nil {
            if register == "p" && queueIdx == 1 {
                // print("init with 1")
                memory[register] = 1
            } else {
                memory[register] = 0
            }
        }
    }

    if let param2 = instruction.param2Str, memory[param2] == nil {
        if param2 == "p" && queueIdx == 1 {
            // print("init with 1")
            memory[param2] = 1
        } else {
            memory[param2] = 0
        }
    }

    switch instruction.op {
    case .set:
        let value: Int = instruction.param2Int ?? memory[instruction.param2Str!]!
        memory[register!] = value
    case .add:
        let memoryVal: Int = memory[register!]!
        let value: Int = instruction.param2Int ?? memory[instruction.param2Str!]!
        memory[register!] = memoryVal + value
    case .mul:
        let memoryVal: Int = memory[register!]!
        let value: Int = instruction.param2Int ?? memory[instruction.param2Str!]!
        memory[register!] = memoryVal * value
    case .mod:
        let memoryVal: Int = memory[register!]!
        let value: Int = instruction.param2Int ?? memory[instruction.param2Str!]!
        memory[register!] = memoryVal % value
    case .snd:
        let memoryVal: Int = memory[register!]!
        valsSent[queueIdx] += 1
        queues[otherQueueIdx].append(memoryVal)
        // print("\(queueIdx) sending \(memoryVal) [\(idx): \(instruction)] \(memory)")
        if locks[otherQueueIdx] {
            print("unlock \(otherQueueIdx) [\(idx): \(instruction)]")
        }
        locks[otherQueueIdx] = false
    case .rcv:
        if queues[queueIdx].count > 0 {
            locks[queueIdx] = false
            // print("\(queueIdx) rceving \(queues[queueIdx].first!) [\(idx): \(instruction)] \(memory)")
            memory[register!] = queues[queueIdx].first!
            queues[queueIdx] = Array(queues[queueIdx].dropFirst())
        } else {
            print("  lock \(queueIdx) [\(idx): \(instruction)] \(memory)")
            locks[queueIdx] = true
            indexes[queueIdx] -= 1
        }
    case .jgz:
    ///// THIS CAN BE A F*CKING INT INSTEAD OF A REGISTER!!! HAD '1' IN THE REGISTER FIRST
        let memoryVal: Int = instruction.param1Int ?? memory[register!]!
        if memoryVal > 0 {
            let value: Int = instruction.param2Int ?? memory[instruction.param2Str!]!
            indexes[queueIdx] += value
        } else {
            indexes[queueIdx] += 1
        }
    }

    if instruction.op != .jgz {
        indexes[queueIdx] += 1
    }

    memories[queueIdx] = memory
}

func solve2(fileName: String = "input.txt") {
    let input = readTerminal(fileName)
    instructions = input.map { Instruction(string: $0) }

    while true {
        if locks[0] && locks[1] {
            print("DEADLOCK")
            break
        }
        if indexes[0] < 0 || indexes[0] >= instructions.count {
            print("OOB1")
            break
        }
        if indexes[1] < 0 || indexes[1] >= instructions.count {
            print("OOB2")
            break
        }

        if !locks[0] {
            perform(queueIdx: 0)
        }
        if !locks[1] {
            perform(queueIdx: 1)
        }
    }

    print(valsSent)
}

if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve2(fileName: fileName)
} else {
    solve2()
}
