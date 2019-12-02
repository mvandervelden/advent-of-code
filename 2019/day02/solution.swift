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
        code = code.prepare(noun: 12, verb: 2)
      }

      let intCode = IntCode(code: code)

      do {
        return try intCode.run().description
      } catch {
        fatalError("Error running IntCode: \(error)")
      }
    }

    return results.description
  }

  private func solveTwo(file: File) -> String {
    let line = file.lines.first!
    let code = line.intsSplitByComma

    for noun in 0...99 {
      for verb in 0...99 {
        let intCode = IntCode(code: code.prepare(noun: noun, verb: verb))

        do {
          let result = try intCode.run()

          if result == 19690720 {
            return (noun * 100 + verb).description
          }
        } catch {
          print("invalid code: \(error)")
        }
      }
    }
    fatalError("Did not find a solution")
  }
}

enum IntCodeError: Error {
  case indexOutOfBounds
  case unexpectedOpcode
  case operatorExceedsBounds
  case operatorRegisterExceedsBounds
}

class IntCode {
  var code: [Int]
  var index = 0

  init(code: [Int]) {
    self.code = code
  }

  func run(resultIndex: Int = 0) throws -> Int {
    try runNext()
    return code[resultIndex]
  }

  private func runNext() throws {
    guard index < code.count else { throw IntCodeError.indexOutOfBounds }
    switch code[index] {
    case .endProgram:
      return
    case .add:
      try performOperator(+)
      try runNext()
    case .multiply:
      try performOperator(*)
      try runNext()
    default:
      throw IntCodeError.unexpectedOpcode
    }
  }

  private func performOperator(_ oper: (Int, Int) -> Int) throws {
    guard index + 3 < code.count else { throw IntCodeError.operatorExceedsBounds }

    let lhsIndex = code[index + 1]
    let rhsIndex = code[index + 2]
    let resultIndex = code[index + 3]

    guard lhsIndex < code.count,
          rhsIndex < code.count,
          resultIndex < code.count else {
      throw IntCodeError.operatorRegisterExceedsBounds
    }

    let lhs = code[lhsIndex]
    let rhs = code[rhsIndex]
    code[resultIndex] = oper(lhs, rhs)
    index += 4
  }
}

extension Int {
  static let endProgram = 99
  static let add = 1
  static let multiply = 2
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
  func prepare(noun: Int, verb: Int) -> [Int] {
    var new = self
    new[1] = noun
    new[2] = verb
    return new
  }
}

let filename = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "input.txt"
let part: Solution.Part = Solution.Part(rawValue: CommandLine.arguments.count > 1 ? Int(CommandLine.arguments[1])! : 1)!
let solution = Solution(part: part, filename: filename)
let result = solution.get()

print(result)
