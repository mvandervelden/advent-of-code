class Solution01: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let calories = file.intsSplitByEmptyLine

    return calories.reduce(0) { max($0, $1.sum()) }.description
  }

  func solve2() -> String {
    return file.intsSplitByEmptyLineSummed.sorted().suffix(3).sum().description
  }
}

extension File {
  var intsSplitByEmptyLine: [[Int]] {
    return string.components(separatedBy: "\n\n").map { (block: String) in
      block.split(separator: "\n").compactMap { Int($0) }
    }
  }

  var intsSplitByEmptyLineSummed: [Int] {
    return string.components(separatedBy: "\n\n").map { (block: String) in
      block.split(separator: "\n").compactMap { Int($0) }.sum()
    }
  }
}
