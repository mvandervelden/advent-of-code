import Foundation

// Running:
// $ swift solver.swift [inputfilename]
// If no argument provided, it takes "input.txt"

class Solver {

    enum Field: CustomStringConvertible {
        case open, trees, lumber

        init(char: Character) {
            switch char {
            case ".": self = .open
            case "|": self = .trees
            case "#": self = .lumber
            default: fatalError("unexpected field: \(char)")
            }
        }

        var description: String {
            switch self {
            case .open: return "."
            case .trees: return "|"
            case .lumber: return "#"
            }
        }
    }

    var grid: [[Field]] = []
    var lastResourceValue: Int = 0

    func solve(_ fileName: String = "input.txt") -> String {
        let input = readFile(fileName)
        let result1 = solve1(input: input)
        let result2 = solve2(input: input)
        return "r1: \(result1)\nr2: \(result2)"
    }

    private func solve1(input: String, noLoops: Int = 10) -> String {
        grid = input.split(separator: "\n").map { line in 
            return Array(line).map { Field(char: $0) }
        }
        let totalMinutes = noLoops
        
        (0..<totalMinutes).forEach { _ in
            let resVal = resourceValue()
            // print(lastResourceValue, resVal - lastResourceValue)
            lastResourceValue = resVal
            // printGrid()
            // print()
            let pGrid: [[Field]] = grid

            for y in 0..<grid.count {
                for x in 0..<grid[0].count {
                    let hSection = max(0, x-1)...min(grid[0].count - 1, x+1)
                    let vSection = max(0, y-1)...min(grid.count - 1, y+1)
                    let base: [Field] = pGrid[vSection].flatMap { row in
                        return row[hSection]
                    }
                    // base.remove { $0 == grid[y][x] }

                    switch pGrid[y][x] {
                    case .open:
                        if base.filter({ $0 == Field.trees }).count >= 3 {
                            grid[y][x] = .trees
                        }
                    case .trees:
                        if base.filter({ $0 == Field.lumber }).count >= 3 {
                            grid[y][x] = .lumber
                        }
                    case .lumber:
                        if !(base.filter({ $0 == Field.lumber }).count >= 2 && base.filter({ $0 == Field.trees }).count >= 1) {
                            grid[y][x] = .open
                        }
                    }
                    // print(x, y, pGrid[y][x], base)
                }
            }
        }

        printGrid()        
        return "\(resourceValue())"
    }

    private func solve2(input: String) -> String {
        // on iteration 464, the output is 179662, again on 492, 520, 548
        // loop is 28 minutes
        let noLoops = 464 + (1_000_000_000 - 464) % 28
        return solve1(input: input, noLoops: noLoops)
    }

    func resourceValue() -> Int {
        let lumberCount = grid.reduce(0) { sum, row in
            return sum + row.filter { $0 == .lumber }.count
        }
        let treesCount = grid.reduce(0) { sum, row in
            return sum + row.filter { $0 == .trees }.count
        }
        return lumberCount * treesCount
    }

    func printGrid() {
        grid.forEach { line in
            print(line.map { $0.description }.joined(separator: ""))
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