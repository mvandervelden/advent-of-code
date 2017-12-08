
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

enum Change {
    case inc, dec

    static func from(_ string: String) -> Change {
        switch string {
        case "inc":
            return .inc
        default:
            return .dec
        }
    }

    func perform(on value: Int, with offset: Int) -> Int {
        switch self {
        case .inc: return value + offset
        case .dec: return value - offset
        }
    }
}

enum Condition {
    case LT, LET, GT, GET, EQ, NEQ

    static func from(_ string: String) -> Condition {
        switch string {
        case "<":
            return .LT
        case "<=":
            return .LET
        case ">":
            return .GT
        case ">=":
            return .GET
        case "==":
            return .EQ
        default:
            return .NEQ
        }
    }

    func conform(_ value: Int, toValue: Int) -> Bool {
        switch self {
        case .LT: return value < toValue
        case .LET: return value <= toValue
        case .GT: return value > toValue
        case .GET: return value >= toValue
        case .EQ: return value == toValue
        case .NEQ: return value != toValue
        }
    }
}

struct Instruction {
    let id: String
    let change: Change
    let offset: Int
    let conditionID: String
    let conditionEquality: Condition
    let conditionValue: Int

    init(string: String) {
        let items = string.split(separator: " ")
        id = String(items[0])
        change = Change.from(String(items[1]))
        offset = Int(String(items[2]))!
        conditionID = String(items[4])
        conditionEquality = Condition.from(String(items[5]))
        conditionValue = Int(String(items[6]))!
    }
}

extension Instruction: CustomDebugStringConvertible {
    var debugDescription: String {
        return "\(id) \(change) \(offset) IF \(conditionID) \(conditionEquality) \(conditionValue)"
    }
}

var mem: [String: Int] = [:]
var allTimeMax: Int = Int.min

func solve1(fileName: String = "input.txt") {
    let input = readTerminal(fileName)
    let instr = input.map { Instruction(string: $0) }

    for inst in instr {
        if mem[inst.id] == nil {
            mem[inst.id] = 0
        }
        if mem[inst.conditionID] == nil {
            mem[inst.conditionID] = 0
        }

        if inst.conditionEquality.conform(mem[inst.conditionID]!, toValue: inst.conditionValue) {
            mem[inst.id] = inst.change.perform(on: mem[inst.id]!, with: inst.offset)
        }
        allTimeMax = max(allTimeMax, mem.max { a, b in a.value < b.value }!.value)
        print(allTimeMax)
    }

    print(mem)
    let lastmax = mem.max { a, b in a.value < b.value }
    print(lastmax ?? "not found")
    print(allTimeMax)
}

if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve1(fileName: fileName)
} else {
    solve1()
}
