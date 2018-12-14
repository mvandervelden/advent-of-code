import Foundation

// Running:
// $ swift solver.swift [inputfilename]
// If no argument provided, it takes "input.txt"

class Solver {

    func solve(_ input: String = "768071") -> String {
        // let input = readFile(fileName)
        let result1 = solve1(input: input)
        let result2 = solve2(input: input)
        return "r1: \(result1)\nr2: \(result2)"
    }

    private func solve1(input: String) -> String {
        let expected = Int(input)!
        var result = [3, 7]
        var e1 =  0
        var e2 = 1

        while result.count < expected + 10 { 
            let res1 = result[e1]
            let res2 = result[e2]
            let recipeRes = res1 + res2
            if recipeRes >= 10 {
                result.append(1)
            }
            result.append(recipeRes % 10)
            
            e1 = (e1 + 1 + res1) % result.count
            e2 = (e2 + 1 + res2) % result.count

            // print(result)
        }
    
        return "\(result[expected..<(expected+10)].reduce("", { $0 + "\($1)"}))"
    }

    private func solve2(input: String) -> String {
        let expected = Array(input).map { Int(String($0))! }
        var result = [3, 7]
        var e1 = 0
        var e2 = 1

        var resultIndex: Int? = nil
        while resultIndex == nil {
            
            if result.count > expected.count + 1 {
                let index = ((result.count - expected.count - 2)...(result.count - expected.count)).filter { ind in 
                    Array(result[ind..<(ind + expected.count)]) == expected
                }
                if index.count > 0 {
                    print(index)
                    resultIndex = index[0]
                    break
                }
            }
            
            let res1 = result[e1]
            let res2 = result[e2]
            let recipeRes = res1 + res2
            if recipeRes >= 10 {
                result.append(1)
            }
            result.append(recipeRes % 10)
            
            e1 = (e1 + 1 + res1) % result.count
            e2 = (e2 + 1 + res2) % result.count

            // print(result)
        }
    
        return "\(resultIndex!)"
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