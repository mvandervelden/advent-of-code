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

    let magicNumber = 23

    private func solve1(input: String) -> String {
        let words = input.split(separator: " ")
        let players = Int(words[0])!
        let lastMarble = Int(words[6])! * 100
        print(lastMarble)
        var scores = Array(repeating: 0, count: players)
        var field: [Int] = [0]
        field.reserveCapacity(lastMarble)
        var index = 0
        (1...lastMarble).forEach { marble in
            if marble % 100_000 == 0 {
                print(marble)
            }
            // print(index)
            // field.enumerated().forEach { i in
            //     if i.offset == index {
            //         print("(\(i.element))", terminator: " ")
            //     } else {
            //         print(i.element, terminator: " ")
            //     }
            // }   
            // print("")
            // print(scores)
            if marble > 0, marble % magicNumber == 0 {
                var newIndex = index - 7
                if newIndex < 0 {
                    newIndex = field.count + newIndex
                }
                index = newIndex
                
                let removed = field.remove(at: index)
                scores[marble % players] += marble + removed
            } else {
                index = (index + 2) % (field.count)
                if index == 0 {
                    field.insert(marble, at: field.count)
                    index = field.count - 1
                } else {
                    field.insert(marble, at: index)
                }
            }
        }

        // field.enumerated().forEach { i in
        //     if i.offset == index {
        //         print("(\(i.element))", terminator: " ")
        //     } else {
        //         print(i.element, terminator: " ")
        //     }
        // }   
        // print("")

        return "\(scores.max()!)"
    }

    private func solve2(input: String) -> String {
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