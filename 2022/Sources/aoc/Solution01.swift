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
    let calories = file.intsSplitByEmptyLine

    var max3 = [0, 0, 0]

    for cal in calories {
      let sum = cal.sum()
      if sum <= max3[2] { continue }
      else if sum > max3[0] {
        max3.insert(sum, at: 0)
      } else if sum > max3[1] {
        max3.insert(sum, at: 1)
      } else if sum > max3[2] {
        max3.insert(sum, at: 2)
      }
      max3.removeLast()
    }

    return max3.sum().description
  }
}

extension File {
  var intsSplitByEmptyLine: [[Int]] {
    return string.components(separatedBy: "\n\n").map { (block: String) in
      block.split(separator: "\n").compactMap { Int($0) }
    }
  }
}
