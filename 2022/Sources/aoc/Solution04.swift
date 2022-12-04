class Solution04: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    return file.csv.reduce(0) { sum, line in
      let pair: [ClosedRange<Int>] = line.map { assignmentStr in
        let ints = assignmentStr.split(separator: "-").map { Int($0)! }
        return ints[0]...ints[1]
      }
      .sorted { $0.count > $1.count } // largest range always comes first

      if pair[0].contains(pair[1].lowerBound) && pair[0].contains(pair[1].upperBound) {
        return sum + 1
      }

      return sum
    }
    .description
  }

  func solve2() -> String {
    return file.csv.reduce(0) { sum, line in
      let pair: [ClosedRange<Int>] = line.map { assignmentStr in
        let ints = assignmentStr.split(separator: "-").map { Int($0)! }
        return ints[0]...ints[1]
      }

      if pair[0].overlaps(pair[1]) {
        return sum + 1
      }

      return sum
    }
    .description
  }
}

