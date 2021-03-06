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
    // let lines = file.lines
    // let results = lines.map { (line) -> String in
      // let code = line.intsSplitByComma

      // let allInputs = [
      //   [1, 2, 3, 4, 0],
      //   [1, 2, 3, 0, 4],
      //   [1, 2, 4, 3, 0],
      //   [1, 2, 4, 0, 3],
      //   [1, 2, 0, 3, 4],
      //   [1, 2, 0, 4, 3],
      //   [1, 3, 2, 4, 0],
      //   [1, 3, 2, 0, 4],
      //   [1, 3, 4, 2, 0],
      //   [1, 3, 4, 0, 2],
      //   [1, 3, 0, 2, 4],
      //   [1, 3, 0, 4, 2],
      //   [1, 4, 3, 2, 0],
      //   [1, 4, 3, 0, 2],
      //   [1, 4, 2, 3, 0],
      //   [1, 4, 2, 0, 3],
      //   [1, 4, 0, 3, 2],
      //   [1, 4, 0, 2, 3],
      //   [1, 0, 2, 4, 3],
      //   [1, 0, 2, 3, 4],
      //   [1, 0, 4, 2, 3],
      //   [1, 0, 4, 3, 2],
      //   [1, 0, 3, 2, 4],
      //   [1, 0, 3, 4, 2],
      //   [2, 1, 3, 4, 0],
      //   [2, 1, 3, 0, 4],
      //   [2, 1, 4, 3, 0],
      //   [2, 1, 4, 0, 3],
      //   [2, 1, 0, 3, 4],
      //   [2, 1, 0, 4, 3],
      //   [2, 3, 1, 4, 0],
      //   [2, 3, 1, 0, 4],
      //   [2, 3, 4, 1, 0],
      //   [2, 3, 4, 0, 1],
      //   [2, 3, 0, 1, 4],
      //   [2, 3, 0, 4, 1],
      //   [2, 4, 3, 1, 0],
      //   [2, 4, 3, 0, 1],
      //   [2, 4, 1, 3, 0],
      //   [2, 4, 1, 0, 3],
      //   [2, 4, 0, 3, 1],
      //   [2, 4, 0, 1, 3],
      //   [2, 0, 1, 4, 3],
      //   [2, 0, 1, 3, 4],
      //   [2, 0, 4, 1, 3],
      //   [2, 0, 4, 3, 1],
      //   [2, 0, 3, 1, 4],
      //   [2, 0, 3, 4, 1],
      //   [3, 2, 1, 4, 0],
      //   [3, 2, 1, 0, 4],
      //   [3, 2, 4, 1, 0],
      //   [3, 2, 4, 0, 1],
      //   [3, 2, 0, 1, 4],
      //   [3, 2, 0, 4, 1],
      //   [3, 1, 2, 4, 0],
      //   [3, 1, 2, 0, 4],
      //   [3, 1, 4, 2, 0],
      //   [3, 1, 4, 0, 2],
      //   [3, 1, 0, 2, 4],
      //   [3, 1, 0, 4, 2],
      //   [3, 4, 1, 2, 0],
      //   [3, 4, 1, 0, 2],
      //   [3, 4, 2, 1, 0],
      //   [3, 4, 2, 0, 1],
      //   [3, 4, 0, 1, 2],
      //   [3, 4, 0, 2, 1],
      //   [3, 0, 2, 4, 1],
      //   [3, 0, 2, 1, 4],
      //   [3, 0, 4, 2, 1],
      //   [3, 0, 4, 1, 2],
      //   [3, 0, 1, 2, 4],
      //   [3, 0, 1, 4, 2],
      //   [4, 1, 3, 2, 0],
      //   [4, 1, 3, 0, 2],
      //   [4, 1, 2, 3, 0],
      //   [4, 1, 2, 0, 3],
      //   [4, 1, 0, 3, 2],
      //   [4, 1, 0, 2, 3],
      //   [4, 3, 1, 2, 0],
      //   [4, 3, 1, 0, 2],
      //   [4, 3, 2, 1, 0],
      //   [4, 3, 2, 0, 1],
      //   [4, 3, 0, 1, 2],
      //   [4, 3, 0, 2, 1],
      //   [4, 2, 3, 1, 0],
      //   [4, 2, 3, 0, 1],
      //   [4, 2, 1, 3, 0],
      //   [4, 2, 1, 0, 3],
      //   [4, 2, 0, 3, 1],
      //   [4, 2, 0, 1, 3],
      //   [4, 0, 1, 2, 3],
      //   [4, 0, 1, 3, 2],
      //   [4, 0, 2, 1, 3],
      //   [4, 0, 2, 3, 1],
      //   [4, 0, 3, 1, 2],
      //   [4, 0, 3, 2, 1],
      //   [0, 1, 3, 2, 4],
      //   [0, 1, 3, 4, 2],
      //   [0, 1, 2, 3, 4],
      //   [0, 1, 2, 4, 3],
      //   [0, 1, 4, 3, 2],
      //   [0, 1, 4, 2, 3],
      //   [0, 3, 1, 2, 4],
      //   [0, 3, 1, 4, 2],
      //   [0, 3, 2, 1, 4],
      //   [0, 3, 2, 4, 1],
      //   [0, 3, 4, 1, 2],
      //   [0, 3, 4, 2, 1],
      //   [0, 2, 3, 1, 4],
      //   [0, 2, 3, 4, 1],
      //   [0, 2, 1, 3, 4],
      //   [0, 2, 1, 4, 3],
      //   [0, 2, 4, 3, 1],
      //   [0, 2, 4, 1, 3],
      //   [0, 4, 1, 2, 3],
      //   [0, 4, 1, 3, 2],
      //   [0, 4, 2, 1, 3],
      //   [0, 4, 2, 3, 1],
      //   [0, 4, 3, 1, 2],
      //   [0, 4, 3, 2, 1]
      // ]

      // var maxCombi = ""
      // var maxVal = 0

      // for input in allInputs {
      //   var nextInput = 0
      //   for index in input {
          // let intCode = IntCode(code: code, inputs: [index, nextInput])

          // do {
          //   let result = try intCode.run()
          //   print(result)
          //   nextInput = result[0]
          // } catch {
          //   print("Error: \(error)")
          //   fatalError("Error running IntCode: \(error)")
          // }
        // }

    //     if nextInput > maxVal {
    //       maxCombi = input.description + nextInput.description
    //       maxVal = nextInput
    //     }
    //   }
    //   return maxCombi
    // }
    // return results.description
    return "TODO"
  }

  private func solveTwo(file: File) -> String {
    let lines = file.lines
    let line = lines[0]
    // let results = lines.map { (line) -> String in
    code = line.intsSplitByComma
    runInput(index: 0)

    return maxCombi.description
  }

  let allInputs = [
    [1, 2, 3, 4, 0],
    [1, 2, 3, 0, 4],
    [1, 2, 4, 3, 0],
    [1, 2, 4, 0, 3],
    [1, 2, 0, 3, 4],
    [1, 2, 0, 4, 3],
    [1, 3, 2, 4, 0],
    [1, 3, 2, 0, 4],
    [1, 3, 4, 2, 0],
    [1, 3, 4, 0, 2],
    [1, 3, 0, 2, 4],
    [1, 3, 0, 4, 2],
    [1, 4, 3, 2, 0],
    [1, 4, 3, 0, 2],
    [1, 4, 2, 3, 0],
    [1, 4, 2, 0, 3],
    [1, 4, 0, 3, 2],
    [1, 4, 0, 2, 3],
    [1, 0, 2, 4, 3],
    [1, 0, 2, 3, 4],
    [1, 0, 4, 2, 3],
    [1, 0, 4, 3, 2],
    [1, 0, 3, 2, 4],
    [1, 0, 3, 4, 2],
    [2, 1, 3, 4, 0],
    [2, 1, 3, 0, 4],
    [2, 1, 4, 3, 0],
    [2, 1, 4, 0, 3],
    [2, 1, 0, 3, 4],
    [2, 1, 0, 4, 3],
    [2, 3, 1, 4, 0],
    [2, 3, 1, 0, 4],
    [2, 3, 4, 1, 0],
    [2, 3, 4, 0, 1],
    [2, 3, 0, 1, 4],
    [2, 3, 0, 4, 1],
    [2, 4, 3, 1, 0],
    [2, 4, 3, 0, 1],
    [2, 4, 1, 3, 0],
    [2, 4, 1, 0, 3],
    [2, 4, 0, 3, 1],
    [2, 4, 0, 1, 3],
    [2, 0, 1, 4, 3],
    [2, 0, 1, 3, 4],
    [2, 0, 4, 1, 3],
    [2, 0, 4, 3, 1],
    [2, 0, 3, 1, 4],
    [2, 0, 3, 4, 1],
    [3, 2, 1, 4, 0],
    [3, 2, 1, 0, 4],
    [3, 2, 4, 1, 0],
    [3, 2, 4, 0, 1],
    [3, 2, 0, 1, 4],
    [3, 2, 0, 4, 1],
    [3, 1, 2, 4, 0],
    [3, 1, 2, 0, 4],
    [3, 1, 4, 2, 0],
    [3, 1, 4, 0, 2],
    [3, 1, 0, 2, 4],
    [3, 1, 0, 4, 2],
    [3, 4, 1, 2, 0],
    [3, 4, 1, 0, 2],
    [3, 4, 2, 1, 0],
    [3, 4, 2, 0, 1],
    [3, 4, 0, 1, 2],
    [3, 4, 0, 2, 1],
    [3, 0, 2, 4, 1],
    [3, 0, 2, 1, 4],
    [3, 0, 4, 2, 1],
    [3, 0, 4, 1, 2],
    [3, 0, 1, 2, 4],
    [3, 0, 1, 4, 2],
    [4, 1, 3, 2, 0],
    [4, 1, 3, 0, 2],
    [4, 1, 2, 3, 0],
    [4, 1, 2, 0, 3],
    [4, 1, 0, 3, 2],
    [4, 1, 0, 2, 3],
    [4, 3, 1, 2, 0],
    [4, 3, 1, 0, 2],
    [4, 3, 2, 1, 0],
    [4, 3, 2, 0, 1],
    [4, 3, 0, 1, 2],
    [4, 3, 0, 2, 1],
    [4, 2, 3, 1, 0],
    [4, 2, 3, 0, 1],
    [4, 2, 1, 3, 0],
    [4, 2, 1, 0, 3],
    [4, 2, 0, 3, 1],
    [4, 2, 0, 1, 3],
    [4, 0, 1, 2, 3],
    [4, 0, 1, 3, 2],
    [4, 0, 2, 1, 3],
    [4, 0, 2, 3, 1],
    [4, 0, 3, 1, 2],
    [4, 0, 3, 2, 1],
    [0, 1, 3, 2, 4],
    [0, 1, 3, 4, 2],
    [0, 1, 2, 3, 4],
    [0, 1, 2, 4, 3],
    [0, 1, 4, 3, 2],
    [0, 1, 4, 2, 3],
    [0, 3, 1, 2, 4],
    [0, 3, 1, 4, 2],
    [0, 3, 2, 1, 4],
    [0, 3, 2, 4, 1],
    [0, 3, 4, 1, 2],
    [0, 3, 4, 2, 1],
    [0, 2, 3, 1, 4],
    [0, 2, 3, 4, 1],
    [0, 2, 1, 3, 4],
    [0, 2, 1, 4, 3],
    [0, 2, 4, 3, 1],
    [0, 2, 4, 1, 3],
    [0, 4, 1, 2, 3],
    [0, 4, 1, 3, 2],
    [0, 4, 2, 1, 3],
    [0, 4, 2, 3, 1],
    [0, 4, 3, 1, 2],
    [0, 4, 3, 2, 1]
  ].map { $0.map { $0 + 5 }}

  var maxCombi = ""
  var maxVal = 0
  var code: [Int] = []

  private func runInput(index: Int) {
    if index == allInputs.count {
      print("FINAL RESULT: \(maxCombi)")
      exit(EXIT_SUCCESS)
    }
    let input = allInputs[index]

    let amps = input.map {
      IntCode(code: code, input: $0)
    }

    for (int, amp) in amps.enumerated() {
      amp.outputReceiver = amps[(int + 1) % 5]
    }

    var outputsReceived: [Int] = []
    let group = DispatchGroup()

    group.enter()
    amps[0].run(input: 0) { output in
      // print("finished: 0")
      group.leave()
      outputsReceived.append(output ?? 0)
      amps[0].onHalt = nil
    }
    for int in 1..<amps.count {
      let amp = amps[int]
      group.enter()
      amp.run { output in
        // print("finished: \(int)")
        group.leave()
        outputsReceived.append(output ?? 0)
        amps[int].onHalt = nil
      }
    }

    group.notify(queue: DispatchQueue.main) {
      print("all finished, index: \(index)")
      let result = outputsReceived.max()!
      print(result)
      if result > self.maxVal {
        self.maxCombi = input.description + " " + result.description
        self.maxVal = result
      }
      self.runInput(index: index + 1)
    }
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

protocol IntCodeOutputReceiver: AnyObject {
  func handleValue(_ value: Int)
}

class IntCode: IntCodeOutputReceiver {
  var code: [Int]
  var index = 0
  weak var outputReceiver: IntCodeOutputReceiver?
  var onHalt: ((Int?) -> Void)?
  var inputs: [Int]
  var output: Int?

  func handleValue(_ value: Int) {
    inputs.append(value)
    DispatchQueue.main.async {
      do {
        try self.runNext()
      } catch {
        print("Error: \(error)")
        fatalError("Error running IntCode: \(error)")
      }
    }
  }

  init(code: [Int], input: Int) {
    self.code = code
    self.inputs = [input]
  }

  func run(input: Int? = nil, onHalt: @escaping (Int?) -> Void) {
    self.onHalt = onHalt
    if let input = input {
      inputs.append(input)
    }

    DispatchQueue.main.async {
      do {
        try self.runNext()
      } catch {
        print("Error: \(error)")
        fatalError("Error running IntCode: \(error)")
      }
    }
    // print(code)
  }

  private func runNext() throws {
    // print("index: \(index): \(code[index])")
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
      if inputs.isEmpty {
        return // Pause
      }

      let input = inputs.removeFirst()

      let inputIndex = code[index + 1]
      // print("input: \(input) -> \(inputIndex) (\(code[(code.count - 3)...]))")

      guard inputIndex < code.count else { throw IntCodeError.operatorRegisterExceedsBounds }

      code[inputIndex] = input
      index += 2

      try runNext()
    case .output:
      try performOutputOperation(opcode: opcodeString)
    case .jumpIfTrue:
      try performJumpOperation(opcode: opcodeString, condition: true)
    case .jumpIfFalse:
      try performJumpOperation(opcode: opcodeString, condition: false)
    case .lessThan:
      try perform3ParamOperation(opcode: opcodeString, oper: { $0 < $1 ? 1 : 0 })
    case .equals:
      try perform3ParamOperation(opcode: opcodeString, oper: { $0 == $1 ? 1 : 0 })
    case .endProgram:
      onHalt?(output)
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

    // print("output: \(value) <- \(outputIndex)")
    output = value
    outputReceiver?.handleValue(value)
    index += 2

    try runNext()
  }

  func performJumpOperation(opcode: String, condition: Bool) throws {
    // print("jump")
    var opcode = opcode
    guard index + 2 < code.count else { throw IntCodeError.operatorExceedsBounds }

    let testValue: Int
    switch opcode.popLast() ?? "0" {
    case "0":
      let testIndex = code[index + 1]
      guard testIndex < code.count else { throw IntCodeError.operatorRegisterExceedsBounds }
      testValue = code[testIndex]
    case "1":
      testValue = code[index + 1]
    default:
      throw IntCodeError.unexpectedOpcode
    }

    let jumpValue: Int
    switch opcode.popLast() ?? "0" {
    case "0":
      let jumpIndex = code[index + 2]
      guard jumpIndex < code.count else { throw IntCodeError.operatorRegisterExceedsBounds }
      jumpValue = code[jumpIndex]
    case "1":
      jumpValue = code[index + 2]
    default:
      throw IntCodeError.unexpectedOpcode
    }

    // print("testValue: \(testValue), condition: \(condition), willJump: \((testValue != 0) == condition)")
    if (testValue != 0) == condition {
      guard jumpValue < code.count, jumpValue >= 0 else { throw IntCodeError.operatorRegisterExceedsBounds }

      index = jumpValue
    } else {
      index += 3
    }

    try runNext()
  }
}

enum InstructionType: Int {
  case add = 1
  case multiply = 2
  case input = 3
  case output = 4
  case jumpIfTrue = 5
  case jumpIfFalse = 6
  case lessThan = 7
  case equals = 8
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
dispatchMain()
