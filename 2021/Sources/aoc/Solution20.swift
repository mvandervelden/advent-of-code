class Solution20: Solving {
  let file: File
  var grid: [[Int]] = []
  var algorithm: [Int] = []
  var edgeValue = 0

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let lines = file.linesSplitByEmptyLine

    algorithm = lines[0][0].map { $0 == "#" ? 1 : 0 }

    parseGrid(lines[1])

    printGrid()
    evaluateGrid()
    printGrid()
    evaluateGrid()
    printGrid()

    return gridCount.description
  }

  func solve2() -> String {
    let lines = file.linesSplitByEmptyLine

    algorithm = lines[0][0].map { $0 == "#" ? 1 : 0 }

    parseGrid(lines[1])

    for _ in 0..<50 {
      evaluateGrid()
    }

    return gridCount.description
  }

  private var gridCount: Int { grid.reduce(0) { $0 + $1.sum() } }

  private func parseGrid(_ gridStrings: [String]) {
    grid = Array(repeating: Array(repeating: 0, count: gridStrings[0].count + 2), count: gridStrings.count + 2)

    for y in 0..<gridStrings.count {
      let line = Array(gridStrings[y])
      for x in 0..<line.count {
        grid[y+1][x+1] = line[x] == "#" ? 1 : 0
      }
    }
  }

  private func evaluateGrid() {
    var newEdgeValue = 0
    if algorithm[0] == 1 {
      newEdgeValue = edgeValue == 1 ? 0 : 1
    }

    var newGrid = Array(repeating: Array(repeating: newEdgeValue, count: grid[0].count + 2), count: grid.count + 2)

    for y in 0..<grid.count {
      for x in 0..<grid.count {
        var surrounding: [Int] = []
        for yy in (y-1)...(y+1) {
          for xx in (x-1)...(x+1) {
            if yy < 0 { surrounding.append(edgeValue); continue }
            if yy >= grid.count { surrounding.append(edgeValue); continue }
            if xx < 0 { surrounding.append(edgeValue); continue }
            if xx >= grid[0].count { surrounding.append(edgeValue); continue }

            surrounding.append(grid[yy][xx])
          }
        }
        let int = Int(surrounding.map { String($0) }.joined(), radix: 2)!
        newGrid[y + 1][x + 1] = algorithm[int]
        // print("(\(x), \(y)): was \(grid[y][x]), will be \(newGrid[y][x]). algorithm '\(int)'")
      }
    }

    edgeValue = newEdgeValue
    grid = newGrid
  }

  private func printGrid() {
    for line in grid {
      for val in line {
        print(val == 0 ? "." : "#", terminator: "")
      }
      print("")
    }
    print("")
  }
}
