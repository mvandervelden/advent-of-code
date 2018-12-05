import Foundation

// Running:
// $ swift solver.swift [inputfilename]
// If no argument provided, it takes "input.txt"

extension Character {
    var value: UInt32 {
        return unicodeScalars.first!.value
    }
}

extension StringProtocol {

    var string: String { return String(self) }

    subscript(offset: Int) -> Element {
        return self[index(startIndex, offsetBy: offset)]
    }

    subscript(_ range: CountableRange<Int>) -> SubSequence {
        return prefix(range.lowerBound + range.count)
            .suffix(range.count)
    }
    subscript(range: CountableClosedRange<Int>) -> SubSequence {
        return prefix(range.lowerBound + range.count)
            .suffix(range.count)
    }

    subscript(range: PartialRangeThrough<Int>) -> SubSequence {
        return prefix(range.upperBound.advanced(by: 1))
    }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence {
        return prefix(range.upperBound)
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence {
        return suffix(Swift.max(0, count - range.lowerBound))
    }
}

extension String {

    func removeCharacters(from forbiddenChars: CharacterSet) -> String {
        let passed = self.unicodeScalars.filter { !forbiddenChars.contains($0) }
        return String(String.UnicodeScalarView(passed))
    }

    func removeCharacters(from: String) -> String {
        return removeCharacters(from: CharacterSet(charactersIn: from))
    }
}

class Solver {

    func solve(_ fileName: String = "input.txt") -> String {
        let input = readFile(fileName).dropLast().string
        // let result1 = solve1(input: input)
        let result2 = solve2(input: input)
        // return "r1: \(result1)\nr2: \(result2)"
        return "r2: \(result2)"
    }

    private func solve1(input: String) -> String {
        var newString = input
        var currentInput = ""
        var nextStart = 0
        while newString != currentInput {
            currentInput = newString

            var previousChar: Character = " "
            newString = currentInput[0..<nextStart].string
            for i in nextStart..<currentInput.count {

                let char = currentInput[i]
                if char.value == previousChar.value + 32 || char.value == previousChar.value - 32 {
                    newString = newString.dropLast().string
                    if i < currentInput.count - 1 {
                        newString.append(contentsOf: currentInput[(i+1)...])
                    }

                    if (input.count - currentInput.count) % 1000 == 0 {
                        // print("+")
                        // print("\(i): \(currentInput.count)")
                    }

                    nextStart = max(i - 2, 0)
                    break
                } else {
                    previousChar = char
                    newString.append(char)
                }

                // print(newString)
            }
        }
        
        return String(newString.count)
    }

    private func solve2(input: String) -> String {
        var counts: [Character: Int] = [:]

        for letter in "abcdefghijklmnopqrstuvwxyz" {
            let strippedInput = input.removeCharacters(from: String(letter) + String(letter).uppercased())
            print("\(letter): \(strippedInput.count)")
            let count = solve1(input: strippedInput)
            counts[letter] = Int(count)
        }

        let min = counts.min { lhs, rhs in
            lhs.value < rhs.value
        }!
        return "\(min)"
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