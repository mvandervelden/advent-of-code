
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
    let input = readTerminal(fileName)

    var score = 0
    var level = 0
    var garbLength = 0
    var ignoreNext = false
    var inGarbage = false
    var resultGraph = ""
    for char in input {
        switch (char, ignoreNext, inGarbage) {
        case (_, true, _):
            ignoreNext = false
            resultGraph += ""
        case ("!", _, _):
            ignoreNext = true
            resultGraph += ""
        case (">", _, true):
            resultGraph += ">"
            inGarbage = false
        case (_, _, true):
            resultGraph += ""
            garbLength += 1
            break
        case ("<", _, _):
            inGarbage = true
            resultGraph += "<"
        case ("{", _, _):
            level += 1
            resultGraph += "{\(level)"
        case ("}", _, _):
            resultGraph += "}"
            score += level
            level -= 1
        default:
            resultGraph += ""
        }
    }

    print(score)
    print(garbLength)
}

if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve1(fileName: fileName)
} else {
    solve1()
}
