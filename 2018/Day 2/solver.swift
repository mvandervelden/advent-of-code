import Foundation

// Running:
// $ swift solver.swift [inputfilename]
// If no argument provided, it takes "input.txt"

class Solver {

    func solve(_ fileName: String = "input.txt") -> String {
        let input = readFile(fileName)
        let result1 = solve1(input: input)
        let result2 = solve2(input: input)
        return "r1: \(result1)\nr2: \(result2)"
    }

    private func solve1(input: String) -> String {
        let lines = input.split(separator: "\n")
        var twoOfAKinds = 0
        var threeOfAKinds = 0

        for line in lines {
            let histogramValues = line.reduce(into: [:]) { counts, char in
                counts[char, default: 0] += 1
            }.values

            twoOfAKinds += histogramValues.contains(2) ? 1 : 0
            threeOfAKinds += histogramValues.contains(3) ? 1 : 0
        }

        return "\(twoOfAKinds * threeOfAKinds)"
    }

    private func solve2(input: String) -> String {
        let lines = input.split(separator: "\n")

        for line in lines {
            for otherLine in lines {
                if line == otherLine { continue }
                
                let nonMatchingCharacters = zip(line, otherLine).reduce(0) { nonMatching, zippy in
                    return nonMatching + (zippy.0 == zippy.1 ? 0 : 1)
                }

                guard nonMatchingCharacters == 1 else { continue }

                return zip(line, otherLine).reduce("") { string, zippy in 
                    return string + (zippy.0 == zippy.1 ? String(zippy.0) : "")
                }
            }
        }

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