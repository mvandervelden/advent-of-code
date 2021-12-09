class Solution09: Solving {
  let file: File
  var grid: [[Int]] = []

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    grid = file.charsByLine.map{ line in line.map { Int(String($0))! }}

    let lows = findLows().map { grid[$0.y][$0.x] }

    return (lows.sum() + lows.count).description
  }

  func solve2() -> String {
    grid = file.charsByLine.map{ line in line.map { Int(String($0))! }}
    let lows = findLows()

    for low in lows {
      var basin = [low]

      // TODO
    }

    return lows.description
  }

  private func findLows() -> [Point2D] {
    var lows: [Point2D] = []

    let yMax = grid.count
    let xMax = grid[0].count

    for y in 0..<yMax {
      for x in 0..<xMax {
        let val = grid[y][x]

        let minY = max(0, y - 1)
        let maxY = min(yMax - 1, y + 1)
        let minX = max(0, x - 1)
        let maxX = min(xMax - 1, x + 1)
        var localMin = true
        for yy in minY...maxY {
          for xx in minX...maxX {
            if grid[yy][xx] < val {
              localMin = false
              break
            }
          }
        }

        if localMin {
          lows.append(Point2D(x: x, y: y))
        }
      }
    }

    return lows
  }
}
