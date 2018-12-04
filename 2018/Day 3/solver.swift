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

class Solver {
    private enum OccupationState: CustomStringConvertible {
        case once(id: Int)
        case multiple

        var description: String {
            switch self {
                case .once(let id): return "\(id)"
                case .multiple: return "X"
            }
        }
    }

    private struct Claim {
        static let regex = try! NSRegularExpression(pattern: "#([0-9]+) @ ([0-9]+),([0-9]+): ([0-9]+)x([0-9]+)", options: .dotMatchesLineSeparators)
        let id: Int
        let x: Int
        let y: Int
        let width: Int
        let height: Int

        init(string: String) {
            guard let match = Claim.regex.matches(in: string, options: [] as NSRegularExpression.MatchingOptions, range: string.nsrange).first else {
                fatalError("No match found")
            }

            self.id = Int(string.substring(with: match.range(at: 1))!)!
            self.x = Int(string.substring(with: match.range(at: 2))!)!
            self.y = Int(string.substring(with: match.range(at: 3))!)!
            self.width = Int(string.substring(with: match.range(at: 4))!)!
            self.height = Int(string.substring(with: match.range(at: 5))!)!
        }
    }

    func solve(_ fileName: String = "input.txt") -> String {
        return solveAll(input: readFile(fileName))
    }

    private func claims(input: String) -> [Claim] {
        let lines = input.split(separator: "\n").map { String($0) }
        return lines.map { Claim(string: $0) }
    }

    private func solveAll(input: String) -> String {
        let claims = self.claims(input: input)

        var occupied: [Int: [Int: OccupationState]] = [:]
        var noDuplicates: [Int] = []

        claims.forEach { claim in
            var violated = false
            for x in claim.x..<(claim.x + claim.width) {
                for y in claim.y..<(claim.y + claim.height) {
                    switch occupied[x]?[y] {
                    case .none:
                        occupied[x, default: [:]][y] = .once(id: claim.id)
                    case .some(.once(let otherID)): 
                        noDuplicates = noDuplicates.filter { $0 != otherID }
                        occupied[x]![y] = .multiple
                        violated = true
                    default: 
                        violated = true
                    }
                }
            }
            if !violated { noDuplicates.append(claim.id) }
        }

        let multipleClaims = occupied.values.reduce(0) { sum, dict in
            return sum + dict.values.filter { $0.description == "X" }.count
        }

        return "r1: \(multipleClaims)\nr2: \(noDuplicates)"
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
