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

      return run(code: code).description
    }

    return results.description
  }

  private func solveTwo(file: File) -> String {
    let line = file.lines.first!
    let code = line.intsSplitByComma

    for noun in 0...99 {
      for verb in 0...99 {
        let result = run(code: code.prepare(noun: noun, verb: verb))

        if result == -1 {
          print("invalid code")
        }

        if result == 19690720 {
          return (noun * 100 + verb).description
        }
      }
    }
    fatalError("Did not find a solution")
  }

  private func run(code: [Int]) -> Int {
    let result = runNext(state: State(code: code, index: 0))
    return result[0]
  }

  private func runNext(state: State) -> [Int] {
    guard state.index < state.code.count else { return [-1] }
    switch state.code[state.index] {
    case 99:
      return state.code
    case 1:
      let result = performOperator(state: state, oper: +)
      return runNext(state: result)
    case 2:
      let result = performOperator(state: state, oper: *)
      return runNext(state: result)
    default:
      return [-1]
    }
  }

  private func performOperator(state: State, oper: (Int, Int) -> Int) -> State {
    let index = state.index
    let code = state.code

    guard index + 3 < code.count else { return .errorState }

    let lhsIndex = code[index + 1]
    let rhsIndex = code[index + 2]
    let resultIndex = code[index + 3]

    guard lhsIndex < code.count,
          rhsIndex < code.count,
          resultIndex < code.count else {
      return .errorState
    }

    let lhs = code[lhsIndex]
    let rhs = code[rhsIndex]
    var result = code
    result[resultIndex] = oper(lhs, rhs)
    return State(code: result, index: index + 4)
  }
}

struct State {
  let code: [Int]
  let index: Int

  static var errorState: State { return State(code: [-1], index: 0) }
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
