
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

var mem: [String: (v: Int, snd: Int?)] = [:]

func solve1(fileName: String = "input.txt") {
    let input = readTerminal(fileName)
    let instr = input.map { Instruction(string: $0) }

    var recoveredFreq: Int? = nil
    var idx: Int = 0
    while recoveredFreq == nil {
        if idx < 0 || idx >= instr.count {
            print("OOB")
            break
        }
        let i = instr[idx]
        // print("\(idx)")//: \(mem)")

        if mem[i.param1] == nil {
            mem[i.param1] = (0, nil)
        }
        if let param2 = i.param2Str, mem[param2] == nil {
            mem[param2] = (0, nil)
        }

        let mem1: (v: Int, snd: Int?) = mem[i.param1]!

        switch i.op {
        case .snd:
            mem[i.param1] = (mem1.0, mem1.0)
        case .set:
            let val2: Int = i.param2Int ?? mem[i.param2Str!]!.0
            mem[i.param1] = (val2, mem1.1)
        case .add:
            let val2: Int = i.param2Int ?? mem[i.param2Str!]!.0
            mem[i.param1] = (mem1.0 + val2, mem1.1)
        case .mul:
            let val2: Int = i.param2Int ?? mem[i.param2Str!]!.0
            mem[i.param1] = (mem1.0 * val2, mem1.1)
        case .mod:
            let val2: Int = i.param2Int ?? mem[i.param2Str!]!.0
            mem[i.param1] = (mem1.0 % val2, mem1.1)
        case .rcv:
            if mem1.0 > 0 {
                recoveredFreq = mem1.1
                print(recoveredFreq ?? "nil")
                break
                // mem[i.param1] = (mem1.1!, mem1.1)//??
            }
        case .jgz:
            let val2: Int = i.param2Int ?? mem[i.param2Str!]!.0
            if mem1.0 > 0 {
                idx += val2
            } else {
                idx += 1
            }
        }

        if i.op != .jgz {
            idx += 1
        }
    }
}

if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve1(fileName: fileName)
} else {
    solve1()
}
