class Solution05: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    return file.charsByLine.map(getSeatIDBin).max()!.description
  }

  func solve2() -> String {
    let seats = file.charsByLine.map(getSeatIDBin)
    return (seats.min()!..<seats.max()!).first { !seats.contains($0) && seats.contains($0 - 1) && seats.contains($0 + 1) }!.description
  }

  func getSeatIDBin(line: [Character]) -> Int {
    let lineBin = line.map { (char: Character) -> Character in
      switch char {
        case "F", "L": return "0"
        case "B", "R": return "1"
        default: preconditionFailure("unexpected character: \(char)")
      }
    }

    return Int(String(lineBin), radix: 2)!
  }
}
