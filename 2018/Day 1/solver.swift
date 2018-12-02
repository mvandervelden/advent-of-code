import Foundation

// Running:
// $ swift volver.swift [inputfilename]
// If no argument provided, it takes "input.txt"

class Solver {

    func solve(_ fileName: String = "input.txt") -> String {
        let input = readFile(fileName)
        let numbers = input.split(separator: "\n").map { Int($0)! }
        let result1 = solve1(input: numbers)
        let result2 = solve2(input: numbers)
        return "r1: \(result1)\nr2: \(result2)"
    }

    func solve1(input: [Int]) -> Int {
        return input.reduce(0) { $0 + $1 }
    }

    func solve2(input: [Int]) -> Int {
        let total = solve1(input: input)

        let frequenciesFound = input.reduce([0]) { freqs, next in
            var newFreqs = freqs
            newFreqs.append(next + freqs.last!)
            return newFreqs
        }

        var loops = 1

        while true {
            for num in frequenciesFound.dropFirst() {
                let newFreq = num + total * loops
                if frequenciesFound.contains(newFreq) {
                    return newFreq
                }
            }
            loops += 1
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