class Solution08: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    return CodeRunner(instructions: file.words).run().0.description
  }

  func solve2() -> String {
    let originalCode = file.words

    for (index, line) in originalCode.enumerated() {
      switch line[0] {
      case "jmp":
        let newLine = ["nop", line[1]]
        var newInstructions = originalCode
        newInstructions[index] = newLine
        let (result, exit) = CodeRunner(instructions: newInstructions).run()
        if exit == .endReached { return result.description }
      case "nop":
        let newLine = ["jmp", line[1]]
        var newInstructions = originalCode
        newInstructions[index] = newLine
        let (result, exit) = CodeRunner(instructions: newInstructions).run()
        if exit == .endReached { return result.description }
      default: continue
      }
    }
    return "nothinig found"
  }
}

class CodeRunner {
  enum ExitCode {
    case loopDetected, endReached
  }

  let instructions: Words
  var accumulator = 0
  var history: Set<Int> = []
  var index = 0

  init(instructions: Words) {
    self.instructions = instructions
  }

  func run() -> (Int, ExitCode) {
    while !history.contains(index) {
      if index == instructions.count { return (accumulator, .endReached) }

      history.insert(index)
      let next = instructions[index]
      switch (next[0], Int(next[1])!) {
      case ("acc", let acc):
        accumulator += acc
        index += 1
      case ("nop", _):
        index += 1
      case ("jmp", let jmp):
        index += jmp
      default:
        preconditionFailure("unexpected code: \(next)")
      }

      // print("\(next): \(index) | \(accumulator) (\(history))")
    }

    return (accumulator, .loopDetected)
  }
}
