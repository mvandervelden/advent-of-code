class Solution05: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    return file.charsByLine.map(getSeat).map(getSeatID).max()!.description
  }

  func solve2() -> String {
    let seats = file.charsByLine.map(getSeat).map(getSeatID)
    return (seats.min()!..<seats.max()!).first { !seats.contains($0) && seats.contains($0 - 1) && seats.contains($0 + 1) }!.description
  }

  func getSeat(line: [Character]) -> (row: Int, col: Int) {
    var rowRange = 0..<128
    var colRange = 0..<8
    for char in line {
      let rowDiff = rowRange.upperBound - rowRange.lowerBound
      let colDiff = colRange.upperBound - colRange.lowerBound
      switch char {
        case "F": rowRange = rowRange.lowerBound..<(rowRange.upperBound - (rowDiff / 2))
        case "B": rowRange = (rowRange.lowerBound + (rowDiff / 2))..<rowRange.upperBound
        case "L": colRange = colRange.lowerBound..<(colRange.upperBound - (colDiff / 2))
        case "R": colRange = (colRange.lowerBound + (colDiff / 2))..<colRange.upperBound
        default: preconditionFailure("unexpected character: \(char)")
      }
    }

    let row = rowRange.lowerBound
    let col = colRange.lowerBound
    return (row: row, col: col)
  }

  func getSeatID(seat: (row: Int, col: Int)) -> Int {
    return seat.row * 8 + seat.col
  }
}
