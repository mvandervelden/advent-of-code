import Foundation

func read1(_ fileName: String = "input") -> [Int] {
    let fileURL = Bundle.main.url(forResource: fileName, withExtension: "txt")
    let content = try! String(contentsOf: fileURL!)
    let lines = content.split(separator: "\n")
    return lines.map { line in
        return Int(String(line).trimmingCharacters(in: .whitespacesAndNewlines))!
    }
}

func readTerminal(_ fileName: String = "input.txt") -> [Int] {
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    guard let fileURL = URL(string: fileName, relativeTo: currentDirectoryURL) else {
        print("file not found: \(currentDirectoryURL.path)/\(fileName)")
        return []
    }
    let content = try! String(contentsOf: fileURL)
    let lines = content.split(separator: "\n")
    return lines.map { line in
        return Int(String(line).trimmingCharacters(in: .whitespacesAndNewlines))!
    }
}

func solve1() {
    var list = read1()

    var numberOfSteps = 0
    var index = 0
    while index >= 0 && index < list.count {
        numberOfSteps += 1
        let jump = list[index]
//        print(index)
//        print(list)
//        print(jump)
        list[index] += 1
        index += jump
    }
    print(index)
//    print(list)
    print(numberOfSteps)
}

func solve2() {
    var list = readTerminal()
    var numberOfSteps = 0
    var index = 0
    while index >= 0 && index < list.count {
        numberOfSteps += 1
        let jump = list[index]
        if jump >= 3 {
            list[index] -= 1
        } else {
            list[index] += 1
        }
        //        print(index)
        //        print(list)
        //        print(jump)

        index += jump
    }
    print(index)
//        print(list)
    print(numberOfSteps)
}
//solve1()
solve2()
