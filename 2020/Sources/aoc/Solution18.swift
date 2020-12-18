class Solution18: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    var sum = 0

    for line in file.charsByLine {
      let (val, _) = evalExpr1(line)
      print(val)
      sum += val
    }
    return sum.description
  }

  func evalExpr1(_ line: [Character]) -> (res: Int, advance: Int) {
    var curVal = 0
    var pendingOperation: ((Int) -> Int)? = nil

    var i = 0
    while i < line.count {
      switch line[i] {
      case " ":
        i += 1
        continue
      case let char where char.isNumber:
        let val = Int(String(char))!
        if let op = pendingOperation {
          curVal = op(val)
          pendingOperation = nil
        } else {
          curVal = val
        }
        i += 1
      case "+":
        pendingOperation = { curVal + $0 }
        i += 1
      case "*":
        pendingOperation = { curVal * $0 }
        i += 1
      case "(":
        let (newVal, advance) = evalExpr1(Array(line[(i + 1)...]))
        if let op = pendingOperation {
          curVal = op(newVal)
          pendingOperation = nil
        } else {
          curVal = newVal
        }
        i += advance + 1
      case ")":
        return (curVal, i+1)
      case let char:
        preconditionFailure("Unexpected character \(char)")
      }
    }
    return (curVal, i)
  }

  func solve2() -> String {
    var sum = 0

    for line in file.charsByLine {
      let newLine = evalExpr2(line)
      print(String(newLine))
      let (val, _) = evalExpr1(newLine)
      print(val)
      sum += val
    }
    return sum.description
  }

  func evalExpr2(_ line: [Character]) -> [Character] {
    var line = line
    var newLine: [Character] = []
    var i = 0
    while i < line.count {
      switch line[i] {
      case "+":
        switch newLine[newLine.count-2] {
        case let char where char.isNumber:
          newLine.insert("(", at: newLine.count - 2)
        case ")":
          let insertionPoint = findMatchingOpenIndex(Array(newLine[0...newLine.count - 2]))
          newLine.insert("(", at: insertionPoint)
        case let char:
          preconditionFailure("unexpected: \(char)")
        }

        switch line[i+2] {
        case let char where char.isNumber:
          newLine.append(contentsOf: line[i...(i + 2)])
          newLine.append(")")
          i += 3
        case "(":
          let insertionPoint = findMatchingClosingIndex(Array(line[i...]))
          newLine.append("+")
          line.insert(")", at: i + insertionPoint)
          i += 1
        case let char:
          preconditionFailure("unexpected: \(char)")
        }

      case let char:
        newLine.append(char)
        i += 1
      }
    }
    return newLine
  }

  func findMatchingOpenIndex(_ line: [Character]) -> Int {
    var depth = 0
    for (idx, char) in line.enumerated().reversed() {
      if char == ")" { depth += 1 }
      if char == "(" {
        depth -= 1
        if depth == 0 {
          return idx
        }
      }
    }
    return 0
  }

func findMatchingClosingIndex(_ line: [Character]) -> Int {
    var depth = 0
    for (idx, char) in line.enumerated() {
      if char == "(" { depth += 1 }
      if char == ")" {
        depth -= 1
        if depth == 0 {
          return idx
        }
      }
    }
    return line.count
  }
}
