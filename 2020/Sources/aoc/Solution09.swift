class Solution09: Solving {
  let file: File
  let preambleSize: Int

  required init(file: File) {
    self.file = file
    preambleSize = file.filename.contains("example") ? 5 : 25
  }

  func solve1() -> String {
    let vals = file.lines.map { Int($0)! }
    let result = findInvalidNumber(vals: vals)
    return result.description
  }

  func solve2() -> String {
    let vals = file.lines.map { Int($0)! }
    let invalidVal = findInvalidNumber(vals: vals)
    var result = -1
    for lowerBound in 0..<vals.count {
      for upperBound in (lowerBound + 1)..<vals.count {
        let range = vals[lowerBound...upperBound]

        if range.sum() == invalidVal {
          result = range.min()! + range.max()!
          break
        } else if range.sum() > invalidVal {
          break
        }
      }

      if result > -1 { break }
    }
    return result.description
  }

  func findInvalidNumber(vals: [Int]) -> Int {
    var result = -1
    for (index, val) in vals[preambleSize...].enumerated() {
      let i = index + preambleSize

      var foundSum = false
      let prev = vals[(i - preambleSize)..<i]
      for p1 in prev {
        for p2 in prev {
          if p1 != p2, p1 + p2 == val {
            foundSum = true
          }
        }
      }

      if !foundSum {
        result = val
        break
      }
    }
    return result
  }
}
