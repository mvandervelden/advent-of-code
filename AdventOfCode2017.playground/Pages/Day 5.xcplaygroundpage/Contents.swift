//: [Previous](@previous)

import Foundation

func read1(_ fileName: String = "input") -> [Int] {
    let fileURL = Bundle.main.url(forResource: fileName, withExtension: "txt")
    let content = try! String(contentsOf: fileURL!)
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

func callCommandLine(_ fileName: String) -> String {
    let task = Process()
    task.currentDirectoryPath = "~/Developer/exp/aoc/2017"
    task.launchPath = "/usr/bin/swift"
    task.arguments = [fileName]
    
    let outputPipe = Pipe()
    task.standardOutput = outputPipe
    task.launch()
    
    let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
    task.terminate()
    task.waitUntilExit()
    let hash = String(data: data, encoding: String.Encoding.utf8)!
    return hash
}

func solve2() {
    print(callCommandLine("day5.swift"))
}

//solve1()
solve2()
//: [Next](@next)
