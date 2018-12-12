import Foundation

// Running:
// $ swift solver.swift [inputfilename]
// If no argument provided, it takes "input.txt"

let planted: Character = "#"
let empty: Character = "."

class Solver {
    struct Rule: CustomStringConvertible {
        let input: [Bool]
        let output: Bool

        init(string: String) {
            let elements = string.split(separator: " ")
            input = elements[0].map { $0 == planted }
            output = elements.last! == String(planted)
        }

        var description: String {
            return input.reduce("") { $0 + String($1 ? planted : empty) } + " -> " + String(output ? planted : empty)
        }

        func match(_ t: [Bool]) -> Bool? {
            return t == input ? output : nil
        }
    }

    func solve(_ fileName: String = "input.txt") -> String {
        let input = readFile(fileName)
        let result1 = solve1(input: input, generations: 20)
        let result2 = solve1(input: input, generations: 50_000_000_000)
        return "r1: \(result1)\nr2: \(result2)"
    }

    private func solve1(input: String, generations: Int) -> String {
        var lines = input.split(separator: "\n")
        let inputState: [Bool] = lines[0].split(separator: " ").last!.map { char in return char == planted }

        lines.removeFirst(1)
        let rules = lines.map { Rule(string: String($0)) }

        var currentState: [Bool] = inputState
        var offset = 0

        var newState: [Bool] = []
        var curResult = currentState.enumerated().reduce(0) { sum, pot in sum + (pot.element ? pot.offset - offset : 0) }
        var diff = 0
        (1...min(generations, 100)).forEach { g in
            // currentState.forEach { print($0 ? "#" : ".", terminator:"") }
            // print("")

            if currentState[0] {
                offset += 2
                currentState = [false, false] + currentState
            } else if currentState[1] {
                offset += 1
                currentState = [false] + currentState
            }

            if currentState[currentState.count - 1] {
                currentState = currentState + [false, false]
            } else if currentState[currentState.count - 2] {
                currentState = currentState + [false]
            }

            let newVal0 = rules.compactMap { $0.match([false, false] + currentState[0...2]) }.first ?? false
            newState.append(newVal0)
            let newVal1 = rules.compactMap { $0.match([false] + currentState[0...3]) }.first ?? false
            newState.append(newVal1)

            (2..<(currentState.count - 2)).forEach { potIndex in
                let template = Array(currentState[(potIndex - 2)...(potIndex + 2)])
                let newVal = rules.compactMap { $0.match(template) }.first ?? false
                newState.append(newVal)
            }

            let newVal1Last = rules.compactMap { $0.match(currentState[(currentState.count - 4)...] + [false]) }.first ?? false
            newState.append(newVal1Last)
            let newValLast = rules.compactMap { $0.match(currentState[(currentState.count - 3)...] + [false, false]) }.first ?? false
            newState.append(newValLast)

            currentState = newState
            newState = []
            let newResult = currentState.enumerated().reduce(0) { sum, pot in sum + (pot.element ? pot.offset - offset : 0) }
            // print(g, offset, newResult, newResult - curResult)
            diff = newResult - curResult
            curResult = newResult
        }

        if generations > 100 {
            let leftovers = generations - 100
            // print(leftovers, diff, leftovers * diff, curResult)
            curResult = curResult + leftovers * diff
        }

        // currentState.forEach { print($0 ? "#" : ".", terminator:"") }
        // print("")

        return "\(curResult)"
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