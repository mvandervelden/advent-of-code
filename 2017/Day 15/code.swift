
// to run: `swift code.swift [input_filename]`
import Foundation

func readTerminal(_ fileName: String) -> String {
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    guard let fileURL = URL(string: fileName, relativeTo: currentDirectoryURL) else {
        print("file not found: \(currentDirectoryURL.path)/\(fileName)")
        return ""
    }
    let content = try! String(contentsOf: fileURL)
    return content
}

func solve1(fileName: String = "input.txt") {
    let input: [Int] = fileName == "input.txt" ? [679, 771] : [65, 8921]
    let factors: [Int] = [16807, 48271]
    let multiples: [Int] = [4, 8]
    let divider: Int = 2147483647

    var results: [[String]] = []
    for i in [0, 1] {
        var nextIn = input[i]
        let nextFactor = factors[i]
        let nextmult = multiples[i]
        var noFound = 0
        var ress: [String] = []

        while noFound < 5_000_000 {
            let prod = nextIn * nextFactor
            let res = prod % divider
            if res % nextmult == 0 {
                noFound += 1
                let bin = String(res, radix: 2)
                ress.append(String(bin.suffix(16)))
            }
            nextIn = res
        }
        results.append(ress)
    }

    var matches = 0
    for i in 0..<results[0].count {
        if results[0][i] == results[1][i] {
             matches += 1
        }
    }

    print(matches)
}

if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve1(fileName: fileName)
} else {
    solve1()
}
