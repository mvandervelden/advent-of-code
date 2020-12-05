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
    let conversions: [Character: Character] = ["F": "0", "B": "1", "L": "0", "R": "1"]
    return Int(String(line.map { conversions[$0]! }), radix: 2)!
  }
}
