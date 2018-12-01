import Foundation

// Running:
// $ swift volver.swift [inputfilename]
// If no argument provided, it takes "input.txt"

class Solver {

    func solve(_ fileName: String = "input.txt") -> String {
        let input = readFile(fileName)
        let result1 = solve1(input: input)
        let result2 = solve2(input: input)
        return "r1: \(result1)\nr2: \(result2)"
    }

    func solve1(input: String) -> String {
        let nums: [Int] = input.split(separator: "\n").map { Int($0)! }
        return "\(nums.reduce(0) { $0 + $1 })"
    }

    func solve2(input: String) -> String {
        let nums: [Int] = input.split(separator: "\n").map { Int($0)! }
        let total = Int(solve1(input: input))!
        let frequenciesFound: [Int] = nums.reduce([0]) { (freqs: [Int], next: Int) in
            var freqss = freqs
            freqss.append(next + freqs.last!)
            return freqss
        }
        var result: Int? = nil
        var loops = 1
        let nextNums: [Int] = Array(frequenciesFound.dropFirst())
        
        while result == nil {
            var newNext: [Int] = []
            for num in nextNums {
                let newFreq = num + total * loops
                if frequenciesFound.contains(newFreq) {
                    result = newFreq
                    break
                }
                newNext.append(newFreq)
            }
            loops += 1
        }   

        return "\(result!)"
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