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

  private func solveOne(file: File) -> String {
    let lines = file.lines
    let results = lines.map { (line) -> String in
      var code = line.intsSplitByComma

      if file.filename == "input.txt" {
        code = code.prepareForPhaseOne()
      }

      return run(code: code)
    }

    return results.description
  }

  private func solveTwo(file: File) -> String {
    return "input: \(file.filename)\ncontent:\n\(file.words)\nresult 2"
  }

  private func run(code: [Int]) -> String {
    let result = runNext(code: code, index: 0)
    return result[0].description
  }

  private func runNext(code: [Int], index: Int) -> [Int] {
    switch code[index] {
    case 99:
      return code
    case 1:
      let lhs = code[code[index + 1]]
      let rhs = code[code[index + 2]]
      var result = code
      result[code[index + 3]] = lhs + rhs
      return runNext(code: result, index: index + 4)
    case 2:
      let lhs = code[code[index + 1]]
      let rhs = code[code[index + 2]]
      var result = code
      result[code[index + 3]] = lhs * rhs
      return runNext(code: result, index: index + 4)
    default:
      fatalError("Unexpected opcode: \(code[index])")
    }
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
  var intsSplitByComma: [Int] {
    return split(separator: ",").compactMap { Int(String($0)) }
  }
}

extension Array where Element == Int {
  func prepareForPhaseOne() -> [Int] {
    var new = self
    new[1] = 12
    new[2] = 2
    return new
  }
}

let filename = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "input.txt"
let part: Solution.Part = Solution.Part(rawValue: CommandLine.arguments.count > 1 ? Int(CommandLine.arguments[1])! : 1)!
let solution = Solution(part: part, filename: filename)
let result = solution.get()

print(result)
