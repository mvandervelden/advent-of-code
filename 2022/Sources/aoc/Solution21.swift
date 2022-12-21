class Solution21: Solving {
  struct Monkey: CustomStringConvertible {
    enum Action: CustomStringConvertible {
      case const(Int)
      case sum(String, String)
      case diff(String, String)
      case prod(String, String)
      case div(String, String)

      init(string: String) {
        if let intVal = Int(string) {
          self = .const(intVal)
          return
        }

        let parts = string.split(separator: " ").map { String($0) }
        switch parts[1] {
        case "+": self = .sum(parts[0], parts[2])
        case "-": self = .diff(parts[0], parts[2])
        case "*": self = .prod(parts[0], parts[2])
        case "/": self = .div(parts[0], parts[2])
        default: fatalError()
        }
      }

      var description: String {
        switch self {
        case .const(let int): return "\(int)"
        case .sum(let lhs, let rhs): return "\(lhs) + \(rhs)"
        case .diff(let lhs, let rhs): return "\(lhs) - \(rhs)"
        case .prod(let lhs, let rhs): return "\(lhs) * \(rhs)"
        case .div(let lhs, let rhs): return "\(lhs) / \(rhs)"
        }
      }
    }

    let name: String
    let action: Action

    init(string: String) {
      let parts = string.components(separatedBy: ": ")

      name = String(parts[0])
      action = Action(string: String(parts[1]))
    }

    var description: String {
      return "\(name): \(action)"
    }
  }

  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let monkeys = file.lines.map { Monkey(string: $0) }

    let result = findResult("root", monkeys: monkeys)

    return result.description
  }

  private func findResult(_ current: String, monkeys: [Monkey]) -> Int {
    let monkey = monkeys.first { $0.name == current }!
    switch monkey.action {
    case .const(let int):
      return int
    case .sum(let lhs, let rhs):
      return findResult(lhs, monkeys: monkeys) + findResult(rhs, monkeys: monkeys)
    case .diff(let lhs, let rhs):
      return findResult(lhs, monkeys: monkeys) - findResult(rhs, monkeys: monkeys)
    case .prod(let lhs, let rhs):
      return findResult(lhs, monkeys: monkeys) * findResult(rhs, monkeys: monkeys)
    case .div(let lhs, let rhs):
      return findResult(lhs, monkeys: monkeys) / findResult(rhs, monkeys: monkeys)
    }
  }

  func solve2() -> String {
    return file.filename
  }
}

