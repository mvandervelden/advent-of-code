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

let xValRx = try! NSRegularExpression(pattern: "x=([0-9]+)", options: [])
let yValRx = try! NSRegularExpression(pattern: "y=([0-9]+)", options: [])
let xRngRx = try! NSRegularExpression(pattern: "x=([0-9]+)\\.\\.([0-9]+)", options: [])
let yRngRx = try! NSRegularExpression(pattern: "y=([0-9]+)\\.\\.([0-9]+)", options: [])

class Solver {

    func solve(_ fileName: String = "input.txt") -> String {
        let input = readFile(fileName)
        let result1 = solve1(input: input)
        return result1
    }

    struct Coord: CustomStringConvertible {
        let x, y: Int

        var description: String {
            return "(\(x), \(y))"
        }
    }

    enum Fill: CustomStringConvertible {
        case sand, clay, stillWater, source, pouringWater, edge

        var description: String {
            switch self {
            case .sand: return "."
            case .clay: return "#"
            case .stillWater: return "~"
            case .source: return "+"
            case .pouringWater: return "|"
            case .edge: return "@"
            }
        }
    }

    var coordList: [Coord] = []
    var grid: [[Fill]] = []
    var frame: (orig: Coord, size: Coord)!
    var sources: [Coord] = []

    private func solve1(input: String) -> String {
        setupInput(input)
        writeGrid("input_grid.txt")
        fill()
        writeGrid()
        return "r1: \(waterCount()), r2: \(retainCount())"
    }

    func setupInput(_ input: String) {
        let lines = input.split(separator: "\n").map(String.init)

        for line in lines {
            var xs: [Int] = []
            var ys: [Int] = []
            
            if let matchXVal = xValRx.matches(in: line, options: [] as NSRegularExpression.MatchingOptions, range: line.nsrange).first {
                xs.append(Int(line.substring(with: matchXVal.range(at: 1))!)!)
            }
            if let matchYVal = yValRx.matches(in: line, options: [] as NSRegularExpression.MatchingOptions, range: line.nsrange).first {
                ys.append(Int(line.substring(with: matchYVal.range(at: 1))!)!)
            }
            if let matchXRng = xRngRx.matches(in: line, options: [] as NSRegularExpression.MatchingOptions, range: line.nsrange).first {
                let xMin = Int(line.substring(with: matchXRng.range(at: 1))!)!
                let xMax = Int(line.substring(with: matchXRng.range(at: 2))!)!

                xs.append(contentsOf: xMin...xMax)
            }
            if let matchYRng = yRngRx.matches(in: line, options: [] as NSRegularExpression.MatchingOptions, range: line.nsrange).first {
                let yMin = Int(line.substring(with: matchYRng.range(at: 1))!)!
                let yMax = Int(line.substring(with: matchYRng.range(at: 2))!)!

                ys.append(contentsOf: yMin...yMax)
            }

            xs.forEach { x in 
                ys.forEach { y in 
                    coordList.append(Coord(x: x, y: y))
                }
            }
        }

        let xMin = coordList.map { $0.x }.min()!
        let xMax = coordList.map { $0.x }.max()!
        let yMin = coordList.map { $0.y }.min()!
        let yMax = coordList.map { $0.y }.max()!
        frame = (orig: Coord(x: xMin - 2, y: yMin), size: Coord(x: xMax - xMin + 2, y: yMax - yMin + 1))
        convertToGrid()
    }

    func convertToGrid() {
        let row = Array(repeating: Fill.sand, count: frame.size.x + 2)
        grid = Array(repeating: row, count: frame.size.y + frame.orig.y)
        grid.append(Array(repeating: Fill.edge, count: frame.size.x + 2))

        (0..<grid.count).forEach { i in 
            grid[i][0] = .edge
            grid[i][row.count - 1] = .edge
        }

        coordList.forEach { coord in 
            grid[coord.y][coord.x - frame.orig.x] = .clay
        }

        sources = [Coord(x: 500 - frame.orig.x, y: 0)]
        grid[0][500 - frame.orig.x] = .source
    }

    func printGrid() {
        grid.forEach { row in 
            print(row.reduce("", { $0 + $1.description }))
        }
    }

    func fill() {
        while !sources.isEmpty {
            // printGrid()
            let currentSource = sources.last!

            // print(sources)
            switch grid[currentSource.y + 1][currentSource.x] {
            case .sand:
                // print("sand")
                grid[currentSource.y + 1][currentSource.x] = .pouringWater
                sources.append(Coord(x: currentSource.x, y: currentSource.y + 1))
            case .clay, .stillWater:
                // print("\(grid[currentSource.y + 1][currentSource.x])")
                let edges: (l: Coord?, r: Coord?) = findEdges(currentSource)
                if let left = edges.l, let right = edges.r {
                    ((left.x + 1)..<right.x).forEach { x in
                        if ![.sand, .pouringWater].contains(grid[left.y][x]) {
                            print("Unexpected conversion to still water:",grid[left.y][x], "coord:", x, left.y )
                        }
                        grid[left.y][x] = .stillWater
                    }
                    sources.removeAll { source in
                        if ((left.x + 1)..<right.x).contains(source.x) && source.y == left.y {
                            if ![.pouringWater, .stillWater].contains(grid[source.y][source.x]) {
                                print("removing source", source, "was:", grid[source.y][source.x])
                            }
                            return true
                        }
                        
                        return false
                    }
                } else {
                    sources.removeLast()
                    if case .sand = grid[currentSource.y][currentSource.x + 1] {
                        grid[currentSource.y][currentSource.x + 1] = .pouringWater
                        sources.append(Coord(x: currentSource.x + 1, y: currentSource.y))
                    }
                    if case .sand = grid[currentSource.y][currentSource.x - 1] {
                        grid[currentSource.y][currentSource.x - 1] = .pouringWater
                        sources.append(Coord(x: currentSource.x - 1, y: currentSource.y))
                    }
                }
            case .edge:
                sources.removeLast()
            case .pouringWater:
                sources.removeLast()
            default:
                break
            }
        }
    }

    func waterCount() -> Int {
        return grid[frame.orig.y...].reduce(0) { sum, row in 
            return sum + row.reduce(0) { rSum, cell in
                switch cell {
                case .stillWater, .pouringWater:
                    return rSum + 1
                default: return rSum
                }
            }
        }
    }

    func retainCount() -> Int {
        return grid[frame.orig.y...].reduce(0) { sum, row in 
            return sum + row.reduce(0) { rSum, cell in
                switch cell {
                case .stillWater:
                    return rSum + 1
                default: return rSum
                }
            }
        }
    }

    func findEdges(_ coord: Coord) -> (l: Coord?, r: Coord?) {
        return (l: findEdge(coord, it: -1), r: findEdge(coord, it: 1))
    }

    func findEdge(_ coord: Coord, it: Int) -> Coord? {
        var x = coord.x

        while true {
            x += it
            switch grid[coord.y][x] {
            case .clay:
                return Coord(x: x, y: coord.y)
            case .sand, .pouringWater:
                switch grid[coord.y + 1][x] {
                case .sand:
                    return nil
                default:
                    continue
                }
            case .edge:
                return nil
            default:
                print("Unexpected findEdge value:", grid[coord.y][x])
                print("Finding edge for: ", coord)
                print("Currently checking: ", x, coord.y)
                writeGrid()
                fatalError()
                continue
            }
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

    func writeGrid(_ filename: String = "output.txt") {
        let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)    

        let fileURL = currentDirectoryURL.appendingPathComponent(filename)

        let string: String = grid.map { row in 
            return row.reduce("", { $0 + $1.description })
        }.joined(separator: "\n")

        do {
            try string.write(to: fileURL, atomically: false, encoding: .utf8)
        }
        catch {
            print(error)
        }
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