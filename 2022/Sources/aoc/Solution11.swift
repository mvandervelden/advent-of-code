class Solution11: Solving {
  class Monkey: CustomStringConvertible {
    var items: [Int]
    let inspect: (Int) -> Int
    let test: (Int) -> Int
    let denominator: Int
    var activity = 0

    init(_ input: [String]) {
      items = input[1].components(separatedBy: ": ")[1].components(separatedBy: ", ").map { Int($0)! }

      let operatorParts = input[2].components(separatedBy: "= old ")[1].split(separator: " ")
      let opString = operatorParts[0]
      let op: (Int, Int) -> Int = {
        opString == "+" ? $0 + $1 : $0 * $1
      }

      let operand = operatorParts[1]

      inspect = { old in
        if let operandConstant = Int(operand) {
          return op(old, operandConstant)
        }

        return op(old, old)
      }

      let denominator = Int(input[3].split(separator: " ").last!)!
      let destinationIfTrue = Int(input[4].split(separator: " ").last!)!
      let destinationIfFalse = Int(input[5].split(separator: " ").last!)!

      test = { val in
        if val % denominator == 0 {
          return destinationIfTrue
        } else {
          return destinationIfFalse
        }
      }
      self.denominator = denominator
    }

    var description: String {
      return "\(items), activity: \(activity)"
    }
  }

  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let monkeys = file.linesSplitByEmptyLine.map(Monkey.init)

    for i in 0..<20 {
      for monkey in monkeys {
        for item in monkey.items {
          var newVal = monkey.inspect(item)
          monkey.activity += 1
          newVal = newVal / 3
          let nextMonkey = monkey.test(newVal)
          monkeys[nextMonkey].items.append(newVal)
        }
        monkey.items = []
      }
      print(i)
      print(monkeys.map(\.description).joined(separator:"\n"))
    }

    let activity = Array(monkeys.map(\.activity).sorted().reversed())

    return (activity[0]*activity[1]).description
  }

  func solve2() -> String {
    let monkeys = file.linesSplitByEmptyLine.map(Monkey.init)
    let leastCommonDenominator = monkeys.reduce(1) { $0 * $1.denominator }

    for _ in 0..<10_000 {
      for monkey in monkeys {
        for item in monkey.items {
          var newVal = monkey.inspect(item)
          newVal = newVal % leastCommonDenominator
          monkey.activity += 1
          let nextMonkey = monkey.test(newVal)
          monkeys[nextMonkey].items.append(newVal)
        }
        monkey.items = []
      }
      // print(i)
      // print(monkeys.map(\.description).joined(separator:"\n"))
    }

    let activity = Array(monkeys.map(\.activity).sorted().reversed())

    return (activity[0]*activity[1]).description
  }
}

