class Solution07: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let crabs = file.csv[0].compactMap(Int.init).sorted()
    let n = crabs.count

    let middle: Int
    if n%2 == 0 {
      middle = (crabs[(n/2) - 1] + crabs[n/2]) / 2
    } else {
      middle = crabs[n/2]
    }

    let dist = crabs.reduce(0) { $0 + abs($1 - middle) }

    return dist.description
  }

  func solve2() -> String {
    let crabs = file.csv[0].compactMap(Int.init).sorted()

    let mean = crabs.sum() / crabs.count

    var costs: [Int] = []
    for m in mean-2...mean+2 {
      var cost = 0
      for c in crabs {
        let d = abs(c - m)
        cost += (d*(d+1))/2
      }
      costs.append(cost)
    }

    return costs.min()!.description
  }
}
