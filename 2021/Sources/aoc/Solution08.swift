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
      var newInstructions = originalCode
      newInstructions[index] = [changeInstr(line[0]), line[1]]

      let (result, exit) = CodeRunner(instructions: newInstructions).run()

      if exit == .endReached { return result.description }
    }
    return "nothing found"
  }

  func changeInstr(_ instr: String) -> String {
    switch instr {
    case "nop": return "jmp"
    case "jmp": return "nop"
    default: return instr
    }
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
    }

    return (accumulator, .loopDetected)
  }
}
