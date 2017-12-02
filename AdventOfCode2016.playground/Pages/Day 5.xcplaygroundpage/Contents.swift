//: [Previous](@previous)

import Foundation

func callRuby(_ fileName: String) -> String {
    let task = Process()
    task.currentDirectoryPath = "~/Developer/exp/aoc/2016"
    task.launchPath = "~/.rbenv/shims/ruby"
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

func solve1() {
    print(callRuby("day5-1.rb"))
}

func solve2() {
    print(callRuby("day5-2.rb"))
}

solve1()
solve2()
//: [Next](@next)
