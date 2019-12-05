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
      let code = line.intsSplitByComma

      let intCode = IntCode(code: code, inputs: [1])

      do {
        return try intCode.run().description
      } catch {
        print("Error: \(error)")
        fatalError("Error running IntCode: \(error)")
      }
    }
    return results.description
  }

  private func solveTwo(file: File) -> String {
    return "TODO"
  }
}

enum IntCodeError: Error {
  case indexOutOfBounds
  case unexpectedOpcode
  case operatorExceedsBounds
  case operatorRegisterExceedsBounds
  case missingInput
  case unexpectedEndProgram
}

class IntCode {
  var code: [Int]
  var index = 0
  var inputs: [Int]

  init(code: [Int], inputs: [Int]) {
    self.code = code
    self.inputs = inputs
  }

  func run(resultIndex: Int = 0) throws -> Int {
    try runNext()
    print(code)
    return code[resultIndex]
  }

  private func runNext() throws {
    guard index < code.count else { throw IntCodeError.indexOutOfBounds }

    let opcode = code[index]
    let typeInt = opcode % 100

    guard let type = InstructionType(rawValue: typeInt) else {
      throw IntCodeError.unexpectedOpcode
    }

    // print("\(type) raw: " + opcode.description)
    let opcodeString = (opcode / 100).description

    switch type {
    case .add:
      try perform3ParamOperation(opcode: opcodeString, oper: +)
    case .multiply:
      try perform3ParamOperation(opcode: opcodeString, oper: *)
    case .input:
      let input = inputs.removeFirst()
      let inputIndex = code[index + 1]
      print("input: \(input) -> \(inputIndex)")

      guard inputIndex < code.count else { throw IntCodeError.operatorRegisterExceedsBounds }

      code[inputIndex] = input
      index += 2

      try runNext()
    case .output:
      try performOutputOperation(opcode: opcodeString)
    case .endProgram:
      return
    }
  }

  private func perform3ParamOperation(opcode: String, oper: (Int, Int) -> Int) throws {
    var opcode = opcode
    guard index + 3 < code.count else { throw IntCodeError.operatorExceedsBounds }

    let lhValue: Int
    switch opcode.popLast() ?? "0" {
    case "0":
      let lhsIndex = code[index + 1]
      guard lhsIndex < code.count else { throw IntCodeError.operatorRegisterExceedsBounds }
      lhValue = code[lhsIndex]
    case "1":
      lhValue = code[index + 1]
    default:
      throw IntCodeError.unexpectedOpcode
    }

    let rhValue: Int
    switch opcode.popLast() ?? "0" {
    case "0":
      let rhsIndex = code[index + 2]
      guard rhsIndex < code.count else { throw IntCodeError.operatorRegisterExceedsBounds }
      rhValue = code[rhsIndex]
    case "1":
      rhValue = code[index + 2]
    default:
      throw IntCodeError.unexpectedOpcode
    }

    let resultIndex = code[index + 3]

    guard resultIndex < code.count else { throw IntCodeError.operatorRegisterExceedsBounds }

    code[resultIndex] = oper(lhValue, rhValue)
    index += 4

    try runNext()
  }

  private func performOutputOperation(opcode: String) throws {
      let value: Int
      var outputIndex = index + 1

      switch opcode.last ?? "0" {
      case "0":
        outputIndex = code[index + 1]
        guard outputIndex < code.count else { throw IntCodeError.operatorRegisterExceedsBounds }
        value = code[outputIndex]
      case "1":
        value = code[index + 1]
      default:
        throw IntCodeError.unexpectedOpcode
      }

      print("output: \(value) -> \(outputIndex)")
      index += 2

      try runNext()
  }
}

enum InstructionType: Int {
  case add = 1
  case multiply = 2
  case input = 3
  case output = 4
  case endProgram = 99
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
