typealias Layout = [[Character]]

class Solution11: Solving {
  let file: File
  let xCount: Int
  let yCount: Int
  var layout: Layout
  var previous: Layout = []

  required init(file: File) {
    self.file = file
    layout = file.charsByLine
    xCount = layout[0].count
    yCount = layout.count
  }

  func solve1() -> String {
    // printLayout(layout)
    return solve(lookupFunc: lookupAdjacent, vacateLimit: 4)
  }

  func solve2() -> String {
    //printLayout(layout)
    return solve(lookupFunc: lookupTrace, vacateLimit: 5)
  }

  func solve(lookupFunc: (Int, Int, (Int) -> Bool) -> Bool, vacateLimit: Int) -> String {
    while layout != previous {
      previous = layout

      for y in 0..<yCount {
        for x in 0..<xCount {
            switch previous[y][x] {
              case "L":
                let ruleHit = lookupFunc(x, y, { $0 > 0 })
                if !ruleHit { layout[y][x] = "#" }
              case "#":
                let ruleHit = lookupFunc(x, y, { $0 > vacateLimit })
                if ruleHit { layout[y][x] = "L" }
              default: continue
            }
        }
      }
      // printLayout(layout)
    }
    let occupiedCount = layout.reduce(0) { $0 + $1.reduce(0) { $0 + ($1 == "#" ? 1 : 0) } }
    return occupiedCount.description
  }

  func lookupAdjacent(x: Int, y: Int, occupiedRule: (Int) -> Bool) -> Bool {
    var occupied = 0
    for row in previous[max(0, y - 1)..<min(yCount, y + 2)] {
      for item in row[max(0, x - 1)..<min(xCount, x + 2)] {
        if item == "#" {
          occupied += 1
          if occupiedRule(occupied) { return true }
        }
      }
      if occupiedRule(occupied) { return true }
    }
    return false
  }

  func lookupTrace(x: Int, y: Int, occupiedRule: (Int) -> Bool) -> Bool {
    var occupied = 0
    for xDir in -1...1 {
      for yDir in -1...1 {
        var sx = x + xDir
        var sy = y + yDir
        var foundSeat: Character = "."
        var mx = 1
        while foundSeat == "." && sx >= 0 && sx < xCount && sy >= 0 && sy < yCount {
          foundSeat = previous[sy][sx]
          mx += 1
          sx += xDir
          sy += yDir
          if foundSeat == "#" {
            occupied += 1
            break
          }
        }
        if occupiedRule(occupied) { return true }
      }
      if occupiedRule(occupied) { return true }
    }
    return false
  }

  func printLayout(_ layout: Layout) {
    for line in layout {
      print(String(line))
    }
    print()
  }
}
