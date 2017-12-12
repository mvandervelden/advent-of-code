
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

var programsByGroup: [Set<Int>] = []
var currentGroup = 0
var programs: [[Int]] = []

func evaluate(int: Int) {
    let connections = programs[int]
    let count = programsByGroup[currentGroup].count
    programsByGroup[currentGroup] = programsByGroup[currentGroup].union(connections)
    if count == programsByGroup[currentGroup].count {
        return
    }
    connections.forEach(evaluate)
}

func solve1(fileName: String = "input.txt") {
    let input = readTerminal(fileName)
    let lines = input.split(separator: "\n")

    programs = lines.map { line in
        let splitLast = line.split(separator: ">")
        let connections: [Int] = splitLast.last!.split(separator: ",").map {
            Int(String($0.trimmingCharacters(in: .whitespacesAndNewlines)))!
        }
        return connections
    }

    programsByGroup.append([0])
    var hasMoreGroups = true
    var newGroupStart = 0
    while hasMoreGroups {
        // print(programsByGroup)
        evaluate(int: newGroupStart)
        let groupsCovered = programsByGroup.reduce(0) { $0 + $1.count }
        hasMoreGroups =  groupsCovered < programs.count
        if hasMoreGroups {
            newGroupStart = (0..<programs.count).filter { progNo in
                programsByGroup.filter { group in
                    return group.contains(progNo)
                }.count == 0
            }.first!
            print(newGroupStart)
            currentGroup += 1
            programsByGroup.append([newGroupStart])
        }
    }

    print(programsByGroup)
    print(programsByGroup.count)

}

if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve1(fileName: fileName)
} else {
    solve1()
}
