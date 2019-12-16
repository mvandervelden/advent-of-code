import Foundation

// Running:
// $ ./solution.swift part [inputfilename]
// part: either `1` or `2`
// If no inputfilename provided, it takes "input.txt"

typealias Lines = [String]
typealias Words = [Lines]

class Solution {
  enum Part: Int {
    case one = 1, two
  }

  let part: Part
  let file: File

  init(part: Part, filename: String) {
    self.part = part
    file = File(filename: filename)
  }

  func get() -> String {
    switch part {
    case .one: return solveOne(file: file)
    case .two: return solveTwo(file: file)
    }
  }

  let basePattern = [0, 1, 0, -1]

  private func solveOne(file: File) -> String {
    let input = file.lines[0].toInts

    var currentSignal = input
    var output: [Int] = Array(repeating: 0, count: input.count)

    for i in 0..<100 {
      // print(currentSignal.description)
      for index in 0..<currentSignal.count {
        var pattern: [Int] = []
        for elem in basePattern {
          pattern += Array(repeating: elem, count: index + 1)
        }

        var nextOutput = 0
        for (intIdx, int) in currentSignal.enumerated() {
          nextOutput += int * pattern[(intIdx + 1) % pattern.count]
        }
        output[index] = abs(nextOutput) % 10
      }

      currentSignal = output
    }
    return output.reduce("") { $0 + $1.description }
  }

  private func solveTwo(file: File) -> String {
    let input = file.lines[0].toInts
    let offset = Int(input[..<7].reduce("") { $0 + $1.description })!
    print(input)
    print(offset)
    var currentSignal = Array(repeating: input, count: 10_000).flatMap { $0 }
    var output: [Int] = Array(repeating: 0, count: currentSignal.count)

    for i in 0..<100 {
      print(i)
      // print(currentSignal.description)
      for index in 0..<currentSignal.count {
        var pattern: [Int] = []
        for elem in basePattern {
          pattern += Array(repeating: elem, count: index + 1)
        }

        var nextOutput = 0
        for (intIdx, int) in currentSignal.enumerated() {
          nextOutput += int * pattern[(intIdx + 1) % pattern.count]
        }
        output[index] = abs(nextOutput) % 10
      }

      currentSignal = output
    }
    return output[offset...(offset + 8)].reduce("") { $0 + $1.description }
  }
}

class File {
  let filename: String

  lazy var string: String = {
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    guard let fileURL = URL(string: filename, relativeTo: currentDirectoryURL),
          let contents = try? String(contentsOf: fileURL) else {
      fatalError("file not found: \(currentDirectoryURL.path)/\(filename)")
    }

    return contents
  }()

  lazy var lines: Lines = {
    let strings = "abc"

    return string.split(separator: "\n").map(String.init)
  }()

  lazy var words: Words = {
    return lines.map { $0.split(separator: " ").map(String.init) }
  }()

  init(filename: String) {
    self.filename = filename
  }
}

extension String {
  var toInts: [Int] {
    return map { Int(String($0))! }
  }
}

let filename = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "input.txt"
let part: Solution.Part = Solution.Part(rawValue: CommandLine.arguments.count > 1 ? Int(CommandLine.arguments[1])! : 1)!
let solution = Solution(part: part, filename: filename)
let result = solution.get()

print(result)
