import Foundation

// Running:
// $ swift solver.swift [inputfilename]
// If no argument provided, it takes "input.txt"

extension String {
    /// An `NSRange` that represents the full range of the string.
    var nsrange: NSRange {
        return NSRange(location: 0, length: utf16.count)
    }

    /// Returns a substring with the given `NSRange`,
    /// or `nil` if the range can't be converted.
    func substring(with nsrange: NSRange) -> String? {
        guard let range = Range(nsrange) else { return nil }
        
        let startIndex = self.index(self.startIndex, offsetBy: range.startIndex)
        let stopIndex = self.index(self.startIndex, offsetBy: range.startIndex + range.count)
        return String(self[startIndex..<stopIndex])
    }

    /// Returns a range equivalent to the given `NSRange`,
    /// or `nil` if the range can't be converted.
    func range(from nsrange: NSRange) -> Range<Index>? {
        guard let range = Range(nsrange) else { return nil }
        
        let startIndex = self.index(self.startIndex, offsetBy: range.startIndex)
        let stopIndex = self.index(self.startIndex, offsetBy: range.startIndex + range.count)

        return startIndex..<stopIndex
    }
}

let beforeRx = try! NSRegularExpression(pattern: "([0-9]), ([0-9]), ([0-9]), ([0-9])", options: [])
let afterRx = try! NSRegularExpression(pattern: "([0-9]), ([0-9]), ([0-9]), ([0-9])", options: [])

class Solver {
    enum Opcode: CaseIterable {
        case addr, addi
        case mulr, muli
        case banr, bani
        case borr, bori
        case setr, seti
        case gtir, gtri, gtrr
        case eqir, eqri, eqrr
    }

    struct Instruction {
        let opcode: Int
        let a: Int
        let b: Int
        let c: Int

        init(string: String) {
            let elements = string.split(separator: " ")
            opcode = Int(elements[0])!
            a = Int(elements[1])!
            b = Int(elements[2])!
            c = Int(elements[3])!
        }
    }

    var register: [Int] = [0, 0, 0, 0]

    func solve(_ fileName: String = "input.txt") -> String {
        let input = readFile(fileName)
        let result1 = solve1(input: input)
        let result2 = solve2(input: input)
        return "r1: \(result1)\nr2: \(result2)"
    }

    private func solve1(input: String) -> String {
        let parts = input.components(separatedBy: "\n\n\n")
        let samples = parts[0].components(separatedBy: "\n\n")

        var result = 0

        for sample in samples {
            let parsed = parseSample(sample)

            var matchingOperations = 0
            Opcode.allCases.forEach { opcode in 
                register = parsed.before
                operate(opcode: opcode, instr: parsed.instr)
                if register == parsed.after { matchingOperations += 1 }
            }

            if matchingOperations >= 3 {
                result += 1
            }
        }
        print(result) 
        return "\(result)"
    }

private func solve2(input: String) -> String {
        let parts = input.components(separatedBy: "\n\n\n")
        let samples = parts[0].components(separatedBy: "\n\n")

        var result = 0

        var translations: [Int: Opcode] = [:]
        
        for sample in samples {
            let parsed = parseSample(sample)

            var matchingOperations: [Opcode] = []
            for opcode in Opcode.allCases {
                guard !translations.values.contains(opcode) else {
                    continue
                }
                register = parsed.before
                operate(opcode: opcode, instr: parsed.instr)
                if register == parsed.after { matchingOperations.append(opcode) }
            }

            if matchingOperations.count == 1 {
                translations[parsed.instr.opcode] = matchingOperations[0]
                result += 1
            }
        }
        print(translations.count, translations) 

        let program: [Instruction] = parts[1].split(separator: "\n").map { Instruction(string: String($0)) }

        register = [0, 0, 0, 0]
        for instr in program {
            operate(opcode: translations[instr.opcode]!, instr: instr)
        }
        print(register)
        return "\(register[0])"
    }

    

    func parseSample(_ sample: String) -> (before: [Int], instr: Instruction, after: [Int]) {
        let lines = sample.split(separator: "\n")

        let bLine = String(lines[0])
        guard let matchBefore = beforeRx.matches(in: bLine, options: [] as NSRegularExpression.MatchingOptions, range: bLine.nsrange).first else {
            fatalError("No match found")
        }
        let before: [Int] = [
            Int(bLine.substring(with: matchBefore.range(at: 1))!)!,
            Int(bLine.substring(with: matchBefore.range(at: 2))!)!,
            Int(bLine.substring(with: matchBefore.range(at: 3))!)!,
            Int(bLine.substring(with: matchBefore.range(at: 4))!)!
        ]
        
        let instr = Instruction(string: String(lines[1]))
        
        let aLine = String(lines[2])
        guard let matchAfter = beforeRx.matches(in: aLine, options: [] as NSRegularExpression.MatchingOptions, range: aLine.nsrange).first else {
            fatalError("No match found")
        }

        let after: [Int] = [
            Int(aLine.substring(with: matchAfter.range(at: 1))!)!,
            Int(aLine.substring(with: matchAfter.range(at: 2))!)!,
            Int(aLine.substring(with: matchAfter.range(at: 3))!)!,
            Int(aLine.substring(with: matchAfter.range(at: 4))!)!
        ]

        return (before: before, instr: instr, after: after)
    }

    func operate(opcode: Opcode, instr: Instruction) {
        switch opcode {
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