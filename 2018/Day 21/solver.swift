import Foundation

// Running:
// $ swift solver.swift [inputfilename]
// If no argument provided, it takes "input.txt"



///SOLUTION PART 1: Check when on IP=28, what is register[1], that's the value register[0] should have
///SOLUTION PART 2: collect register[1] values on IP=28, wait for a loop, then take the last one.

class Solver {

    enum Opcode: CaseIterable {
        case addr, addi
        case mulr, muli
        case banr, bani
        case borr, bori
        case setr, seti
        case gtir, gtri, gtrr
        case eqir, eqri, eqrr

        init(string: String) {
            switch string {
            case "addr": self = .addr
            case "addi": self = .addi
            case "mulr": self = .mulr
            case "muli": self = .muli
            case "banr": self = .banr
            case "bani": self = .bani
            case "borr": self = .borr
            case "bori": self = .bori
            case "setr": self = .setr
            case "seti": self = .seti
            case "gtir": self = .gtir
            case "gtri": self = .gtri
            case "gtrr": self = .gtrr
            case "eqir": self = .eqir
            case "eqri": self = .eqri
            case "eqrr": self = .eqrr
            default: fatalError("Unexpected \(string)")
            }
        }
    }

    struct Instruction: CustomStringConvertible {
        let opcode: Opcode
        let a: Int
        let b: Int
        let c: Int

        init(string: String) {
            let elements = string.split(separator: " ")
            opcode = Opcode(string: String(elements[0]))
            a = Int(elements[1])!
            b = Int(elements[2])!
            c = Int(elements[3])!
        }

        var description: String {
            return "\(opcode) \(a) \(b) \(c)"
        }
    }

    var register: [Int] = [0, 0, 0, 0, 0, 0]
    var ip: Int = 0
    var ipAddr: Int = 0

    func operate(instr: Instruction) {
        switch instr.opcode {
        case .addr: register[instr.c] = register[instr.a] + register[instr.b]
        case .addi: register[instr.c] = register[instr.a] + instr.b
        case .mulr: register[instr.c] = register[instr.a] * register[instr.b]
        case .muli: register[instr.c] = register[instr.a] * instr.b
        case .banr: register[instr.c] = register[instr.a] & register[instr.b]
        case .bani: register[instr.c] = register[instr.a] & instr.b
        case .borr: register[instr.c] = register[instr.a] | register[instr.b]
        case .bori: register[instr.c] = register[instr.a] | instr.b
        case .setr: register[instr.c] = register[instr.a]
        case .seti: register[instr.c] = instr.a
        case .gtir: register[instr.c] = instr.a > register[instr.b] ? 1 : 0
        case .gtri: register[instr.c] = register[instr.a] > instr.b ? 1 : 0
        case .gtrr: register[instr.c] = register[instr.a] > register[instr.b] ? 1 : 0
        case .eqir: register[instr.c] = instr.a == register[instr.b] ? 1 : 0
        case .eqri: register[instr.c] = register[instr.a] == instr.b ? 1 : 0
        case .eqrr: register[instr.c] = register[instr.a] == register[instr.b] ? 1 : 0
        }
    }

    func solve(_ fileName: String = "input.txt") -> String {
        let input = readFile(fileName)
        let result1 = solve1(input: input)
        let result2 = solve2(input: input)
        return "r1: \(result1)\nr2: \(result2)"
    }

private func solve1(input: String) -> String {
        register[0] = Int.max
        let lines = input.split(separator: "\n")
        ipAddr = Int(String(lines.first!.last!))!
        let instructions: [Instruction] = lines[1...].map { return Instruction(string: String($0)) }
        // print(instructions)
        var i = 0
        var lastInstr = instructions[0]
        var lastIP = ip
        var lastReg1 = 0
        var reg1Vals: Set<Int> = []
        while ip >= 0 && ip < instructions.count {
            i += 1
            lastInstr = instructions[ip]
            // print(i, "ip=\(ip)", instructions[ip], "|", register[1], register[2], "|", String(register[1], radix: 2), String(register[2], radix: 2))

            if [28].contains(ip) {
                print(register[1], reg1Vals.count)
                let hadReg = lastReg1 != 0
                let prevCount = reg1Vals.count
                reg1Vals.insert(register[1])
                if prevCount == reg1Vals.count {
                    print(lastReg1)
                    break
                }
                lastReg1 = register[1]
                lastIP = ip
                operate(instr: instructions[ip])
                // if hadReg {
                    // break
                // }
                
                // print(register)
                // fatalError()
            } else {
                lastIP = ip
            // print(i, "ip=\(ip)", register, instructions[ip], terminator: " ")
                operate(instr: instructions[ip])
            // print(register)
            }
            register[ipAddr] += 1
            ip = register[ipAddr]
        }
        print("ip=\(ip)", register, i, lastInstr, lastIP)
        return "\(register[0])"
    }

    private func solve2(input: String) -> String {
        // let lines = input.split(separator: "\n")

        return ""
    }

    private func readFile(_ fileName: String) -> String {
        let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        guard let fileURL = URL(string: fileName, relativeTo: currentDirectoryURL) else {
            print("file not found: \(currentDirectoryURL.path)/\(fileName)")
            return ""
        }
        let content = try! String(contentsOf: fileURL)
        return content
    }
}

let solver = Solver()
let result: String

if CommandLine.arguments.count > 1 {
    result = solver.solve(CommandLine.arguments[1])
} else {
    result = solver.solve()
}

print(result)