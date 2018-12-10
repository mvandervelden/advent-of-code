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
    let regex = try! NSRegularExpression(pattern: "position=< *(.+), *(.+)> velocity=< *(.+), *(.+)>", options: .dotMatchesLineSeparators)

    func solve(_ fileName: String = "input.txt") -> String {
        let input = readFile(fileName)
        let result1 = solve1(input: input)
        let result2 = solve2(input: input)
        return "r1: \(result1)\nr2: \(result2)"
    }

    private func solve1(input: String) -> String {
        let points: [(x: Int, y: Int, dx: Int, dy: Int)] = input.split(separator: "\n").map { String($0)}.map { string in
            guard let match = regex.matches(in: string, options: [] as NSRegularExpression.MatchingOptions, range: string.nsrange).first else {
                fatalError("No match found")
            }
            let x = Int(string.substring(with: match.range(at: 1))!)!
            let y = Int(string.substring(with: match.range(at: 2))!)!
            let dx = Int(string.substring(with: match.range(at: 3))!)!
            let dy = Int(string.substring(with: match.range(at: 4))!)!
            return (x: x, y: y, dx: dx, dy: dy)
        }
    
        var range =  rangeFor(points: points)
        var rangeNum = (range.maxx - range.minx) + (range.maxy - range.miny)
        var rangeDiff = -1
        var t = 0
        // print(range)
        while rangeDiff < 0 {
            t += 1
            let newPoints = points.map { point in
                return (
                    x: point.x + point.dx * t,
                    y: point.y + point.dy * t,
                    dx: point.dx,
                    dy: point.dy
                )
            }

            range = rangeFor(points: newPoints)
            // print(range)
            let newRangeNum = (range.maxx - range.minx) + (range.maxy - range.miny)
            rangeDiff = newRangeNum - rangeNum
            // print(rangeNum, newRangeNum)
            rangeNum = newRangeNum
        }

        printPoints(points, t: t - 1)
        return "\(range)"
    }

    func rangeFor(points: [(x: Int, y: Int, dx: Int, dy: Int)]) -> (minx: Int, miny: Int, maxx: Int, maxy: Int) {
        return points.reduce((minx: Int.max, miny: Int.max, maxx: Int.min, maxy: Int.min)) { spread, point in 
            return (
                minx: min(spread.minx, point.x), 
                miny: min(spread.miny, point.y),
                maxx: max(spread.maxx, point.x),
                maxy: max(spread.maxy, point.y)
            )
        }
    }

    func printPoints(_ points: [(x: Int, y: Int, dx: Int, dy: Int)], t: Int) {
        let newPoints = points.map { point in
            return (
                x: point.x + point.dx * t,
                y: point.y + point.dy * t,
                dx: point.dx,
                dy: point.dy
            )
        }
        let range = rangeFor(points: newPoints)
        let printRow = Array(repeating: ".", count: range.maxx-range.minx + 1)

        var printGrid: [[String]] = Array(repeating: printRow, count: range.maxy-range.miny + 1)
        // print("g:", printGrid.count, printGrid[0].count)
        newPoints.forEach { point in
            // print("p:", point.y-range.miny, point.x-range.minx)
            printGrid[point.y-range.miny][point.x-range.minx] = "#"
        }

        printGrid.forEach { row in
            row.forEach { cell in
                print(cell, terminator: "")
            }
            print("")
        }
        print(t)
    }

    private func solve2(input: String) -> String {
        // let lines = input.split(separator: "\n")

        return "No match found"
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