class Solution09: Solving {
  let file: File
  var grid: [[Int]] = []
  lazy var yMax: Int = grid.count
  lazy var xMax: Int = grid[0].count

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

    var sizes: [Int] = []
    for low in lows {
      let basin = bfs(root: low)
      sizes.append(basin.count)
    }

    let result = sizes.sorted().reversed()[0..<3].product()
    return result.description
  }

  private func findLows() -> [Point2D] {
    var lows: [Point2D] = []

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

  private func bfs(root: Point2D) -> Set<Point2D> {
    var queue: [Point2D] = [root]
    var explored: Set<Point2D> = [root]
    var result: Set<Point2D> = []

    while !queue.isEmpty {
      let point = queue.removeLast()

      if grid[point.y][point.x] == 9 {
        continue
      } else {
        result.insert(point)
        for next in getAdjacent(point) {
          if !explored.contains(next) {
            explored.insert(next)
            queue.append(next)
          }
        }
      }
    }
    return result
  }

  private func getAdjacent(_ point: Point2D) -> [Point2D] {
    let maxY = yMax - 1
    let maxX = xMax - 1
    let xPlus = Point2D(x: point.x + 1, y: point.y)
    let xMin  = Point2D(x: point.x - 1, y: point.y)
    let yPlus = Point2D(x: point.x, y: point.y + 1)
    let yMin  = Point2D(x: point.x, y: point.y - 1)

    switch (point.x, point.y) {
    case (0, 0):       return [xPlus, yPlus]
    case (0, maxY):    return [xPlus, yMin]
    case (maxX, 0):    return [xMin, yPlus]
    case (maxX, maxY): return [xMin, yMin]
    case (0, _):       return [xPlus, yMin, yPlus]
    case (maxX, _):    return [xMin, yMin, yPlus]
    case (_, 0):       return [xMin, xPlus, yPlus]
    case (_, maxY):    return [xMin, xPlus, yMin]
    default:           return [xMin, xPlus, yMin, yPlus]
    }
  }
}
