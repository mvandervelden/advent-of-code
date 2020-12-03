struct Rule: CustomStringConvertible {
  let letter: Character
  let lowerRange: Int
  let upperRange: Int

  var description: String { "\(lowerRange)-\(upperRange) \(letter)" }

  init(_ string: String) {
    let parts = string.split(separator: " ")
    letter = parts.last!.first!
    let rangeParts = parts.first!.split(separator: "-")
    lowerRange = Int(rangeParts.first!)!
    upperRange = Int(rangeParts.last!)!
  }
}

struct Entry: CustomStringConvertible {
  let rule: Rule
  let pwd: String

  var description: String { "\(rule): \(pwd)" }

  init(_ string: String) {
    let parts = string.split(separator: ":")
    rule = Rule(String(parts.first!))
    pwd = String(parts.last!.dropFirst())
  }

  var isValid1: Bool {
    let amountFound = pwd.reduce(0) { $0 + ($1 == rule.letter ? 1 : 0) }
    return amountFound >= rule.lowerRange && amountFound <= rule.upperRange
  }

  var isValid2: Bool {
    let lowerChar = pwd[pwd.index(pwd.startIndex, offsetBy: rule.lowerRange - 1)]
    let upperChar = pwd[pwd.index(pwd.startIndex, offsetBy: rule.upperRange - 1)]
    return [lowerChar, upperChar].filter { $0 == rule.letter }.count == 1
  }
}

class Solution02: Solving {
  let file: File

  let entries: [Entry]

  required init(file: File) {
    self.file = file
    entries = file.lines.map(Entry.init)
  }

  func solve1() -> String {
    let validCount = entries.reduce(0) { $0 + ($1.isValid1 ? 1 : 0) }

    return validCount.description
  }

  func solve2() -> String {
    let validCount = entries.reduce(0) { $0 + ($1.isValid2 ? 1 : 0) }

    return validCount.description
  }
}
