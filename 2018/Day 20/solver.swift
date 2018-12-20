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

let optionalLoopRx = try! NSRegularExpression(pattern: "\\((.+)\\|\\)", options: [])
let branchRx = try! NSRegularExpression(pattern: "\\((.+)\\|(.+)\\)", options: [])

class Solver {
    struct Coord: CustomStringConvertible {
        let x, y: Int

        var description: String {
            return "(\(x), \(y))"
        }

        func above() -> Coord {
            return Coord(x: x, y: y - 1)
        }

        func below() -> Coord {
            return Coord(x: x, y: y + 1)
        }

        func left() -> Coord {
            return Coord(x: x - 1, y: y)
        }
        
        func right() -> Coord {
            return Coord(x: x + 1, y: y)
        }
    }
    
    var doors: [Coord: [Coord]] = [:]

    func solve(_ fileName: String = "input.txt") -> String {
        let input = readFile(fileName)
        let result1 = solve1(input: input)
        let result2 = solve2(input: input)
        return "r1: \(result1)\nr2: \(result2)"
    }

    private func solve1(input: String) -> String {
        let array = Array(input)

        var i = 1
        var currentCoord = Coord(x: 0, y: 0)
        var nextCoord = Coord(x: 0, y: 0)
        while true {
            let nextChar = array[i]
            switch nextChar {
            case "$": break
            case "N":
                nextCoord = currentCoord.above()
                doors[currentCoord, default: []].append(nextCoord)
                doors[nextCoord, default: []].append(currentCoord)
            case "E":
                nextCoord = currentCoord.right()
                doors[currentCoord, default: []].append(nextCoord)
                doors[nextCoord, default: []].append(currentCoord
            case "S":
                nextCoord = currentCoord.below()
                doors[currentCoord, default: []].append(nextCoord)
                doors[nextCoord, default: []].append(currentCoord
            case "W":
                nextCoord = currentCoord.left()
                doors[currentCoord, default: []].append(nextCoord)
                doors[nextCoord, default: []].append(currentCoord
            case "(":
                let branchString = String(array[i...])
                if let optionalLoop = optionalLoopRx.matches(in: branchString, options: [] as NSRegularExpression.MatchingOptions, range: branchString.nsrange).first {
                    let loop = branchString.substring(with: optionalLoop.range(at: 1))!
                    //TODO recursively solve loop
                } else if //TODO branch

            }
        }
        
        return ""
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