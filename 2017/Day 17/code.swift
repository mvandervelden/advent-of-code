
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
    // let input = readTerminal(fileName)

    let input = fileName == "input.txt" ? 337 : 3

    var list: [Int] = [0]
    var idx = 0
    for i in 1...2017 {
        // print("\(idx), \(i)")
        idx = ((idx + input) % i) + 1
        // print(idx)
        list.insert(i, at: idx)
        // print(list)
    }

    print(list[idx + 1])
}

func solve2(fileName: String = "input.txt") {
    // let input = readTerminal(fileName)

    let input = fileName == "input.txt" ? 337 : 3

    // var list: [Int] = [0]
    var idx = 0
    var noAfter0 = -1

    for i in 1...50_000_000 {
        // print("\(idx), \(i)")
        idx = ((idx + input) % i) + 1
        if idx == 1 {
            noAfter0 = i
            print(i)
        }
        // print(idx)
        // list.insert(i, at: idx)
        // print(list)
    }

    print(noAfter0)
}

if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve2(fileName: fileName)
} else {
    solve2()
}
