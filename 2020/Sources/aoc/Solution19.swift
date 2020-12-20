class Solution19: Solving {
  let indices: [String]
  let rules: [[String]]
  let file: File
  let input: [[String]]

  var rulesDescription: String { zip(indices, rules).map { "\($0.0): \($0.1)" }.joined(separator: "\n") }

  required init(file: File) {
    self.file = file
    let sections = file.linesSplitByEmptyLine
    var rules: [[String]] = []
    var indices: [String] = []
    for line in sections[0] {
      let splitIndex = line.components(separatedBy: ": ")
      indices.append(splitIndex[0])
      rules.append(splitIndex[1].components(separatedBy: " "))
    }
    self.rules = rules
    self.indices = indices

    input = sections[1].map { line in
      line.map { "\"\($0)\"" }
    }
  }

  func solve1() -> String {
    var valids = 0
    for line in input {
      let v = isValid(line)
      print(v, line.joined(separator: " "))
      valids += v ? 1 : 0
    }
    return valids.description
  }

  var i = 0
  var checked: [[String]: Bool] = [["0"]: true]

  func isValid(_ line: [String]) -> Bool {
    if let v = checked[line] { return v }
    if i % 10_000 == 0 { print(i, line.joined(separator: " ")) }
    if line == ["0"] { return true }
    // if i > 10 { preconditionFailure("HALT") }
    i += 1
    for (idx, rule) in zip(indices, rules) {
      for part in rule.split(separator: "|").map({Array($0)}) {
        let matches = line.lazy.enumerated().compactMap { idx, str in
          return str == part[0] ? idx : nil
        }.filter { idx in
          Array(line[idx...].prefix(part.count)) == part
        }
        if matches.isEmpty { continue }

        if part[0].contains("\"") {
          // literal, we replace all in one go
          var newLine = line
          for match in matches.reversed() {
            newLine.replaceSubrange(match..<(match+part.count), with: [idx])
          }
          // print("lit:", newLine)
          if isValid(newLine) {
            checked[line] = true
            print("found")
            return true
          }
        } else {
          for match in matches {
            var newLine = line
            newLine.replaceSubrange(match..<(match+part.count), with: [idx])

            if isValid(newLine) {
              checked[line] = true
              print("found")
              return true
            }
          }
        }
      }
    }
    // print("not found: \(line)")
    checked[line] = false
    return false
  }

  func solve2() -> String {

    return file.lines.joined(separator: "\n")
  }

}
