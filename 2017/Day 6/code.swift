
// to run: `swift code.swift [input_filename]`
import Foundation

func readTerminal(_ fileName: String) -> [Int] {
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    guard let fileURL = URL(string: fileName, relativeTo: currentDirectoryURL) else {
        print("file not found: \(currentDirectoryURL.path)/\(fileName)")
        return []
    }
    let content = try! String(contentsOf: fileURL)
    let ints = content.split(separator: "\t")
    return ints.map { int in
        return Int(String(int).trimmingCharacters(in: .whitespacesAndNewlines))!
    }
}


func solve1(fileName: String = "input.txt") {
    var memory = readTerminal(fileName)
    print(memory)
    let memSize = memory.count

    var permutations: [[Int]] = []

    while true {
        let maxBank = memory.max()!
        let maxBankIdx = memory.index(of: maxBank)!
        let startIdx = maxBankIdx + 1
        let endIdx = startIdx + maxBank

        memory[maxBankIdx] = 0
        for i in startIdx..<endIdx {
            memory[i % memSize] += 1
        }

        if permutations.contains(where: { $0 == memory }) {
            break
        }
        permutations.append(memory)

        // print(memory)
    }
    print(memory)
    print("Steps: \(permutations.count + 1)")
    let loopSize = permutations.count - permutations.index {
        $0 == memory
    }!
    print("Loop size: \(loopSize)")
}

if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve1(fileName: fileName)
} else {
    solve1()
}
