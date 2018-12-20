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

// let optionalLoopRx = try! NSRegularExpression(pattern: "^\\((.+)\\|\\)([NWES]*\\$)", options: [])
// let branchRx = try! NSRegularExpression(pattern: "^\\(([NWES]*)\\|(.+)\\)([NWES]*\\$)", options: [])

class Solver {
    struct Coord: CustomStringConvertible, Hashable {
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
        // print(input)
        let array = Array(input)

        parseDirections(Array(array[1..<(array.count-1)]), current: Coord(x: 0, y: 0))
        let dist = findLongestRoute(current: Coord(x: 0, y: 0), cost: 0)
        print(doors.count)
        print("r2:", thousandSet.count)
        return "\(dist)"
    }

    private func solve2(input: String) -> String {
        // let lines = input.split(separator: "\n")

        return ""
    }

    func parseDirections(_ directions: [Character], current: Coord) {
        let nextChar = directions.first!
        // print(nextChar)
        switch nextChar {
        case "$":
            // print("found end")
            return
        case "N":
            let nextCoord = current.above()
            doors[current, default: []].append(nextCoord)
            doors[nextCoord, default: []].append(current)
            parseDirections(Array(directions[1...]), current: nextCoord)
        case "E":
            let nextCoord = current.right()
            doors[current, default: []].append(nextCoord)
            doors[nextCoord, default: []].append(current)
            parseDirections(Array(directions[1...]), current: nextCoord)
        case "S":
            let nextCoord = current.below()
            doors[current, default: []].append(nextCoord)
            doors[nextCoord, default: []].append(current)
            parseDirections(Array(directions[1...]), current: nextCoord)
        case "W":
            let nextCoord = current.left()
            doors[current, default: []].append(nextCoord)
            doors[nextCoord, default: []].append(current)
            parseDirections(Array(directions[1...]), current: nextCoord)
        case "(":
            // print("branch", String(directions))
            var endOfBranch: Int? = nil
            var depth = 0
            for dir in directions.enumerated() { 
                // print(dir, depth)
                switch dir.element {
                case "(": depth += 1
                case ")":
                    // print(dir, depth)

                    depth -= 1
                    // print(dir, depth)

                    if depth == 0 {
                        // print("break", dir.offset)
                        endOfBranch = dir.offset
                        break
                    }
                default: continue
                }
                if endOfBranch != nil { break }
            }
            // print(endOfBranch!)
            let rest = directions[(endOfBranch! + 1)...]
            if directions[endOfBranch! - 1] == "|" {
                let loop = directions[1..<(endOfBranch! - 1)]
                // print("optionalLoop", String(loop))
                // print("optionalLoop - rest", String(rest))
                parseDirections(Array(loop) + Array(rest), current: current)
                // parseDirections(Array(rest), current: current)
            } else {
                // branches
                let dividers = directions.enumerated().filter { 
                    guard $0.element == "|" else { return false }
                    let openCount = directions[1..<$0.offset].filter { $0 == "(" }.count
                    let closeCount = directions[1..<$0.offset].filter { $0 == ")" }.count
                    return openCount == closeCount
                }.map { $0.offset }

                var previousDivider = 0
                for divider in dividers {
                    let branch = directions[(previousDivider+1)..<divider]
                    // print("branch - ", String(firstBranch))
                    // print("branch - rest", String(rest))
                    parseDirections(Array(branch) + Array(rest), current: current)
                    previousDivider = divider
                }
                let branch = directions[(previousDivider+1)..<endOfBranch!]
                
                // print("branch - last", String(secondBranch))
                // print("branch - rest", String(rest))
                parseDirections(Array(branch) + Array(rest), current: current)
            }
        default:
            print("Unexpected characted: \(nextChar)", String(directions))
        }
    }

    var found: Set<Coord> = []
    var thousandSet: Set<Coord> = []

    func findLongestRoute(current: Coord, cost: Int) -> Int {
        found.insert(current)
        if cost >= 1000 { thousandSet.insert(current) }
        return doors[current]!.filter { !found.contains($0) }.map { findLongestRoute(current: $0, cost: cost + 1) }.max() ?? cost
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