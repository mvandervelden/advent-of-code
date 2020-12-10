class Solution10: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let adapters = file.lines.map { Int($0)! }
    let sorted = [0] + adapters.sorted()
    var diff1s = 0
    var diff3s = 1
    for i in 1..<sorted.count {
      let diff = sorted[i] - sorted[i - 1]
      if diff == 1 { diff1s += 1 }
      if diff == 3 { diff3s += 1 }
    }
    return (diff1s * diff3s).description
  }

  func solve2() -> String {
    var adapters = file.lines.map { Int($0)! }.sorted()
    adapters.append(adapters.last! + 3)
    let paths2 = search2(remaining: [0] + adapters)
    let paths = search(joltage: 0, remaining: adapters)
    return paths.description + " " + paths2.description
  }


  // Recursion, doesn't work on the input
  var cache: [[Int]: Int] = [[]: 1]

  func search(joltage: Int, remaining: [Int]) -> Int {
    if let val = cache[remaining] { return val }

    var pathsFound = 0
    for (ind, i) in remaining.enumerated() where i <= joltage + 3 {
      let newRemaining = Array(remaining[(ind + 1)...])
      let result = search(joltage: i, remaining: newRemaining)
      pathsFound += result
      cache[newRemaining] = result
    }
    return pathsFound
  }

  // Working solution
  func search2(remaining: [Int]) -> Int {
    let n = remaining.count

    var openPaths: [Int: Int] = [0: 1]
    for (ind, i) in (remaining).enumerated() {
      if ind == n { break }

      let curCount = openPaths[ind]!
      openPaths[ind + 1, default: 0] += curCount

      if ind + 2 < n, remaining[ind + 2] <= i + 3 {
        openPaths[ind + 2, default: 0] += curCount
      }

      if ind + 3 < n, remaining[ind + 3] <= i + 3 {
        openPaths[ind + 3, default: 0] += curCount
      }
    }
    return openPaths[n]!
  }
}
