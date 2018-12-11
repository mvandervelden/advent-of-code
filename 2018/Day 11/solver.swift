import Foundation

// Running:
// $ swift solver.swift [inputfilename]
// If no argument provided, it takes "input.txt"

class Solver {

    func solve(_ input: String = "5468") -> String {
        let result1 = solve1(input: Int(input)!)
        let result2 = solve2(input: Int(input)!)
        return "r1: \(result1)\nr2: \(result2)"
    }

    private func solve1(input: Int) -> String {
        let grid: [[Int]] = (1...300).map { y in
            return (1...300).map { x in
                let rackID = x + 10
                let power = (rackID * y + input) * rackID
                return ((power % 1000) / 100) - 5
            }
        }

        var max = Int.min
        var maxCoords = (x:-1, y: -1)
        let sums: [[Int]] = (0..<298).map { y in
            return (0..<298).map { x in
                let sum = grid[y..<(y+3)].reduce(0) { sum, line in
                    return sum + line[x..<(x+3)].reduce(0, +)
                }
                if sum > max {
                    max = sum
                    maxCoords = (x: x, y: y)
                }
                return sum
            }
        }

        grid[(maxCoords.y-1)..<(maxCoords.y+4)].forEach { line in
            line[(maxCoords.x-1)..<(maxCoords.x+4)].forEach { cell in
                print(cell, ", ", terminator: "")
            }
            print("")
        }

        return "\(max): \(maxCoords.x+1),\(maxCoords.y+1)"
    }

    private func solve2(input: Int) -> String {
        let grid: [[Int]] = (1...300).map { y in
            return (1...300).map { x in
                let rackID = x + 10
                let power = (rackID * y + input) * rackID
                return ((power % 1000) / 100) - 5
            }
        }

        var max = Int.min
        var maxCoords = (x:-1, y: -1, size: 0)

        (1..<300).forEach { size in 
            print("size", size)
            print(max, maxCoords)
            (0...(300 - size)).forEach { y in
                (0..<(300 - size)).forEach { x in
                    let sum = grid[y..<(y+size)].reduce(0) { sum, line in
                        return sum + line[x..<(x+size)].reduce(0, +)
                    }
                    if sum > max {
                        max = sum
                        maxCoords = (x: x, y: y, size: size)
                    }
                }
            }
        }

        // grid[(maxCoords.y-1)..<(maxCoords.y+4)].forEach { line in
        //     line[(maxCoords.x-1)..<(maxCoords.x+4)].forEach { cell in
        //         print(cell, ", ", terminator: "")
        //     }
        //     print("")
        // }

        return "\(max): \(maxCoords.x+1),\(maxCoords.y+1),\(maxCoords.size)"    }

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