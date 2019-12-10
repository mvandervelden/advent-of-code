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
    let line = lines[0]
    code = line.indexDict

    runInput(index: 0)
    return maxCombi.description
  }

  private func solveTwo(file: File) -> String {
    let lines = file.lines
    let line = lines[0]
    code = line.indexDict
    allInputs = [[2]]
    runInput(index: 0)
    return maxCombi.description
  }

  var allInputs = [[1]]

  var maxCombi = "initial"
  var maxVal = 0
  var code: [Int: Int] = [:]

  private func runInput(index: Int) {
    // print(allInputs.count)
    // print(index)
    if index == allInputs.count {
      print("FINAL RESULT: \(maxCombi)")
      exit(EXIT_SUCCESS)
    }
    // print("is this run")
    let input = allInputs[index]

    let amps = input.map {
      IntCode(code: code, input: $0)
    }
    // print(amps)
    // for (int, amp) in amps.enumerated() {
    //   amp.outputReceiver = amps[(int + 1) % 5]
    // }

    var outputsReceived: [Int] = []
    let group = DispatchGroup()

    group.enter()
    amps[0].run(input: 0) { output in
      print("finished: 0")
      group.leave()
      outputsReceived.append(output ?? 0)
      amps[0].onHalt = nil
    }
    // for int in 1..<amps.count {
    //   let amp = amps[int]
    //   group.enter()
    //   amp.run { output in
    //     // print("finished: \(int)")
    //     group.leave()
    //     outputsReceived.append(output ?? 0)
    //     amps[int].onHalt = nil
    //   }
    // }

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
  var code: [Int: Int]
  var index = 0
  weak var outputReceiver: IntCodeOutputReceiver?
  var onHalt: ((Int?) -> Void)?
  var inputs: [Int]
  var output: Int?
  var relativeBase = 0

  func handleValue(_ value: Int) {
    inputs.append(value)
    DispatchQueue.main.async {
      self.runNext()
    }
  }

  init(code: [Int: Int], input: Int) {
    self.code = code
    self.inputs = [input]
  }

  func run(input: Int? = nil, onHalt: @escaping (Int?) -> Void) {
    self.onHalt = onHalt
    if let input = input {
      inputs.append(input)
    }

    DispatchQueue.main.async {
      self.runNext()
    }
    // print(code)
  }

  private func runNext() {
    DispatchQueue.main.async {
      // print("index: \(index): \(code[index])")
      guard self.index < self.code.count else { fatalError("IntCodeError.indexOutOfBounds") }

      let opcode = self.code[self.index]!
      let typeInt = opcode % 100

      guard let type = InstructionType(rawValue: typeInt) else {
        fatalError("IntCodeError.unexpectedOpcode")
      }

      // print("\(type) raw: " + opcode.description)
      let opcodeString = (opcode / 100).description

      switch type {
      case .add:
        self.perform3ParamOperation(opcode: opcodeString, oper: +)
      case .multiply:
        self.perform3ParamOperation(opcode: opcodeString, oper: *)
      case .input:
        self.performInputOperation(opcode: opcodeString)
      case .output:
        self.performOutputOperation(opcode: opcodeString)
      case .jumpIfTrue:
        self.performJumpOperation(opcode: opcodeString, condition: true)
      case .jumpIfFalse:
        self.performJumpOperation(opcode: opcodeString, condition: false)
      case .lessThan:
        self.perform3ParamOperation(opcode: opcodeString, oper: { $0 < $1 ? 1 : 0 })
      case .equals:
        self.perform3ParamOperation(opcode: opcodeString, oper: { $0 == $1 ? 1 : 0 })
      case .setRelativeBase:
        self.performRelativeBaseOperation(opcode: opcodeString)
      case .endProgram:
        self.onHalt?(self.output)
        return
      }
    }
  }

  private func perform3ParamOperation(opcode: String, oper: (Int, Int) -> Int) {
    var opcode = opcode
    guard index + 3 < code.count else { fatalError("IntCodeError.operatorExceedsBounds") }

    let lhValue: Int
    switch opcode.popLast() ?? "0" {
    case "0":
      let lhsIndex = code[index + 1]!
      let val = code[lhsIndex, default: 0]
      lhValue = val
    case "1":
      lhValue = code[index + 1]!
    case "2":
      let lhsIndex = code[index + 1]! + relativeBase
      let val = code[lhsIndex, default: 0]
      lhValue = val
    default:
      fatalError("IntCodeError.unexpectedOpcode")
    }

    let rhValue: Int
    switch opcode.popLast() ?? "0" {
    case "0":
      let rhsIndex = code[index + 2]!
      let val = code[rhsIndex, default: 0]
      rhValue = val
    case "1":
      rhValue = code[index + 2]!
    case "2":
      let rhsIndex = code[index + 2]! + relativeBase
      let val = code[rhsIndex, default: 0]
      rhValue = val
    default:
      fatalError("IntCodeError.unexpectedOpcode")
    }

    let resultIndex: Int
    switch opcode.popLast() ?? "0" {
    case "0":
      resultIndex = code[index + 3]!
    case "2":
      resultIndex = code[index + 3]! + relativeBase
    default:
      fatalError("IntCodeError.unexpectedOpcode")
    }

    // guard resultIndex < code.count else { throw IntCodeError.operatorRegisterExceedsBounds }

    code[resultIndex] = oper(lhValue, rhValue)
    index += 4

    runNext()
  }

  private func performInputOperation(opcode: String) {
    if inputs.isEmpty {
      return // Pause
    }

    let input = inputs.removeFirst()
    let inputIndex: Int

    switch opcode.last ?? "0" {
    case "0":
      inputIndex = code[index + 1]!
    case "2":
      inputIndex = code[index + 1]! + relativeBase
    default:
      fatalError("IntCodeError.unexpectedOpcode")
    }

    // print("input: \(input) -> \(inputIndex) (\(code[(code.count - 3)...]))")

    code[inputIndex] = input
    index += 2

    runNext()
  }

  private func performOutputOperation(opcode: String) {
    let value: Int
    var outputIndex = index + 1

    switch opcode.last ?? "0" {
    case "0":
      outputIndex = code[index + 1]!
      let val = code[outputIndex, default: 0]
      value = val
    case "1":
      value = code[index + 1]!
    case "2":
      outputIndex = code[index + 1]! + relativeBase
      let val = code[outputIndex, default: 0]
      value = val
    default:
      fatalError("IntCodeError.unexpectedOpcode")
    }

    print("output: \(value) <- \(outputIndex)")
    output = value
    outputReceiver?.handleValue(value)
    index += 2

    runNext()
  }

  private func performRelativeBaseOperation(opcode: String) {
    let value: Int
    var relativeBaseIndex = index + 1

    switch opcode.last ?? "0" {
    case "0":
      relativeBaseIndex = code[index + 1]!
      let val = code[relativeBaseIndex, default: 0]
      value = val
    case "1":
      value = code[index + 1]!
    case "2":
      relativeBaseIndex = code[index + 1]! + relativeBase
      let val = code[relativeBaseIndex, default: 0]
      value = val
    default:
      fatalError("IntCodeError.unexpectedOpcode")
    }

    // print("output: \(value) <- \(outputIndex)")
    relativeBase += value
    index += 2

    runNext()
  }

  func performJumpOperation(opcode: String, condition: Bool) {
    // print("jump")
    var opcode = opcode
    guard index + 2 < code.count else { fatalError("IntCodeError.operatorExceedsBounds") }

    let testValue: Int
    switch opcode.popLast() ?? "0" {
    case "0":
      let testIndex = code[index + 1]!
      let val = code[testIndex, default: 0]
      testValue = val
    case "1":
      testValue = code[index + 1]!
    case "2":
      let testIndex = code[index + 1]! + relativeBase
      let val = code[testIndex, default: 0]
      testValue = val
    default:
      fatalError("IntCodeError.unexpectedOpcode")
    }

    let jumpValue: Int
    switch opcode.popLast() ?? "0" {
    case "0":
      let jumpIndex = code[index + 2]!
      let val = code[jumpIndex, default: 0]
      jumpValue = val
    case "1":
      jumpValue = code[index + 2]!
    case "2":
      let jumpIndex = code[index + 2]! + relativeBase
      let val = code[jumpIndex, default: 0]
      jumpValue = val
    default:
      fatalError("IntCodeError.unexpectedOpcode")
    }

    // print("testValue: \(testValue), condition: \(condition), willJump: \((testValue != 0) == condition)")
    if (testValue != 0) == condition {
      // guard jumpValue < code.count, jumpValue >= 0 else { throw IntCodeError.operatorRegisterExceedsBounds }

      index = jumpValue
    } else {
      index += 3
    }

    runNext()
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
  case setRelativeBase = 9
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
  var indexDict: [Int: Int] {
    let array = intsSplitByComma
    var output: [Int: Int] = [:]
    for (index, elem) in array.enumerated() {
      output[index] = elem
    }
    return output
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
