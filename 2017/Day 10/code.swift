
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

var currentIndex = 0
var currentLenIndex = 0
var skipSize = 0
var result:[Int] = []
var lengths: [Int] = []

func solve1(fileName: String = "input.txt") {
    let input = readTerminal(fileName)

    lengths = input.split(separator: ",").map {
        Int(String($0).trimmingCharacters(in: .whitespacesAndNewlines))!
    }
    let list = Array(0..<5)
    print(list)
    print(lengths)

    result = list

    for len in lengths {
        printState()
        _ = result[currentIndex..<len]
    }

    print(result)
}

func printState() {
    let string = (0..<result.count).reduce("") {
        var newResult = $0
        if $1 == currentIndex {
            newResult += "([\(result[$1])]"
        } else if $1 == currentIndex + lengths[currentLenIndex] {
            newResult += "\(result[$1]))"
        } else {
            newResult += "\(result[$1])"
        }
        return newResult
    }
    print(string)
}

if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve1(fileName: fileName)
} else {
    solve1()
}
