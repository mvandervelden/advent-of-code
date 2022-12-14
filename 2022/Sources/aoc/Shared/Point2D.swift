struct Point2D: Hashable, CustomStringConvertible {
  let x: Int
  let y: Int

  init(x: Int, y: Int) {
    self.x = x
    self.y = y
  }

  init(string: String) {
    let parts = string.split(separator: ",").map { Int($0)! }
    x = parts[0]
    y = parts[1]
  }

  var description: String { "(\(x),\(y))" }

  func neighbors() -> [Point2D] {
    let xMin = x - 1
    let yMin = y - 1
    let xMax = x + 1
    let yMax = y + 1

    var neighbors: [Point2D] = []

    for xx in xMin...xMax {
      for yy in yMin...yMax {
        if xx == x && yy == y { continue }

        neighbors.append(Point2D(x: xx, y: yy))
      }
    }

    return neighbors
  }

  func neighbors(maxX: Int, maxY: Int) -> [Point2D] {
    let xMin = max(x - 1, 0)
    let yMin = max(y - 1, 0)
    let xMax = min(x + 1, maxX)
    let yMax = min(y + 1, maxY)

    var neighbors: [Point2D] = []

    for xx in xMin...xMax {
      for yy in yMin...yMax {
        if xx == x && yy == y { continue }

        neighbors.append(Point2D(x: xx, y: yy))
      }
    }

    return neighbors
  }

  func nonDiagNeighbors(maxX: Int, maxY: Int) -> [Point2D] {
    let xPlus = Point2D(x: x + 1, y: y)
    let xMin  = Point2D(x: x - 1, y: y)
    let yPlus = Point2D(x: x, y: y + 1)
    let yMin  = Point2D(x: x, y: y - 1)

    switch (x, y) {
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

  func isAdjacentTo(_ other: Point2D) -> Bool {
    return neighbors().contains(other) || self == other
  }

  func up(_ count: Int = 1) -> Point2D {
    return Point2D(x: x, y: y - count)
  }

  func down(_ count: Int = 1) -> Point2D {
    return Point2D(x: x, y: y + count)
  }

  func left(_ count: Int = 1) -> Point2D {
    return Point2D(x: x - count, y: y)
  }

  func right(_ count: Int = 1) -> Point2D {
    return Point2D(x: x + count, y: y)
  }

  func isIn(grid: [[Any]], xOffset: Int = 0, yOffset: Int = 0) -> Bool {
    return y-yOffset < grid.count
      && y-yOffset >= 0
      && x-xOffset < grid[0].count
      && x-xOffset >= 0
  }
}
