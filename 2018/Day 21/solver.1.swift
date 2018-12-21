import Foundation

// Running:
// $ swift solver.swift [inputfilename]
// If no argument provided, it takes "input.txt"

class Solver {

    func solve(_ fileName: String = "output.1.txt") -> String {
        let input = readFile(fileName)
        let result1 = solve1(input: input)
        return result1
    }

    private func solve1(input: String) -> String {
        let lines = input.split(separator: "\n").map { $0.split(separator: " ") }
        let vals = lines.map { Int($0[0])! } 
        let max = vals.max { lhs, rhs in lhs < rhs }!
        let min = vals.min { lhs, rhs in lhs < rhs  }!
        print(max, min)
        print(vals.sorted())

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