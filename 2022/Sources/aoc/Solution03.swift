class Solution03: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    return file.lines.reduce(0) {
      let chars = Array($1)
      let first = Set(chars[..<(chars.count / 2)])
      let last = Set(chars[(chars.count / 2)...])
      let char = first.intersection(last).first!
      return $0 + Int(char.priority)
    }.description
  }

  func solve2() -> String {
    let sacks = file.charsByLine
    let groups = sacks.chunked(into: 3)

    return groups.reduce(0) {
      let intersection = Set($1[0]).intersection(Set($1[1])).intersection(Set($1[2]))
      return $0 + Int(intersection.first!.priority)
    }.description
  }
}

extension Character {
  var priority: Int {
    switch asciiValue! {
      case 65...90:
        return Int(asciiValue!) - 65 + 27
      case 97...122:
        return Int(asciiValue!) - 97 + 1
      default:
        fatalError("unexpected input")
    }
  }
}