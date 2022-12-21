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

    var rootParts: (String, String)? {
        guard name == "root" else { return nil }
        switch action {
        case .sum(let lhs, let rhs): return (lhs, rhs)
        case .diff(let lhs, let rhs): return (lhs, rhs)
        case .prod(let lhs, let rhs): return (lhs, rhs)
        case .div(let lhs, let rhs): return (lhs, rhs)
        default: return nil
        }
      }
  }

  let file: File
  var monkeys: [Monkey]!

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    monkeys = file.lines.map { Monkey(string: $0) }

    let result = findResult1("root")

    return result.description
  }

 private func findResult1(_ current: String) -> Int {
    let monkey = monkeys.first { $0.name == current }!

    switch monkey.action {
    case .const(let int):
      return int
    case .sum(let lhs, let rhs):
      return findResult1(lhs) + findResult1(rhs)
    case .diff(let lhs, let rhs):
      return findResult1(lhs) - findResult1(rhs)
    case .prod(let lhs, let rhs):
      return findResult1(lhs) * findResult1(rhs)
    case .div(let lhs, let rhs):
      return findResult1(lhs) / findResult1(rhs)
    }
  }

  private func findResult2(_ current: String) -> Int? {
    let monkey = monkeys.first { $0.name == current }!
    if monkey.name == "humn" { return nil }

    switch monkey.action {
    case .const(let int):
      return int
    case .sum(let lhs, let rhs):
      if let lhsRes = findResult2(lhs),
         let rhsRes = findResult2(rhs) {
          return lhsRes + rhsRes
      } else { return nil }

    case .diff(let lhs, let rhs):
      if let lhsRes = findResult2(lhs),
         let rhsRes = findResult2(rhs) {
          return lhsRes - rhsRes
      } else { return nil }

    case .prod(let lhs, let rhs):
      if let lhsRes = findResult2(lhs),
         let rhsRes = findResult2(rhs) {
          return lhsRes * rhsRes
      } else { return nil }

    case .div(let lhs, let rhs):
      if let lhsRes = findResult2(lhs),
         let rhsRes = findResult2(rhs) {
          return lhsRes / rhsRes
      } else { return nil }
    }
  }

  private func resolveOperation(_ current: String, toMatch: Int) -> Int {
    let monkey = monkeys.first { $0.name == current }!
    if monkey.name == "humn" { return toMatch }

    switch monkey.action {
    case .const:
      fatalError("not expected to have a const here")
    case .sum(let lhs, let rhs):
      if let lhsRes = findResult2(lhs) {
        return resolveOperation(rhs, toMatch: toMatch - lhsRes)
      } else if let rhsRes = findResult2(rhs) {
        return resolveOperation(lhs, toMatch: toMatch - rhsRes)
      }
    case .diff(let lhs, let rhs):
      if let lhsRes = findResult2(lhs) {
        return resolveOperation(rhs, toMatch: -(toMatch - lhsRes))
      } else if let rhsRes = findResult2(rhs) {
        return resolveOperation(lhs, toMatch: toMatch + rhsRes)
      }
    case .prod(let lhs, let rhs):
      if let lhsRes = findResult2(lhs) {
        return resolveOperation(rhs, toMatch: toMatch / lhsRes)
      } else if let rhsRes = findResult2(rhs) {
        return resolveOperation(lhs, toMatch: toMatch / rhsRes)
      }
    case .div(let lhs, let rhs):
      if let lhsRes = findResult2(lhs) {
        return resolveOperation(rhs, toMatch:  lhsRes / toMatch)
      } else if let rhsRes = findResult2(rhs) {
        return resolveOperation(lhs, toMatch: rhsRes * toMatch)
      }
    }
    fatalError("unexpected no-return")
  }

  private func testResolve() {
    let human = Monkey(string: "humn: 5")
    let five = Monkey(string: "five: 5")
    let plusX = Monkey(string: "plus: five + humn")
    let xPlus = Monkey(string: "plux: humn + five")
    let minX = Monkey(string: "mins: five - humn")
    let xMin = Monkey(string: "minx: humn - five")
    let multX = Monkey(string: "muls: five * humn")
    let xMult = Monkey(string: "mulx: humn * five")
    let divX = Monkey(string: "divs: five / humn")
    let xDiv = Monkey(string: "divx: humn / five")

    monkeys = [human, five, plusX, xPlus, minX, xMin, multX, xMult, divX, xDiv]

    print("Test 1 - addition +X")

    for inOut in [(0, -5), (10, 5), (-10, -15)] {
      let value = resolveOperation("plus", toMatch: inOut.0)
      print(value == inOut.1 ? "✅" : "❌", "val:", value, "expected:", inOut.1)
    }

    print("Test 2 - addition X+")
    for inOut in [(0, -5), (10, 5), (-10, -15)] {
      let value = resolveOperation("plux", toMatch: inOut.0)
      print(value == inOut.1 ? "✅" : "❌", "val:", value, "expected:", inOut.1)
    }

    print("Test 3 - subtraction -X")
    for inOut in [(0, 5), (10, -5), (-10, 15)] {
      let value = resolveOperation("mins", toMatch: inOut.0)
      print(value == inOut.1 ? "✅" : "❌", "val:", value, "expected:", inOut.1)
    }

    print("Test 4 - subtraction X-")
    for inOut in [(0, 5), (10, 15), (-10, -5)] {
      let value = resolveOperation("minx", toMatch: inOut.0)
      print(value == inOut.1 ? "✅" : "❌", "val:", value, "expected:", inOut.1)
    }
  }

  func solve2() -> String {
    // testResolve()
    // return ""

    monkeys = file.lines.map { Monkey(string: $0) }
    let root = monkeys.first { $0.name == "root" }!.rootParts!

    let result1 = findResult2(root.0)
    let result2 = findResult2(root.1)

    let toMatch = [result1, result2].compactMap { $0 }[0]

    if result1 == nil {
      let humn = resolveOperation(root.0, toMatch: toMatch)
      return humn.description
    } else {
      let humn = resolveOperation(root.1, toMatch: toMatch)
      return humn.description
    }
  }
}

